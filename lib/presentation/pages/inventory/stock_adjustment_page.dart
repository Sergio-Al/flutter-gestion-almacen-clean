import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gestion_almacen_stock/presentation/providers/stock_providers.dart';
import '../../../domain/entities/stock_batch.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/entities/warehouse.dart';
import 'widgets/adjustment_form_widget.dart';
import 'widgets/batch_card_widget.dart';
import '../../../presentation/providers/stock_adjustment_provider.dart';
import '../../../presentation/providers/warehouse_providers.dart'; // Added warehouse providers import

class StockAdjustmentPage extends ConsumerStatefulWidget {
  final StockBatch? selectedBatch;
  final Product? selectedProduct;
  final Warehouse? selectedWarehouse;

  const StockAdjustmentPage({
    Key? key,
    this.selectedBatch,
    this.selectedProduct,
    this.selectedWarehouse,
  }) : super(key: key);

  @override
  ConsumerState<StockAdjustmentPage> createState() => _StockAdjustmentPageState();
}

class _StockAdjustmentPageState extends ConsumerState<StockAdjustmentPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
        title: const Text('Ajuste de Inventario'),
        backgroundColor: theme.colorScheme.surfaceVariant,
        actions: [
          IconButton(
            onPressed: () => _showAdjustmentHistory(context),
            icon: const Icon(Icons.history),
            tooltip: 'Historial de Ajustes',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.tune),
              text: 'Nuevo Ajuste',
            ),
            Tab(
              icon: Icon(Icons.inventory),
              text: 'Seleccionar Lote',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // New Adjustment Tab
          _buildNewAdjustmentTab(),
          
          // Select Batch Tab
          _buildSelectBatchTab(),
        ],
      ),
    );
  }

  Widget _buildNewAdjustmentTab() {
    return SingleChildScrollView(
      child: AdjustmentFormWidget(
        selectedProduct: widget.selectedProduct,
        selectedWarehouse: widget.selectedWarehouse,
        selectedBatch: widget.selectedBatch,
        onSubmit: _handleAdjustmentSubmit,
        onCancel: () => Navigator.of(context).pop(),
      ),
    );
  }

  Widget _buildSelectBatchTab() {
    final stockBatchesAsync = ref.watch(stockBatchesProvider);

    return Column(
      children: [
        // Search Bar
        Container(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Buscar lotes...',
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
        ),
        
        // Batch List
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
                            ? 'No se han encontrado lotes'
                            : 'No se encontraron lotes que coincidan con "$_searchQuery"',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _searchQuery.isEmpty
                            ? 'Agregue algunos productos para comenzar'
                            : 'Intente con otra búsqueda',
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
                    onTap: () => _selectBatchForAdjustment(batch),
                    onEdit: () => _showEditBatchDialog(batch),
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
                  Text('Error cargando lotes: $error'),
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

  void _selectBatchForAdjustment(StockBatch batch) {
    // Switch to the first tab and show adjustment form with selected batch
    _tabController.animateTo(0);
    
    // Show bottom sheet with adjustment form
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
          child: AdjustmentFormWidget(
            selectedBatch: batch,
            onSubmit: (adjustmentData) {
              Navigator.of(context).pop();
              _handleAdjustmentSubmit(adjustmentData);
            },
            onCancel: () => Navigator.of(context).pop(),
          ),
        ),
      ),
    );
  }

  void _handleAdjustmentSubmit(Map<String, dynamic> adjustmentData) async {
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
              Text('Procesando ajuste...'),
            ],
          ),
        ),
      );

      // Usar el controlador de ajuste de stock
      final stockAdjustmentController = ref.read(stockAdjustmentControllerProvider);
      final success = await stockAdjustmentController.processStockAdjustment(adjustmentData);
      
      // Refresh warehouse-related providers directly to ensure updates
      final warehouseId = adjustmentData['warehouseId'] as String?;
      if (success && warehouseId != null) {
        // Forzar actualización completa de todos los providers relacionados con almacenes
        ref.invalidate(warehousesProvider);
        ref.invalidate(warehouseByIdProvider(warehouseId));
        ref.invalidate(warehouseCurrentStockProvider(warehouseId));
        ref.invalidate(warehouseCapacityProvider(warehouseId));
        ref.invalidate(stockBatchesByWarehouseProvider(warehouseId));
      }

      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      // Show success or error message
      if (mounted) {
        if (success) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Ajuste realizado con éxito'),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
          
          // Navigate back or stay on page based on context
          if (widget.selectedBatch != null && mounted) {
            Navigator.of(context).pop(true); // Return true to indicate successful adjustment
          } else if (widget.selectedWarehouse != null && mounted) {
            Navigator.of(context).pop(true); // Return true when coming from warehouse detail
          }
        } else {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(child: Text('Error al procesar el ajuste')),
                ],
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
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
                Expanded(child: Text('Error: $error')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showEditBatchDialog(StockBatch batch) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Lote'),
        content: Text('Fucionalidad para editar lote ${batch.batchNumber} sera implementada aqui.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showAdjustmentHistory(BuildContext context) {
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
                    'Historial de Ajustes',
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
                  itemCount: 10, // Mock data
                  itemBuilder: (context, index) => Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: index % 2 == 0 ? Colors.green : Colors.orange,
                        child: Icon(
                          index % 2 == 0 ? Icons.add : Icons.remove,
                          color: Colors.white,
                        ),
                      ),
                      title: Text('Lote #${index + 1001}'),
                      subtitle: Text('${index % 2 == 0 ? 'Incrementado' : 'Reducido'} por ${(index + 1) * 5} unidades'),
                      trailing: Text('hace ${index + 1}h '),
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
}
