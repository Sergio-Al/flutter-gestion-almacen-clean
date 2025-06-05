class Category {
  final String id;
  final String name;
  final String? description;
  final String? parentId; // Para categorías jerárquicas

  Category({
    required this.id,
    required this.name,
    this.description,
    this.parentId,
  });

  Category copyWith({ // Permite crear una copia de la categoría con algunos campos modificados
    String? id,
    String? name,
    String? description,
    String? parentId,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      parentId: parentId ?? this.parentId,
    );
  }
}
