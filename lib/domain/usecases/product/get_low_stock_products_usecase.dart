import '../../repositories/product_repository.dart';
import '../../entities/product.dart';

class GetLowStockProductsUseCase {
  final ProductRepository _repository;

  GetLowStockProductsUseCase(this._repository);

  Future<List<Product>> call() async {
    // Obtener productos con stock bajo
    final lowStockProducts = await _repository.getLowStockProducts();
    
    // Ordenar por cantidad de stock (ascendente)
    // La implementación dependerá de cómo obtengas la cantidad de stock,
    // pero conceptualmente es así:
    
    return lowStockProducts;
  }
}
