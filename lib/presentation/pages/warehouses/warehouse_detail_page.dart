import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/warehouse_providers.dart';
import '../../providers/stock_providers.dart';
import '../../../domain/entities/warehouse.dart';
import 'add_edit_warehouse_page.dart';
import 'widgets/capacity_indicator.dart';
import 'widgets/stock_distribution_chart.dart';
import 'widgets/warehouse_map_canvas.dart';

class WarehouseDetailPage extends ConsumerWidget {
  final String warehouseId;

  const WarehouseDetailPage({
    super.key,
    required this.warehouseId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final warehouseAsync = ref.watch(warehouseByIdProvider(warehouseId));
    final currentStockAsync = ref.watch(warehouseCurrentStockProvider(warehouseId));
    final capacityAsync = ref.watch(warehouseCapacityProvider(warehouseId));
    final stockBatchesAsync = ref.watch(stockBatchesByWarehouseProvider(warehouseId));

    return Scaffold(
      body: warehouseAsync.when(
        data: (warehouse) {
          if (warehouse == null) {
            return _buildNotFoundState(context);
          }
          return _buildContent(context, warehouse, currentStockAsync, capacityAsync, stockBatchesAsync);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorState(context, error.toString()),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToEdit(context),
        tooltip: 'Editar Almacén',
        child: const Icon(Icons.edit),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    Warehouse warehouse,
    AsyncValue<int> currentStockAsync,
    AsyncValue<int> capacityAsync,
    AsyncValue<List> stockBatchesAsync,
  ) {
    final theme = Theme.of(context);

    return CustomScrollView(
      slivers: [
        // App Bar
        SliverAppBar(
          expandedHeight: 200,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              warehouse.name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primary.withOpacity(0.8),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: 20,
                    bottom: 20,
                    child: Icon(
                      Icons.warehouse,
                      size: 80,
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            IconButton(
              onPressed: () => _showMoreOptions(context),
              icon: const Icon(Icons.more_vert),
            ),
          ],
        ),

        // Content
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Basic Info Card
                _buildInfoCard(context, warehouse),
                const SizedBox(height: 16),

                // Capacity Indicator
                capacityAsync.when(
                  data: (capacity) => currentStockAsync.when(
                    data: (currentStock) => CapacityIndicator(
                      currentStock: currentStock,
                      capacity: capacity,
                    ),
                    loading: () => const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    ),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                  loading: () => const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
                  error: (_, __) => const SizedBox.shrink(),
                ),
                const SizedBox(height: 16),

                // Stock Distribution Chart
                stockBatchesAsync.when(
                  data: (batches) => StockDistributionChart(
                    warehouseId: warehouseId,
                  ),
                  loading: () => const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
                  error: (_, __) => const SizedBox.shrink(),
                ),
                const SizedBox(height: 16),

                // Warehouse Map/Layout
                WarehouseMapCanvas(
                  warehouseId: warehouseId,
                ),
                const SizedBox(height: 16),

                // Quick Actions
                _buildQuickActions(context, warehouse),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(BuildContext context, Warehouse warehouse) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.blue[600],
                ),
                const SizedBox(width: 8),
                Text(
                  'Información General',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(context, Icons.location_on, 'Ubicación', warehouse.location),
            const SizedBox(height: 12),
            _buildInfoRow(context, Icons.inventory_2, 'Capacidad', '${warehouse.capacity} unidades'),
            const SizedBox(height: 12),
            _buildInfoRow(context, Icons.person, 'Responsable', warehouse.managerName),
            const SizedBox(height: 12),
            _buildInfoRow(context, Icons.contact_phone, 'Contacto', warehouse.contactInfo),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context, Warehouse warehouse) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.flash_on,
                  color: Colors.orange[600],
                ),
                const SizedBox(width: 8),
                Text(
                  'Acciones Rápidas',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildActionChip(
                  context,
                  'Ver Stock',
                  Icons.inventory,
                  Colors.blue,
                  () => _navigateToStock(context),
                ),
                _buildActionChip(
                  context,
                  'Transferir',
                  Icons.swap_horiz,
                  Colors.green,
                  () => _navigateToTransfer(context),
                ),
                _buildActionChip(
                  context,
                  'Ajustar',
                  Icons.tune,
                  Colors.orange,
                  () => _navigateToAdjustment(context),
                ),
                _buildActionChip(
                  context,
                  'Reportes',
                  Icons.analytics,
                  Colors.purple,
                  () => _showReports(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionChip(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return ActionChip(
      avatar: Icon(icon, size: 18, color: color),
      label: Text(label),
      onPressed: onTap,
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide(color: color.withOpacity(0.3)),
    );
  }

  Widget _buildNotFoundState(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Almacén no encontrado')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Almacén no encontrado',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'El almacén solicitado no existe o ha sido eliminado',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Volver'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Error al cargar almacén',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Volver'),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToEdit(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditWarehousePage(warehouseId: warehouseId),
      ),
    );
  }

  void _navigateToStock(BuildContext context) {
    // Navigate to stock view filtered by this warehouse
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navegando a vista de stock...')),
    );
  }

  void _navigateToTransfer(BuildContext context) {
    // Navigate to stock transfer with this warehouse pre-selected
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navegando a transferencia...')),
    );
  }

  void _navigateToAdjustment(BuildContext context) {
    // Navigate to stock adjustment with this warehouse pre-selected
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navegando a ajuste de stock...')),
    );
  }

  void _showReports(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reportes próximamente...')),
    );
  }

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Editar'),
            onTap: () {
              Navigator.pop(context);
              _navigateToEdit(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('Compartir'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Compartir próximamente...')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Eliminar', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              _showDeleteConfirmation(context);
            },
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text(
          '¿Está seguro de que desea eliminar este almacén? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Go back to list
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Almacén eliminado'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
