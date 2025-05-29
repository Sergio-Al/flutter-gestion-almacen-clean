import '../../domain/entities/sales_order.dart';

class SalesOrderModel extends SalesOrder {
  const SalesOrderModel({
    required super.id,
    required super.customerName,
    required super.orderDate,
    required super.status,
    required super.totalAmount,
  });

  factory SalesOrderModel.fromMap(Map<String, dynamic> map) {
    return SalesOrderModel(
      id: map['id'] as String,
      customerName: map['customer_name'] as String,
      orderDate: DateTime.parse(map['order_date'] as String),
      status: OrderStatus.values.firstWhere(
        (e) => e.name == map['status'] as String,
      ),
      totalAmount: (map['total_amount'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customer_name': customerName,
      'order_date': orderDate.toIso8601String(),
      'status': status.name,
      'total_amount': totalAmount,
    };
  }

  factory SalesOrderModel.fromEntity(SalesOrder salesOrder) {
    return SalesOrderModel(
      id: salesOrder.id,
      customerName: salesOrder.customerName,
      orderDate: salesOrder.orderDate,
      status: salesOrder.status,
      totalAmount: salesOrder.totalAmount,
    );
  }
}
