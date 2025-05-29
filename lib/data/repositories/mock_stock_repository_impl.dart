import '../../domain/repositories/stock_repository.dart';
import '../../domain/entities/stock_batch.dart';
import '../../core/utils/mock_data.dart';

/// Implementación simulada del repositorio de stock para desarrollo
class MockStockRepositoryImpl implements StockRepository {
  final List<StockBatch> _stockBatches;

  MockStockRepositoryImpl(this._stockBatches);

  @override
  Future<List<StockBatch>> getAllStockBatches() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_stockBatches);
  }

  @override
  Future<StockBatch?> getStockBatchById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _stockBatches.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<StockBatch>> getStockBatchesByProduct(String productId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _stockBatches.where((s) => s.productId == productId).toList();
  }

  @override
  Future<List<StockBatch>> getStockBatchesByWarehouse(String warehouseId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _stockBatches.where((s) => s.warehouseId == warehouseId).toList();
  }

  @override
  Future<String> createStockBatch(StockBatch stockBatch) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _stockBatches.add(stockBatch);
    return stockBatch.id;
  }

  @override
  Future<void> updateStockBatch(StockBatch stockBatch) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _stockBatches.indexWhere((s) => s.id == stockBatch.id);
    if (index >= 0) {
      _stockBatches[index] = stockBatch;
    } else {
      throw Exception('Lote de stock no encontrado para actualización');
    }
  }

  @override
  Future<void> deleteStockBatch(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _stockBatches.indexWhere((s) => s.id == id);
    if (index >= 0) {
      _stockBatches.removeAt(index);
    } else {
      throw Exception('Lote de stock no encontrado para eliminación');
    }
  }

  @override
  Future<int> getTotalStockForProduct(String productId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    int total = 0;
    for (final batch in _stockBatches.where((s) => s.productId == productId)) {
      total += await Future.value(batch.quantity);
    }
    return total;
  }

  @override
  Future<List<StockBatch>> getExpiringBatches(DateTime beforeDate) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _stockBatches
        .where((s) => s.expiryDate != null && s.expiryDate!.isBefore(beforeDate))
        .toList();
  }
}
