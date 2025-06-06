import 'package:sqflite/sqflite.dart';
import '../../domain/entities/sales_order.dart';
import '../../domain/entities/order_item.dart';
import '../../domain/repositories/sales_repository.dart';
import '../models/sales_order_model.dart';
import '../models/order_item_model.dart';
import '../datasources/local/database_helper.dart';

class SalesRepositoryImpl implements SalesRepository {
  final DatabaseHelper _databaseHelper;

  SalesRepositoryImpl(this._databaseHelper);

  @override
  Future<List<SalesOrder>> getAllSalesOrders() async {
    final db = await _databaseHelper.database;
    print('here');
    final List<Map<String, dynamic>> maps = await db.query(
      'sales_orders',
      orderBy: 'created_at DESC',
    );

    return maps.map((map) => SalesOrderModel.fromMap(map)).toList();
  }

  @override
  Future<SalesOrder?> getSalesOrderById(String id) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'sales_orders',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return SalesOrderModel.fromMap(maps.first);
  }

  @override
  Future<List<OrderItem>> getOrderItems(String orderId) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'order_items',
      where: 'order_id = ?',
      whereArgs: [orderId],
    );

    return maps.map((map) => OrderItemModel.fromMap(map)).toList();
  }

  @override
  Future<String> createSalesOrder(
    SalesOrder salesOrder,
    List<OrderItem> items,
  ) async {
    final db = await _databaseHelper.database;

    print('Creando pedido: ${salesOrder.id}');
    try {
      await db.transaction((txn) async {
        // Insert sales order
        final salesOrderModel = SalesOrderModel.fromEntity(salesOrder);
        await txn.insert(
          'sales_orders',
          salesOrderModel.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        // Insert order items - convertir cada item manualmente sin usar fromEntity
        for (final item in items) {
          // Crear directamente el mapa para insertar, evitando conversiones de tipo
          final Map<String, dynamic> itemMap = {
            'id': item.id,
            'order_id': item.orderId,
            'product_id': item.productId,
            'product_name': item.productName,
            'product_description': item.productDescription,
            'quantity': item.quantity,
            'unit_price': item.unitPrice,
            'batch_id': item.batchId,
          };
          await txn.insert(
            'order_items',
            itemMap,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      });
      
      print('Pedido guardado con éxito: ${salesOrder.id}');
      return salesOrder.id;
    } catch (e) {
      print('Error al guardar pedido: ${e.toString()}');
      throw e;
    }
  }

  @override
  Future<void> updateSalesOrder(SalesOrder salesOrder) async {
    final db = await _databaseHelper.database;
    final salesOrderModel = SalesOrderModel.fromEntity(salesOrder);

    await db.update(
      'sales_orders',
      salesOrderModel.toMap(),
      where: 'id = ?',
      whereArgs: [salesOrder.id],
    );
  }

  @override
  Future<void> deleteSalesOrder(String id) async {
    final db = await _databaseHelper.database;

    await db.transaction((txn) async {
      // Delete order items first
      await txn.delete('order_items', where: 'order_id = ?', whereArgs: [id]);

      // Delete sales order
      await txn.delete('sales_orders', where: 'id = ?', whereArgs: [id]);
    });
  }

  @override
  Future<List<SalesOrder>> getSalesOrdersByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'sales_orders',
      where: 'order_date >= ? AND order_date <= ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'order_date DESC',
    );

    return maps.map((map) => SalesOrderModel.fromMap(map)).toList();
  }

  @override
  Future<List<SalesOrder>> getSalesOrdersByStatus(OrderStatus status) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'sales_orders',
      where: 'status = ?',
      whereArgs: [status.name],
      orderBy: 'order_date DESC',
    );

    return maps.map((map) => SalesOrderModel.fromMap(map)).toList();
  }
}
