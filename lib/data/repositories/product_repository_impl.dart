import 'package:sqflite/sqflite.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../models/product_model.dart';
import '../datasources/local/database_helper.dart';

class ProductRepositoryImpl implements ProductRepository {
  final DatabaseHelper _databaseHelper;

  ProductRepositoryImpl(this._databaseHelper);

  @override
  Future<List<Product>> getAllProducts() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('products');
    
    return maps.map((map) => ProductModel.fromMap(map)).cast<Product>().toList();
  }

  @override
  Future<Product?> getProductById(String id) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isEmpty) return null;
    return ProductModel.fromMap(maps.first) as Product?;
  }

  @override
  Future<Product?> getProductBySku(String sku) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'products',
      where: 'sku = ?',
      whereArgs: [sku],
    );
    
    if (maps.isEmpty) return null;
    return ProductModel.fromMap(maps.first) as Product?;
  }

  @override
  Future<String> createProduct(Product product) async {
    final db = await _databaseHelper.database;
    final productModel = ProductModel.fromEntity(product);
    
    await db.insert(
      'products',
      productModel.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    
    return product.id;
  }

  @override
  Future<void> updateProduct(Product product) async {
    final db = await _databaseHelper.database;
    final productModel = ProductModel.fromEntity(product);
    
    await db.update(
      'products',
      productModel.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  @override
  Future<void> deleteProduct(String id) async {
    final db = await _databaseHelper.database;
    await db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<List<Product>> getProductsByCategory(String categoryId) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'products',
      where: 'category_id = ?',
      whereArgs: [categoryId],
    );
    
    return maps.map((map) => ProductModel.fromMap(map)).cast<Product>().toList();
  }

  @override
  Future<List<Product>> getLowStockProducts() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT p.* FROM products p
      LEFT JOIN (
        SELECT product_id, SUM(quantity) as total_stock
        FROM stock_batches
        GROUP BY product_id
      ) s ON p.id = s.product_id
      WHERE COALESCE(s.total_stock, 0) <= p.reorder_point
    ''');
    
    return maps.map((map) => ProductModel.fromMap(map)).cast<Product>().toList();
  }
  
  @override
  Future<int> getProductCount() async{
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('SELECT COUNT(*) as count FROM products');
    
    if (maps.isEmpty) return 0;
    return maps.first['count'] as int;
  }
}
