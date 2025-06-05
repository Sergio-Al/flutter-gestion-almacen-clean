import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/product_providers.dart';
import '../../providers/customer_providers.dart';
import '../../providers/sales_providers.dart';
import '../../../domain/entities/customer.dart';
import '../../../domain/usecases/sales/save_sales_order_usecase.dart';
import 'widgets/customer_selector.dart';

class CreateOrderPage extends ConsumerStatefulWidget {
  const CreateOrderPage({super.key});

  @override
  ConsumerState<CreateOrderPage> createState() => _CreateOrderPageState();
}

class _CreateOrderPageState extends ConsumerState<CreateOrderPage> {
  final _formKey = GlobalKey<FormState>();
  final _customerController = TextEditingController();
  final _notesController = TextEditingController();
  
  Customer? _selectedCustomer;
  List<OrderItemData> _orderItems = [];
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    // Configurar el listener para cambios de estado aquí en initState
    Future.microtask(() {
      ref.listenManual(saveSalesOrderStateProvider, (previous, current) {
        if (!mounted) return;
        
        if (!current.isLoading && (previous?.isLoading ?? false)) {
          setState(() {
            _isLoading = false;
          });
          
          if (current.isSuccess) {
            // Éxito
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Pedido #${current.orderId!.substring(0, 8)} creado exitosamente'),
                backgroundColor: Colors.green,
                action: SnackBarAction(
                  label: 'VER',
                  textColor: Colors.white,
                  onPressed: () {
                    Navigator.pushNamed(
                      context, 
                      '/sales/orders/detail',
                      arguments: current.orderId,
                    );
                  },
                ),
              ),
            );
            
            // Reiniciar el estado después de mostrarlo
            ref.read(saveSalesOrderControllerProvider.notifier).resetState();
          } else if (current.isError) {
            // Error
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${current.failure!.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _customerController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Pedido'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveOrder,
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('GUARDAR'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Customer Section
                    _buildCustomerSection(),
                    const SizedBox(height: 20),
                    
                    // Order Items Section
                    _buildOrderItemsSection(),
                    const SizedBox(height: 20),
                    
                    // Add Product Button
                    productsAsync.when(
                      data: (products) => _buildAddProductSection(products),
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (_, __) => _buildErrorSection(),
                    ),
                    const SizedBox(height: 20),
                    
                    // Notes Section
                    _buildNotesSection(),
                  ],
                ),
              ),
            ),
            
            // Order Summary
            _buildOrderSummary(),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerSection() {
    final customersAsync = ref.watch(customersProvider);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Información del Cliente',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            customersAsync.when(
              data: (customers) {
                return CustomerSelector(
                  selectedCustomer: _selectedCustomer,
                  customers: customers,
                  onCustomerSelected: (customer) {
                    setState(() {
                      _selectedCustomer = customer;
                      // También actualiza el controlador del texto para mostrar el nombre
                      if (customer != null) {
                        _customerController.text = customer.name;
                      } else {
                        _customerController.clear();
                      }
                    });
                  },
                  hintText: 'Seleccionar cliente...',
                );
              },
              loading: () => const Center(
                child: SizedBox(
                  height: 48,
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (error, stackTrace) => CustomerSelector(
                customers: const [],
                onCustomerSelected: (_) {},
                hintText: 'Error al cargar clientes',
                enabled: false,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItemsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Productos del Pedido',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (_orderItems.isEmpty)
              Container(
                height: 100,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    'No hay productos agregados\nToca "Agregar Producto" para comenzar',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ..._orderItems.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return _buildOrderItemCard(item, index);
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItemCard(OrderItemData item, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.productName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'SKU: ${item.productSku}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _removeOrderItem(index),
                  tooltip: 'Eliminar',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: item.quantity.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Cantidad',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Requerido';
                      }
                      final quantity = int.tryParse(value);
                      if (quantity == null || quantity <= 0) {
                        return 'Cantidad inválida';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      final quantity = int.tryParse(value);
                      if (quantity != null && quantity > 0) {
                        setState(() {
                          _orderItems[index] = item.copyWith(quantity: quantity);
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    initialValue: item.unitPrice.toStringAsFixed(2),
                    decoration: const InputDecoration(
                      labelText: 'Precio Unitario',
                      border: OutlineInputBorder(),
                      isDense: true,
                      prefixText: '\$ ',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Requerido';
                      }
                      final price = double.tryParse(value);
                      if (price == null || price <= 0) {
                        return 'Precio inválido';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      final price = double.tryParse(value);
                      if (price != null && price > 0) {
                        setState(() {
                          _orderItems[index] = item.copyWith(unitPrice: price);
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '\$${(item.quantity * item.unitPrice).toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddProductSection(List products) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _showAddProductDialog(products),
        icon: const Icon(Icons.add),
        label: const Text('Agregar Producto'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[600],
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildErrorSection() {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: const Center(
          child: Column(
            children: [
              Icon(Icons.error_outline, color: Colors.red),
              SizedBox(height: 8),
              Text('Error al cargar productos'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notas del Pedido',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                hintText: 'Agregar notas opcionales...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    final subtotal = _orderItems.fold<double>(
      0,
      (sum, item) => sum + (item.quantity * item.unitPrice),
    );
    final taxes = subtotal * 0.1; // 10% tax
    final total = subtotal + taxes;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Subtotal:'),
              Text('\$${subtotal.toStringAsFixed(2)}'),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Impuestos:'),
              Text('\$${taxes.toStringAsFixed(2)}'),
            ],
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total:',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '\$${total.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddProductDialog(List products) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seleccionar Producto'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ListTile(
                title: Text(product.name),
                subtitle: Text('SKU: ${product.sku} • \$${product.unitPrice.toStringAsFixed(2)}'),
                onTap: () {
                  _addOrderItem(product);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  void _addOrderItem(dynamic product) {
    final newItem = OrderItemData(
      productId: product.id,
      productName: product.name,
      productSku: product.sku,
      quantity: 1,
      unitPrice: product.unitPrice,
      batchId: '', // This should be selected from available batches
    );

    setState(() {
      _orderItems.add(newItem);
    });
  }

  void _removeOrderItem(int index) {
    setState(() {
      _orderItems.removeAt(index);
    });
  }

  Future<void> _saveOrder() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona un cliente'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_orderItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Agrega al menos un producto al pedido'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Convertir los orderItems a la estructura que espera el caso de uso
      final orderItemInputs = _orderItems.map((item) {
        return OrderItemInput(
          productId: item.productId,
          productName: item.productName,
          quantity: item.quantity,
          unitPrice: item.unitPrice,
          batchId: item.batchId.isEmpty ? null : item.batchId,
        );
      }).toList();
      
      // Preparar los parámetros para el proveedor
      final params = SaveOrderParams(
        customerId: _selectedCustomer!.id,
        customerName: _selectedCustomer!.name,
        items: orderItemInputs,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );
      
      // Guardar el pedido usando el controlador (el listener ya está configurado en initState)
      final controller = ref.read(saveSalesOrderControllerProvider.notifier);
      controller.saveSalesOrder(params);
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al crear pedido: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }

      setState(() {
        _isLoading = false;
      });
    }
  }
}

class OrderItemData {
  final String productId;
  final String productName;
  final String productSku;
  final int quantity;
  final double unitPrice;
  final String batchId;

  OrderItemData({
    required this.productId,
    required this.productName,
    required this.productSku,
    required this.quantity,
    required this.unitPrice,
    required this.batchId,
  });

  OrderItemData copyWith({
    String? productId,
    String? productName,
    String? productSku,
    int? quantity,
    double? unitPrice,
    String? batchId,
  }) {
    return OrderItemData(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productSku: productSku ?? this.productSku,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      batchId: batchId ?? this.batchId,
    );
  }
}
