import '../../repositories/warehouse_repository.dart';

class GetWarehouseCapacityUseCase {
  final WarehouseRepository _repository;

  GetWarehouseCapacityUseCase(this._repository);

  Future<({double capacityPercentage, int currentStock, int totalCapacity})> call(String warehouseId) async {
    final currentStock = await _repository.getWarehouseCurrentStock(warehouseId);
    final totalCapacity = await _repository.getWarehouseCapacity(warehouseId);
    
    double capacityPercentage = 0;
    if (totalCapacity > 0) {
      capacityPercentage = (currentStock / totalCapacity) * 100;
    }
    
    return (
      capacityPercentage: capacityPercentage,
      currentStock: currentStock,
      totalCapacity: totalCapacity
    );
  }
}
