import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/product.dart';
import '../../core/providers/repository_providers.dart';

// Products State Provider
final productsProvider = FutureProvider<List<Product>>((ref) async {
  final repository = ref.watch(productRepositoryProvider);
  return await repository.getAllProducts();
});

// Low Stock Products Provider
final lowStockProductsProvider = FutureProvider<List<Product>>((ref) async {
  final repository = ref.watch(productRepositoryProvider);
  return await repository.getLowStockProducts();
});

// Product by ID Provider
final productByIdProvider = FutureProvider.family<Product?, String>((ref, productId) async {
  final repository = ref.watch(productRepositoryProvider);
  return await repository.getProductById(productId);
});

// Products by Category Provider
final productsByCategoryProvider = FutureProvider.family<List<Product>, String>((ref, categoryId) async {
  final repository = ref.watch(productRepositoryProvider);
  return await repository.getProductsByCategory(categoryId);
});
