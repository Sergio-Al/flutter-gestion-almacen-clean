class Product {
  final String id;
  final String sku;
  final String name;
  final String description;
  final String categoryId;
  final double unitPrice;
  final double costPrice;
  final int reorderPoint;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Product({
    required this.id,
    required this.sku,
    required this.name,
    required this.description,
    required this.categoryId,
    required this.unitPrice,
    required this.costPrice,
    required this.reorderPoint,
    required this.createdAt,
    required this.updatedAt,
  });

  Product copyWith({
    String? id,
    String? sku,
    String? name,
    String? description,
    String? categoryId,
    double? unitPrice,
    double? costPrice,
    int? reorderPoint,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      sku: sku ?? this.sku,
      name: name ?? this.name,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      unitPrice: unitPrice ?? this.unitPrice,
      costPrice: costPrice ?? this.costPrice,
      reorderPoint: reorderPoint ?? this.reorderPoint,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Product && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
