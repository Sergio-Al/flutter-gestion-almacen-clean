import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gestion_almacen_stock/domain/repositories/stock_repository.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/stock_batch.dart';
import '../../core/providers/repository_providers.dart';
import 'stock_providers.dart';
import 'warehouse_providers.dart';

// Provider para el controlador de ajustes de stock
final stockAdjustmentControllerProvider = Provider((ref) {
  return StockAdjustmentController(ref);
});

class StockAdjustmentController {
  final ProviderRef ref;

  StockAdjustmentController(this.ref);

  /// Procesa un ajuste de stock y actualiza el lote correspondiente
  /// Devuelve true si el ajuste se realizó con éxito, false en caso de error
  Future<bool> processStockAdjustment(Map<String, dynamic> adjustmentData) async {
    final type = adjustmentData['type'] as String;
    final quantity = adjustmentData['quantity'] as int;
    final productId = adjustmentData['productId'] as String?;
    final warehouseId = adjustmentData['warehouseId'] as String?;
    final batchId = adjustmentData['batchId'] as String?;
    final reason = adjustmentData['reason'] as String?;
    
    if (productId == null || warehouseId == null) {
      return false;
    }

    try {
      final stockRepository = ref.read(stockRepositoryProvider);
      
      // Si se proporcionó un lote específico, ajustamos ese lote
      if (batchId != null) {
        final batch = await stockRepository.getStockBatchById(batchId);
        if (batch == null) {
          return false;
        }

        int newQuantity;
        switch (type) {
          case 'increase':
            newQuantity = batch.quantity + quantity;
            break;
          case 'decrease':
            newQuantity = batch.quantity - quantity;
            if (newQuantity < 0) {
              return false;
            }
            break;
          case 'set':
            newQuantity = quantity;
            break;
          default:
            return false;
        }

        // Usar copyWith para una actualización más segura
        final updatedBatch = batch.copyWith(quantity: newQuantity);
        await stockRepository.updateStockBatch(updatedBatch);
        
        // Si la cantidad resultante es cero o negativa, eliminar el lote
        if (newQuantity <= 0) {
          await stockRepository.deleteStockBatch(batchId);
        }
      }
      // Si no se proporcionó un lote específico
      else {
        switch (type) {
          case 'increase':
            // Para incrementos, siempre creamos un nuevo lote
            final newBatch = StockBatch(
              id: const Uuid().v4(),
              productId: productId,
              warehouseId: warehouseId,
              quantity: quantity,
              batchNumber: _generateBatchNumber(reason),
              expiryDate: null,
              receivedDate: DateTime.now(),
              supplierId: 'AJUSTE-SISTEMA',
            );
            await stockRepository.createStockBatch(newBatch);
            break;
            
          case 'decrease':
            // Para disminuciones, necesitamos distribuir la reducción entre los lotes existentes
            final batches = await stockRepository.getStockBatchesByProduct(productId);
            final filteredBatches = batches.where((b) => b.warehouseId == warehouseId).toList();
            
            if (filteredBatches.isEmpty) {
              return false;
            }
            
            int totalStock = filteredBatches.fold(0, (sum, batch) => sum + batch.quantity);
            if (totalStock < quantity) {
              return false;
            }
            
            // Ordenar los lotes por fecha de expiración (primero los que caducan antes)
            filteredBatches.sort((a, b) {
              if (a.expiryDate == null && b.expiryDate == null) return 0;
              if (a.expiryDate == null) return 1;
              if (b.expiryDate == null) return -1;
              return a.expiryDate!.compareTo(b.expiryDate!);
            });
            
            await _reduceStockFromBatches(filteredBatches, quantity, stockRepository);
            break;
            
          case 'set':
            // Para establecer una cantidad específica, calculamos la diferencia con el stock actual
            final batches = await stockRepository.getStockBatchesByProduct(productId);
            final filteredBatches = batches.where((b) => b.warehouseId == warehouseId).toList();
            
            int currentStock = filteredBatches.fold(0, (sum, batch) => sum + batch.quantity);
            
            if (quantity > currentStock) {
              // Necesitamos aumentar el stock
              final increaseAmount = quantity - currentStock;
              final newBatch = StockBatch(
                id: const Uuid().v4(),
                productId: productId,
                warehouseId: warehouseId,
                quantity: increaseAmount,
                batchNumber: _generateBatchNumber(reason),
                expiryDate: null,
                receivedDate: DateTime.now(),
                supplierId: 'AJUSTE-SISTEMA',
              );
              await stockRepository.createStockBatch(newBatch);
            } else if (quantity < currentStock) {
              // Necesitamos reducir el stock
              final decreaseAmount = currentStock - quantity;
              // Ordenar los lotes por fecha de expiración (primero los que caducan antes)
              filteredBatches.sort((a, b) {
                if (a.expiryDate == null && b.expiryDate == null) return 0;
                if (a.expiryDate == null) return 1;
                if (b.expiryDate == null) return -1;
                return a.expiryDate!.compareTo(b.expiryDate!);
              });
              
              await _reduceStockFromBatches(filteredBatches, decreaseAmount, stockRepository);
            }
            // Si son iguales, no hacemos nada
            break;
            
          default:
            return false;
        }
      }

      // Invalidamos los proveedores relacionados para forzar la recarga de datos
      ref.invalidate(stockBatchesProvider);
      ref.invalidate(stockBatchesByProductProvider(productId));
      ref.invalidate(stockBatchesByWarehouseProvider(warehouseId));
      ref.invalidate(totalStockForProductProvider(productId));
      
      // Invalidar también los providers de warehouse para actualizar los datos en la UI
      ref.invalidate(warehouseByIdProvider(warehouseId));
      ref.invalidate(warehouseCurrentStockProvider(warehouseId));
      ref.invalidate(warehouseCapacityProvider(warehouseId));
      ref.invalidate(warehousesProvider);
      
      return true;
    } catch (e) {
      print('Error en ajuste de stock: $e');
      return false;
    }
  }
  
  /// Reduce el stock de una lista de lotes, empezando por los que caducan primero
  Future<void> _reduceStockFromBatches(
    List<StockBatch> batches,
    int amountToReduce,
    StockRepository repository
  ) async {
    for (var batch in batches) {
      if (amountToReduce <= 0) break;
      
      if (batch.quantity <= amountToReduce) {
        // Si el lote completo se va a consumir
        amountToReduce -= batch.quantity;
        await repository.deleteStockBatch(batch.id);
      } else {
        // Si solo se consumirá parcialmente el lote
        final updatedBatch = batch.copyWith(quantity: batch.quantity - amountToReduce);
        await repository.updateStockBatch(updatedBatch);
        amountToReduce = 0;
      }
    }
  }
  
  /// Genera un número de lote basado en la fecha y razón
  String _generateBatchNumber(String? reason) {
    final now = DateTime.now();
    final timestamp = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final reasonPrefix = reason != null && reason.isNotEmpty 
        ? reason.substring(0, reason.length > 3 ? 3 : reason.length).toUpperCase() 
        : 'ADJ';
    return '$reasonPrefix-$timestamp-${now.millisecondsSinceEpoch % 10000}';
  }
}
