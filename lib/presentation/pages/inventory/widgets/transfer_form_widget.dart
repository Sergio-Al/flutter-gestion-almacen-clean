import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../domain/entities/product.dart';
import '../../../../domain/entities/warehouse.dart';
import '../../../../domain/entities/stock_batch.dart';

class TransferFormWidget extends StatefulWidget {
  final Product? selectedProduct;
  final Warehouse? fromWarehouse;
  final Warehouse? toWarehouse;
  final StockBatch? selectedBatch;
  final Function(Map<String, dynamic> transferData) onSubmit;
  final VoidCallback? onCancel;

  const TransferFormWidget({
    Key? key,
    this.selectedProduct,
    this.fromWarehouse,
    this.toWarehouse,
    this.selectedBatch,
    required this.onSubmit,
    this.onCancel,
  }) : super(key: key);

  @override
  State<TransferFormWidget> createState() => _TransferFormWidgetState();
}

class _TransferFormWidgetState extends State<TransferFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _reasonController = TextEditingController();
  final _notesController = TextEditingController();

  Product? _selectedProduct;
  Warehouse? _fromWarehouse;
  Warehouse? _toWarehouse;
  StockBatch? _selectedBatch;
  bool _isLoading = false;
  int _availableStock = 0;

  @override
  void initState() {
    super.initState();
    _selectedProduct = widget.selectedProduct;
    _fromWarehouse = widget.fromWarehouse;
    _toWarehouse = widget.toWarehouse;
    _selectedBatch = widget.selectedBatch;
    _availableStock = _selectedBatch?.quantity ?? 0;
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
                    Icons.swap_horiz,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Stock Transfer',
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
                      _selectedBatch = null;
                      _availableStock = 0;
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

              // Transfer Direction Row
              Row(
                children: [
                  // From Warehouse
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'From Warehouse *',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (widget.fromWarehouse == null)
                          DropdownButtonFormField<Warehouse>(
                            value: _fromWarehouse,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Select source',
                              prefixIcon: Icon(Icons.warehouse),
                            ),
                            validator: (value) => value == null ? 'Please select source warehouse' : null,
                            onChanged: (warehouse) {
                              setState(() {
                                _fromWarehouse = warehouse;
                                if (_toWarehouse?.id == warehouse?.id) {
                                  _toWarehouse = null;
                                }
                              });
                            },
                            items: [], // This would be populated from a provider
                          )
                        else
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: theme.colorScheme.outline.withOpacity(0.5)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.warehouse, color: theme.colorScheme.primary),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    widget.fromWarehouse!.name,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  
                  // Transfer Arrow
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        Icon(
                          Icons.arrow_forward,
                          color: theme.colorScheme.primary,
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
                          'To Warehouse *',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (widget.toWarehouse == null)
                          DropdownButtonFormField<Warehouse>(
                            value: _toWarehouse,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Select destination',
                              prefixIcon: Icon(Icons.warehouse_outlined),
                            ),
                            validator: (value) {
                              if (value == null) return 'Please select destination warehouse';
                              if (value.id == _fromWarehouse?.id) {
                                return 'Source and destination cannot be the same';
                              }
                              return null;
                            },
                            onChanged: (warehouse) {
                              setState(() {
                                _toWarehouse = warehouse;
                              });
                            },
                            items: [], // This would be populated from a provider
                          )
                        else
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: theme.colorScheme.outline.withOpacity(0.5)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.warehouse_outlined, color: theme.colorScheme.primary),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    widget.toWarehouse!.name,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

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
                      _availableStock = batch?.quantity ?? 0;
                    });
                  },
                  items: [], // This would be populated based on selected product and warehouse
                ),
                const SizedBox(height: 16),
              ],

              // Quantity and Available Stock
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Transfer Quantity *',
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
                            suffixText: 'units',
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
                            if (quantity > _availableStock) {
                              return 'Cannot transfer more than available stock';
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
                          'Available Stock',
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
                            color: _availableStock > 0 
                                ? Colors.green.withOpacity(0.1)
                                : Colors.orange.withOpacity(0.1),
                          ),
                          child: Text(
                            '$_availableStock units',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: _availableStock > 0 ? Colors.green : Colors.orange,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Quick Quantity Buttons
              if (_availableStock > 0) ...[
                Text(
                  'Quick Select',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (_availableStock >= 10)
                      _buildQuickQuantityButton('10', 10, theme),
                    if (_availableStock >= 25) ...[
                      const SizedBox(width: 8),
                      _buildQuickQuantityButton('25', 25, theme),
                    ],
                    if (_availableStock >= 50) ...[
                      const SizedBox(width: 8),
                      _buildQuickQuantityButton('50', 50, theme),
                    ],
                    const SizedBox(width: 8),
                    _buildQuickQuantityButton('All', _availableStock, theme),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              // Reason Input
              Text(
                'Transfer Reason *',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _reasonController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter reason for transfer',
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
                'Additional Notes (Optional)',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Additional notes about the transfer...',
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
                          : const Text('Transfer Stock'),
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

  Widget _buildQuickQuantityButton(String label, int quantity, ThemeData theme) {
    return OutlinedButton(
      onPressed: () {
        _quantityController.text = quantity.toString();
      },
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: Text(label),
    );
  }

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final transferData = {
        'quantity': int.parse(_quantityController.text),
        'reason': _reasonController.text.trim(),
        'notes': _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        'productId': _selectedProduct?.id,
        'fromWarehouseId': _fromWarehouse?.id,
        'toWarehouseId': _toWarehouse?.id,
        'batchId': _selectedBatch?.id,
        'timestamp': DateTime.now().toIso8601String(),
      };

      widget.onSubmit(transferData);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
