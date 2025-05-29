import '../../entities/product.dart';
import '../../repositories/product_repository.dart';

class GetTotalProductsCountUseCase {
  final ProductRepository _repository;

  GetTotalProductsCountUseCase(this._repository);

  Future<int> call() async {
    final products = await _repository.getAllProducts();
    return products.length;
  }
}
