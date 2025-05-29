import 'package:sqflite/sqflite.dart';
import '../../domain/entities/stock_batch.dart';
import '../../domain/repositories/stock_repository.dart';
import '../models/stock_batch_model.dart';
import '../datasources/local/database_helper.dart';

class StockRepositoryImpl implements StockRepository {
  final DatabaseHelper _databaseHelper;

  StockRepositoryImpl(this._databaseHelper);

  @override
  Future<List<StockBatch>> getAllStockBatches() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('stock_batches');
    
    return maps.map((map) => StockBatchModel.fromMap(map)).toList();
  }

  @override
  Future<StockBatch?> getStockBatchById(String id) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'stock_batches',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isEmpty) return null;
    return StockBatchModel.fromMap(maps.first);
  }

  @override
  Future<List<StockBatch>> getStockBatchesByProduct(String productId) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'stock_batches',
      where: 'product_id = ?',
      whereArgs: [productId],
    );
    
    return maps.map((map) => StockBatchModel.fromMap(map)).toList();
  }

  @override
  Future<List<StockBatch>> getStockBatchesByWarehouse(String warehouseId) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'stock_batches',
      where: 'warehouse_id = ?',
      whereArgs: [warehouseId],
    );
    
    return maps.map((map) => StockBatchModel.fromMap(map)).toList();
  }

  @override
  Future<String> createStockBatch(StockBatch stockBatch) async {
    final db = await _databaseHelper.database;
    final stockBatchModel = StockBatchModel.fromEntity(stockBatch);
    
    await db.insert(
      'stock_batches',
      stockBatchModel.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    
    return stockBatch.id;
  }

  @override
  Future<void> updateStockBatch(StockBatch stockBatch) async {
    final db = await _databaseHelper.database;
    final stockBatchModel = StockBatchModel.fromEntity(stockBatch);
    
    await db.update(
      'stock_batches',
      stockBatchModel.toMap(),
      where: 'id = ?',
      whereArgs: [stockBatch.id],
    );
  }

  @override
  Future<void> deleteStockBatch(String id) async {
    final db = await _databaseHelper.database;
    await db.delete(
      'stock_batches',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<int> getTotalStockForProduct(String productId) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT SUM(quantity) as total_stock
      FROM stock_batches
      WHERE product_id = ?
    ''', [productId]);
    
    return result.first['total_stock'] as int? ?? 0;
  }

  @override
  Future<List<StockBatch>> getExpiringBatches(DateTime beforeDate) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'stock_batches',
      where: 'expiry_date IS NOT NULL AND expiry_date <= ?',
      whereArgs: [beforeDate.toIso8601String()],
      orderBy: 'expiry_date ASC',
    );
    
    return maps.map((map) => StockBatchModel.fromMap(map)).toList();
  }
}
