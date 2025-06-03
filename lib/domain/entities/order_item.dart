class OrderItem {
  final String id;
  final String orderId;
  final String productId;
  final String productName;
  final String? productDescription;
  final int quantity;
  final double unitPrice;
  final String? batchId;

  const OrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.productName,
    this.productDescription,
    required this.quantity,
    required this.unitPrice,
    this.batchId,
  });

  OrderItem copyWith({
    String? id,
    String? orderId,
    String? productId,
    String? productName,
    String? productDescription,
    int? quantity,
    double? unitPrice,
    String? batchId,
  }) {
    return OrderItem(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productDescription: productDescription ?? this.productDescription,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      batchId: batchId ?? this.batchId,
    );
  }

  double get subtotal => quantity * unitPrice;
  double get totalPrice => quantity * unitPrice; // Keep for backward compatibility

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OrderItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'OrderItem(id: $id, orderId: $orderId, productId: $productId, productName: $productName, productDescription: $productDescription, quantity: $quantity, unitPrice: $unitPrice, batchId: $batchId)';
  }
}
