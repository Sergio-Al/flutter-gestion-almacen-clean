import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/dashboard_providers.dart';
import '../../widgets/dashboard/stat_card.dart';
import '../../widgets/dashboard/sales_chart.dart';
import '../../widgets/dashboard/activity_item.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Obtener datos del dashboard
    final totalProductsAsync = ref.watch(totalProductsProvider);
    final lowStockAlertsAsync = ref.watch(lowStockAlertsCountProvider);
    final todaysSalesAsync = ref.watch(todaysSalesProvider);
    final activeOrdersAsync = ref.watch(activeOrdersCountProvider);
    final salesPerformanceAsync = ref.watch(salesPerformanceProvider(30)); // Últimos 30 días
    final warehouseCapacityAsync = ref.watch(warehouseCapacityProvider('warehouse-main')); // ID del almacén principal
    
    final today = DateTime.now();
    final dateFormat = DateFormat('MMMM d, yyyy');
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Acción de configuración
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Recargar todos los providers
          ref.refresh(totalProductsProvider);
          ref.refresh(lowStockAlertsCountProvider);
          ref.refresh(todaysSalesProvider);
          ref.refresh(activeOrdersCountProvider);
          ref.refresh(salesPerformanceProvider(30));
          ref.refresh(warehouseCapacityProvider('warehouse-main'));
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Cabecera del dashboard
            Text(
              'Welcome back, Alex',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Today is ${dateFormat.format(today)}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            
            // Tarjetas de estadísticas (primera fila)
            Row(
              children: [
                Expanded(
                  child: totalProductsAsync.when(
                    data: (count) => StatCard(
                      title: 'Total Products',
                      value: count.toString(),
                      percentChange: 10,
                      isPositive: true,
                      icon: Icons.inventory_2,
                    ),
                    loading: () => const StatCard.loading(title: 'Total Products'),
                    error: (_, __) => StatCard.error(title: 'Total Products'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: lowStockAlertsAsync.when(
                    data: (count) => StatCard(
                      title: 'Low Stock Alerts',
                      value: count.toString(),
                      percentChange: 5,
                      isPositive: false,
                      icon: Icons.warning_amber,
                      iconColor: Colors.orange,
                    ),
                    loading: () => const StatCard.loading(title: 'Low Stock Alerts'),
                    error: (_, __) => StatCard.error(title: 'Low Stock Alerts'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Tarjetas de estadísticas (segunda fila)
            Row(
              children: [
                Expanded(
                  child: todaysSalesAsync.when(
                    data: (amount) => StatCard(
                      title: 'Today\'s Sales',
                      value: currencyFormat.format(amount),
                      percentChange: 15,
                      isPositive: true,
                      icon: Icons.attach_money,
                      iconColor: Colors.green,
                    ),
                    loading: () => const StatCard.loading(title: 'Today\'s Sales'),
                    error: (_, __) => StatCard.error(title: 'Today\'s Sales'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: activeOrdersAsync.when(
                    data: (count) => StatCard(
                      title: 'Active Orders',
                      value: count.toString(),
                      percentChange: 8,
                      isPositive: true,
                      icon: Icons.local_shipping,
                    ),
                    loading: () => const StatCard.loading(title: 'Active Orders'),
                    error: (_, __) => StatCard.error(title: 'Active Orders'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Gráfico de rendimiento de ventas
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sales Performance',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  salesPerformanceAsync.when(
                    data: (data) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currencyFormat.format(data.totalAmount),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Text('Last 30 Days'),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: data.percentChange >= 0 ? Colors.green[50] : Colors.red[50],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${data.percentChange >= 0 ? "+" : ""}${data.percentChange.toStringAsFixed(1)}%',
                                style: TextStyle(
                                  color: data.percentChange >= 0 ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 200,
                          child: SalesChart(data: data.dailyData),
                        ),
                      ],
                    ),
                    loading: () => const Center(
                      child: SizedBox(
                        height: 200,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    ),
                    error: (_, __) => const SizedBox(
                      height: 200,
                      child: Center(child: Text('Error loading sales data')),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Actividad reciente
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recent Activities',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Ejemplo de elementos de actividad
                  ActivityItem(
                    icon: Icons.local_shipping,
                    title: 'Order #12345 shipped',
                    time: '10:30 AM',
                  ),
                  const Divider(),
                  ActivityItem(
                    icon: Icons.inventory,
                    title: 'Product \'Widget X\' restocked',
                    time: '11:45 AM',
                  ),
                  const Divider(),
                  ActivityItem(
                    icon: Icons.shopping_cart,
                    title: 'New order received #67890',
                    time: '1:20 PM',
                  ),
                  const Divider(),
                  ActivityItem(
                    icon: Icons.edit,
                    title: 'Stock adjustment for \'Gadget Y\'',
                    time: '2:55 PM',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Capacidad del almacén
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Warehouse Capacity',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  warehouseCapacityAsync.when(
                    data: (data) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: data.capacityPercentage / 100,
                            minHeight: 8,
                            backgroundColor: Colors.grey[200],
                            color: data.capacityPercentage > 90
                                ? Colors.red
                                : data.capacityPercentage > 70
                                    ? Colors.orange
                                    : Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('${data.capacityPercentage.toStringAsFixed(0)}%'),
                      ],
                    ),
                    loading: () => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    error: (_, __) => const Text('Error loading warehouse data'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Mostrar menú de acciones rápidas
          showModalBottomSheet(
            context: context,
            builder: (context) => Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.add_shopping_cart),
                    title: const Text('Nueva Orden de Venta'),
                    onTap: () {
                      Navigator.pop(context);
                      // TODO: Navigate to create sales order
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.add_box),
                    title: const Text('Nuevo Producto'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/products/create');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.warehouse),
                    title: const Text('Nuevo Almacén'),
                    onTap: () {
                      Navigator.pop(context);
                      // TODO: Navigate to create warehouse
                    },
                  ),
                ],
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'Productos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt),
            label: 'Órdenes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Ajustes',
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/products');
              break;
            case 2:
              // TODO: Implementar navegación a órdenes
              break;
            case 3:
              // TODO: Implementar navegación a ajustes
              break;
          }
        },
      ),
    );
  }
}
