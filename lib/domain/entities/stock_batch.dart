class StockBatch {
  final String id;
  final String productId;
  final String warehouseId;
  final int quantity;
  final String batchNumber;
  final DateTime? expiryDate;
  final DateTime receivedDate;
  final String supplierId;

  const StockBatch({
    required this.id,
    required this.productId,
    required this.warehouseId,
    required this.quantity,
    required this.batchNumber,
    this.expiryDate,
    required this.receivedDate,
    required this.supplierId,
  });

  StockBatch copyWith({
    String? id,
    String? productId,
    String? warehouseId,
    int? quantity,
    String? batchNumber,
    DateTime? expiryDate,
    DateTime? receivedDate,
    String? supplierId,
  }) {
    return StockBatch(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      warehouseId: warehouseId ?? this.warehouseId,
      quantity: quantity ?? this.quantity,
      batchNumber: batchNumber ?? this.batchNumber,
      expiryDate: expiryDate ?? this.expiryDate,
      receivedDate: receivedDate ?? this.receivedDate,
      supplierId: supplierId ?? this.supplierId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StockBatch && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
