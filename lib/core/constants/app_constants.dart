class AppConstants {
  // App Configuration
  static const bool useMockData = false; // Cambiar a false para usar datos reales
  
  // Database
  static const String databaseName = 'warehouse_management.db';
  static const int databaseVersion = 1;
  
  // Table Names
  static const String productsTable = 'products';
  static const String warehousesTable = 'warehouses';
  static const String stockBatchesTable = 'stock_batches';
  static const String salesOrdersTable = 'sales_orders';
  static const String orderItemsTable = 'order_items';
  static const String usersTable = 'users';
  
  // Date Formats
  static const String dateFormat = 'yyyy-MM-dd';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm:ss';
  
  // Default Values
  static const int defaultReorderPoint = 10;
  static const int defaultWarehouseCapacity = 1000;
}
