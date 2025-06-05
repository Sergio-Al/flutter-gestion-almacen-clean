class StockTransfer {
  final String id;
  final int quantity;
  final String reason;
  final String? notes;
  final String productId;
  final String fromWarehouseId;
  final String toWarehouseId;
  final String? batchId;
  final String status; // 'pending', 'completed', 'cancelled'
  final String timestamp;

  StockTransfer({
    required this.id,
    required this.quantity,
    required this.reason,
    this.notes,
    required this.productId,
    required this.fromWarehouseId,
    required this.toWarehouseId,
    this.batchId,
    required this.status,
    required this.timestamp,
  });
}
