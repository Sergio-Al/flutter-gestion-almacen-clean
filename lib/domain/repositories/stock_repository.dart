import '../entities/stock_batch.dart';

abstract class StockRepository {
  Future<List<StockBatch>> getAllStockBatches();
  Future<StockBatch?> getStockBatchById(String id);
  Future<List<StockBatch>> getStockBatchesByProduct(String productId);
  Future<List<StockBatch>> getStockBatchesByWarehouse(String warehouseId);
  Future<String> createStockBatch(StockBatch stockBatch);
  Future<void> updateStockBatch(StockBatch stockBatch);
  Future<void> deleteStockBatch(String id);
  Future<int> getTotalStockForProduct(String productId);
  Future<List<StockBatch>> getExpiringBatches(DateTime beforeDate);
}
