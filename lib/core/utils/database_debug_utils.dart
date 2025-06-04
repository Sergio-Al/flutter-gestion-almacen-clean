import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:developer' as developer;

/// Database debugging utilities for development purposes
class DatabaseDebugUtils {
  /// Gets the absolute path to the database file
  static Future<String> getDatabasePath() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'warehouse_management.db');
    return path;
  }

  /// Prints the database path to console for debugging
  static Future<void> printDatabasePath() async {
    final path = await getDatabasePath();
    developer.log('📂 Database Path: $path', name: 'DatabaseDebug');
    print('📂 Database Path: $path');
  }

  /// Gets database information including tables and their schemas
  static Future<Map<String, dynamic>> getDatabaseInfo() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'warehouse_management.db');
    
    // Check if database exists
    final dbExists = await databaseExists(path);
    
    if (!dbExists) {
      return {
        'path': path,
        'exists': false,
        'message': 'Database file does not exist yet. It will be created on first app launch.',
      };
    }

    // Open database and get table information
    final db = await openDatabase(path);
    
    // Get all table names
    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'"
    );
    
    final tableInfo = <String, List<Map<String, dynamic>>>{};
    
    // Get schema for each table
    for (final table in tables) {
      final tableName = table['name'] as String;
      final columns = await db.rawQuery('PRAGMA table_info($tableName)');
      tableInfo[tableName] = columns;
    }
    
    // Get database size (approximate)
    final result = await db.rawQuery('PRAGMA page_count');
    final pageCount = result.first['page_count'] as int;
    final pageSize = (await db.rawQuery('PRAGMA page_size')).first['page_size'] as int;
    final dbSizeBytes = pageCount * pageSize;
    
    await db.close();
    
    return {
      'path': path,
      'exists': true,
      'size_bytes': dbSizeBytes,
      'size_mb': (dbSizeBytes / (1024 * 1024)).toStringAsFixed(2),
      'tables': tableInfo,
      'table_names': tables.map((t) => t['name']).toList(),
    };
  }

  /// Prints comprehensive database information
  static Future<void> printDatabaseInfo() async {
    final info = await getDatabaseInfo();
    
    developer.log('🗃️  Database Information:', name: 'DatabaseDebug');
    developer.log('   Path: ${info['path']}', name: 'DatabaseDebug');
    developer.log('   Exists: ${info['exists']}', name: 'DatabaseDebug');
    
    if (info['exists']) {
      developer.log('   Size: ${info['size_mb']} MB', name: 'DatabaseDebug');
      developer.log('   Tables: ${info['table_names']}', name: 'DatabaseDebug');
    } else {
      developer.log('   ${info['message']}', name: 'DatabaseDebug');
    }
    
    print('\n🗃️  Database Information:');
    print('   Path: ${info['path']}');
    print('   Exists: ${info['exists']}');
    
    if (info['exists']) {
      print('   Size: ${info['size_mb']} MB');
      print('   Tables: ${info['table_names']}');
    } else {
      print('   ${info['message']}');
    }
  }

  /// Gets the platform-specific database directory path
  static Future<String> getDatabaseDirectory() async {
    return await getDatabasesPath();
  }

  /// Utility to export database (for debugging/backup purposes)
  static Future<String> exportDatabaseForDebugging() async {
    final path = await getDatabasePath();
    final dbExists = await databaseExists(path);
    
    if (!dbExists) {
      return 'Database does not exist yet.';
    }
    
    // For debugging, you could copy the database file to app documents
    // This is just returning the path for now
    return 'Database available at: $path\n'
           'You can copy this file to view with SQLite browser tools.';
  }
}

/// Extension to add database debugging to DatabaseHelper
extension DatabaseHelperDebug on Object {
  /// Quick method to print database path during development
  static Future<void> debugDatabaseLocation() async {
    await DatabaseDebugUtils.printDatabaseInfo();
  }
}
