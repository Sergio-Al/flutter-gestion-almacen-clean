import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/local/database_helper.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../data/repositories/warehouse_repository_impl.dart';
import '../../data/repositories/stock_repository_impl.dart';
import '../../data/repositories/sales_repository_impl.dart';
import '../../data/datasources/mock/mock_repositories.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/repositories/warehouse_repository.dart';
import '../../domain/repositories/stock_repository.dart';
import '../../domain/repositories/sales_repository.dart';

// Database Helper Provider
final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper();
});

// Repository Providers - Automáticamente selecciona entre implementaciones mock o reales
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  final useMock = ref.watch(useMockRepositoriesProvider);
  if (useMock) {
    return ref.watch(mockProductRepositoryProvider);
  } else {
    final databaseHelper = ref.watch(databaseHelperProvider);
    return ProductRepositoryImpl(databaseHelper);
  }
});

final warehouseRepositoryProvider = Provider<WarehouseRepository>((ref) {
  final useMock = ref.watch(useMockRepositoriesProvider);
  if (useMock) {
    return ref.watch(mockWarehouseRepositoryProvider);
  } else {
    final databaseHelper = ref.watch(databaseHelperProvider);
    return WarehouseRepositoryImpl(databaseHelper);
  }
});

final stockRepositoryProvider = Provider<StockRepository>((ref) {
  final useMock = ref.watch(useMockRepositoriesProvider);
  if (useMock) {
    return ref.watch(mockStockRepositoryProvider);
  } else {
    final databaseHelper = ref.watch(databaseHelperProvider);
    return StockRepositoryImpl(databaseHelper);
  }
});

final salesRepositoryProvider = Provider<SalesRepository>((ref) {
  final useMock = ref.watch(useMockRepositoriesProvider);
  if (useMock) {
    return ref.watch(mockSalesRepositoryProvider);
  } else {
    final databaseHelper = ref.watch(databaseHelperProvider);
    return SalesRepositoryImpl(databaseHelper);
  }
});
