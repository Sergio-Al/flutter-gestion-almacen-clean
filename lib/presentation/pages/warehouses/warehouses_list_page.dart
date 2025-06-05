import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/warehouse_providers.dart';
import '../../../core/providers/repository_providers.dart';
import 'warehouse_detail_page.dart';
import 'add_edit_warehouse_page.dart';
import 'widgets/warehouse_card_widget.dart';

class WarehousesListPage extends ConsumerStatefulWidget {
  const WarehousesListPage({super.key});

  @override
  ConsumerState<WarehousesListPage> createState() => _WarehousesListPageState();
}

class _WarehousesListPageState extends ConsumerState<WarehousesListPage> {
  String _searchQuery = '';
  String _selectedFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final warehousesAsync = ref.watch(warehousesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Almacenes'),
        backgroundColor: theme.colorScheme.surfaceContainer,
        actions: [
          IconButton(
            onPressed: () {
              ref.invalidate(warehousesProvider);
            },
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
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
                    Text('Exportar'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings),
                    SizedBox(width: 8),
                    Text('Configuración'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndFilter(),
          Expanded(
            child: warehousesAsync.when(
              data: (warehouses) {
                final filteredWarehouses = _filterWarehouses(warehouses);
                
                if (filteredWarehouses.isEmpty) {
                  return _buildEmptyState();
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(warehousesProvider);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredWarehouses.length,
                    itemBuilder: (context, index) {
                      final warehouse = filteredWarehouses[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: WarehouseCardWidget(
                          warehouse: warehouse,
                          onTap: () => _navigateToDetail(warehouse.id),
                          onEdit: () => _navigateToEdit(warehouse.id),
                          onDelete: () => _showDeleteConfirmation(warehouse.id),
                        ),
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error al cargar almacenes',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[500],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.invalidate(warehousesProvider),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAdd,
        tooltip: 'Agregar Almacén',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search Bar
          TextField(
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Buscar almacenes...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: theme.colorScheme.surface,
            ),
          ),
          const SizedBox(height: 12),
          
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('all', 'Todos'),
                const SizedBox(width: 8),
                _buildFilterChip('high_capacity', 'Alta Capacidad'),
                const SizedBox(width: 8),
                _buildFilterChip('low_stock', 'Stock Bajo'),
                const SizedBox(width: 8),
                _buildFilterChip('full', 'Llenos'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _selectedFilter == value;
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = selected ? value : 'all';
        });
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.warehouse_outlined,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No hay almacenes',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Comienza agregando tu primer almacén',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _navigateToAdd,
            icon: const Icon(Icons.add),
            label: const Text('Agregar Almacén'),
          ),
        ],
      ),
    );
  }

  List _filterWarehouses(List warehouses) {
    var filtered = warehouses.where((warehouse) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!warehouse.name.toLowerCase().contains(query) &&
            !warehouse.location.toLowerCase().contains(query) &&
            !warehouse.managerName.toLowerCase().contains(query)) {
          return false;
        }
      }
      
      return true;
    }).toList();

    // Additional filters would require async data - for now we'll keep it simple
    switch (_selectedFilter) {
      case 'high_capacity':
        filtered = filtered.where((w) => w.capacity > 1000).toList();
        break;
      case 'low_stock':
        // This would require checking current stock vs capacity
        break;
      case 'full':
        // This would require checking if current stock >= capacity
        break;
    }

    return filtered;
  }

  void _handleMenuSelection(String value) {
    switch (value) {
      case 'export':
        _exportWarehouses();
        break;
      case 'settings':
        _showSettings();
        break;
    }
  }

  void _exportWarehouses() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Función de exportación próximamente...'),
      ),
    );
  }

  void _showSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Configuración próximamente...'),
      ),
    );
  }

  void _navigateToDetail(String warehouseId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WarehouseDetailPage(warehouseId: warehouseId),
      ),
    );
  }

  void _navigateToAdd() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddEditWarehousePage(),
      ),
    );
    
    // If we returned with a result, refresh the warehouses list
    if (result != null) {
      ref.invalidate(warehousesProvider);
    }
  }

  void _navigateToEdit(String warehouseId) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditWarehousePage(warehouseId: warehouseId),
      ),
    );
    
    // If we returned with a result, refresh the warehouses list
    if (result != null) {
      ref.invalidate(warehousesProvider);
    }
  }

  void _showDeleteConfirmation(String warehouseId) {
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
              _deleteWarehouse(warehouseId);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _deleteWarehouse(String warehouseId) async {
    try {
      final repository = ref.read(warehouseRepositoryProvider);
      await repository.deleteWarehouse(warehouseId);
      
      // Refresh the warehouses list
      ref.invalidate(warehousesProvider);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Almacén eliminado exitosamente'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar: ${error.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
