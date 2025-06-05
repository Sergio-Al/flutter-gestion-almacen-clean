import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/local/database_helper.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../data/repositories/warehouse_repository_impl.dart';
import '../../data/repositories/stock_repository_impl.dart';
import '../../data/repositories/sales_repository_impl.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/stock_transfer_repository_impl.dart';
import '../../data/repositories/customer_repository_impl.dart';
import '../../data/datasources/mock/mock_auth_repository.dart';
import '../../data/datasources/stock_transfer_local_data_source.dart';
import '../../data/datasources/customer_local_data_source.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/repositories/warehouse_repository.dart';
import '../../domain/repositories/stock_repository.dart';
import '../../domain/repositories/sales_repository.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/stock_transfer_repository.dart';
import '../../domain/repositories/customer_repository.dart';
import '../constants/app_constants.dart';

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

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  if (AppConstants.useMockData) {
    return MockAuthRepository();
  } else {
    final databaseHelper = ref.watch(databaseHelperProvider);
    return AuthRepositoryImpl(databaseHelper);
  }
});

final stockTransferDataSourceProvider = Provider<StockTransferLocalDataSource>((ref) {
  final databaseHelper = ref.watch(databaseHelperProvider);
  return StockTransferLocalDataSource(databaseHelper);
});

final stockTransferRepositoryProvider = Provider<StockTransferRepository>((ref) {
  final dataSource = ref.watch(stockTransferDataSourceProvider);
  return StockTransferRepositoryImpl(dataSource);
});

final customerLocalDataSourceProvider = Provider<CustomerLocalDataSource>((ref) {
  final databaseHelper = ref.watch(databaseHelperProvider);
  return CustomerLocalDataSourceImpl(dbHelper: databaseHelper);
});

final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  final dataSource = ref.watch(customerLocalDataSourceProvider);
  return CustomerRepositoryImpl(localDataSource: dataSource);
});
