import 'package:flutter/material.dart';

class CapacityIndicator extends StatelessWidget {
  final int currentStock;
  final int capacity;
  final String? title;

  const CapacityIndicator({
    super.key,
    required this.currentStock,
    required this.capacity,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final occupancyRate = capacity > 0 ? (currentStock / capacity * 100).clamp(0, 100).toDouble() : 0.0;
    final color = _getCapacityColor(occupancyRate);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.inventory_2,
                  color: color,
                ),
                const SizedBox(width: 8),
                Text(
                  title ?? 'Capacidad del Almacén',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Circular Progress Indicator
            Center(
              child: SizedBox(
                width: 160,
                height: 160,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Background Circle
                    SizedBox(
                      width: 160,
                      height: 160,
                      child: CircularProgressIndicator(
                        value: 1.0,
                        strokeWidth: 12,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[200]!),
                      ),
                    ),
                    
                    // Progress Circle
                    SizedBox(
                      width: 160,
                      height: 160,
                      child: CircularProgressIndicator(
                        value: occupancyRate / 100,
                        strokeWidth: 12,
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    
                    // Center Content
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${occupancyRate.toStringAsFixed(1)}%',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                        Text(
                          'Ocupado',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Stock Information
            _buildStockInfo(context, color),
            const SizedBox(height: 16),

            // Status Indicators
            _buildStatusIndicators(context, occupancyRate),
          ],
        ),
      ),
    );
  }

  Widget _buildStockInfo(BuildContext context, Color color) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Text(
                  currentStock.toString(),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  'En Stock',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.grey[300],
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  capacity.toString(),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                Text(
                  'Capacidad Total',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.grey[300],
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  (capacity - currentStock).toString(),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green[600],
                  ),
                ),
                Text(
                  'Disponible',
                  style: theme.textTheme.bodySmall?.copyWith(
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

  Widget _buildStatusIndicators(BuildContext context, double occupancyRate) {
    return Row(
      children: [
        Expanded(
          child: _buildStatusCard(
            context,
            'Estado',
            _getStatusText(occupancyRate),
            _getStatusIcon(occupancyRate),
            _getCapacityColor(occupancyRate),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatusCard(
            context,
            'Nivel',
            _getLevelText(occupancyRate),
            _getLevelIcon(occupancyRate),
            _getLevelColor(occupancyRate),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getCapacityColor(double occupancyRate) {
    if (occupancyRate >= 95) return Colors.red[600]!;
    if (occupancyRate >= 85) return Colors.orange[600]!;
    if (occupancyRate >= 70) return Colors.amber[600]!;
    if (occupancyRate >= 30) return Colors.green[600]!;
    return Colors.blue[600]!;
  }

  Color _getLevelColor(double occupancyRate) {
    if (occupancyRate >= 80) return Colors.red[600]!;
    if (occupancyRate >= 60) return Colors.orange[600]!;
    if (occupancyRate >= 40) return Colors.green[600]!;
    return Colors.blue[600]!;
  }

  String _getStatusText(double occupancyRate) {
    if (occupancyRate >= 95) return 'Crítico';
    if (occupancyRate >= 85) return 'Alto';
    if (occupancyRate >= 70) return 'Medio';
    if (occupancyRate >= 30) return 'Normal';
    return 'Bajo';
  }

  String _getLevelText(double occupancyRate) {
    if (occupancyRate >= 80) return 'Lleno';
    if (occupancyRate >= 60) return 'Alto';
    if (occupancyRate >= 40) return 'Medio';
    if (occupancyRate >= 20) return 'Bajo';
    return 'Vacío';
  }

  IconData _getStatusIcon(double occupancyRate) {
    if (occupancyRate >= 95) return Icons.warning;
    if (occupancyRate >= 85) return Icons.priority_high;
    if (occupancyRate >= 70) return Icons.info;
    if (occupancyRate >= 30) return Icons.check_circle;
    return Icons.inventory_2;
  }

  IconData _getLevelIcon(double occupancyRate) {
    if (occupancyRate >= 80) return Icons.trending_up;
    if (occupancyRate >= 60) return Icons.trending_neutral;
    if (occupancyRate >= 40) return Icons.trending_neutral;
    if (occupancyRate >= 20) return Icons.trending_down;
    return Icons.inventory_2_outlined;
  }
}
