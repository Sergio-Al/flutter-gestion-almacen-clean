/// Definition of the customer table schema for the database
class CustomerTable {
  static const String tableName = 'customers';
  
  static const String columnId = 'id';
  static const String columnName = 'name';
  static const String columnEmail = 'email';
  static const String columnPhone = 'phone';
  static const String columnAddress = 'address';
  static const String columnCreatedAt = 'created_at';
  static const String columnUpdatedAt = 'updated_at';

  /// SQL statement to create the customer table
  static String createTable() {
    return '''
      CREATE TABLE $tableName (
        $columnId TEXT PRIMARY KEY,
        $columnName TEXT NOT NULL,
        $columnEmail TEXT,
        $columnPhone TEXT,
        $columnAddress TEXT,
        $columnCreatedAt TEXT NOT NULL,
        $columnUpdatedAt TEXT NOT NULL
      )
    ''';
  }
}
