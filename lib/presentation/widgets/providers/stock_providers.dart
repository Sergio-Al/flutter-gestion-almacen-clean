import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/stock_batch.dart';
import '../../../core/providers/repository_providers.dart';

// Stock Batches State Provider
final stockBatchesProvider = FutureProvider<List<StockBatch>>((ref) async {
  final repository = ref.watch(stockRepositoryProvider);
  return await repository.getAllStockBatches();
});

// Stock Batches by Product Provider
final stockBatchesByProductProvider = FutureProvider.family<List<StockBatch>, String>((ref, productId) async {
  final repository = ref.watch(stockRepositoryProvider);
  return await repository.getStockBatchesByProduct(productId);
});

// Stock Batches by Warehouse Provider
final stockBatchesByWarehouseProvider = FutureProvider.family<List<StockBatch>, String>((ref, warehouseId) async {
  final repository = ref.watch(stockRepositoryProvider);
  return await repository.getStockBatchesByWarehouse(warehouseId);
});

// Total Stock for Product Provider
final totalStockForProductProvider = FutureProvider.family<int, String>((ref, productId) async {
  final repository = ref.watch(stockRepositoryProvider);
  return await repository.getTotalStockForProduct(productId);
});

// Expiring Batches Provider
final expiringBatchesProvider = FutureProvider.family<List<StockBatch>, DateTime>((ref, beforeDate) async {
  final repository = ref.watch(stockRepositoryProvider);
  return await repository.getExpiringBatches(beforeDate);
});
