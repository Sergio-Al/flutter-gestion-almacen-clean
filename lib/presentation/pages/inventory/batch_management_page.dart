import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/stock_providers.dart';
import '../../providers/warehouse_providers.dart';
import '../../../domain/entities/stock_batch.dart';
import 'widgets/batch_card_widget.dart';
import 'widgets/batch_form_widget.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/providers/repository_providers.dart';

enum BatchFilter { all, active, lowStock, nearExpiry, expired }

enum BatchSort { batchNumber, expirationDate, quantity, recentlyAdded }

class BatchManagementPage extends ConsumerStatefulWidget {
  final String? warehouseId; // ID del almacén para filtrar (opcional)
  
  const BatchManagementPage({
    Key? key, 
    this.warehouseId,
  }) : super(key: key);

  @override
  ConsumerState<BatchManagementPage> createState() =>
      _BatchManagementPageState();
}

class _BatchManagementPageState extends ConsumerState<BatchManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  BatchFilter _selectedFilter = BatchFilter.all;
  BatchSort _selectedSort = BatchSort.recentlyAdded;
  bool _isGridView = false;
  String? _currentWarehouseId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Inicializar el filtro de almacén si se proporciona un ID
    if (widget.warehouseId != null) {
      _currentWarehouseId = widget.warehouseId;
    }
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
        title: _currentWarehouseId != null 
            ? Consumer(
                builder: (context, ref, child) {
                  final warehouseAsync = ref.watch(warehouseByIdProvider(_currentWarehouseId!));
                  return Row(
                    children: [
                      const Text('Lotes en Almacén'),
                      const SizedBox(width: 8),
                      warehouseAsync.when(
                        data: (warehouse) {
                          if (warehouse != null) {
                            return Chip(
                              label: Text(warehouse.name),
                              backgroundColor: theme.colorScheme.primaryContainer,
                              labelStyle: TextStyle(color: theme.colorScheme.onPrimaryContainer),
                            );
                          }
                          return const SizedBox();
                        },
                        loading: () => const SizedBox(
                          width: 20, 
                          height: 20, 
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        error: (_, __) => const SizedBox(),
                      ),
                    ],
                  );
                },
              )
            : const Text('Gestión de Lotes'),
        backgroundColor: theme.colorScheme.surfaceVariant,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
            icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
            tooltip: _isGridView ? 'Lista' : 'Cuadros',
          ),
          IconButton(
            onPressed: () => _showFilterDialog(context),
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filtrar y Ordenar',
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuSelection,
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'export',
                    child: Row(
                      children: [
                        Icon(Icons.download),
                        SizedBox(width: 8),
                        Text('Exportar lotes'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'bulk_actions',
                    child: Row(
                      children: [
                        Icon(Icons.checklist),
                        SizedBox(width: 8),
                        Text('Acciones masivas'),
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
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.inventory), text: 'Todos los Lotes'),
            Tab(icon: Icon(Icons.analytics), text: 'Analíticas'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // All Batches Tab
          _buildBatchesTab(),

          // Analytics Tab
          _buildAnalyticsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateBatchDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Lote'),
      ),
    );
  }

  Widget _buildBatchesTab() {
    // Usar el provider filtrado por almacén si _currentWarehouseId no es nulo
    final stockBatchesAsync = _currentWarehouseId != null 
        ? ref.watch(stockBatchesByWarehouseProvider(_currentWarehouseId!))
        : ref.watch(stockBatchesProvider);

    return Column(
      children: [
        // Search and Quick Filters
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Search Bar
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Buscar lotes por numero o producto...',
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

              const SizedBox(height: 12),

              // Quick Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children:
                      BatchFilter.values.map((filter) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(_getFilterLabel(filter)),
                            selected: _selectedFilter == filter,
                            onSelected: (selected) {
                              setState(() {
                                _selectedFilter = filter;
                              });
                            },
                          ),
                        );
                      }).toList(),
                ),
              ),
            ],
          ),
        ),

        // Batch Count Summary
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.surfaceVariant.withOpacity(0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: stockBatchesAsync.when(
            data: (batches) {
              final filteredBatches = _filterAndSortBatches(batches);
              return Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${filteredBatches.length} lotes encontrados',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _getFilterLabel(_selectedFilter),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              );
            },
            loading: () => const SizedBox(),
            error: (error, stack) => const SizedBox(),
          ),
        ),

        const SizedBox(height: 8),

        // Batch List/Grid
        Expanded(
          child: stockBatchesAsync.when(
            data: (batches) {
              final filteredBatches = _filterAndSortBatches(batches);

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
                        _searchQuery.isEmpty &&
                                _selectedFilter == BatchFilter.all
                            ? 'No se encontraron lotes'
                            : 'No hay lotes que coincidan con tu búsqueda',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _searchQuery.isEmpty &&
                                _selectedFilter == BatchFilter.all
                            ? 'Crea tu primer lote para comenzar'
                            : 'Intenta ajustar tu búsqueda o filtros',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => _showCreateBatchDialog(context),
                        icon: const Icon(Icons.add),
                        label: const Text('Crear Lote'),
                      ),
                    ],
                  ),
                );
              }

              if (_isGridView) {
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: filteredBatches.length,
                  itemBuilder: (context, index) {
                    final batch = filteredBatches[index];
                    return _buildBatchGridItem(batch);
                  },
                );
              } else {
                return ListView.builder(
                  itemCount: filteredBatches.length,
                  itemBuilder: (context, index) {
                    final batch = filteredBatches[index];
                    return BatchCardWidget(
                      batch: batch,
                      onTap: () => _showBatchDetails(batch),
                      onEdit: () => _showEditBatchDialog(batch),
                      onDelete: () => _showDeleteBatchDialog(batch),
                    );
                  },
                );
              }
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error:
                (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Error cargando lotes: $error'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          if (_currentWarehouseId != null) {
                            ref.invalidate(stockBatchesByWarehouseProvider(_currentWarehouseId!));
                          } else {
                            ref.invalidate(stockBatchesProvider);
                          }
                        },
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

  Widget _buildBatchGridItem(StockBatch batch) {
    final theme = Theme.of(context);
    final isExpired = batch.expiryDate?.isBefore(DateTime.now()) ?? false;
    final isNearExpiry =
        batch.expiryDate != null &&
        batch.expiryDate!.isAfter(DateTime.now()) &&
        batch.expiryDate!.isBefore(
          DateTime.now().add(const Duration(days: 30)),
        );

    Color statusColor = Colors.green;
    if (isExpired)
      statusColor = Colors.red;
    else if (isNearExpiry)
      statusColor = Colors.orange;
    else if (batch.quantity <= 0)
      statusColor = Colors.grey;

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => _showBatchDetails(batch),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with status
              Row(
                children: [
                  Expanded(
                    child: Text(
                      batch.batchNumber,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Quantity
              Row(
                children: [
                  const Icon(Icons.inventory, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${batch.quantity} unidades',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),

              // Cost - using placeholder since StockBatch doesn't have costPerUnit
              Row(
                children: [
                  const Icon(Icons.attach_money, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '\$0.00', // Placeholder - will be calculated from product cost
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),

              const Spacer(),

              // Expiration date
              if (batch.expiryDate != null) ...[
                Row(
                  children: [
                    Icon(Icons.event, size: 16, color: statusColor),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        DateFormatter.formatDate(batch.expiryDate!),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: statusColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    // Usar el provider filtrado por almacén si _currentWarehouseId no es nulo
    final stockBatchesAsync = _currentWarehouseId != null 
        ? ref.watch(stockBatchesByWarehouseProvider(_currentWarehouseId!))
        : ref.watch(stockBatchesProvider);

    return stockBatchesAsync.when(
      data:
          (batches) => SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary Cards
                _buildAnalyticsSummary(batches),
                const SizedBox(height: 24),

                // Charts and Insights
                Text(
                  'Insights',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // Expiration Timeline
                _buildExpirationTimeline(batches),
                const SizedBox(height: 24),

                // Stock Distribution
                _buildStockDistribution(batches),
                const SizedBox(height: 24),

                // Recent Activity
                _buildRecentActivity(),
              ],
            ),
          ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }

  Widget _buildAnalyticsSummary(List<dynamic> batches) {
    final totalBatches = batches.length;
    final activeBatches = batches.where((b) => (b.quantity ?? 0) > 0).length;
    final expiredBatches =
        batches.where((b) {
          final expiry = b.expiryDate;
          return expiry != null && expiry.isBefore(DateTime.now());
        }).length;
    final nearExpiryBatches =
        batches.where((b) {
          final expiry = b.expiryDate;
          return expiry != null &&
              expiry.isAfter(DateTime.now()) &&
              expiry.isBefore(DateTime.now().add(const Duration(days: 30)));
        }).length;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildAnalyticsCard(
          'Total de Lotes',
          totalBatches.toString(),
          Icons.inventory,
          Colors.blue,
        ),
        _buildAnalyticsCard(
          'Lotes Activos',
          activeBatches.toString(),
          Icons.check_circle,
          Colors.green,
        ),
        _buildAnalyticsCard(
          'Lotes Expirados',
          expiredBatches.toString(),
          Icons.error,
          Colors.red,
        ),
        _buildAnalyticsCard(
          'Lotes Cerca de Expirar',
          nearExpiryBatches.toString(),
          Icons.warning,
          Colors.orange,
        ),
      ],
    );
  }

  Widget _buildAnalyticsCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpirationTimeline(List<dynamic> batches) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Linea de Tiempo de Expiración',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              alignment: Alignment.center,
              child: const Text(
                'Se implementará aquí la línea de tiempo de expiración',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockDistribution(List<dynamic> batches) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Distribución de Stock',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              alignment: Alignment.center,
              child: const Text(
                'Se implementará aquí la distribución de stock',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Actividad Reciente',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...List.generate(
              5,
              (index) => ListTile(
                leading: CircleAvatar(
                  backgroundColor: index % 2 == 0 ? Colors.green : Colors.blue,
                  child: Icon(
                    index % 2 == 0 ? Icons.add : Icons.edit,
                    color: Colors.white,
                  ),
                ),
                title: Text(
                  'Lote #${1001 + index} ${index % 2 == 0 ? 'creado' : 'ajustado'}',
                ),
                subtitle: Text('hace ${index + 1} horas'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<dynamic> _filterAndSortBatches(List<dynamic> batches) {
    var filtered =
        batches.where((batch) {
          // Search filter
          if (_searchQuery.isNotEmpty) {
            final searchLower = _searchQuery.toLowerCase();
            if (!batch.batchNumber.toLowerCase().contains(searchLower)) {
              return false;
            }
          }

          // Status filter
          switch (_selectedFilter) {
            case BatchFilter.all:
              return true;
            case BatchFilter.active:
              return (batch.quantity ?? 0) > 0;
            case BatchFilter.lowStock:
              return (batch.quantity ?? 0) < 10 && (batch.quantity ?? 0) > 0;
            case BatchFilter.nearExpiry:
              final expiry = batch.expiryDate;
              return expiry != null &&
                  expiry.isAfter(DateTime.now()) &&
                  expiry.isBefore(DateTime.now().add(const Duration(days: 30)));
            case BatchFilter.expired:
              final expiry = batch.expiryDate;
              return expiry != null && expiry.isBefore(DateTime.now());
          }
        }).toList();

    // Sort
    switch (_selectedSort) {
      case BatchSort.batchNumber:
        filtered.sort((a, b) => a.batchNumber.compareTo(b.batchNumber));
        break;
      case BatchSort.expirationDate:
        filtered.sort((a, b) {
          final aDate = a.expiryDate;
          final bDate = b.expiryDate;
          if (aDate == null && bDate == null) return 0;
          if (aDate == null) return 1;
          if (bDate == null) return -1;
          return aDate.compareTo(bDate);
        });
        break;
      case BatchSort.quantity:
        filtered.sort((a, b) => (b.quantity ?? 0).compareTo(a.quantity ?? 0));
        break;
      case BatchSort.recentlyAdded:
        // Assuming newer batches have higher IDs
        filtered.sort((a, b) => (b.id ?? '').compareTo(a.id ?? ''));
        break;
    }

    return filtered;
  }

  String _getFilterLabel(BatchFilter filter) {
    switch (filter) {
      case BatchFilter.all:
        return 'Todo';
      case BatchFilter.active:
        return 'Activos';
      case BatchFilter.lowStock:
        return 'Stock Bajo';
      case BatchFilter.nearExpiry:
        return 'Cerca a Expirar';
      case BatchFilter.expired:
        return 'Expirados';
    }
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Filtrar y Ordenar Lotes'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Filter section
                const Text(
                  'Filtrado por:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                DropdownButton<BatchFilter>(
                  value: _selectedFilter,
                  isExpanded: true,
                  onChanged: (filter) {
                    setState(() {
                      _selectedFilter = filter!;
                    });
                    Navigator.of(context).pop();
                  },
                  items:
                      BatchFilter.values
                          .map(
                            (filter) => DropdownMenuItem(
                              value: filter,
                              child: Text(_getFilterLabel(filter)),
                            ),
                          )
                          .toList(),
                ),

                const SizedBox(height: 16),

                // Sort section
                const Text(
                  'Ordenado por:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                DropdownButton<BatchSort>(
                  value: _selectedSort,
                  isExpanded: true,
                  onChanged: (sort) {
                    setState(() {
                      _selectedSort = sort!;
                    });
                    Navigator.of(context).pop();
                  },
                  items:
                      BatchSort.values
                          .map(
                            (sort) => DropdownMenuItem(
                              value: sort,
                              child: Text(
                                sort.name
                                    .replaceAll('_', ' ')
                                    .split(' ')
                                    .map(
                                      (word) =>
                                          word.isEmpty
                                              ? word
                                              : word[0].toUpperCase() +
                                                  word.substring(1),
                                    )
                                    .join(' '),
                              ),
                            ),
                          )
                          .toList(),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cerrar'),
              ),
            ],
          ),
    );
  }

  void _showBatchDetails(StockBatch batch) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Detalle del Lote',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 16),

                  _buildDetailRow('Numero de Lote:', batch.batchNumber),
                  _buildDetailRow('Cantidad:', '${batch.quantity} unidades'),
                  _buildDetailRow(
                    'Fecha Entrante :',
                    DateFormatter.formatDate(batch.receivedDate),
                  ),

                  if (batch.expiryDate != null)
                    _buildDetailRow(
                      'Fecha de expiracion:',
                      DateFormatter.formatDate(batch.expiryDate!),
                    ),

                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            _showEditBatchDialog(batch);
                          },
                          child: const Text('Editar'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            // Navigate to adjustment page with this batch
                          },
                          child: const Text('Ajustar Stock'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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

  void _showCreateBatchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            child: Container(
              padding: const EdgeInsets.all(24),
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.add_circle,
                        color: Theme.of(context).primaryColor,
                        size: 28,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Crear Nuevo Lote',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                        tooltip: 'Cerrar',
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 8),
                  Flexible(
                    child: BatchFormWidget(
                      onSubmit: (batch) async {
                        try {
                          // Intentamos crear el lote
                          final repository = ref.read(stockRepositoryProvider);
                          await repository.createStockBatch(batch);
                          
                          // Refrescamos la lista de lotes
                          if (_currentWarehouseId != null) {
                            ref.invalidate(stockBatchesByWarehouseProvider(_currentWarehouseId!));
                          }
                          ref.invalidate(stockBatchesProvider);
                          
                          if (mounted) {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Lote creado exitosamente'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } catch (e) {
                          // Manejamos errores
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error al crear lote: ${e.toString()}'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      onCancel: () => Navigator.of(context).pop(),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  void _showEditBatchDialog(StockBatch batch) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            child: Container(
              padding: const EdgeInsets.all(24),
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.edit,
                        color: Theme.of(context).primaryColor,
                        size: 28,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Editar Lote ${batch.batchNumber}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                        tooltip: 'Cerrar',
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 8),
                  Flexible(
                    child: BatchFormWidget(
                      batch: batch,
                      onSubmit: (updatedBatch) async {
                        try {
                          // Intentamos actualizar el lote
                          final repository = ref.read(stockRepositoryProvider);
                          await repository.updateStockBatch(updatedBatch);
                          
                          // Refrescamos la lista de lotes
                          if (_currentWarehouseId != null) {
                            ref.invalidate(stockBatchesByWarehouseProvider(_currentWarehouseId!));
                          }
                          ref.invalidate(stockBatchesProvider);
                          
                          if (mounted) {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Lote actualizado exitosamente'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } catch (e) {
                          // Manejamos errores
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error al actualizar lote: ${e.toString()}'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      onCancel: () => Navigator.of(context).pop(),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  void _showDeleteBatchDialog(StockBatch batch) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Eliminar lote'),
            content: Text(
              '¿Estás seguro de eliminar el lote ${batch.batchNumber}? Esta acción no se puede deshacer.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  
                  try {
                    // Intentamos eliminar el lote
                    final repository = ref.read(stockRepositoryProvider);
                    await repository.deleteStockBatch(batch.id);
                    
                    // Refrescamos la lista de lotes
                    if (_currentWarehouseId != null) {
                      ref.invalidate(stockBatchesByWarehouseProvider(_currentWarehouseId!));
                    }
                    ref.invalidate(stockBatchesProvider);
                    
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Lote eliminado exitosamente'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    // Manejamos errores
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error al eliminar lote: ${e.toString()}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Eliminar'),
              ),
            ],
          ),
    );
  }

  void _handleMenuSelection(String value) {
    switch (value) {
      case 'export':
        _showExportDialog();
        break;
      case 'bulk_actions':
        _showBulkActionsDialog();
        break;
      case 'settings':
        _showSettingsDialog();
        break;
    }
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Exportar Lotes'),
            content: const Text(
              'Funcionalidad de exportacion sera implementada aqui.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Exportar'),
              ),
            ],
          ),
    );
  }

  void _showBulkActionsDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Acciones Masivas'),
            content: const Text(
              'Funcionalidad de acciones masivas sera implementada aqui.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
            ],
          ),
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Ajustes'),
            content: const Text('Opciones de configuracion sera implementada aqui.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cerrar'),
              ),
            ],
          ),
    );
  }
}
