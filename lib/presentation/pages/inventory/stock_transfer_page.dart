import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/stock_providers.dart';
import '../../providers/warehouse_providers.dart';
import '../../providers/stock_transfer_providers.dart';
import '../../../domain/entities/stock_batch.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/entities/warehouse.dart';
import '../../../domain/entities/stock_transfer.dart';
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
        title: const Text('Transferencia de Stock'),
        backgroundColor: theme.colorScheme.surfaceVariant,
        actions: [
          IconButton(
            onPressed: () => _showTransferHistory(context),
            icon: const Icon(Icons.history),
            tooltip: 'Historial de Transferencias',
          ),
          IconButton(
            onPressed: () => _showBulkTransferDialog(context),
            icon: const Icon(Icons.multiple_stop),
            tooltip: 'Transferencia Masiva',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.swap_horiz), text: 'Nueva Transferencia'),
            Tab(icon: Icon(Icons.inventory), text: 'Seleccionar Stock'),
            Tab(icon: Icon(Icons.track_changes), text: 'Seguir Transferencias'),
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
      data:
          (warehouses) => Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.surfaceVariant.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Seleccionar Almacenes',
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
                          Row(
                            children: [
                              Icon(
                                Icons.warehouse,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Almacén Origen',
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),
                          DropdownButtonFormField<Warehouse>(
                            value: _selectedFromWarehouse,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Origen', // Hint text is already short
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 8,
                              ), // Adjusted padding
                            ),
                            onChanged: (warehouse) {
                              setState(() {
                                _selectedFromWarehouse = warehouse;
                                if (_selectedToWarehouse?.id == warehouse?.id) {
                                  _selectedToWarehouse = null;
                                }
                              });
                            },
                            items:
                                warehouses.map((warehouse) {
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
                          Row(
                          children: [
                            Icon(
                            Icons.warehouse_outlined,
                            color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                            'Almacén Destino',
                            style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ],
                          ),

                          const SizedBox(height: 8),
                          DropdownButtonFormField<Warehouse>(
                          value: _selectedToWarehouse,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'destino',
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 8,
                            ), // Adjusted padding
                          ),
                          onChanged: (warehouse) {
                            setState(() {
                            _selectedToWarehouse = warehouse;
                            });
                          },
                          items:
                            warehouses
                              .where(
                                (w) => w.id != _selectedFromWarehouse?.id,
                              )
                              .map((warehouse) {
                                return DropdownMenuItem(
                                value: warehouse,
                                child: Text(warehouse.name),
                                );
                              })
                              .toList(),
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
      error:
          (error, stack) =>
              Center(child: Text('Error cargando almacenes: $error')),
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
                  hintText: 'Buscar lotes de stock...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon:
                      _searchQuery.isNotEmpty
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
                    label: const Text('Stock Alto'),
                    selected: false,
                    onSelected: (selected) {
                      // Implement filter logic
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Stock Bajo'),
                    selected: false,
                    onSelected: (selected) {
                      // Implement filter logic
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Próximo a Vencer'),
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
              final filteredBatches =
                  batches.where((batch) {
                    if (_searchQuery.isEmpty) return true;
                    return batch.batchNumber.toLowerCase().contains(
                      _searchQuery,
                    );
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
                            ? 'No se encontraron lotes de stock'
                            : 'No hay lotes que coincidan con su búsqueda',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _searchQuery.isEmpty
                            ? 'Agregue stock para comenzar a transferir'
                            : 'Intente ajustar sus términos de búsqueda',
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
            error:
                (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Error cargando stock: $error'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref.invalidate(stockBatchesProvider),
                        child: const Text('Reintentar'),
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
    final transfersAsync = ref.watch(stockTransfersProvider);
    
    return transfersAsync.when(
      data: (transfers) {
        if (transfers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.swap_horiz,
                  size: 64,
                  color: Colors.grey.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                const Text(
                  'No hay transferencias registradas',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Las transferencias que realices aparecerán aquí',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: transfers.length,
          itemBuilder: (context, index) {
            final transfer = transfers[index];
            final isCompleted = transfer.status == 'completed';
            final isPending = transfer.status == 'pending';
            
            // Format the timestamp for display
            final timestamp = DateTime.parse(transfer.timestamp);
            final now = DateTime.now();
            final difference = now.difference(timestamp);
            
            String timeAgo;
            if (difference.inDays > 0) {
              timeAgo = 'Hace ${difference.inDays}d';
            } else if (difference.inHours > 0) {
              timeAgo = 'Hace ${difference.inHours}h';
            } else if (difference.inMinutes > 0) {
              timeAgo = 'Hace ${difference.inMinutes}m';
            } else {
              timeAgo = 'Hace un momento';
            }

            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      isCompleted
                          ? Colors.green
                          : isPending
                              ? Colors.orange
                              : Colors.red,
                  child: Icon(
                    isCompleted
                        ? Icons.check
                        : isPending
                            ? Icons.hourglass_bottom
                            : Icons.error,
                    color: Colors.white,
                  ),
                ),
                title: Text('Transferencia ${transfer.id.split('-')[1]}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (transfer.batchId != null) 
                      Text('Lote: ${transfer.batchId!.split('-')[1]}'),
                    Text('Cantidad: ${transfer.quantity} unidades'),
                    Text('Razón: ${transfer.reason}'),
                  ],
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isCompleted
                          ? 'Completada'
                          : isPending
                              ? 'Pendiente'
                              : 'Cancelada',
                      style: TextStyle(
                        color: isCompleted
                            ? Colors.green
                            : isPending
                                ? Colors.orange
                                : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(timeAgo),
                  ],
                ),
                onTap: () => _showTransferDetails(transfer),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red.withOpacity(0.8),
            ),
            const SizedBox(height: 16),
            const Text(
              'Error al cargar transferencias',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: const TextStyle(
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
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
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.9,
            maxChildSize: 0.95,
            minChildSize: 0.5,
            expand: false,
            builder:
                (context, scrollController) => SingleChildScrollView(
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
        builder:
            (context) => const AlertDialog(
              content: Row(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 16),
                  Text('Procesando transferencia...'),
                ],
              ),
            ),
      );

      // Use the create transfer use case through the provider
      final createTransferNotifier = ref.read(createTransferNotifierProvider.notifier);
      final result = await createTransferNotifier.createTransfer(transferData);
      
      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      result.when(
        data: (transfer) {
          if (transfer != null) {
            // Show success message
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.white),
                      SizedBox(width: 8),
                      Text('¡Transferencia de stock iniciada exitosamente!'),
                    ],
                  ),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }

            // Refresh all state data
            ref.invalidate(stockBatchesProvider);
            ref.invalidate(stockTransfersProvider);
            ref.invalidate(stockTransfersByStatusProvider('pending'));

            // Navigate to track transfers tab
            _tabController.animateTo(2);
          }
        },
        error: (error, stackTrace) {
          // Show error message
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(child: Text('Transferencia fallida: $error')),
                  ],
                ),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        loading: () {
          // This should not happen as we're using our own loading dialog
        },
      );
      
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
                Expanded(child: Text('Transferencia fallida: $error')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showTransferDetails(StockTransfer transfer) {
    // Format timestamp for display
    final timestamp = DateTime.parse(transfer.timestamp);
    final formattedDate = '${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Transferencia ${transfer.id.split('-')[1]}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (transfer.batchId != null)
                  _buildDetailRow('Lote:', transfer.batchId!.split('-')[1]),
                _buildDetailRow('Producto ID:', transfer.productId),
                _buildDetailRow('Desde Almacén:', transfer.fromWarehouseId),
                _buildDetailRow('Hacia Almacén:', transfer.toWarehouseId),
                _buildDetailRow('Cantidad:', '${transfer.quantity} unidades'),
                _buildDetailRow('Estado:', 
                  transfer.status == 'completed' 
                    ? 'Completada'
                    : transfer.status == 'pending'
                      ? 'Pendiente' 
                      : 'Cancelada'
                ),
                _buildDetailRow('Razón:', transfer.reason),
                if (transfer.notes != null)
                  _buildDetailRow('Notas:', transfer.notes!),
                _buildDetailRow('Fecha:', formattedDate),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cerrar'),
              ),
              if (transfer.status == 'pending') ...[
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _completeTransfer(transfer.id);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text('Completar Transferencia'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _cancelTransfer(transfer.id);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: const Text('Cancelar Transferencia'),
                ),
              ],
            ],
          ),
    );
  }

  void _completeTransfer(String transferId) async {
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
              Text('Completando transferencia...'),
            ],
          ),
        ),
      );

      // Call the update transfer status use case
      final updateTransferStatus = ref.read(updateTransferStatusUseCaseProvider);
      final result = await updateTransferStatus(transferId, 'completed');
      
      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      result.fold(
        (failure) {
          // Show error message
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(child: Text('Error al completar transferencia: ${failure.message}')),
                  ],
                ),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }, 
        (transfer) {
          // Show success message
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 8),
                    Text('¡Transferencia completada exitosamente!'),
                  ],
                ),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }

          // Refresh data
          ref.invalidate(stockBatchesProvider);
          ref.invalidate(stockTransfersProvider);
        }
      );
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
                Expanded(child: Text('Error al completar transferencia: $error')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _cancelTransfer(String transferId) async {
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
              Text('Cancelando transferencia...'),
            ],
          ),
        ),
      );

      // Call the cancel transfer use case
      final cancelTransfer = ref.read(cancelTransferUseCaseProvider);
      final result = await cancelTransfer(transferId);
      
      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      result.fold(
        (failure) {
          // Show error message
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(child: Text('Error al cancelar transferencia: ${failure.message}')),
                  ],
                ),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }, 
        (_) {
          // Show success message
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 8),
                    Text('¡Transferencia cancelada exitosamente!'),
                  ],
                ),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }

          // Refresh data
          ref.invalidate(stockBatchesProvider);
          ref.invalidate(stockTransfersProvider);
        }
      );
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
                Expanded(child: Text('Error al cancelar transferencia: $error')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
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
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.7,
            maxChildSize: 0.9,
            minChildSize: 0.5,
            expand: false,
            builder:
                (context, scrollController) => Container(
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
                            'Historial de Transferencias',
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
                          itemBuilder:
                              (context, index) => Card(
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor:
                                        index % 3 == 0
                                            ? Colors.green
                                            : Colors.blue,
                                    child: const Icon(
                                      Icons.swap_horiz,
                                      color: Colors.white,
                                    ),
                                  ),
                                  title: Text('Transferencia #${1001 + index}'),
                                  subtitle: Text(
                                    'Almacén A → Almacén B\n${(index + 1) * 10} unidades',
                                  ),
                                  trailing: Text('Hace ${index + 1}d'),
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
      builder:
          (context) => AlertDialog(
            title: const Text('Transferencia Masiva'),
            content: const Text(
              'La funcionalidad de transferencia masiva se implementará aquí.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Iniciar Transferencia Masiva'),
              ),
            ],
          ),
    );
  }
}
