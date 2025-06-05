import '../entities/product.dart';

abstract class ProductRepository {
  Future<List<Product>> getAllProducts();
  Future<int> getProductCount();
  Future<Product?> getProductById(String id);
  Future<Product?> getProductBySku(String sku);
  Future<String> createProduct(Product product);
  Future<void> updateProduct(Product product);
  Future<void> deleteProduct(String id);
  Future<List<Product>> getProductsByCategory(String categoryId);
  Future<List<Product>> getLowStockProducts();
}
