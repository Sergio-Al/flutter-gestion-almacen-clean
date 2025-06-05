import 'package:gestion_almacen_stock/data/datasources/local/database_helper.dart';
import 'package:gestion_almacen_stock/data/models/stock_transfer_model.dart';
import 'package:sqflite/sqflite.dart';

class StockTransferLocalDataSource {
  final DatabaseHelper _databaseHelper;

  StockTransferLocalDataSource(this._databaseHelper);

  Future<StockTransferModel> createTransfer(Map<String, dynamic> transferData) async {
    final db = await _databaseHelper.database;
    final transfer = StockTransferModel.fromTransferData(transferData);
    
    // Start a transaction for data consistency
    await db.transaction((txn) async {
      // 1. Insert the transfer record
      await txn.insert(
        'stock_transfers',
        transfer.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // 2. If a specific batch is selected, update its quantity
      if (transfer.batchId != null) {
        await txn.rawUpdate('''
          UPDATE stock_batches
          SET quantity = quantity - ?
          WHERE id = ?
        ''', [transfer.quantity, transfer.batchId]);
      } 
      // 3. If no specific batch, reduce from any available batches
      else {
        // First, get all batches for this product in the source warehouse
        final batches = await txn.query(
          'stock_batches',
          where: 'product_id = ? AND warehouse_id = ? AND quantity > 0',
          whereArgs: [transfer.productId, transfer.fromWarehouseId],
          orderBy: 'expiry_date ASC, received_date ASC', // FIFO approach
        );

        int remainingQuantity = transfer.quantity;
        
        // Subtract from each batch until we've fulfilled the total quantity
        for (var batch in batches) {
          if (remainingQuantity <= 0) break;
          
          final batchId = batch['id'] as String;
          final batchQuantity = batch['quantity'] as int;
          
          if (batchQuantity <= remainingQuantity) {
            // Use the entire batch
            await txn.update(
              'stock_batches',
              {'quantity': 0},
              where: 'id = ?',
              whereArgs: [batchId],
            );
            remainingQuantity -= batchQuantity;
          } else {
            // Use partial batch
            await txn.update(
              'stock_batches',
              {'quantity': batchQuantity - remainingQuantity},
              where: 'id = ?',
              whereArgs: [batchId],
            );
            remainingQuantity = 0;
          }
        }
        
        // If we couldn't fulfill the entire quantity, rollback
        if (remainingQuantity > 0) {
          throw Exception('Insufficient stock available for transfer');
        }
      }
    });
    
    return transfer;
  }

  Future<List<StockTransferModel>> getAllTransfers() async {
    final db = await _databaseHelper.database;
    final transfersData = await db.query('stock_transfers');
    
    return transfersData.map((data) => StockTransferModel.fromMap(data)).toList();
  }

  Future<List<StockTransferModel>> getTransfersByStatus(String status) async {
    final db = await _databaseHelper.database;
    final transfersData = await db.query(
      'stock_transfers',
      where: 'status = ?',
      whereArgs: [status],
    );
    
    return transfersData.map((data) => StockTransferModel.fromMap(data)).toList();
  }

  Future<StockTransferModel> updateTransferStatus(String transferId, String newStatus) async {
    final db = await _databaseHelper.database;
    
    await db.update(
      'stock_transfers',
      {'status': newStatus},
      where: 'id = ?',
      whereArgs: [transferId],
    );
    
    // If status is 'completed', we need to add the stock to the destination warehouse
    if (newStatus == 'completed') {
      final transferData = await db.query(
        'stock_transfers', 
        where: 'id = ?', 
        whereArgs: [transferId]
      );
      
      if (transferData.isNotEmpty) {
        final transfer = StockTransferModel.fromMap(transferData.first);
        
        // Add stock to destination warehouse
        await _completeTransfer(db, transfer);
      }
    }
    
    // Return the updated transfer
    final updatedData = await db.query(
      'stock_transfers',
      where: 'id = ?',
      whereArgs: [transferId],
    );
    
    return StockTransferModel.fromMap(updatedData.first);
  }

  Future<void> _completeTransfer(Database db, StockTransferModel transfer) async {
    // Generate a new batch ID if not transferring a specific batch
    final newBatchId = transfer.batchId ?? 'batch-${DateTime.now().millisecondsSinceEpoch}';
    
    // If a specific batch was transferred, we copy its details
    if (transfer.batchId != null) {
      final batchData = await db.query(
        'stock_batches',
        where: 'id = ?',
        whereArgs: [transfer.batchId],
      );
      
      if (batchData.isNotEmpty) {
        final batch = batchData.first;
        
        // Create a new batch in destination warehouse with same details
        await db.insert('stock_batches', {
          'id': newBatchId,
          'product_id': transfer.productId,
          'warehouse_id': transfer.toWarehouseId,
          'quantity': transfer.quantity,
          'batch_number': batch['batch_number'],
          'expiry_date': batch['expiry_date'],
          'received_date': DateTime.now().toIso8601String(),
          'supplier_id': batch['supplier_id'],
        });
      }
    } 
    // If no specific batch, create a new one at the destination
    else {
      // Get product info to maintain consistency
      final productData = await db.query(
        'products',
        where: 'id = ?',
        whereArgs: [transfer.productId],
      );
      
      if (productData.isNotEmpty) {
        // Create new batch in destination warehouse
        await db.insert('stock_batches', {
          'id': newBatchId,
          'product_id': transfer.productId,
          'warehouse_id': transfer.toWarehouseId,
          'quantity': transfer.quantity,
          'batch_number': 'TF-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
          'expiry_date': null,
          'received_date': DateTime.now().toIso8601String(),
          'supplier_id': 'transfer', // Indicate this came from a transfer
        });
      }
    }
  }

  Future<void> cancelTransfer(String transferId) async {
    final db = await _databaseHelper.database;
    
    // Get transfer details
    final transferData = await db.query(
      'stock_transfers',
      where: 'id = ?',
      whereArgs: [transferId],
    );
    
    if (transferData.isEmpty) {
      throw Exception('Transfer not found');
    }
    
    final transfer = StockTransferModel.fromMap(transferData.first);
    
    // Can only cancel pending transfers
    if (transfer.status != 'pending') {
      throw Exception('Only pending transfers can be cancelled');
    }
    
    // Update transfer status to cancelled
    await db.update(
      'stock_transfers',
      {'status': 'cancelled'},
      where: 'id = ?',
      whereArgs: [transferId],
    );
    
    // If a specific batch was used, restore its quantity
    if (transfer.batchId != null) {
      await db.rawUpdate('''
        UPDATE stock_batches
        SET quantity = quantity + ?
        WHERE id = ?
      ''', [transfer.quantity, transfer.batchId]);
    } 
    // Otherwise restore to any batch or create a new one
    else {
      // For simplicity, we'll create a new batch with the returned quantity
      await db.insert('stock_batches', {
        'id': 'return-${DateTime.now().millisecondsSinceEpoch}',
        'product_id': transfer.productId,
        'warehouse_id': transfer.fromWarehouseId,
        'quantity': transfer.quantity,
        'batch_number': 'RT-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
        'expiry_date': null,
        'received_date': DateTime.now().toIso8601String(),
        'supplier_id': 'return', // Indicate this is a returned transfer
      });
    }
  }
}
