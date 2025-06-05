import 'package:sqflite/sqflite.dart';
import '../database_helper.dart';

class StockTransferTable {
  // Create the stock transfers table
  static Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE stock_transfers (
        id TEXT PRIMARY KEY,
        quantity INTEGER NOT NULL,
        reason TEXT NOT NULL,
        notes TEXT,
        product_id TEXT NOT NULL,
        from_warehouse_id TEXT NOT NULL,
        to_warehouse_id TEXT NOT NULL,
        batch_id TEXT,
        status TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        FOREIGN KEY (product_id) REFERENCES products (id),
        FOREIGN KEY (from_warehouse_id) REFERENCES warehouses (id),
        FOREIGN KEY (to_warehouse_id) REFERENCES warehouses (id),
        FOREIGN KEY (batch_id) REFERENCES stock_batches (id)
      )
    ''');

    // Create indexes for efficient querying
    await db.execute('CREATE INDEX idx_transfers_product_id ON stock_transfers (product_id)');
    await db.execute('CREATE INDEX idx_transfers_from_warehouse ON stock_transfers (from_warehouse_id)');
    await db.execute('CREATE INDEX idx_transfers_to_warehouse ON stock_transfers (to_warehouse_id)');
    await db.execute('CREATE INDEX idx_transfers_status ON stock_transfers (status)');
  }
}
