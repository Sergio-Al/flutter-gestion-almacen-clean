import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/usecases/dashboard/get_total_products_count_usecase.dart';
import '../../../../domain/usecases/dashboard/get_low_stock_alerts_count_usecase.dart';
import '../../../../domain/usecases/dashboard/get_todays_sales_usecase.dart';
import '../../../../domain/usecases/dashboard/get_active_orders_count_usecase.dart';
import '../../../../domain/usecases/dashboard/get_sales_performance_usecase.dart';
import '../../../../domain/usecases/dashboard/get_warehouse_capacity_usecase.dart';
import '../../../core/providers/repository_providers.dart';

// UseCases Providers
final getTotalProductsCountUseCaseProvider = Provider<GetTotalProductsCountUseCase>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return GetTotalProductsCountUseCase(repository);
});

final getLowStockAlertsCountUseCaseProvider = Provider<GetLowStockAlertsCountUseCase>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return GetLowStockAlertsCountUseCase(repository);
});

final getTodaysSalesUseCaseProvider = Provider<GetTodaysSalesUseCase>((ref) {
  final repository = ref.watch(salesRepositoryProvider);
  return GetTodaysSalesUseCase(repository);
});

final getActiveOrdersCountUseCaseProvider = Provider<GetActiveOrdersCountUseCase>((ref) {
  final repository = ref.watch(salesRepositoryProvider);
  return GetActiveOrdersCountUseCase(repository);
});

final getSalesPerformanceUseCaseProvider = Provider<GetSalesPerformanceUseCase>((ref) {
  final repository = ref.watch(salesRepositoryProvider);
  return GetSalesPerformanceUseCase(repository);
});

final getWarehouseCapacityUseCaseProvider = Provider<GetWarehouseCapacityUseCase>((ref) {
  final repository = ref.watch(warehouseRepositoryProvider);
  return GetWarehouseCapacityUseCase(repository);
});

// Dashboard Data Providers
final totalProductsProvider = FutureProvider<int>((ref) async {
  final useCase = ref.watch(getTotalProductsCountUseCaseProvider);
  return await useCase();
});

final lowStockAlertsCountProvider = FutureProvider<int>((ref) async {
  final useCase = ref.watch(getLowStockAlertsCountUseCaseProvider);
  return await useCase();
});

final todaysSalesProvider = FutureProvider<double>((ref) async {
  final useCase = ref.watch(getTodaysSalesUseCaseProvider);
  return await useCase();
});

final activeOrdersCountProvider = FutureProvider<int>((ref) async {
  final useCase = ref.watch(getActiveOrdersCountUseCaseProvider);
  return await useCase();
});

final salesPerformanceProvider = FutureProvider.family<({
  double totalAmount, 
  double percentChange, 
  List<({DateTime date, double amount})> dailyData
}), int>((ref, days) async {
  final useCase = ref.watch(getSalesPerformanceUseCaseProvider);
  return await useCase(days);
});

final warehouseCapacityProvider = FutureProvider.family<({
  double capacityPercentage,
  int currentStock,
  int totalCapacity
}), String>((ref, warehouseId) async {
  final useCase = ref.watch(getWarehouseCapacityUseCaseProvider);
  return await useCase(warehouseId);
});
