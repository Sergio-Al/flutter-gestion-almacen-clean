import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/sales_providers.dart';
import '../../../domain/entities/sales_order.dart';
import 'orders_list_page.dart';
import 'create_order_page.dart';
import 'customers_page.dart';
import 'widgets/sales_chart_canvas.dart';

class SalesDashboardPage extends ConsumerWidget {
  const SalesDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final salesOrdersAsync = ref.watch(salesOrdersProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard de Ventas'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(salesOrdersProvider);
            },
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick Actions
            _buildQuickActions(context),
            const SizedBox(height: 20),
            
            // Statistics Cards
            salesOrdersAsync.when(
              data: (orders) => _buildStatisticsCards(context, orders),
              loading: () => _buildLoadingCards(),
              error: (_, __) => _buildErrorCards(context, ref),
            ),
            const SizedBox(height: 20),
            
            // Sales Chart
            SalesChartCanvas(
              height: 300,
              salesData: salesOrdersAsync.maybeWhen(
                data: (orders) => orders.map((order) => order.total).toList(),
                orElse: () => [],
              ),
            ),
            const SizedBox(height: 20),
            
            // Recent Orders
            Text(
              'Pedidos Recientes',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            salesOrdersAsync.when(
              data: (orders) => _buildRecentOrders(context, orders),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => _buildErrorWidget(context, ref),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const CreateOrderPage(),
          ),
        ),
        backgroundColor: Colors.blue[600],
        child: const Icon(Icons.add, color: Colors.white),
        tooltip: 'Crear Pedido',
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Acciones Rápidas',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    context,
                    'Nuevo Pedido',
                    Icons.add_shopping_cart,
                    Colors.green,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreateOrderPage(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    context,
                    'Ver Pedidos',
                    Icons.list_alt,
                    Colors.blue,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const OrdersListPage(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    context,
                    'Clientes',
                    Icons.people,
                    Colors.orange,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CustomersPage(),
                      ),
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

  Widget _buildActionButton(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: color.withOpacity(0.3)),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCards(BuildContext context, List<SalesOrder> orders) {
    final today = DateTime.now();
    final thisMonth = DateTime(today.year, today.month);
    
    final todayOrders = orders.where((order) =>
        order.date.year == today.year &&
        order.date.month == today.month &&
        order.date.day == today.day).toList();
    
    final monthOrders = orders.where((order) =>
        order.date.isAfter(thisMonth)).toList();
    
    final completedOrders = orders.where((order) =>
        order.status == OrderStatus.delivered).toList();
    
    final todaySales = todayOrders.fold<double>(0, (sum, order) => sum + order.total);
    final monthSales = monthOrders.fold<double>(0, (sum, order) => sum + order.total);
    final totalSales = orders.fold<double>(0, (sum, order) => sum + order.total);

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            'Hoy',
            '\$${todaySales.toStringAsFixed(0)}',
            todayOrders.length.toString(),
            'pedidos',
            Icons.today,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            'Mes',
            '\$${monthSales.toStringAsFixed(0)}',
            monthOrders.length.toString(),
            'pedidos',
            Icons.calendar_month,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            'Total',
            '\$${totalSales.toStringAsFixed(0)}',
            completedOrders.length.toString(),
            'completados',
            Icons.trending_up,
            Colors.purple,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String mainValue,
    String subValue,
    String subLabel,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 24),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    title,
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              mainValue,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$subValue $subLabel',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingCards() {
    return Row(
      children: List.generate(3, (index) => 
        Expanded(
          child: Card(
            child: Container(
              height: 120,
              padding: const EdgeInsets.all(16),
              child: const Center(child: CircularProgressIndicator()),
            ),
          ),
        ),
      ).expand((widget) => [widget, const SizedBox(width: 12)]).take(5).toList(),
    );
  }

  Widget _buildErrorCards(BuildContext context, WidgetRef ref) {
    return Card(
      child: Container(
        height: 120,
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red),
              const SizedBox(height: 8),
              const Text('Error al cargar estadísticas'),
              TextButton(
                onPressed: () => ref.invalidate(salesOrdersProvider),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentOrders(BuildContext context, List<SalesOrder> orders) {
    final recentOrders = orders.take(5).toList();
    
    if (recentOrders.isEmpty) {
      return Card(
        child: Container(
          height: 200,
          padding: const EdgeInsets.all(16),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_cart_outlined, size: 48, color: Colors.grey),
                SizedBox(height: 8),
                Text('No hay pedidos recientes'),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      child: Column(
        children: [
          ...recentOrders.map((order) => ListTile(
            leading: CircleAvatar(
              backgroundColor: _getStatusColor(order.status).withOpacity(0.1),
              child: Icon(
                _getStatusIcon(order.status),
                color: _getStatusColor(order.status),
                size: 20,
              ),
            ),
            title: Text(order.customerName),
            subtitle: Text(
              '${_formatDate(order.date)} • \$${order.total.toStringAsFixed(2)}',
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(order.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getStatusText(order.status),
                style: TextStyle(
                  color: _getStatusColor(order.status),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            onTap: () => Navigator.pushNamed(
              context,
              '/order-detail',
              arguments: order.id,
            ),
          )),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.view_list),
            title: const Text('Ver todos los pedidos'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const OrdersListPage(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, WidgetRef ref) {
    return Card(
      child: Container(
        height: 200,
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 8),
              const Text('Error al cargar pedidos'),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => ref.invalidate(salesOrdersProvider),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.confirmed:
        return Colors.blue;
      case OrderStatus.shipped:
        return Colors.indigo;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Icons.pending;
      case OrderStatus.confirmed:
        return Icons.check_circle_outline;
      case OrderStatus.shipped:
        return Icons.local_shipping;
      case OrderStatus.delivered:
        return Icons.check_circle;
      case OrderStatus.cancelled:
        return Icons.cancel;
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
