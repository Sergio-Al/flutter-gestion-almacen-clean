import '../entities/warehouse.dart';

abstract class WarehouseRepository {
  Future<List<Warehouse>> getAllWarehouses();
  Future<Warehouse?> getWarehouseById(String id);
  Future<String> createWarehouse(Warehouse warehouse);
  Future<void> updateWarehouse(Warehouse warehouse);
  Future<void> deleteWarehouse(String id);
  Future<int> getWarehouseCapacity(String warehouseId);
  Future<int> getWarehouseCurrentStock(String warehouseId);
}
