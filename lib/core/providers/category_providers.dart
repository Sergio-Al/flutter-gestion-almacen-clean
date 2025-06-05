import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../../data/repositories/category_repository_impl.dart';
import '../../data/datasources/local/database_helper.dart';

// Proveedor del repositorio
final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  final dbHelper = DatabaseHelper();
  return CategoryRepositoryImpl(dbHelper);
});

// Proveedor para obtener todas las categorías
final categoriesProvider = FutureProvider<List<Category>>((ref) {
  final repository = ref.watch(categoryRepositoryProvider);
  return repository.getCategories();
});

// Proveedor para obtener una categoría por ID
final categoryByIdProvider = 
    FutureProvider.family<Category?, String>((ref, id) {
  final repository = ref.watch(categoryRepositoryProvider);
  return repository.getCategoryById(id);
});
