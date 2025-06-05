import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/product.dart';
import '../../../../domain/entities/warehouse.dart';
import '../../../../domain/entities/stock_batch.dart';
import '../../../providers/warehouse_providers.dart';

enum AdjustmentType { increase, decrease, set }

class AdjustmentFormWidget extends ConsumerStatefulWidget {
  final Product? selectedProduct;
  final Warehouse? selectedWarehouse;
  final StockBatch? selectedBatch;
  final Function(Map<String, dynamic> adjustmentData) onSubmit;
  final VoidCallback? onCancel;

  const AdjustmentFormWidget({
    Key? key,
    this.selectedProduct,
    this.selectedWarehouse,
    this.selectedBatch,
    required this.onSubmit,
    this.onCancel,
  }) : super(key: key);

  @override
  ConsumerState<AdjustmentFormWidget> createState() => _AdjustmentFormWidgetState();
}

class _AdjustmentFormWidgetState extends ConsumerState<AdjustmentFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _reasonController = TextEditingController();
  final _notesController = TextEditingController();

  AdjustmentType _selectedType = AdjustmentType.increase;
  Product? _selectedProduct;
  Warehouse? _selectedWarehouse;
  StockBatch? _selectedBatch;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedProduct = widget.selectedProduct;
    _selectedWarehouse = widget.selectedWarehouse;
    _selectedBatch = widget.selectedBatch;
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _reasonController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Form Header
              Row(
                children: [
                  Icon(
                    Icons.adjust,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Ajuste de stock',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (widget.onCancel != null)
                    IconButton(
                      onPressed: widget.onCancel,
                      icon: const Icon(Icons.close),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Product Selection (if not pre-selected)
              if (widget.selectedProduct == null) ...[
                Text(
                  'Producto *',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<Product>(
                  value: _selectedProduct,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Seleccione un producto',
                    prefixIcon: Icon(Icons.inventory_2),
                  ),
                  validator: (value) => value == null ? 'Por favor seleccionan un producto' : null,
                  onChanged: (product) {
                    setState(() {
                      _selectedProduct = product;
                      _selectedBatch = null; // Reset batch when product changes
                    });
                  },
                  items: [], // This would be populated from a provider
                ),
                const SizedBox(height: 16),
              ] else ...[
                _buildInfoCard(
                  'Producto',
                  widget.selectedProduct!.name,
                  Icons.inventory_2,
                  theme,
                ),
                const SizedBox(height: 16),
              ],

              // Warehouse Selection (if not pre-selected)
              if (widget.selectedWarehouse == null) ...[
                Text(
                  'Almacen *',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<Warehouse>(
                  value: _selectedWarehouse,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Selecciona un almacen',
                    prefixIcon: Icon(Icons.warehouse),
                  ),
                  validator: (value) => value == null ? 'Por favor selecciona un almacen' : null,
                  onChanged: (warehouse) {
                    setState(() {
                      _selectedWarehouse = warehouse;
                    });
                  },
                  items: ref.watch(warehousesProvider).when(
                    data: (warehouses) => warehouses.map((warehouse) {
                      print('Buscando almacen: ${warehouse.name}');
                      return DropdownMenuItem<Warehouse>(
                        value: warehouse,
                        child: Text(warehouse.name),
                      );
                    }).toList(),
                    loading: () => [],
                    error: (_, __) => [],
                  ),
                ),
                const SizedBox(height: 16),
              ] else ...[
                _buildInfoCard(
                  'Almacen',
                  widget.selectedWarehouse!.name,
                  Icons.warehouse,
                  theme,
                ),
                const SizedBox(height: 16),
              ],

              // Batch Selection (optional)
              if (_selectedProduct != null) ...[
                Text(
                  'Lote (Opcional)',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<StockBatch>(
                  value: _selectedBatch,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Selecciona un lote o deja en blanco',
                    prefixIcon: Icon(Icons.numbers),
                  ),
                  onChanged: (batch) {
                    setState(() {
                      _selectedBatch = batch;
                    });
                  },
                  items: [], // This would be populated based on selected product
                ),
                const SizedBox(height: 16),
              ],

              // Adjustment Type
              Text(
                'Tipo de Ajuste *',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<AdjustmentType>(
                      title: const Text('Incrementar'),
                      subtitle: const Text('Agregar stock'),
                      value: AdjustmentType.increase,
                      groupValue: _selectedType,
                      onChanged: (type) {
                        setState(() {
                          _selectedType = type!;
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<AdjustmentType>(
                      title: const Text('Reducir'),
                      subtitle: const Text('Eliminar stock'),
                      value: AdjustmentType.decrease,
                      groupValue: _selectedType,
                      onChanged: (type) {
                        setState(() {
                          _selectedType = type!;
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<AdjustmentType>(
                      title: const Text('Establecer'),
                      subtitle: const Text('Establecer stock exacto'),
                      value: AdjustmentType.set,
                      groupValue: _selectedType,
                      onChanged: (type) {
                        setState(() {
                          _selectedType = type!;
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Quantity Input
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cantidad *',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _quantityController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Ingrese cantidad',
                            prefixIcon: Icon(Icons.numbers),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingrese una cantidad';
                            }
                            final quantity = int.tryParse(value);
                            if (quantity == null || quantity <= 0) {
                              return 'Por favor ingrese una cantidad válida mayor a 0';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Stock Actual',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 56,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: Border.all(color: theme.colorScheme.outline),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _selectedBatch?.quantity.toString() ?? '0',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Reason Input
              Text(
                'Razon *',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _reasonController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Ingrese la razon del ajuste',
                  prefixIcon: Icon(Icons.help_outline),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor ingrese una razon para el ajuste';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Notes Input
              Text(
                'Notas (Opcional)',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Notas adicionales...',
                  prefixIcon: Icon(Icons.note),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  if (widget.onCancel != null)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isLoading ? null : widget.onCancel,
                        child: const Text('Cancelar'),
                      ),
                    ),
                  if (widget.onCancel != null) const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleSubmit,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Guardar Ajuste'),
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

  Widget _buildInfoCard(String label, String value, IconData icon, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final adjustmentData = {
        'type': _selectedType.name,
        'quantity': int.parse(_quantityController.text),
        'reason': _reasonController.text.trim(),
        'notes': _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        'productId': _selectedProduct?.id,
        'warehouseId': _selectedWarehouse?.id,
        'batchId': _selectedBatch?.id,
        'timestamp': DateTime.now().toIso8601String(),
      };

      widget.onSubmit(adjustmentData);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
