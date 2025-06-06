import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/stock_providers.dart';

class StockLevelChart extends ConsumerWidget {
  final String? warehouseId;
  final String? productId;

  const StockLevelChart({Key? key, this.warehouseId, this.productId})
    : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Niveles de Stock',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    ref.refresh(stockBatchesProvider);
                    if (productId != null) {
                      ref.refresh(stockBatchesByProductProvider(productId!));
                    }
                    if (warehouseId != null) {
                      ref.refresh(
                        stockBatchesByWarehouseProvider(warehouseId!),
                      );
                    }
                  },
                  tooltip: 'Actualizar',
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(height: 200, child: _buildChart(context, ref)),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(BuildContext context, WidgetRef ref) {
    final stockBatchesAsyncValue =
        warehouseId != null
            ? ref.watch(stockBatchesByWarehouseProvider(warehouseId!))
            : productId != null
            ? ref.watch(stockBatchesByProductProvider(productId!))
            : ref.watch(stockBatchesProvider);

    return stockBatchesAsyncValue.when(
      data: (batches) => _buildStockChart(context, batches),
      loading: () => const Center(child: CircularProgressIndicator()),
      error:
          (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 8),
                Text(
                  'Error al cargar datos',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => ref.refresh(stockBatchesProvider),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildStockChart(BuildContext context, List batches) {
    if (batches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 8),
            Text(
              'No hay datos de stock',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    // Group batches by product for chart display
    final Map<String, int> productStocks = {};
    for (final batch in batches) {
      final productId = batch.productId;
      final currentStock = productStocks[productId] ?? 0;
      final batchQuantity = batch.quantity;
      productStocks[productId] = (currentStock + batchQuantity).toInt();
    }

    final int maxStock =
        productStocks.values.isNotEmpty
            ? productStocks.values.reduce((a, b) => a > b ? a : b)
            : 100;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children:
            productStocks.entries.map((entry) {
              final productId = entry.key;
              final stock = entry.value;
              final height = (stock / maxStock) * 150;

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Stock value
                    Text(
                      stock.toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Bar
                    Container(
                      width: 40,
                      height: height.clamp(10, 150),
                      decoration: BoxDecoration(
                        color: _getStockColor(stock),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Product ID (truncated)
                    SizedBox(
                      width: 40,
                      child: Text(
                        productId.length > 8
                            ? '${productId.substring(0, 8)}...'
                            : productId,
                        style: const TextStyle(fontSize: 10),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
      ),
    );
  }

  Color _getStockColor(int stock) {
    if (stock >= 100) return Colors.green;
    if (stock >= 50) return Colors.orange;
    if (stock >= 10) return Colors.red;
    return Colors.grey;
  }
}
