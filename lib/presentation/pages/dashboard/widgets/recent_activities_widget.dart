import 'package:flutter/material.dart';

class RecentActivitiesWidget extends StatelessWidget {
  const RecentActivitiesWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Actividades Recientes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  _buildActivityItem(
                    'Producto "Laptop HP" agregado al inventario',
                    '2 min',
                    Icons.add_circle,
                    Colors.green,
                  ),
                  _buildActivityItem(
                    'Venta procesada: #VT-2024-001',
                    '15 min',
                    Icons.point_of_sale,
                    Colors.blue,
                  ),
                  _buildActivityItem(
                    'Stock actualizado: Mouse Inalámbrico',
                    '32 min',
                    Icons.update,
                    Colors.orange,
                  ),
                  _buildActivityItem(
                    'Nuevo usuario registrado: Ana García',
                    '1 h',
                    Icons.person_add,
                    Colors.purple,
                  ),
                  _buildActivityItem(
                    'Respaldo de base de datos completado',
                    '2 h',
                    Icons.backup,
                    Colors.teal,
                  ),
                  _buildActivityItem(
                    'Reporte mensual generado',
                    '3 h',
                    Icons.analytics,
                    Colors.red,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(
    String activity,
    String time,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 16,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Hace $time',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
