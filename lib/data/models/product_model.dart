import '../../domain/entities/product.dart';

class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.sku,
    required super.name,
    required super.description,
    required super.categoryId,
    required super.unitPrice,
    required super.costPrice,
    required super.reorderPoint,
    required super.createdAt,
    required super.updatedAt,
    super.imageUrl,
  });

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] as String,
      sku: map['sku'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      categoryId: map['category_id'] as String,
      unitPrice: (map['unit_price'] as num).toDouble(),
      costPrice: (map['cost_price'] as num).toDouble(),
      reorderPoint: map['reorder_point'] as int,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      imageUrl: map['image_url'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sku': sku,
      'name': name,
      'description': description,
      'category_id': categoryId,
      'unit_price': unitPrice,
      'cost_price': costPrice,
      'reorder_point': reorderPoint,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'image_url': imageUrl,
    };
  }

  factory ProductModel.fromEntity(Product product) {
    return ProductModel(
      id: product.id,
      sku: product.sku,
      name: product.name,
      description: product.description,
      categoryId: product.categoryId,
      unitPrice: product.unitPrice,
      costPrice: product.costPrice,
      reorderPoint: product.reorderPoint,
      createdAt: product.createdAt,
      updatedAt: product.updatedAt,
      imageUrl: product.imageUrl,
    );
  }
}
