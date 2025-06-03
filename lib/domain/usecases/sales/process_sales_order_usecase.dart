import 'package:uuid/uuid.dart';
import '../../repositories/sales_repository.dart';
import '../../repositories/stock_repository.dart';
import '../../entities/sales_order.dart';
import '../../entities/order_item.dart';
import '../../entities/stock_batch.dart';

class ProcessSalesOrderUseCase {
  final SalesRepository _salesRepository;
  final StockRepository _stockRepository;

  ProcessSalesOrderUseCase(this._salesRepository, this._stockRepository);

  Future<String> call({
    required String customerId,
    required String customerName,
    required List<({String productId, String productName, String? batchId, int quantity, double unitPrice})> items,
  }) async {
    // Verificar el stock disponible para cada item
    for (final item in items) {
      if (item.batchId != null) {
        final batch = await _stockRepository.getStockBatchById(item.batchId!);
        
        if (batch == null) {
          throw Exception('Lote no encontrado: ${item.batchId}');
        }
        
        if (batch.quantity < item.quantity) {
          throw Exception('Stock insuficiente para el producto ${item.productId}. Disponible: ${batch.quantity}, Solicitado: ${item.quantity}');
        }
      }
    }

    // Crear la orden de venta
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
        quantity: item.quantity,
        unitPrice: item.unitPrice,
        batchId: item.batchId,
      );
      
      orderItems.add(orderItem);
      totalAmount += orderItem.totalPrice;
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
      createdAt: orderDate,
      updatedAt: orderDate,
    );

    // Guardar la orden y sus items
    await _salesRepository.createSalesOrder(salesOrder, orderItems);

    // Actualizar el stock de cada lote
    for (final item in orderItems) {
      if (item.batchId != null) {
        final batch = await _stockRepository.getStockBatchById(item.batchId!);
        
        if (batch != null) {
          final updatedBatch = StockBatch(
            id: batch.id,
            productId: batch.productId,
            warehouseId: batch.warehouseId,
            quantity: batch.quantity - item.quantity,
            batchNumber: batch.batchNumber,
            expiryDate: batch.expiryDate,
            receivedDate: batch.receivedDate,
            supplierId: batch.supplierId,
          );
          
          await _stockRepository.updateStockBatch(updatedBatch);
        }
      }
    }

    return orderId;
  }
}
