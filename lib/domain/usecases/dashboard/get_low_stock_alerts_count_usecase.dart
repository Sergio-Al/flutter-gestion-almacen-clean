import '../../entities/product.dart';
import '../../repositories/product_repository.dart';

class GetLowStockAlertsCountUseCase {
  final ProductRepository _repository;

  GetLowStockAlertsCountUseCase(this._repository);

  Future<int> call() async {
    final lowStockProducts = await _repository.getLowStockProducts();
    return lowStockProducts.length;
  }
}
