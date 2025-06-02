import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/stock_providers.dart';
import '../../providers/warehouse_providers.dart';
import '../../../domain/entities/stock_batch.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/entities/warehouse.dart';
import 'widgets/transfer_form_widget.dart';
import 'widgets/batch_card_widget.dart';

class StockTransferPage extends ConsumerStatefulWidget {
  final StockBatch? selectedBatch;
  final Product? selectedProduct;
  final Warehouse? fromWarehouse;
  final Warehouse? toWarehouse;

  const StockTransferPage({
    Key? key,
    this.selectedBatch,
    this.selectedProduct,
    this.fromWarehouse,
    this.toWarehouse,
  }) : super(key: key);

  @override
  ConsumerState<StockTransferPage> createState() => _StockTransferPageState();
}

class _StockTransferPageState extends ConsumerState<StockTransferPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Warehouse? _selectedFromWarehouse;
  Warehouse? _selectedToWarehouse;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _selectedFromWarehouse = widget.fromWarehouse;
    _selectedToWarehouse = widget.toWarehouse;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Transfer'),
        backgroundColor: theme.colorScheme.surfaceVariant,
        actions: [
          IconButton(
            onPressed: () => _showTransferHistory(context),
            icon: const Icon(Icons.history),
            tooltip: 'Transfer History',
          ),
          IconButton(
            onPressed: () => _showBulkTransferDialog(context),
            icon: const Icon(Icons.multiple_stop),
            tooltip: 'Bulk Transfer',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.swap_horiz),
              text: 'New Transfer',
            ),
            Tab(
              icon: Icon(Icons.inventory),
              text: 'Select Stock',
            ),
            Tab(
              icon: Icon(Icons.track_changes),
              text: 'Track Transfers',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // New Transfer Tab
          _buildNewTransferTab(),
          
          // Select Stock Tab
          _buildSelectStockTab(),
          
          // Track Transfers Tab
          _buildTrackTransfersTab(),
        ],
      ),
    );
  }

  Widget _buildNewTransferTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Warehouse Selection (if not pre-selected)
          if (widget.fromWarehouse == null || widget.toWarehouse == null)
            _buildWarehouseSelector(),
          
          // Transfer Form
          TransferFormWidget(
            selectedProduct: widget.selectedProduct,
            selectedBatch: widget.selectedBatch,
            fromWarehouse: _selectedFromWarehouse,
            toWarehouse: _selectedToWarehouse,
            onSubmit: _handleTransferSubmit,
            onCancel: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildWarehouseSelector() {
    final warehousesAsync = ref.watch(warehousesProvider);
    
    return warehousesAsync.when(
      data: (warehouses) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.warehouse,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Select Warehouses',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                // From Warehouse
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'From Warehouse',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<Warehouse>(
                        value: _selectedFromWarehouse,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Select source',
                          prefixIcon: Icon(Icons.warehouse),
                        ),
                        onChanged: (warehouse) {
                          setState(() {
                            _selectedFromWarehouse = warehouse;
                            if (_selectedToWarehouse?.id == warehouse?.id) {
                              _selectedToWarehouse = null;
                            }
                          });
                        },
                        items: warehouses.map((warehouse) {
                          return DropdownMenuItem(
                            value: warehouse,
                            child: Text(warehouse.name),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                
                // Arrow
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      Icon(
                        Icons.arrow_forward,
                        color: Theme.of(context).colorScheme.primary,
                        size: 32,
                      ),
                    ],
                  ),
                ),
                
                // To Warehouse
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'To Warehouse',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<Warehouse>(
                        value: _selectedToWarehouse,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Select destination',
                          prefixIcon: Icon(Icons.warehouse_outlined),
                        ),
                        onChanged: (warehouse) {
                          setState(() {
                            _selectedToWarehouse = warehouse;
                          });
                        },
                        items: warehouses.where((w) => w.id != _selectedFromWarehouse?.id).map((warehouse) {
                          return DropdownMenuItem(
                            value: warehouse,
                            child: Text(warehouse.name),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error loading warehouses: $error')),
    );
  }

  Widget _buildSelectStockTab() {
    final stockBatchesAsync = ref.watch(stockBatchesProvider);

    return Column(
      children: [
        // Search and Filter Bar
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search stock batches...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                          icon: const Icon(Icons.clear),
                        )
                      : null,
                  border: const OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
              ),
              
              // Quick Filters
              const SizedBox(height: 12),
              Row(
                children: [
                  FilterChip(
                    label: const Text('High Stock'),
                    selected: false,
                    onSelected: (selected) {
                      // Implement filter logic
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Low Stock'),
                    selected: false,
                    onSelected: (selected) {
                      // Implement filter logic
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Expiring Soon'),
                    selected: false,
                    onSelected: (selected) {
                      // Implement filter logic
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Stock List
        Expanded(
          child: stockBatchesAsync.when(
            data: (batches) {
              final filteredBatches = batches.where((batch) {
                if (_searchQuery.isEmpty) return true;
                return batch.batchNumber.toLowerCase().contains(_searchQuery);
              }).toList();

              if (filteredBatches.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 64,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _searchQuery.isEmpty 
                            ? 'No stock batches found'
                            : 'No batches match your search',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _searchQuery.isEmpty
                            ? 'Add some stock to start transferring'
                            : 'Try adjusting your search terms',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                itemCount: filteredBatches.length,
                itemBuilder: (context, index) {
                  final batch = filteredBatches[index];
                  return BatchCardWidget(
                    batch: batch,
                    onTap: () => _selectBatchForTransfer(batch),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error loading stock: $error'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.invalidate(stockBatchesProvider),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTrackTransfersTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 8, // Mock data
      itemBuilder: (context, index) {
        final isCompleted = index < 5;
        final isPending = !isCompleted && index < 7;
        
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isCompleted 
                  ? Colors.green 
                  : isPending 
                      ? Colors.orange 
                      : Colors.red,
              child: Icon(
                isCompleted 
                    ? Icons.check 
                    : isPending 
                        ? Icons.hourglass_empty 
                        : Icons.error,
                color: Colors.white,
              ),
            ),
            title: Text('Transfer #${1001 + index}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Batch: #${2001 + index}'),
                Text('Warehouse A → Warehouse B'),
                Text('Quantity: ${(index + 1) * 25} units'),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isCompleted 
                      ? 'Completed' 
                      : isPending 
                          ? 'In Transit' 
                          : 'Failed',
                  style: TextStyle(
                    color: isCompleted 
                        ? Colors.green 
                        : isPending 
                            ? Colors.orange 
                            : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text('${index + 1}h ago'),
              ],
            ),
            onTap: () => _showTransferDetails(index),
          ),
        );
      },
    );
  }

  void _selectBatchForTransfer(StockBatch batch) {
    // Switch to the first tab and show transfer form with selected batch
    _tabController.animateTo(0);
    
    // Show bottom sheet with transfer form
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: TransferFormWidget(
            selectedBatch: batch,
            fromWarehouse: _selectedFromWarehouse,
            toWarehouse: _selectedToWarehouse,
            onSubmit: (transferData) {
              Navigator.of(context).pop();
              _handleTransferSubmit(transferData);
            },
            onCancel: () => Navigator.of(context).pop(),
          ),
        ),
      ),
    );
  }

  void _handleTransferSubmit(Map<String, dynamic> transferData) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Processing transfer...'),
            ],
          ),
        ),
      );

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Stock transfer initiated successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      // Refresh stock data
      ref.invalidate(stockBatchesProvider);

      // Navigate to track transfers tab
      _tabController.animateTo(2);
    } catch (error) {
      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('Transfer failed: $error')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showTransferDetails(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Transfer #${1001 + index}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Batch:', '#${2001 + index}'),
            _buildDetailRow('From:', 'Warehouse A'),
            _buildDetailRow('To:', 'Warehouse B'),
            _buildDetailRow('Quantity:', '${(index + 1) * 25} units'),
            _buildDetailRow('Status:', index < 5 ? 'Completed' : 'In Transit'),
            _buildDetailRow('Initiated:', '${index + 1} hours ago'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          if (index >= 5)
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Implement cancel transfer logic
              },
              child: const Text('Cancel Transfer'),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showTransferHistory(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Header
              Row(
                children: [
                  const Icon(Icons.history),
                  const SizedBox(width: 8),
                  const Text(
                    'Transfer History',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const Divider(),
              
              // History List
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: 15, // Mock data
                  itemBuilder: (context, index) => Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: index % 3 == 0 ? Colors.green : Colors.blue,
                        child: const Icon(Icons.swap_horiz, color: Colors.white),
                      ),
                      title: Text('Transfer #${1001 + index}'),
                      subtitle: Text('Warehouse A → Warehouse B\n${(index + 1) * 10} units'),
                      trailing: Text('${index + 1}d ago'),
                      isThreeLine: true,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBulkTransferDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bulk Transfer'),
        content: const Text('Bulk transfer functionality will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Start Bulk Transfer'),
          ),
        ],
      ),
    );
  }
}
