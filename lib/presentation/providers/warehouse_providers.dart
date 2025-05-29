import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/warehouse.dart';
import '../../core/providers/repository_providers.dart';

// Warehouses State Provider
final warehousesProvider = FutureProvider<List<Warehouse>>((ref) async {
  final repository = ref.watch(warehouseRepositoryProvider);
  return await repository.getAllWarehouses();
});

// Warehouse by ID Provider
final warehouseByIdProvider = FutureProvider.family<Warehouse?, String>((ref, warehouseId) async {
  final repository = ref.watch(warehouseRepositoryProvider);
  return await repository.getWarehouseById(warehouseId);
});

// Warehouse Current Stock Provider
final warehouseCurrentStockProvider = FutureProvider.family<int, String>((ref, warehouseId) async {
  final repository = ref.watch(warehouseRepositoryProvider);
  return await repository.getWarehouseCurrentStock(warehouseId);
});

// Warehouse Capacity Provider
final warehouseCapacityProvider = FutureProvider.family<int, String>((ref, warehouseId) async {
  final repository = ref.watch(warehouseRepositoryProvider);
  return await repository.getWarehouseCapacity(warehouseId);
});
