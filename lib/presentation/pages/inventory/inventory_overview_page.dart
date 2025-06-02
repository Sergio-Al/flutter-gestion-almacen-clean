import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gestion_almacen_stock/presentation/providers/stock_providers.dart';
import 'package:gestion_almacen_stock/presentation/providers/warehouse_providers.dart';
import 'widgets/stock_level_chart.dart';
import 'stock_adjustment_page.dart';
import 'stock_transfer_page.dart';
import 'batch_management_page.dart';

class InventoryOverviewPage extends ConsumerStatefulWidget {
  const InventoryOverviewPage({Key? key}) : super(key: key);

  @override
  ConsumerState<InventoryOverviewPage> createState() => _InventoryOverviewPageState();
}

class _InventoryOverviewPageState extends ConsumerState<InventoryOverviewPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stockBatchesAsync = ref.watch(stockBatchesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Overview'),
        backgroundColor: theme.colorScheme.surfaceVariant,
        actions: [
          IconButton(
            onPressed: () {
              ref.invalidate(stockBatchesProvider);
              ref.invalidate(warehousesProvider);
            },
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuSelection,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.download),
                    SizedBox(width: 8),
                    Text('Export Data'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings),
                    SizedBox(width: 8),
                    Text('Settings'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary Cards
          Container(
            padding: const EdgeInsets.all(16),
            child: stockBatchesAsync.when(
              data: (batches) => _buildSummaryCards(batches, theme),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('Error loading summary: $error'),
              ),
            ),
          ),
          
          // Quick Actions
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildQuickActions(theme),
          ),
          
          // Tab Bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
            child: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(
                  icon: Icon(Icons.bar_chart),
                  text: 'Stock Levels',
                ),
                Tab(
                  icon: Icon(Icons.warning),
                  text: 'Low Stock',
                ),
                Tab(
                  icon: Icon(Icons.schedule),
                  text: 'Expiring Soon',
                ),
              ],
            ),
          ),
          
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Stock Levels Tab
                const StockLevelChart(),
                
                // Low Stock Tab
                _buildLowStockTab(),
                
                // Expiring Soon Tab
                _buildExpiringSoonTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showQuickActionDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Quick Action'),
      ),
    );
  }

  Widget _buildSummaryCards(List<dynamic> batches, ThemeData theme) {
    final totalProducts = batches.length;
    final lowStockCount = batches.where((b) => b.quantity < 10).length;
    final expiredCount = batches.where((b) {
      final expiry = b.expiryDate;
      return expiry != null && expiry.isBefore(DateTime.now());
    }).length;
    // Note: StockBatch doesn't have costPerUnit, so we'll calculate a simple total quantity
    final totalQuantity = batches.fold<int>(
      0,
      (sum, b) => (sum + b.quantity) as int,
    );

    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            'Total Products',
            totalProducts.toString(),
            Icons.inventory,
            Colors.blue,
            theme,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            'Low Stock',
            lowStockCount.toString(),
            Icons.warning,
            Colors.orange,
            theme,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            'Expired',
            expiredCount.toString(),
            Icons.error,
            Colors.red,
            theme,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            'Total Quantity',
            totalQuantity.toString(),
            Icons.inventory_2,
            Colors.green,
            theme,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: _buildQuickActionButton(
            'Stock Adjustment',
            Icons.tune,
            () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const StockAdjustmentPage(),
              ),
            ),
            theme,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildQuickActionButton(
            'Transfer Stock',
            Icons.swap_horiz,
            () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const StockTransferPage(),
              ),
            ),
            theme,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildQuickActionButton(
            'Batch Management',
            Icons.inventory_2,
            () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const BatchManagementPage(),
              ),
            ),
            theme,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionButton(
    String title,
    IconData icon,
    VoidCallback onTap,
    ThemeData theme,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outline.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: theme.colorScheme.primary,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLowStockTab() {
    final stockBatchesAsync = ref.watch(stockBatchesProvider);
    
    return stockBatchesAsync.when(
      data: (batches) {
        final lowStockBatches = batches.where((b) => b.quantity < 10).toList();
        
        if (lowStockBatches.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, size: 64, color: Colors.green),
                SizedBox(height: 16),
                Text('No low stock items found!'),
                Text('All products have adequate stock levels.'),
              ],
            ),
          );
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: lowStockBatches.length,
          itemBuilder: (context, index) {
            final batch = lowStockBatches[index];
            return Card(
              child: ListTile(
                leading: const Icon(Icons.warning, color: Colors.orange),
                title: Text(batch.batchNumber),
                subtitle: Text('Quantity: ${batch.quantity}'),
                trailing: ElevatedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => StockAdjustmentPage(selectedBatch: batch),
                    ),
                  ),
                  child: const Text('Adjust'),
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }

  Widget _buildExpiringSoonTab() {
    final stockBatchesAsync = ref.watch(stockBatchesProvider);
    
    return stockBatchesAsync.when(
      data: (batches) {
        final thirtyDaysFromNow = DateTime.now().add(const Duration(days: 30));
        final expiringSoonBatches = batches.where((b) {
          final expiry = b.expiryDate;
          return expiry != null && 
                 expiry.isAfter(DateTime.now()) && 
                 expiry.isBefore(thirtyDaysFromNow);
        }).toList();
        
        if (expiringSoonBatches.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, size: 64, color: Colors.green),
                SizedBox(height: 16),
                Text('No products expiring soon!'),
                Text('All products have sufficient shelf life.'),
              ],
            ),
          );
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: expiringSoonBatches.length,
          itemBuilder: (context, index) {
            final batch = expiringSoonBatches[index];
            final daysUntilExpiry = batch.expiryDate!.difference(DateTime.now()).inDays;
            
            return Card(
              child: ListTile(
                leading: Icon(
                  Icons.schedule,
                  color: daysUntilExpiry <= 7 ? Colors.red : Colors.orange,
                ),
                title: Text(batch.batchNumber),
                subtitle: Text('Expires in $daysUntilExpiry days'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => StockTransferPage(selectedBatch: batch),
                        ),
                      ),
                      child: const Text('Transfer'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => StockAdjustmentPage(selectedBatch: batch),
                        ),
                      ),
                      child: const Text('Adjust'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }

  void _handleMenuSelection(String value) {
    switch (value) {
      case 'export':
        _showExportDialog();
        break;
      case 'settings':
        _showSettingsDialog();
        break;
    }
  }

  void _showQuickActionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quick Actions'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.tune),
              title: const Text('Stock Adjustment'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const StockAdjustmentPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.swap_horiz),
              title: const Text('Transfer Stock'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const StockTransferPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.inventory_2),
              title: const Text('Batch Management'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const BatchManagementPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Data'),
        content: const Text('Export functionality will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Export'),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Inventory Settings'),
        content: const Text('Settings will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
