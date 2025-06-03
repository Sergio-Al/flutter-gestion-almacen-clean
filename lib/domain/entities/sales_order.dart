import 'order_item.dart';

enum OrderStatus { pending, confirmed, shipped, delivered, cancelled }

class SalesOrder {
  final String id;
  final String customerId;
  final String customerName;
  final DateTime date;
  final OrderStatus status;
  final List<OrderItem> items;
  final double total;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SalesOrder({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.date,
    required this.status,
    required this.items,
    required this.total,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  SalesOrder copyWith({
    String? id,
    String? customerId,
    String? customerName,
    DateTime? date,
    OrderStatus? status,
    List<OrderItem>? items,
    double? total,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SalesOrder(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      date: date ?? this.date,
      status: status ?? this.status,
      items: items ?? this.items,
      total: total ?? this.total,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SalesOrder && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'SalesOrder(id: $id, customerId: $customerId, customerName: $customerName, date: $date, status: $status, items: ${items.length}, total: $total, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}
