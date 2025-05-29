import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/local/database_helper.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../data/repositories/warehouse_repository_impl.dart';
import '../../data/repositories/stock_repository_impl.dart';
import '../../data/repositories/sales_repository_impl.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/repositories/warehouse_repository.dart';
import '../../domain/repositories/stock_repository.dart';
import '../../domain/repositories/sales_repository.dart';

// Database Helper Provider
final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper();
});

// Repository Providers
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  final databaseHelper = ref.watch(databaseHelperProvider);
  return ProductRepositoryImpl(databaseHelper);
});

final warehouseRepositoryProvider = Provider<WarehouseRepository>((ref) {
  final databaseHelper = ref.watch(databaseHelperProvider);
  return WarehouseRepositoryImpl(databaseHelper);
});

final stockRepositoryProvider = Provider<StockRepository>((ref) {
  final databaseHelper = ref.watch(databaseHelperProvider);
  return StockRepositoryImpl(databaseHelper);
});

final salesRepositoryProvider = Provider<SalesRepository>((ref) {
  final databaseHelper = ref.watch(databaseHelperProvider);
  return SalesRepositoryImpl(databaseHelper);
});
