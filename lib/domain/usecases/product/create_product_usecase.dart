import 'package:uuid/uuid.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/repositories/product_repository.dart';

class CreateProductUseCase {
  final ProductRepository _repository;

  CreateProductUseCase(this._repository);

  Future<String> call({
    required String sku,
    required String name,
    required String description,
    required String categoryId,
    required double unitPrice,
    required double costPrice,
    required int reorderPoint,
  }) async {
    // Verificar si el SKU ya existe
    final existingProduct = await _repository.getProductBySku(sku);
    if (existingProduct != null) {
      throw Exception('El SKU $sku ya existe en la base de datos');
    }

    // Crear el producto si no existe el SKU
    final now = DateTime.now();
    final product = Product(
      id: const Uuid().v4(),
      sku: sku,
      name: name,
      description: description,
      categoryId: categoryId,
      unitPrice: unitPrice,
      costPrice: costPrice,
      reorderPoint: reorderPoint,
      createdAt: now,
      updatedAt: now,
    );

    // Guardar en el repositorio
    return await _repository.createProduct(product);
  }
}
