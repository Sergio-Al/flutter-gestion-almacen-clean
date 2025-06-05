// filepath: /Users/sergio/Documents/WebDevelopment/Flutter/gestion_almacen_stock/lib/domain/usecases/sales/save_sales_order_usecase.dart
import 'package:uuid/uuid.dart';
import '../../entities/sales_order.dart';
import '../../entities/order_item.dart';
import '../../repositories/sales_repository.dart';
import '../../repositories/stock_repository.dart';
import '../../../core/errors/failures.dart';
import 'package:dartz/dartz.dart';

class SaveSalesOrderUseCase {
  final SalesRepository _salesRepository;
  final StockRepository _stockRepository;

  SaveSalesOrderUseCase(this._salesRepository, this._stockRepository);

  Future<Either<Failure, String>> call({
    required String customerId,
    required String customerName,
    required List<OrderItemInput> items,
    String? notes,
  }) async {
    try {
      // Validar disponibilidad de stock para cada item
      for (final item in items) {
        if (item.batchId != null && item.batchId!.isNotEmpty) {
          final batch = await _stockRepository.getStockBatchById(item.batchId!);
          
          if (batch == null) {
            return Left(NotFoundFailure(message: 'Lote no encontrado: ${item.batchId}'));
          }
          
          if (batch.quantity < item.quantity) {
            return Left(ValidationFailure(
              message: 'Stock insuficiente para el producto ${item.productName}. ' +
                      'Disponible: ${batch.quantity}, Solicitado: ${item.quantity}'
            ));
          }
        }
      }

      // Crear ID y fecha para la orden
      final orderId = const Uuid().v4();
      final orderDate = DateTime.now();
      final orderItems = <OrderItem>[];
      double totalAmount = 0;

      // Crear los items de la orden
      for (final item in items) {
        final orderItem = OrderItem(
          id: const Uuid().v4(),
          orderId: orderId,
          productId: item.productId,
          productName: item.productName,
          productDescription: item.productDescription,
          quantity: item.quantity,
          unitPrice: item.unitPrice,
          batchId: item.batchId,
        );
        
        orderItems.add(orderItem);
        totalAmount += item.quantity * item.unitPrice;
      }

      // Crear la orden de venta
      final salesOrder = SalesOrder(
        id: orderId,
        customerId: customerId,
        customerName: customerName,
        date: orderDate,
        status: OrderStatus.pending,
        items: orderItems,
        total: totalAmount,
        notes: notes,
        createdAt: orderDate,
        updatedAt: orderDate,
      );

      // Guardar la orden y sus items
      await _salesRepository.createSalesOrder(salesOrder, orderItems);

      // Actualizar el stock de cada lote
      for (final item in orderItems) {
        if (item.batchId != null && item.batchId!.isNotEmpty) {
          final batch = await _stockRepository.getStockBatchById(item.batchId!);
          
          if (batch != null) {
            final updatedBatch = batch.copyWith(
              quantity: batch.quantity - item.quantity,
            );
            
            await _stockRepository.updateStockBatch(updatedBatch);
          }
        }
      }
      
      return Right(orderId);
    } catch (e) {
      return Left(UnexpectedFailure(message: 'Error al guardar la orden: ${e.toString()}'));
    }
  }
}

class OrderItemInput {
  final String productId;
  final String productName;
  final String? productDescription;
  final int quantity;
  final double unitPrice;
  final String? batchId;

  OrderItemInput({
    required this.productId,
    required this.productName,
    this.productDescription,
    required this.quantity,
    required this.unitPrice,
    this.batchId,
  });
}
