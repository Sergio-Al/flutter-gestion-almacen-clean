import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/sales_providers.dart';
import '../../../domain/entities/sales_order.dart';
import '../../../domain/entities/order_item.dart';
import 'widgets/order_status_chip.dart';
import 'widgets/order_items_list.dart';

class OrderDetailPage extends ConsumerStatefulWidget {
  final String orderId;

  const OrderDetailPage({super.key, required this.orderId});

  @override
  ConsumerState<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends ConsumerState<OrderDetailPage> {

  @override
  Widget build(BuildContext context) {
    final orderAsync = ref.watch(salesOrderByIdProvider(widget.orderId));
    final orderItemsAsync = ref.watch(orderItemsProvider(widget.orderId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Pedido'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareOrder(context),
            tooltip: 'Compartir',
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(context, ref, value),
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'edit_status',
                    child: Row(
                      children: [
                        Icon(Icons.edit),
                        SizedBox(width: 8),
                        Text('Cambiar Estado'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'duplicate',
                    child: Row(
                      children: [
                        Icon(Icons.copy),
                        SizedBox(width: 8),
                        Text('Duplicar Pedido'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Eliminar', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Header
            orderAsync.when(
              data:
                  (order) =>
                      order != null
                          ? _buildOrderHeader(context, order)
                          : _buildNotFoundState(),
              loading: () => _buildLoadingHeader(),
              error: (_, __) => _buildErrorHeader(context, ref),
            ),
            const SizedBox(height: 20),

            // Order Items
            Text(
              'Productos del Pedido',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            orderItemsAsync.when(
              data: (items) => OrderItemsList(items: items),
              loading: () => _buildLoadingItems(),
              error: (_, __) => _buildErrorItems(context, ref),
            ),
            const SizedBox(height: 20),

            // Order Summary
            orderAsync.when(
              data:
                  (order) =>
                      order != null
                          ? _buildOrderSummary(
                            context,
                            order,
                            orderItemsAsync.value ?? [],
                            ref,
                          )
                          : const SizedBox(),
              loading: () => const SizedBox(),
              error: (_, __) => const SizedBox(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderHeader(BuildContext context, SalesOrder order) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pedido #${order.id.substring(0, 8)}',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                OrderStatusChip(status: order.status),
              ],
            ),
            const SizedBox(height: 16),

            _buildInfoRow(Icons.person, 'Cliente', order.customerName),
            const SizedBox(height: 12),

            _buildInfoRow(
              Icons.calendar_today,
              'Fecha del Pedido',
              _formatDate(order.date),
            ),
            const SizedBox(height: 12),

            _buildInfoRow(
              Icons.attach_money,
              'Total',
              '\$${order.total.toStringAsFixed(2)}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Text(
          '$label:',
          style: TextStyle(
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderSummary(
    BuildContext context,
    SalesOrder order,
    List<OrderItem> items,
    WidgetRef ref,
  ) {
    final subtotal = items.fold<double>(
      0,
      (sum, item) => sum + item.totalPrice,
    );
    final taxes = subtotal * 0.1; // 10% tax example
    final total = order.total;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumen del Pedido',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            _buildSummaryRow('Subtotal:', '\$${subtotal.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            _buildSummaryRow('Impuestos:', '\$${taxes.toStringAsFixed(2)}'),
            const Divider(),
            _buildSummaryRow(
              'Total:',
              '\$${total.toStringAsFixed(2)}',
              isTotal: true,
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showEditStatusDialog(context, ref, order),
                    child: const Text('Cambiar Estado'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _printOrder(context, order),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Imprimir'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            fontSize: isTotal ? 16 : 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isTotal ? 16 : 14,
            color: isTotal ? Colors.blue[600] : null,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingHeader() {
    return Card(
      child: Container(
        height: 150,
        padding: const EdgeInsets.all(16),
        child: const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _buildLoadingItems() {
    return Card(
      child: Container(
        height: 200,
        padding: const EdgeInsets.all(16),
        child: const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _buildErrorHeader(BuildContext context, WidgetRef ref) {
    return Card(
      child: Container(
        height: 150,
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red),
              const SizedBox(height: 8),
              const Text('Error al cargar el pedido'),
              TextButton(
                onPressed: () => ref.refresh(salesOrderByIdProvider(widget.orderId)),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorItems(BuildContext context, WidgetRef ref) {
    return Card(
      child: Container(
        height: 200,
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red),
              const SizedBox(height: 8),
              const Text('Error al cargar los productos'),
              TextButton(
                onPressed: () => ref.refresh(orderItemsProvider(widget.orderId)),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotFoundState() {
    return Card(
      child: Container(
        height: 150,
        padding: const EdgeInsets.all(16),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 48, color: Colors.grey),
              SizedBox(height: 8),
              Text('Pedido no encontrado'),
            ],
          ),
        ),
      ),
    );
  }

  void _handleMenuAction(BuildContext context, WidgetRef ref, String action) {
    switch (action) {
      case 'edit_status':
        final order = ref.read(salesOrderByIdProvider(widget.orderId)).value;
        if (order != null) {
          _showEditStatusDialog(context, ref, order);
        }
        break;
      case 'duplicate':
        _duplicateOrder(context, ref);
        break;
      case 'delete':
        _showDeleteDialog(context, ref);
        break;
    }
  }

  void _showEditStatusDialog(
    BuildContext context,
    WidgetRef ref,
    SalesOrder order,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Cambiar Estado del Pedido'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children:
                  OrderStatus.values
                      .map(
                        (status) => RadioListTile<OrderStatus>(
                          title: Text(_getStatusText(status)),
                          value: status,
                          groupValue: order.status,
                          onChanged: (value) async {
                            print('Cambiando estado a: $value');
                            if (value != null && value != order.status) {
                              // Cerrar el diálogo
                              Navigator.pop(context);

                              // Usar una función asíncrona separada para evitar problemas de contexto
                              _updateOrderStatus(order.id, value);
                            } else {
                              Navigator.pop(context);
                            }
                          },
                        ),
                      )
                      .toList(),
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

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Eliminar Pedido'),
            content: const Text(
              '¿Estás seguro de que quieres eliminar este pedido? Esta acción no se puede deshacer.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  // TODO: Implement delete functionality
                  Navigator.pop(context);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Pedido eliminado')),
                  );
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Eliminar'),
              ),
            ],
          ),
    );
  }

  void _duplicateOrder(BuildContext context, WidgetRef ref) {
    // TODO: Implement duplicate functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funcionalidad de duplicar pendiente')),
    );
  }

  void _shareOrder(BuildContext context) {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funcionalidad de compartir pendiente')),
    );
  }

  void _printOrder(BuildContext context, SalesOrder order) {
    // TODO: Implement print functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funcionalidad de imprimir pendiente')),
    );
  }

  Future<void> _updateOrderStatus(String orderId, OrderStatus newStatus) async {
    if (!mounted) return;

    // Mostrar indicador de progreso
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            ),
            SizedBox(width: 10),
            Text('Actualizando estado...'),
          ],
        ),
        duration: Duration(seconds: 1),
      ),
    );

    try {
      // Actualizar el estado con el provider
      final result = await ref.read(
        updateOrderStatusProvider((
          orderId: orderId,
          newStatus: newStatus,
        )).future,
      );

      // Verificar que el widget sigue montado antes de mostrar el SnackBar
      if (mounted) {
        if (result) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Estado actualizado a ${_getStatusText(newStatus)}',
              ),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Error al actualizar el estado',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('Error al actualizar estado: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: ${e.toString()}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Pendiente';
      case OrderStatus.confirmed:
        return 'Confirmado';
      case OrderStatus.shipped:
        return 'Enviado';
      case OrderStatus.delivered:
        return 'Entregado';
      case OrderStatus.cancelled:
        return 'Cancelado';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
