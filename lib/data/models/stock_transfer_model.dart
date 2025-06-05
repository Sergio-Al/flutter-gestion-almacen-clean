import '../../domain/entities/stock_transfer.dart';

class StockTransferModel extends StockTransfer {
  StockTransferModel({
    required String id,
    required int quantity,
    required String reason,
    String? notes,
    required String productId,
    required String fromWarehouseId,
    required String toWarehouseId,
    String? batchId,
    required String status,
    required String timestamp,
  }) : super(
          id: id,
          quantity: quantity,
          reason: reason,
          notes: notes,
          productId: productId,
          fromWarehouseId: fromWarehouseId,
          toWarehouseId: toWarehouseId,
          batchId: batchId,
          status: status,
          timestamp: timestamp,
        );

  factory StockTransferModel.fromMap(Map<String, dynamic> map) {
    return StockTransferModel(
      id: map['id'],
      quantity: map['quantity'],
      reason: map['reason'],
      notes: map['notes'],
      productId: map['product_id'],
      fromWarehouseId: map['from_warehouse_id'],
      toWarehouseId: map['to_warehouse_id'],
      batchId: map['batch_id'],
      status: map['status'],
      timestamp: map['timestamp'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'quantity': quantity,
      'reason': reason,
      'notes': notes,
      'product_id': productId,
      'from_warehouse_id': fromWarehouseId,
      'to_warehouse_id': toWarehouseId,
      'batch_id': batchId,
      'status': status,
      'timestamp': timestamp,
    };
  }

  factory StockTransferModel.fromTransferData(Map<String, dynamic> transferData) {
    // Generate a unique ID for the transfer
    final id = 'transfer-${DateTime.now().millisecondsSinceEpoch}-${transferData['productId']}';
    
    return StockTransferModel(
      id: id,
      quantity: transferData['quantity'],
      reason: transferData['reason'],
      notes: transferData['notes'],
      productId: transferData['productId'],
      fromWarehouseId: transferData['fromWarehouseId'],
      toWarehouseId: transferData['toWarehouseId'],
      batchId: transferData['batchId'],
      status: 'pending', // Initial status is pending
      timestamp: transferData['timestamp'],
    );
  }
}
