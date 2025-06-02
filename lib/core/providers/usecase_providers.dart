import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/product/create_product_usecase.dart';
import '../../domain/usecases/product/get_low_stock_products_usecase.dart';
import '../../domain/usecases/sales/process_sales_order_usecase.dart';
import '../../domain/usecases/auth/login_usecase.dart';
import '../../domain/usecases/auth/logout_usecase.dart';
import '../../domain/usecases/auth/get_current_user_usecase.dart';
import '../../domain/usecases/auth/check_auth_status_usecase.dart';
import './repository_providers.dart';

// Product UseCases
final createProductUseCaseProvider = Provider<CreateProductUseCase>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return CreateProductUseCase(repository);
});

final getLowStockProductsUseCaseProvider = Provider<GetLowStockProductsUseCase>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return GetLowStockProductsUseCase(repository);
});

// Sales UseCases
final processSalesOrderUseCaseProvider = Provider<ProcessSalesOrderUseCase>((ref) {
  final salesRepository = ref.watch(salesRepositoryProvider);
  final stockRepository = ref.watch(stockRepositoryProvider);
  return ProcessSalesOrderUseCase(salesRepository, stockRepository);
});

// Auth UseCases
final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LoginUseCase(repository);
});

final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LogoutUseCase(repository);
});

final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return GetCurrentUserUseCase(repository);
});

final checkAuthStatusUseCaseProvider = Provider<CheckAuthStatusUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return CheckAuthStatusUseCase(repository);
});
