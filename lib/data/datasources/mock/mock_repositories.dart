import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/repositories/product_repository.dart';
import '../../../domain/repositories/warehouse_repository.dart';
import '../../../domain/repositories/stock_repository.dart';
import '../../../domain/repositories/sales_repository.dart';
import '../../repositories/mock_product_repository_impl.dart';
import '../../repositories/mock_warehouse_repository_impl.dart';
import '../../repositories/mock_stock_repository_impl.dart';
import '../../repositories/mock_sales_repository_impl.dart';
import '../../../core/utils/mock_data.dart';

// Para cambiar entre implementaciones reales y simuladas durante desarrollo
final useMockRepositoriesProvider = Provider<bool>((ref) => true);

// Providers para los repositorios mock
final mockProductRepositoryProvider = Provider<ProductRepository>((ref) {
  final products = ref.watch(mockProductsProvider);
  return MockProductRepositoryImpl(products);
});

final mockWarehouseRepositoryProvider = Provider<WarehouseRepository>((ref) {
  final warehouses = ref.watch(mockWarehousesProvider);
  return MockWarehouseRepositoryImpl(warehouses);
});

final mockStockRepositoryProvider = Provider<StockRepository>((ref) {
  final stockBatches = ref.watch(mockStockBatchesProvider);
  return MockStockRepositoryImpl(stockBatches);
});

final mockSalesRepositoryProvider = Provider<SalesRepository>((ref) {
  final salesOrders = ref.watch(mockSalesOrdersProvider);
  final orderItems = ref.watch(mockOrderItemsProvider);
  return MockSalesRepositoryImpl(salesOrders, orderItems);
});
