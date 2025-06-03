import '../../domain/entities/order_item.dart';

class OrderItemModel extends OrderItem {
  const OrderItemModel({
    required super.id,
    required super.orderId,
    required super.productId,
    required super.productName,
    super.productDescription,
    required super.quantity,
    required super.unitPrice,
    super.batchId,
  });

  factory OrderItemModel.fromMap(Map<String, dynamic> map) {
    return OrderItemModel(
      id: map['id'] as String,
      orderId: map['order_id'] as String,
      productId: map['product_id'] as String,
      productName: map['product_name'] as String,
      productDescription: map['product_description'] as String?,
      quantity: map['quantity'] as int,
      unitPrice: (map['unit_price'] as num).toDouble(),
      batchId: map['batch_id'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'order_id': orderId,
      'product_id': productId,
      'product_name': productName,
      'product_description': productDescription,
      'quantity': quantity,
      'unit_price': unitPrice,
      'batch_id': batchId,
    };
  }

  factory OrderItemModel.fromEntity(OrderItem orderItem) {
    return OrderItemModel(
      id: orderItem.id,
      orderId: orderItem.orderId,
      productId: orderItem.productId,
      productName: orderItem.productName,
      productDescription: orderItem.productDescription,
      quantity: orderItem.quantity,
      unitPrice: orderItem.unitPrice,
      batchId: orderItem.batchId,
    );
  }
}
