import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/sales_order.dart';
import '../../domain/entities/order_item.dart';
import '../../core/providers/repository_providers.dart';

// Sales Orders State Provider
final salesOrdersProvider = FutureProvider<List<SalesOrder>>((ref) async {
  final repository = ref.watch(salesRepositoryProvider);
  return await repository.getAllSalesOrders();
});

// Sales Order by ID Provider
final salesOrderByIdProvider = FutureProvider.family<SalesOrder?, String>((ref, orderId) async {
  final repository = ref.watch(salesRepositoryProvider);
  return await repository.getSalesOrderById(orderId);
});

// Order Items Provider
final orderItemsProvider = FutureProvider.family<List<OrderItem>, String>((ref, orderId) async {
  final repository = ref.watch(salesRepositoryProvider);
  return await repository.getOrderItems(orderId);
});

// Sales Orders by Status Provider
final salesOrdersByStatusProvider = FutureProvider.family<List<SalesOrder>, OrderStatus>((ref, status) async {
  final repository = ref.watch(salesRepositoryProvider);
  return await repository.getSalesOrdersByStatus(status);
});

// Sales Orders by Date Range Provider
final salesOrdersByDateRangeProvider = FutureProvider.family<List<SalesOrder>, ({DateTime start, DateTime end})>((ref, dateRange) async {
  final repository = ref.watch(salesRepositoryProvider);
  return await repository.getSalesOrdersByDateRange(dateRange.start, dateRange.end);
});
