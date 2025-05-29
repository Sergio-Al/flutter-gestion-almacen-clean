import '../entities/sales_order.dart';
import '../entities/order_item.dart';

abstract class SalesRepository {
  Future<List<SalesOrder>> getAllSalesOrders();
  Future<SalesOrder?> getSalesOrderById(String id);
  Future<List<OrderItem>> getOrderItems(String orderId);
  Future<String> createSalesOrder(SalesOrder salesOrder, List<OrderItem> items);
  Future<void> updateSalesOrder(SalesOrder salesOrder);
  Future<void> deleteSalesOrder(String id);
  Future<List<SalesOrder>> getSalesOrdersByDateRange(DateTime start, DateTime end);
  Future<List<SalesOrder>> getSalesOrdersByStatus(OrderStatus status);
}
