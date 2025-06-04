import 'package:flutter/material.dart';

class ReportFilterWidget extends StatefulWidget {
  final ReportFilterOptions options;
  final Function(ReportFilterOptions) onFilterChanged;
  final bool showDateRange;
  final bool showCategories;
  final bool showWarehouses;
  final bool showProducts;
  final bool showCustomers;

  const ReportFilterWidget({
    Key? key,
    required this.options,
    required this.onFilterChanged,
    this.showDateRange = true,
    this.showCategories = true,
    this.showWarehouses = true,
    this.showProducts = false,
    this.showCustomers = false,
  }) : super(key: key);

  @override
  State<ReportFilterWidget> createState() => _ReportFilterWidgetState();
}

class _ReportFilterWidgetState extends State<ReportFilterWidget>
    with TickerProviderStateMixin {
  late AnimationController _expansionController;
  late Animation<double> _expansionAnimation;
  bool _isExpanded = false;
  late ReportFilterOptions _currentOptions;

  @override
  void initState() {
    super.initState();
    _currentOptions = widget.options;
    _expansionController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expansionAnimation = CurvedAnimation(
      parent: _expansionController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _expansionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with toggle button
          InkWell(
            onTap: _toggleExpansion,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.filter_list,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Filtros de Reporte',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _getFilterSummary(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      Icons.expand_more,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Expandable content
          AnimatedBuilder(
            animation: _expansionAnimation,
            builder: (context, child) {
              return ClipRect(
                child: Align(
                  alignment: Alignment.topCenter,
                  heightFactor: _expansionAnimation.value,
                  child: child,
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  const SizedBox(height: 8),
                  
                  // Quick preset buttons
                  _buildQuickPresets(context),
                  const SizedBox(height: 16),
                  
                  // Date range filter
                  if (widget.showDateRange) ...[
                    _buildDateRangeFilter(context),
                    const SizedBox(height: 16),
                  ],
                  
                  // Categories filter
                  if (widget.showCategories) ...[
                    _buildCategoriesFilter(context),
                    const SizedBox(height: 16),
                  ],
                  
                  // Warehouses filter
                  if (widget.showWarehouses) ...[
                    _buildWarehousesFilter(context),
                    const SizedBox(height: 16),
                  ],
                  
                  // Products filter
                  if (widget.showProducts) ...[
                    _buildProductsFilter(context),
                    const SizedBox(height: 16),
                  ],
                  
                  // Customers filter
                  if (widget.showCustomers) ...[
                    _buildCustomersFilter(context),
                    const SizedBox(height: 16),
                  ],
                  
                  // Action buttons
                  _buildActionButtons(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickPresets(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Períodos Rápidos',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _PresetButton(
              label: 'Hoy',
              onPressed: () => _applyDatePreset(DatePreset.today),
              theme: theme,
            ),
            _PresetButton(
              label: 'Esta Semana',
              onPressed: () => _applyDatePreset(DatePreset.thisWeek),
              theme: theme,
            ),
            _PresetButton(
              label: 'Este Mes',
              onPressed: () => _applyDatePreset(DatePreset.thisMonth),
              theme: theme,
            ),
            _PresetButton(
              label: 'Último Mes',
              onPressed: () => _applyDatePreset(DatePreset.lastMonth),
              theme: theme,
            ),
            _PresetButton(
              label: 'Últimos 3 Meses',
              onPressed: () => _applyDatePreset(DatePreset.lastThreeMonths),
              theme: theme,
            ),
            _PresetButton(
              label: 'Este Año',
              onPressed: () => _applyDatePreset(DatePreset.thisYear),
              theme: theme,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateRangeFilter(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rango de Fechas',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _selectStartDate,
                icon: const Icon(Icons.calendar_today, size: 16),
                label: Text(
                  'Desde: ${_formatDate(_currentOptions.startDate)}',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _selectEndDate,
                icon: const Icon(Icons.calendar_today, size: 16),
                label: Text(
                  'Hasta: ${_formatDate(_currentOptions.endDate)}',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoriesFilter(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Categorías',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: _selectAllCategories,
              child: const Text('Todas'),
            ),
            TextButton(
              onPressed: _clearCategories,
              child: const Text('Ninguna'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: _getAvailableCategories().map((category) {
            final isSelected = _currentOptions.selectedCategories.contains(category);
            return FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _currentOptions.selectedCategories.add(category);
                  } else {
                    _currentOptions.selectedCategories.remove(category);
                  }
                  _notifyFilterChange();
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildWarehousesFilter(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Almacenes',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: _selectAllWarehouses,
              child: const Text('Todos'),
            ),
            TextButton(
              onPressed: _clearWarehouses,
              child: const Text('Ninguno'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: _getAvailableWarehouses().map((warehouse) {
            final isSelected = _currentOptions.selectedWarehouses.contains(warehouse);
            return FilterChip(
              label: Text(warehouse),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _currentOptions.selectedWarehouses.add(warehouse);
                  } else {
                    _currentOptions.selectedWarehouses.remove(warehouse);
                  }
                  _notifyFilterChange();
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildProductsFilter(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Productos',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          decoration: const InputDecoration(
            hintText: 'Buscar productos...',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
            isDense: true,
          ),
          onChanged: (value) {
            setState(() {
              _currentOptions.productSearchTerm = value;
              _notifyFilterChange();
            });
          },
        ),
      ],
    );
  }

  Widget _buildCustomersFilter(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Clientes',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          decoration: const InputDecoration(
            hintText: 'Buscar clientes...',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
            isDense: true,
          ),
          onChanged: (value) {
            setState(() {
              _currentOptions.customerSearchTerm = value;
              _notifyFilterChange();
            });
          },
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        TextButton(
          onPressed: _resetFilters,
          child: const Text('Restablecer'),
        ),
        const Spacer(),
        FilledButton.icon(
          onPressed: _applyFilters,
          icon: const Icon(Icons.check),
          label: const Text('Aplicar'),
        ),
      ],
    );
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _expansionController.forward();
      } else {
        _expansionController.reverse();
      }
    });
  }

  void _applyDatePreset(DatePreset preset) {
    final now = DateTime.now();
    late DateTime startDate;
    late DateTime endDate;

    switch (preset) {
      case DatePreset.today:
        startDate = DateTime(now.year, now.month, now.day);
        endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case DatePreset.thisWeek:
        final weekday = now.weekday;
        startDate = now.subtract(Duration(days: weekday - 1));
        endDate = now.add(Duration(days: 7 - weekday));
        break;
      case DatePreset.thisMonth:
        startDate = DateTime(now.year, now.month, 1);
        endDate = DateTime(now.year, now.month + 1, 0);
        break;
      case DatePreset.lastMonth:
        startDate = DateTime(now.year, now.month - 1, 1);
        endDate = DateTime(now.year, now.month, 0);
        break;
      case DatePreset.lastThreeMonths:
        startDate = DateTime(now.year, now.month - 3, 1);
        endDate = now;
        break;
      case DatePreset.thisYear:
        startDate = DateTime(now.year, 1, 1);
        endDate = DateTime(now.year, 12, 31);
        break;
    }

    setState(() {
      _currentOptions.startDate = startDate;
      _currentOptions.endDate = endDate;
      _notifyFilterChange();
    });
  }

  void _selectStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _currentOptions.startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() {
        _currentOptions.startDate = date;
        _notifyFilterChange();
      });
    }
  }

  void _selectEndDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _currentOptions.endDate,
      firstDate: _currentOptions.startDate,
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() {
        _currentOptions.endDate = date;
        _notifyFilterChange();
      });
    }
  }

  void _selectAllCategories() {
    setState(() {
      _currentOptions.selectedCategories.clear();
      _currentOptions.selectedCategories.addAll(_getAvailableCategories());
      _notifyFilterChange();
    });
  }

  void _clearCategories() {
    setState(() {
      _currentOptions.selectedCategories.clear();
      _notifyFilterChange();
    });
  }

  void _selectAllWarehouses() {
    setState(() {
      _currentOptions.selectedWarehouses.clear();
      _currentOptions.selectedWarehouses.addAll(_getAvailableWarehouses());
      _notifyFilterChange();
    });
  }

  void _clearWarehouses() {
    setState(() {
      _currentOptions.selectedWarehouses.clear();
      _notifyFilterChange();
    });
  }

  void _resetFilters() {
    setState(() {
      _currentOptions = ReportFilterOptions.defaultOptions();
      _notifyFilterChange();
    });
  }

  void _applyFilters() {
    widget.onFilterChanged(_currentOptions);
    _toggleExpansion();
  }

  void _notifyFilterChange() {
    widget.onFilterChanged(_currentOptions);
  }

  String _getFilterSummary() {
    final parts = <String>[];
    
    if (widget.showDateRange) {
      parts.add('${_formatDate(_currentOptions.startDate)} - ${_formatDate(_currentOptions.endDate)}');
    }
    
    if (widget.showCategories && _currentOptions.selectedCategories.isNotEmpty) {
      parts.add('${_currentOptions.selectedCategories.length} categorías');
    }
    
    if (widget.showWarehouses && _currentOptions.selectedWarehouses.isNotEmpty) {
      parts.add('${_currentOptions.selectedWarehouses.length} almacenes');
    }

    return parts.isEmpty ? 'Sin filtros aplicados' : parts.join(' • ');
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  List<String> _getAvailableCategories() {
    return [
      'Electrónicos',
      'Ropa',
      'Hogar',
      'Deportes',
      'Libros',
      'Juguetes',
      'Salud',
      'Automóvil',
    ];
  }

  List<String> _getAvailableWarehouses() {
    return [
      'Almacén Central',
      'Almacén Norte',
      'Almacén Sur',
      'Centro de Distribución',
    ];
  }
}

class _PresetButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final ThemeData theme;

  const _PresetButton({
    required this.label,
    required this.onPressed,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        label,
        style: theme.textTheme.bodySmall,
      ),
    );
  }
}

enum DatePreset {
  today,
  thisWeek,
  thisMonth,
  lastMonth,
  lastThreeMonths,
  thisYear,
}

class ReportFilterOptions {
  DateTime startDate;
  DateTime endDate;
  Set<String> selectedCategories;
  Set<String> selectedWarehouses;
  String productSearchTerm;
  String customerSearchTerm;

  ReportFilterOptions({
    required this.startDate,
    required this.endDate,
    required this.selectedCategories,
    required this.selectedWarehouses,
    this.productSearchTerm = '',
    this.customerSearchTerm = '',
  });

  factory ReportFilterOptions.defaultOptions() {
    final now = DateTime.now();
    return ReportFilterOptions(
      startDate: DateTime(now.year, now.month, 1),
      endDate: now,
      selectedCategories: <String>{},
      selectedWarehouses: <String>{},
    );
  }

  ReportFilterOptions copyWith({
    DateTime? startDate,
    DateTime? endDate,
    Set<String>? selectedCategories,
    Set<String>? selectedWarehouses,
    String? productSearchTerm,
    String? customerSearchTerm,
  }) {
    return ReportFilterOptions(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      selectedCategories: selectedCategories ?? Set.from(this.selectedCategories),
      selectedWarehouses: selectedWarehouses ?? Set.from(this.selectedWarehouses),
      productSearchTerm: productSearchTerm ?? this.productSearchTerm,
      customerSearchTerm: customerSearchTerm ?? this.customerSearchTerm,
    );
  }
}
