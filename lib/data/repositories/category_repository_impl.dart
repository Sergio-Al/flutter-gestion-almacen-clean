import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/local/database_helper.dart';
import '../models/category_model.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final DatabaseHelper _databaseHelper;

  CategoryRepositoryImpl(this._databaseHelper);

  @override
  Future<List<Category>> getCategories() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('categories');
    
    return List.generate(maps.length, (i) {
      return CategoryModel.fromDatabase(maps[i]);
    });
  }

  @override
  Future<Category?> getCategoryById(String id) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    
    if (maps.isEmpty) return null;
    return CategoryModel.fromDatabase(maps.first);
  }

  @override
  Future<String> createCategory(Category category) async {
    // Implementación para crear una categoría
    return 'new-id';
  }

  @override
  Future<void> updateCategory(Category category) async {
    // Implementación para actualizar una categoría
  }

  @override
  Future<void> deleteCategory(String id) async {
    // Implementación para eliminar una categoría
  }
}
