import 'package:flutter/material.dart';
import '../../products/create_product_page.dart';

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
        Expanded(
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildActionCard(
                context,
                'Crear Producto',
                Icons.add_shopping_cart,
                Colors.blue,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateProductPage(),
                  ),
                ),
              ),
              _buildActionCard(
                context,
                'Ver Productos',
                Icons.inventory,
                Colors.green,
                () => _showComingSoon(context),
              ),
              _buildActionCard(
                context,
                'Gestionar Stock',
                Icons.storage,
                Colors.orange,
                () => _showComingSoon(context),
              ),
              _buildActionCard(
                context,
                'Ventas',
                Icons.point_of_sale,
                Colors.purple,
                () => _showComingSoon(context),
              ),
              _buildActionCard(
                context,
                'Almacenes',
                Icons.warehouse,
                Colors.teal,
                () => _showComingSoon(context),
              ),
              _buildActionCard(
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

  Widget _buildActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.1),
                color.withOpacity(0.05),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 40,
                color: color,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
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
