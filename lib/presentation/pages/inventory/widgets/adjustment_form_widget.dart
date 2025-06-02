import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../domain/entities/product.dart';
import '../../../../domain/entities/warehouse.dart';
import '../../../../domain/entities/stock_batch.dart';

enum AdjustmentType { increase, decrease, set }

class AdjustmentFormWidget extends StatefulWidget {
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
  State<AdjustmentFormWidget> createState() => _AdjustmentFormWidgetState();
}

class _AdjustmentFormWidgetState extends State<AdjustmentFormWidget> {
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
                    'Stock Adjustment',
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
                  'Product *',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<Product>(
                  value: _selectedProduct,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Select a product',
                    prefixIcon: Icon(Icons.inventory_2),
                  ),
                  validator: (value) => value == null ? 'Please select a product' : null,
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
                  'Product',
                  widget.selectedProduct!.name,
                  Icons.inventory_2,
                  theme,
                ),
                const SizedBox(height: 16),
              ],

              // Warehouse Selection (if not pre-selected)
              if (widget.selectedWarehouse == null) ...[
                Text(
                  'Warehouse *',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<Warehouse>(
                  value: _selectedWarehouse,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Select a warehouse',
                    prefixIcon: Icon(Icons.warehouse),
                  ),
                  validator: (value) => value == null ? 'Please select a warehouse' : null,
                  onChanged: (warehouse) {
                    setState(() {
                      _selectedWarehouse = warehouse;
                    });
                  },
                  items: [], // This would be populated from a provider
                ),
                const SizedBox(height: 16),
              ] else ...[
                _buildInfoCard(
                  'Warehouse',
                  widget.selectedWarehouse!.name,
                  Icons.warehouse,
                  theme,
                ),
                const SizedBox(height: 16),
              ],

              // Batch Selection (optional)
              if (_selectedProduct != null) ...[
                Text(
                  'Batch (Optional)',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<StockBatch>(
                  value: _selectedBatch,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Select a batch or leave empty',
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
                'Adjustment Type *',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<AdjustmentType>(
                      title: const Text('Increase'),
                      subtitle: const Text('Add stock'),
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
                      title: const Text('Decrease'),
                      subtitle: const Text('Remove stock'),
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
                      title: const Text('Set'),
                      subtitle: const Text('Set exact amount'),
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
                          'Quantity *',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _quantityController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Enter quantity',
                            prefixIcon: Icon(Icons.numbers),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter quantity';
                            }
                            final quantity = int.tryParse(value);
                            if (quantity == null || quantity <= 0) {
                              return 'Please enter a valid quantity';
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
                          'Current Stock',
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
                'Reason *',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _reasonController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter reason for adjustment',
                  prefixIcon: Icon(Icons.help_outline),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a reason';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Notes Input
              Text(
                'Notes (Optional)',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Additional notes...',
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
                        child: const Text('Cancel'),
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
                          : const Text('Submit Adjustment'),
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
