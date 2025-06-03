import 'package:flutter/material.dart';
import '../../products/add_edit_product_page.dart';
import '../../products/products_list_page.dart';
import '../../inventory/inventory_overview_page.dart';
import '../../warehouses/warehouses_list_page.dart';
import '../../sales/sales_dashboard_page.dart';

class QuickActionsWidget extends StatelessWidget {
  const QuickActionsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Acciones Rápidas',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildCircularActionButton(
                context,
                'Crear Producto',
                Icons.add_shopping_cart,
                Colors.blue,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddEditProductPage(),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              _buildCircularActionButton(
                context,
                'Ver Productos',
                Icons.inventory,
                Colors.green,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProductsListPage(),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              _buildCircularActionButton(
                context,
                'Gestionar Stock',
                Icons.storage,
                Colors.orange,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const InventoryOverviewPage(),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              _buildCircularActionButton(
                context,
                'Ventas',
                Icons.point_of_sale,
                Colors.purple,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SalesDashboardPage(),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              _buildCircularActionButton(
                context,
                'Almacenes',
                Icons.warehouse,
                Colors.teal,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WarehousesListPage(),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              _buildCircularActionButton(
                context,
                'Reportes',
                Icons.analytics,
                Colors.red,
                () => _showComingSoon(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCircularActionButton(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color,
                  color.withOpacity(0.7),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 32,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 80,
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Función próximamente disponible'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
