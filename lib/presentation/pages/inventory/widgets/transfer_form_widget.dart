import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/product.dart';
import '../../../../domain/entities/warehouse.dart';
import '../../../../domain/entities/stock_batch.dart';
import '../../../providers/product_providers.dart';
import '../../../providers/stock_providers.dart';
import '../../../providers/warehouse_providers.dart';

class TransferFormWidget extends ConsumerStatefulWidget {
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
  ConsumerState<TransferFormWidget> createState() => _TransferFormWidgetState();
}

class _TransferFormWidgetState extends ConsumerState<TransferFormWidget> {
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
    
    // Si hay un producto y almacén seleccionados, actualizar el stock disponible
    if (_selectedProduct != null && _fromWarehouse != null) {
      Future.microtask(() => _updateAvailableStock(_selectedProduct!.id, _fromWarehouse!.id));
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _reasonController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(TransferFormWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    bool needsStockUpdate = false;
    
    // Verificar si cambió el producto seleccionado
    if (widget.selectedProduct != oldWidget.selectedProduct) {
      setState(() {
        _selectedProduct = widget.selectedProduct;
        _selectedBatch = null;
        _availableStock = 0;
      });
      needsStockUpdate = true;
    }
    
    // Verificar si cambió el almacén de origen
    if (widget.fromWarehouse != oldWidget.fromWarehouse) {
      setState(() {
        _fromWarehouse = widget.fromWarehouse;
        _availableStock = 0;
      });
      needsStockUpdate = true;
    }
    
    // Verificar si cambió el almacén de destino
    if (widget.toWarehouse != oldWidget.toWarehouse) {
      setState(() {
        _toWarehouse = widget.toWarehouse;
      });
    }
    
    // Verificar si cambió el lote seleccionado
    if (widget.selectedBatch != oldWidget.selectedBatch) {
      setState(() {
        _selectedBatch = widget.selectedBatch;
        _availableStock = _selectedBatch?.quantity ?? 0;
      });
    }
    
    // Si necesitamos actualizar el stock, lo hacemos después del setState
    if (needsStockUpdate && _selectedProduct != null && _fromWarehouse != null) {
      // Usamos Future.microtask para asegurarnos de que se ejecute después de que el setState se complete
      Future.microtask(() => _updateAvailableStock(_selectedProduct!.id, _fromWarehouse!.id));
    }
  }

  // Actualiza el stock disponible usando el provider
  void _updateAvailableStock(String productId, String warehouseId) async {
    // Reiniciamos primero el stock disponible para que muestre un indicador de carga
    setState(() {
      _availableStock = 0;
    });
    
    try {
      // Forzamos una actualización del provider obteniendo su valor directamente
      final stockAmount = await ref.refresh(availableStockProvider((
        productId: productId, 
        warehouseId: warehouseId
      )).future);
      
      // Actualizamos el estado con el nuevo valor
      if (mounted) {
        setState(() {
          _availableStock = stockAmount;
        });
      }
    } catch (e) {
      // Manejamos los errores si ocurren
      debugPrint('Error al actualizar stock disponible: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
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
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Transferencia de Stock',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (widget.onCancel != null)
                    IconButton(
                      onPressed: widget.onCancel,
                      icon: const Icon(Icons.close, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minHeight: 36,
                        minWidth: 36,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Product Selection (if not pre-selected)
              if (widget.selectedProduct == null) ...[
                Text(
                  'Producto *',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Consumer(
                  builder: (context, ref, child) {
                    final productsAsync = ref.watch(productsProvider);
                    
                    return productsAsync.when(
                      data: (products) {
                        return DropdownButtonFormField<Product>(
                          value: _selectedProduct,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Seleccione un producto',
                            prefixIcon: Icon(Icons.inventory_2, size: 18),
                            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            isDense: true,
                          ),
                          validator: (value) => value == null ? 'Por favor selecciona un producto' : null,
                          onChanged: (product) {
                            setState(() {
                              _selectedProduct = product;
                              _selectedBatch = null;
                              _availableStock = 0;
                            });
                            
                            // Cuando se seleccione un producto, actualizar el stock disponible
                            if (product != null && _fromWarehouse != null) {
                              _updateAvailableStock(product.id, _fromWarehouse!.id);
                            }
                          },
                          items: products.map((Product product) {
                            return DropdownMenuItem<Product>(
                              value: product,
                              child: Text(product.name),
                            );
                          }).toList(),
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (err, stack) => Text('Error: $err'),
                    );
                  },
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

              // Transfer Direction Row
              Row(
                children: [
                  // From Warehouse
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Almacen origen *',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (widget.fromWarehouse == null)
                          Consumer(
                            builder: (context, ref, child) {
                              final warehousesAsync = ref.watch(warehousesProvider);
                              
                              return warehousesAsync.when(
                                data: (warehouses) {
                                  return DropdownButtonFormField<Warehouse>(
                                    value: _fromWarehouse,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      hintText: 'origen',
                                      prefixIcon: Icon(Icons.warehouse, size: 18),
                                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                      isDense: true,
                                    ),
                                    validator: (value) => value == null ? 'Por favor selecciona un almacen origen' : null,
                                    onChanged: (warehouse) {
                                      setState(() {
                                        _fromWarehouse = warehouse;
                                        if (_toWarehouse?.id == warehouse?.id) {
                                          _toWarehouse = null;
                                        }
                                        
                                        // Actualizar stock disponible si hay un producto seleccionado
                                        if (_selectedProduct != null && warehouse != null) {
                                          _updateAvailableStock(_selectedProduct!.id, warehouse.id);
                                        }
                                      });
                                    },
                                    items: warehouses.map((Warehouse warehouse) {
                                      return DropdownMenuItem<Warehouse>(
                                        value: warehouse,
                                        child: Text(warehouse.name),
                                      );
                                    }).toList(),
                                  );
                                },
                                loading: () => const Center(child: CircularProgressIndicator()),
                                error: (err, stack) => Text('Error: $err'),
                              );
                            },
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            height: 40,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: theme.colorScheme.outline.withOpacity(0.5)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.warehouse, color: theme.colorScheme.primary, size: 18),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    widget.fromWarehouse!.name,
                                    overflow: TextOverflow.ellipsis,
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
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      children: [
                        const SizedBox(height: 24),
                        Icon(
                          Icons.arrow_forward,
                          color: theme.colorScheme.primary,
                          size: 20,
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
                          'A Almacen *',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (widget.toWarehouse == null)
                          Consumer(
                            builder: (context, ref, child) {
                              final warehousesAsync = ref.watch(warehousesProvider);
                              
                              return warehousesAsync.when(
                                data: (warehouses) {
                                  // Filtrar los almacenes para excluir el de origen
                                  final filteredWarehouses = _fromWarehouse != null 
                                      ? warehouses.where((w) => w.id != _fromWarehouse!.id).toList()
                                      : warehouses;
                                  
                                  return DropdownButtonFormField<Warehouse>(
                                    value: _toWarehouse,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      hintText: 'destino',
                                      prefixIcon: Icon(Icons.warehouse_outlined, size: 18),
                                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                      isDense: true,
                                    ),
                                    validator: (value) {
                                      if (value == null) return 'Por favor selecciona un almacen destino';
                                      if (value.id == _fromWarehouse?.id) {
                                        return 'No puedes transferir al mismo almacen de origen';
                                      }
                                      return null;
                                    },
                                    onChanged: (warehouse) {
                                      setState(() {
                                        _toWarehouse = warehouse;
                                      });
                                    },
                                    items: filteredWarehouses.map((Warehouse warehouse) {
                                      return DropdownMenuItem<Warehouse>(
                                        value: warehouse,
                                        child: Text(warehouse.name),
                                      );
                                    }).toList(),
                                  );
                                },
                                loading: () => const Center(child: CircularProgressIndicator()),
                                error: (err, stack) => Text('Error: $err'),
                              );
                            },
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            height: 40,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: theme.colorScheme.outline.withOpacity(0.5)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.warehouse_outlined, color: theme.colorScheme.primary, size: 18),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    widget.toWarehouse!.name,
                                    overflow: TextOverflow.ellipsis,
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
              const SizedBox(height: 12),

              // Batch Selection (optional)
              if (_selectedProduct != null && _fromWarehouse != null) ...[
                Text(
                  'Lote de Stock (opcional)',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Consumer(
                  builder: (context, ref, child) {
                    final stockBatchesAsync = ref.watch(stockBatchesByProductProvider(_selectedProduct!.id));
                    
                    return stockBatchesAsync.when(
                      data: (batches) {
                        // Filtrar los lotes que están en el almacén origen
                        final warehouseBatches = batches
                            .where((batch) => batch.warehouseId == _fromWarehouse!.id)
                            .toList();
                        
                        if (warehouseBatches.isEmpty) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.orange.withOpacity(0.5)),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.warning, color: Colors.orange, size: 16),
                                SizedBox(width: 6),
                                Expanded(
                                  child: Text('No hay lotes disponibles para este producto en el almacén de origen'),
                                ),
                              ],
                            ),
                          );
                        }
                        
                        return DropdownButtonFormField<StockBatch>(
                          value: _selectedBatch,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Seleccione un lote o deje en blanco',
                            prefixIcon: Icon(Icons.numbers, size: 18),
                            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            isDense: true,
                          ),
                          onChanged: (batch) {
                            setState(() {
                              _selectedBatch = batch;
                              _availableStock = batch?.quantity ?? 0;
                            });
                          },
                          items: warehouseBatches.map((StockBatch batch) {
                            return DropdownMenuItem<StockBatch>(
                              value: batch,
                              child: Text('${batch.batchNumber} - ${batch.quantity} unidades'),
                            );
                          }).toList(),
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (err, stack) => Text('Error: $err'),
                    );
                  },
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
                          'Transferir cantidad *',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _quantityController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Ingrese cantidad a transferir',
                            prefixIcon: Icon(Icons.numbers, size: 18),
                            suffixText: 'unidades',
                            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            isDense: true,
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
                              return 'Por favor ingrese una cantidad válida';
                            }
                            if (quantity > _availableStock) {
                              return 'No puede transferir más de $_availableStock unidades';
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
                          'Stock disponible',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _selectedProduct != null && _fromWarehouse != null
                        ? Consumer(
                            builder: (context, ref, child) {
                              final availableStockAsync = ref.watch(
                                availableStockProvider((productId: _selectedProduct!.id, warehouseId: _fromWarehouse!.id))
                              );
                              
                              return availableStockAsync.when(
                                data: (stockAmount) {
                                  // Actualizamos _availableStock para usarlo en validaciones
                                  if (_availableStock != stockAmount) {
                                    Future.microtask(() => setState(() {
                                      _availableStock = stockAmount;
                                    }));
                                  }
                                  
                                  return Container(
                                    height: 42,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: theme.colorScheme.outline),
                                      borderRadius: BorderRadius.circular(4),
                                      color: stockAmount > 0 
                                          ? Colors.green.withOpacity(0.1)
                                          : Colors.orange.withOpacity(0.1),
                                    ),
                                    child: Text(
                                      '$stockAmount unidades', // Mostrar stock disponible
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: stockAmount > 0 ? Colors.green : Colors.orange,
                                      ),
                                    ),
                                  );
                                },
                                loading: () => Container(
                                  height: 42,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: theme.colorScheme.outline),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const CircularProgressIndicator(strokeWidth: 2),
                                ),
                                error: (err, stack) => Container(
                                  height: 42,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.red),
                                    borderRadius: BorderRadius.circular(4),
                                    color: Colors.red.withOpacity(0.1),
                                  ),
                                  child: Text(
                                    'Error al cargar',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              );
                            },
                          )
                        : Container(
                            height: 42,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              border: Border.all(color: theme.colorScheme.outline),
                              borderRadius: BorderRadius.circular(4),
                              color: Colors.grey.withOpacity(0.1),
                            ),
                            child: Text(
                              '0 unidades', 
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
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
                  'Cantidad rápida',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
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
                    _buildQuickQuantityButton('Todo', _availableStock, theme),
                  ],
                ),
                const SizedBox(height: 12),
              ],

              // Reason Input
              Text(
                'Razon de transferencia *',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              TextFormField(
                controller: _reasonController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Ingrese la razón de la transferencia',
                  prefixIcon: Icon(Icons.help_outline, size: 18),
                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  isDense: true,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor ingrese una razón para la transferencia';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Notes Input
              Text(
                'Notas adicionales (opcional)',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Notas adicionales sobre la transferencia...',
                  prefixIcon: Icon(Icons.note, size: 18),
                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  isDense: true,
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
                          : const Text('Transferir'),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 18),
          const SizedBox(width: 8),
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
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        minimumSize: const Size(40, 30),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(label, style: const TextStyle(fontSize: 12)),
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
