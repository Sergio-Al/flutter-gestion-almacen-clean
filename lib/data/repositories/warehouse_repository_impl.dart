import 'package:sqflite/sqflite.dart';
import '../../domain/entities/warehouse.dart';
import '../../domain/repositories/warehouse_repository.dart';
import '../models/warehouse_model.dart';
import '../datasources/local/database_helper.dart';

class WarehouseRepositoryImpl implements WarehouseRepository {
  final DatabaseHelper _databaseHelper;

  WarehouseRepositoryImpl(this._databaseHelper);

  @override
  Future<List<Warehouse>> getAllWarehouses() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('warehouses');
    
    return maps.map((map) => WarehouseModel.fromMap(map)).toList();
  }

  @override
  Future<Warehouse?> getWarehouseById(String id) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'warehouses',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isEmpty) return null;
    return WarehouseModel.fromMap(maps.first);
  }

  @override
  Future<String> createWarehouse(Warehouse warehouse) async {
    final db = await _databaseHelper.database;
    final warehouseModel = WarehouseModel.fromEntity(warehouse);
    
    await db.insert(
      'warehouses',
      warehouseModel.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    
    return warehouse.id;
  }

  @override
  Future<void> updateWarehouse(Warehouse warehouse) async {
    final db = await _databaseHelper.database;
    final warehouseModel = WarehouseModel.fromEntity(warehouse);
    
    await db.update(
      'warehouses',
      warehouseModel.toMap(),
      where: 'id = ?',
      whereArgs: [warehouse.id],
    );
  }

  @override
  Future<void> deleteWarehouse(String id) async {
    final db = await _databaseHelper.database;
    
    // Check if there are stock batches associated with this warehouse
    final List<Map<String, dynamic>> stockBatches = await db.query(
      'stock_batches',
      where: 'warehouse_id = ?',
      whereArgs: [id],
    );
    
    if (stockBatches.isNotEmpty) {
      throw Exception('No se puede eliminar el almacén porque tiene lotes de stock asociados');
    }
    
    // If no stock batches are associated, proceed with deletion
    await db.delete(
      'warehouses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<int> getWarehouseCapacity(String warehouseId) async {
    final warehouse = await getWarehouseById(warehouseId);
    return warehouse?.capacity ?? 0;
  }

  @override
  Future<int> getWarehouseCurrentStock(String warehouseId) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT SUM(quantity) as total_stock
      FROM stock_batches
      WHERE warehouse_id = ?
    ''', [warehouseId]);
    
    return result.first['total_stock'] as int? ?? 0;
  }
}
