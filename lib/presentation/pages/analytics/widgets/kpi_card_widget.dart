import 'package:flutter/material.dart';

class KpiCardWidget extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String? trend;
  final double? trendValue;
  final bool isPositiveTrend;

  const KpiCardWidget({
    Key? key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.trend,
    this.trendValue,
    this.isPositiveTrend = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 3,
      child: Container(
        padding: const EdgeInsets.all(16),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (trend != null && trendValue != null) ...[
                  const SizedBox(width: 8),
                  _buildTrendIndicator(context),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendIndicator(BuildContext context) {
    final theme = Theme.of(context);
    final trendColor = isPositiveTrend ? Colors.green : Colors.red;
    final trendIcon = isPositiveTrend ? Icons.trending_up : Icons.trending_down;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: trendColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            trendIcon,
            size: 12,
            color: trendColor,
          ),
          const SizedBox(width: 2),
          Text(
            '${trendValue!.abs().toStringAsFixed(1)}%',
            style: theme.textTheme.bodySmall?.copyWith(
              color: trendColor,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

// Predefined KPI card types for common use cases
class RevenueKpiCard extends StatelessWidget {
  final double revenue;
  final double? previousRevenue;

  const RevenueKpiCard({
    Key? key,
    required this.revenue,
    this.previousRevenue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double? trendValue;
    bool isPositive = true;

    if (previousRevenue != null && previousRevenue! > 0) {
      trendValue = ((revenue - previousRevenue!) / previousRevenue!) * 100;
      isPositive = trendValue >= 0;
    }

    return KpiCardWidget(
      title: 'Ingresos Totales',
      value: '\$${revenue.toStringAsFixed(0)}',
      subtitle: 'Este período',
      icon: Icons.attach_money,
      color: Colors.green,
      trendValue: trendValue,
      isPositiveTrend: isPositive,
    );
  }
}

class OrdersKpiCard extends StatelessWidget {
  final int orders;
  final int? previousOrders;

  const OrdersKpiCard({
    Key? key,
    required this.orders,
    this.previousOrders,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double? trendValue;
    bool isPositive = true;

    if (previousOrders != null && previousOrders! > 0) {
      trendValue = ((orders - previousOrders!) / previousOrders!) * 100;
      isPositive = trendValue >= 0;
    }

    return KpiCardWidget(
      title: 'Órdenes',
      value: orders.toString(),
      subtitle: 'Este período',
      icon: Icons.receipt_long,
      color: Colors.blue,
      trendValue: trendValue,
      isPositiveTrend: isPositive,
    );
  }
}

class InventoryValueKpiCard extends StatelessWidget {
  final double inventoryValue;
  final double? previousValue;

  const InventoryValueKpiCard({
    Key? key,
    required this.inventoryValue,
    this.previousValue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double? trendValue;
    bool isPositive = true;

    if (previousValue != null && previousValue! > 0) {
      trendValue = ((inventoryValue - previousValue!) / previousValue!) * 100;
      isPositive = trendValue >= 0;
    }

    return KpiCardWidget(
      title: 'Valor Inventario',
      value: '\$${inventoryValue.toStringAsFixed(0)}',
      subtitle: 'Valor actual',
      icon: Icons.inventory,
      color: Colors.orange,
      trendValue: trendValue,
      isPositiveTrend: isPositive,
    );
  }
}

class TurnoverRateKpiCard extends StatelessWidget {
  final double turnoverRate;
  final double? previousRate;

  const TurnoverRateKpiCard({
    Key? key,
    required this.turnoverRate,
    this.previousRate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double? trendValue;
    bool isPositive = true;

    if (previousRate != null && previousRate! > 0) {
      trendValue = ((turnoverRate - previousRate!) / previousRate!) * 100;
      isPositive = trendValue >= 0;
    }

    return KpiCardWidget(
      title: 'Rotación Inventario',
      value: '${turnoverRate.toStringAsFixed(1)}x',
      subtitle: 'Veces por año',
      icon: Icons.sync_alt,
      color: Colors.purple,
      trendValue: trendValue,
      isPositiveTrend: isPositive,
    );
  }
}
