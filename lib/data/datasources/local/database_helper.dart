import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'tables/stock_transfer_table.dart';
import 'tables/customer_table.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database == null || !_database!.isOpen) {
      _database = await _initDatabase();
    }
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'warehouse_management.db');

    return await openDatabase(
      path,
      version: 5,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Users table (NUEVA TABLA)
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        email TEXT UNIQUE NOT NULL,
        name TEXT NOT NULL,
        role TEXT NOT NULL,
        password_hash TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        last_login_at TEXT
      )
    ''');

    // Products table
    await db.execute('''
      CREATE TABLE products (
        id TEXT PRIMARY KEY,
        sku TEXT UNIQUE NOT NULL,
        name TEXT NOT NULL,
        description TEXT,
        category_id TEXT,
        unit_price REAL NOT NULL,
        cost_price REAL NOT NULL,
        reorder_point INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        image_url TEXT
      )
    ''');

    // Warehouses table
    await db.execute('''
      CREATE TABLE warehouses (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        location TEXT NOT NULL,
        capacity INTEGER NOT NULL,
        manager_name TEXT NOT NULL,
        contact_info TEXT NOT NULL
      )
    ''');

    // Stock Batches table
    await db.execute('''
      CREATE TABLE stock_batches (
        id TEXT PRIMARY KEY,
        product_id TEXT NOT NULL,
        warehouse_id TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        batch_number TEXT NOT NULL,
        expiry_date TEXT,
        received_date TEXT NOT NULL,
        supplier_id TEXT NOT NULL,
        FOREIGN KEY (product_id) REFERENCES products (id),
        FOREIGN KEY (warehouse_id) REFERENCES warehouses (id)
      )
    ''');

    // Sales Orders table
    await db.execute('''
      CREATE TABLE sales_orders (
        id TEXT PRIMARY KEY,
        customer_id TEXT NOT NULL,
        customer_name TEXT NOT NULL,
        date TEXT NOT NULL,
        status TEXT NOT NULL,
        total REAL NOT NULL,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Order Items table
    await db.execute('''
      CREATE TABLE order_items (
        id TEXT PRIMARY KEY,
        order_id TEXT NOT NULL,
        product_id TEXT NOT NULL,
        product_name TEXT NOT NULL,
        product_description TEXT,
        quantity INTEGER NOT NULL,
        unit_price REAL NOT NULL,
        batch_id TEXT,
        FOREIGN KEY (order_id) REFERENCES sales_orders (id),
        FOREIGN KEY (product_id) REFERENCES products (id)
      )
    ''');

    // Categories table
    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        parent_id TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (parent_id) REFERENCES categories (id)
      )
    ''');

    // Create the customers table
    await db.execute(CustomerTable.createTable());
    
    // Create indexes for better performance
    await db.execute('CREATE INDEX idx_users_email ON users (email)');
    await db.execute('CREATE INDEX idx_users_role ON users (role)');
    await db.execute('CREATE INDEX idx_products_sku ON products (sku)');
    await db.execute('CREATE INDEX idx_stock_batches_product_id ON stock_batches (product_id)');
    await db.execute('CREATE INDEX idx_stock_batches_warehouse_id ON stock_batches (warehouse_id)');
    await db.execute('CREATE INDEX idx_order_items_order_id ON order_items (order_id)');
    await db.execute('CREATE INDEX idx_order_items_product_id ON order_items (product_id)');
    await db.execute('CREATE INDEX idx_customers_name ON ${CustomerTable.tableName} (${CustomerTable.columnName})');
    await db.execute('CREATE INDEX idx_customers_email ON ${CustomerTable.tableName} (${CustomerTable.columnEmail})');

    // Insert default users and categories after creating tables
    await _insertDefaultUsers(db);
    await _seedCategoriesTable(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle upgrade from version 1 to 2
    if (oldVersion == 1 && newVersion >= 2) {
      await StockTransferTable.createTable(db);
    }
    
    // Handle upgrade from version 2 to 3
    if (oldVersion <= 2 && newVersion >= 3) {
      await db.execute(CustomerTable.createTable());
      await db.execute('CREATE INDEX idx_customers_name ON ${CustomerTable.tableName} (${CustomerTable.columnName})');
      await db.execute('CREATE INDEX idx_customers_email ON ${CustomerTable.tableName} (${CustomerTable.columnEmail})');
    }
    
    // Handle upgrade from version 3 to 4
    if (oldVersion <= 3 && newVersion >= 4) {
      // Drop old tables if they exist
      await db.execute('DROP TABLE IF EXISTS order_items');
      await db.execute('DROP TABLE IF EXISTS sales_orders');
      
      // Create new sales_orders table
      await db.execute('''
        CREATE TABLE sales_orders (
          id TEXT PRIMARY KEY,
          customer_id TEXT NOT NULL,
          customer_name TEXT NOT NULL,
          date TEXT NOT NULL,
          status TEXT NOT NULL,
          total REAL NOT NULL,
          notes TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        )
      ''');
      
      // Create new order_items table
      await db.execute('''
        CREATE TABLE order_items (
          id TEXT PRIMARY KEY,
          order_id TEXT NOT NULL,
          product_id TEXT NOT NULL,
          product_name TEXT NOT NULL,
          product_description TEXT,
          quantity INTEGER NOT NULL,
          unit_price REAL NOT NULL,
          batch_id TEXT,
          FOREIGN KEY (order_id) REFERENCES sales_orders (id),
          FOREIGN KEY (product_id) REFERENCES products (id)
        )
      ''');
      
      // Re-create indexes
      await db.execute('CREATE INDEX idx_order_items_order_id ON order_items (order_id)');
      await db.execute('CREATE INDEX idx_order_items_product_id ON order_items (product_id)');
    }
    
    // Handle upgrade from version 4 to 5
    if (oldVersion <= 4 && newVersion >= 5) {
      // Add the image_url column to the products table
      await db.execute('ALTER TABLE products ADD COLUMN image_url TEXT');
    }
    // Add future migration steps here as needed
  }

  Future<void> _insertDefaultUsers(Database db) async {
    final now = DateTime.now().toIso8601String();
    
    await db.insert('users', {
      'id': 'root-user',
      'email': 'admin@sistema.com',
      'name': 'Administrador del Sistema',
      'role': 'admin',
      'password_hash': _hashPassword('admin123'),
      'created_at': now,
      'updated_at': now,
      'last_login_at': null,
    });
    
    await db.insert('users', {
      'id': 'user-manager',
      'email': 'gerente@almacen.com',
      'name': 'Gerente de Almacén',
      'role': 'manager',
      'password_hash': _hashPassword('gerente123'),
      'created_at': now,
      'updated_at': now,
      'last_login_at': null,
    });
    
    await db.insert('users', {
      'id': 'user-operator',
      'email': 'operador@almacen.com',
      'name': 'Operador',
      'role': 'operator',
      'password_hash': _hashPassword('operador123'),
      'created_at': now,
      'updated_at': now,
      'last_login_at': null,
    });
  }

  Future<void> _seedCategoriesTable(Database db) async {
    final now = DateTime.now().toIso8601String();
    
    final List<Map<String, dynamic>> categories = [
      {
        'id': 'cat-1',
        'name': 'Electrónicos',
        'description': 'Productos electrónicos y gadgets',
        'parent_id': null,
        'created_at': now,
        'updated_at': now,
      },
      {
        'id': 'cat-2',
        'name': 'Ropa',
        'description': 'Prendas de vestir y accesorios',
        'parent_id': null,
        'created_at': now,
        'updated_at': now,
      },
      {
        'id': 'cat-3',
        'name': 'Alimentos',
        'description': 'Productos alimenticios',
        'parent_id': null,
        'created_at': now,
        'updated_at': now,
      },
      // Añadir más categorías según necesites
    ];
    
    for (final category in categories) {
      await db.insert('categories', category);
    }
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
  
    return digest.toString();
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
