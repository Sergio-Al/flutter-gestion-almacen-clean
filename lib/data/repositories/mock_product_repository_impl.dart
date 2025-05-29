import '../../domain/repositories/product_repository.dart';
import '../../domain/entities/product.dart';
import '../../core/utils/mock_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Implementación simulada del repositorio de productos para desarrollo
/// Utiliza datos mock en vez de acceder a la base de datos
class MockProductRepositoryImpl implements ProductRepository {
  final List<Product> _products;

  MockProductRepositoryImpl(this._products);

  @override
  Future<List<Product>> getAllProducts() async {
    // Simulamos un pequeño retraso para imitar el acceso a la base de datos
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_products);
  }

  @override
  Future<Product?> getProductById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _products.firstWhere((p) => p.id == id, orElse: () => throw Exception('Producto no encontrado'));
  }

  @override
  Future<Product?> getProductBySku(String sku) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _products.firstWhere((p) => p.sku == sku);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<String> createProduct(Product product) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _products.add(product);
    return product.id;
  }

  @override
  Future<void> updateProduct(Product product) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _products.indexWhere((p) => p.id == product.id);
    if (index >= 0) {
      _products[index] = product;
    } else {
      throw Exception('Producto no encontrado para actualización');
    }
  }

  @override
  Future<void> deleteProduct(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _products.indexWhere((p) => p.id == id);
    if (index >= 0) {
      _products.removeAt(index);
    } else {
      throw Exception('Producto no encontrado para eliminación');
    }
  }

  @override
  Future<List<Product>> getProductsByCategory(String categoryId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _products.where((p) => p.categoryId == categoryId).toList();
  }

  @override
  Future<List<Product>> getLowStockProducts() async {
    await Future.delayed(const Duration(milliseconds: 300));
    // Esta es una implementación simplificada - normalmente necesitaríamos
    // cruzar datos con la tabla de stock para determinar productos con bajo stock
    return _products.where((p) => p.reorderPoint > 5).toList();
  }
}
