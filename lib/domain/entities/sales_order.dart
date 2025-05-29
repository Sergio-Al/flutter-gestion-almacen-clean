enum OrderStatus { pending, processing, completed, cancelled }

class SalesOrder {
  final String id;
  final String customerName;
  final DateTime orderDate;
  final OrderStatus status;
  final double totalAmount;

  const SalesOrder({
    required this.id,
    required this.customerName,
    required this.orderDate,
    required this.status,
    required this.totalAmount,
  });

  SalesOrder copyWith({
    String? id,
    String? customerName,
    DateTime? orderDate,
    OrderStatus? status,
    double? totalAmount,
  }) {
    return SalesOrder(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      orderDate: orderDate ?? this.orderDate,
      status: status ?? this.status,
      totalAmount: totalAmount ?? this.totalAmount,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SalesOrder && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
