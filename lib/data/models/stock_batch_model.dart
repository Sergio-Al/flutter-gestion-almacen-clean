import '../../domain/entities/stock_batch.dart';

class StockBatchModel extends StockBatch {
  const StockBatchModel({
    required super.id,
    required super.productId,
    required super.warehouseId,
    required super.quantity,
    required super.batchNumber,
    super.expiryDate,
    required super.receivedDate,
    required super.supplierId,
  });

  factory StockBatchModel.fromMap(Map<String, dynamic> map) {
    return StockBatchModel(
      id: map['id'] as String,
      productId: map['product_id'] as String,
      warehouseId: map['warehouse_id'] as String,
      quantity: map['quantity'] as int,
      batchNumber: map['batch_number'] as String,
      expiryDate: map['expiry_date'] != null 
          ? DateTime.parse(map['expiry_date'] as String)
          : null,
      receivedDate: DateTime.parse(map['received_date'] as String),
      supplierId: map['supplier_id'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product_id': productId,
      'warehouse_id': warehouseId,
      'quantity': quantity,
      'batch_number': batchNumber,
      'expiry_date': expiryDate?.toIso8601String(),
      'received_date': receivedDate.toIso8601String(),
      'supplier_id': supplierId,
    };
  }

  factory StockBatchModel.fromEntity(StockBatch stockBatch) {
    return StockBatchModel(
      id: stockBatch.id,
      productId: stockBatch.productId,
      warehouseId: stockBatch.warehouseId,
      quantity: stockBatch.quantity,
      batchNumber: stockBatch.batchNumber,
      expiryDate: stockBatch.expiryDate,
      receivedDate: stockBatch.receivedDate,
      supplierId: stockBatch.supplierId,
    );
  }
}
