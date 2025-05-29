import '../../domain/repositories/warehouse_repository.dart';
import '../../domain/entities/warehouse.dart';
import '../../core/utils/mock_data.dart';

/// Implementación simulada del repositorio de almacenes para desarrollo
class MockWarehouseRepositoryImpl implements WarehouseRepository {
  final List<Warehouse> _warehouses;
  final Map<String, int> _currentStock;

  MockWarehouseRepositoryImpl(this._warehouses)
      : _currentStock = {
          'warehouse-main': 750, // 75% de capacidad
          'warehouse-north': 480, // 60% de capacidad
        };

  @override
  Future<List<Warehouse>> getAllWarehouses() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_warehouses);
  }

  @override
  Future<Warehouse?> getWarehouseById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _warehouses.firstWhere((w) => w.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<String> createWarehouse(Warehouse warehouse) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _warehouses.add(warehouse);
    _currentStock[warehouse.id] = 0;
    return warehouse.id;
  }

  @override
  Future<void> updateWarehouse(Warehouse warehouse) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _warehouses.indexWhere((w) => w.id == warehouse.id);
    if (index >= 0) {
      _warehouses[index] = warehouse;
    } else {
      throw Exception('Almacén no encontrado para actualización');
    }
  }

  @override
  Future<void> deleteWarehouse(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _warehouses.indexWhere((w) => w.id == id);
    if (index >= 0) {
      _warehouses.removeAt(index);
      _currentStock.remove(id);
    } else {
      throw Exception('Almacén no encontrado para eliminación');
    }
  }

  @override
  Future<int> getWarehouseCapacity(String warehouseId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final warehouse = await getWarehouseById(warehouseId);
    return warehouse?.capacity ?? 0;
  }

  @override
  Future<int> getWarehouseCurrentStock(String warehouseId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _currentStock[warehouseId] ?? 0;
  }
}
