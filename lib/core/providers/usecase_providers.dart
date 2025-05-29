import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/product/create_product_usecase.dart';
import '../../domain/usecases/product/get_low_stock_products_usecase.dart';
import '../../domain/usecases/sales/process_sales_order_usecase.dart';
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
