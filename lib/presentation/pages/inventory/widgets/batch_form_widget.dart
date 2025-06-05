import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../domain/entities/stock_batch.dart';
import '../../../../domain/entities/product.dart';
import '../../../../domain/entities/warehouse.dart';
import '../../../providers/product_providers.dart';
import '../../../providers/warehouse_providers.dart';
import '../../../providers/stock_providers.dart';

class BatchFormWidget extends ConsumerStatefulWidget {
  final StockBatch? batch;
  final Product? preselectedProduct;
  final Warehouse? preselectedWarehouse;
  final Function(StockBatch batch) onSubmit;
  final VoidCallback onCancel;

  const BatchFormWidget({
    Key? key,
    this.batch,
    this.preselectedProduct,
    this.preselectedWarehouse,
    required this.onSubmit,
    required this.onCancel,
  }) : super(key: key);

  @override
  ConsumerState<BatchFormWidget> createState() => _BatchFormWidgetState();
}

class _BatchFormWidgetState extends ConsumerState<BatchFormWidget> {
  final _formKey = GlobalKey<FormState>();
  
  // Controladores para los campos del formulario
  final _batchNumberController = TextEditingController();
  final _quantityController = TextEditingController();
  final _supplierIdController = TextEditingController();
  final _receivedDateController = TextEditingController();
  final _expiryDateController = TextEditingController();
  
  // Variables para almacenar valores
  Product? _selectedProduct;
  Warehouse? _selectedWarehouse;
  DateTime _receivedDate = DateTime.now();
  DateTime? _expiryDate;
  bool _isLoading = false;

  bool get _isEditing => widget.batch != null;

  @override
  void initState() {
    super.initState();
    
    // Si se está editando, cargar datos del lote
    if (_isEditing) {
      _batchNumberController.text = widget.batch!.batchNumber;
      _quantityController.text = widget.batch!.quantity.toString();
      _supplierIdController.text = widget.batch!.supplierId;
      _receivedDate = widget.batch!.receivedDate;
      _receivedDateController.text = _formatDate(_receivedDate);
      
      if (widget.batch!.expiryDate != null) {
        _expiryDate = widget.batch!.expiryDate;
        _expiryDateController.text = _formatDate(_expiryDate!);
      }
      
      // La carga del producto y almacén se realizará en didChangeDependencies
    } else {
      _receivedDateController.text = _formatDate(_receivedDate);
      
      // Si hay valores preseleccionados, usarlos
      _selectedProduct = widget.preselectedProduct;
      _selectedWarehouse = widget.preselectedWarehouse;
    }
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    if (_isEditing) {
      // Cargar producto y almacén si estamos editando
      _loadProduct(widget.batch!.productId);
      _loadWarehouse(widget.batch!.warehouseId);
    }
  }
  
  void _loadProduct(String productId) async {
    final productAsync = await ref.read(productByIdProvider(productId).future);
    if (mounted && productAsync != null) {
      setState(() {
        _selectedProduct = productAsync;
      });
    }
  }
  
  void _loadWarehouse(String warehouseId) async {
    final warehouseAsync = await ref.read(warehouseByIdProvider(warehouseId).future);
    if (mounted && warehouseAsync != null) {
      setState(() {
        _selectedWarehouse = warehouseAsync;
      });
    }
  }

  @override
  void dispose() {
    _batchNumberController.dispose();
    _quantityController.dispose();
    _supplierIdController.dispose();
    _receivedDateController.dispose();
    _expiryDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final productsAsync = ref.watch(productsProvider);
    final warehousesAsync = ref.watch(warehousesProvider);
    
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Selección de Producto
            _buildSectionTitle('Producto *'),
            const SizedBox(height: 8),
            
            Container(
              padding: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: productsAsync.when(
                data: (products) => DropdownButtonFormField<Product>(
                  value: _selectedProduct,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    border: InputBorder.none,
                  ),
                  hint: const Text('Seleccionar producto'),
                  validator: (value) => value == null ? 'Producto requerido' : null,
                  onChanged: widget.preselectedProduct != null ? null : (product) {
                    setState(() {
                      _selectedProduct = product;
                    });
                  },
                  items: products.map((product) {
                    return DropdownMenuItem<Product>(
                      value: product,
                      child: Text('${product.name} (${product.sku})'),
                    );
                  }).toList(),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const Text('Error cargando productos'),
              ),
            ),
            const SizedBox(height: 16),
            
            // Selección de Almacén
            _buildSectionTitle('Almacén *'),
            const SizedBox(height: 8),
            
            Container(
              padding: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: warehousesAsync.when(
                data: (warehouses) => DropdownButtonFormField<Warehouse>(
                  value: _selectedWarehouse,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    border: InputBorder.none,
                  ),
                  hint: const Text('Seleccionar almacén'),
                  validator: (value) => value == null ? 'Almacén requerido' : null,
                  onChanged: widget.preselectedWarehouse != null ? null : (warehouse) {
                    setState(() {
                      _selectedWarehouse = warehouse;
                    });
                  },
                  items: warehouses.map((warehouse) {
                    return DropdownMenuItem<Warehouse>(
                      value: warehouse,
                      child: Text(warehouse.name),
                    );
                  }).toList(),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const Text('Error cargando almacenes'),
              ),
            ),
            const SizedBox(height: 16),
            
            // Número de Lote
            _buildSectionTitle('Número de Lote *'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _batchNumberController,
              decoration: _getInputDecoration('Ej: LOT-2025-001'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Número de lote requerido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Cantidad
            _buildSectionTitle('Cantidad *'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _quantityController,
              decoration: _getInputDecoration('Cantidad en unidades'),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Cantidad requerida';
                }
                final quantity = int.tryParse(value);
                if (quantity == null || quantity <= 0) {
                  return 'Ingrese un número válido mayor que 0';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Proveedor
            _buildSectionTitle('Proveedor *'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _supplierIdController,
              decoration: _getInputDecoration('ID o nombre del proveedor'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Proveedor requerido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Fecha de Recepción
            _buildSectionTitle('Fecha de Recepción *'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _receivedDateController,
              decoration: _getInputDecoration('Fecha de recepción'),
              readOnly: true,
              onTap: () => _selectDate(context, isExpiryDate: false),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Fecha de recepción requerida';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Fecha de Expiración (opcional)
            _buildSectionTitle('Fecha de Expiración (opcional)'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _expiryDateController,
              decoration: _getInputDecoration('Fecha de expiración (si aplica)'),
              readOnly: true,
              onTap: () => _selectDate(context, isExpiryDate: true),
            ),
            const SizedBox(height: 24),
            
            // Botones de acción
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : widget.onCancel,
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSubmit,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(_isEditing ? 'Actualizar' : 'Crear'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
    );
  }

  InputDecoration _getInputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
    );
  }

  Future<void> _selectDate(BuildContext context, {required bool isExpiryDate}) async {
    final initialDate = isExpiryDate 
        ? _expiryDate ?? DateTime.now().add(const Duration(days: 365))
        : _receivedDate;
    
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: isExpiryDate 
          ? DateTime.now() 
          : DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    
    if (pickedDate != null) {
      setState(() {
        if (isExpiryDate) {
          _expiryDate = pickedDate;
          _expiryDateController.text = _formatDate(pickedDate);
        } else {
          _receivedDate = pickedDate;
          _receivedDateController.text = _formatDate(pickedDate);
        }
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedProduct == null || _selectedWarehouse == null) {
      return;
    }
    
    setState(() {
      _isLoading = true;
    });

    try {
      final StockBatch batch = StockBatch(
        id: _isEditing ? widget.batch!.id : const Uuid().v4(),
        productId: _selectedProduct!.id,
        warehouseId: _selectedWarehouse!.id,
        quantity: int.parse(_quantityController.text),
        batchNumber: _batchNumberController.text.trim(),
        expiryDate: _expiryDate,
        receivedDate: _receivedDate,
        supplierId: _supplierIdController.text.trim(),
      );

      widget.onSubmit(batch);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
