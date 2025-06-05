import '../../domain/entities/sales_order.dart';
import 'order_item_model.dart';

class SalesOrderModel extends SalesOrder {
  const SalesOrderModel({
    required super.id,
    required super.customerId,
    required super.customerName,
    required super.date,
    required super.status,
    required super.items,
    required super.total,
    super.notes,
    required super.createdAt,
    required super.updatedAt,
  });

  factory SalesOrderModel.fromMap(Map<String, dynamic> map) {
    return SalesOrderModel(
      id: map['id'] as String,
      customerId: map['customer_id'] as String,
      customerName: map['customer_name'] as String,
      date: DateTime.parse(map['date'] as String),
      status: OrderStatus.values.firstWhere(
        (e) => e.name == map['status'] as String,
      ),
      items: (map['items'] as List<dynamic>?)
          ?.map((item) => OrderItemModel.fromMap(item as Map<String, dynamic>))
          .toList() ?? [],
      total: (map['total'] as num).toDouble(),
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customer_id': customerId,
      'customer_name': customerName,
      'date': date.toIso8601String(),
      'status': status.name,
      'total': total,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory SalesOrderModel.fromEntity(SalesOrder salesOrder) {
    // Convertir items manualmente para evitar problemas de tipo
    final convertedItems = salesOrder.items.map((item) => 
      OrderItemModel(
        id: item.id,
        orderId: item.orderId,
        productId: item.productId,
        productName: item.productName,
        productDescription: item.productDescription,
        quantity: item.quantity,
        unitPrice: item.unitPrice,
        batchId: item.batchId,
      )
    ).toList();
    
    return SalesOrderModel(
      id: salesOrder.id,
      customerId: salesOrder.customerId,
      customerName: salesOrder.customerName,
      date: salesOrder.date,
      status: salesOrder.status,
      items: convertedItems,
      total: salesOrder.total,
      notes: salesOrder.notes,
      createdAt: salesOrder.createdAt,
      updatedAt: salesOrder.updatedAt,
    );
  }
}
