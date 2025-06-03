import 'package:flutter/material.dart';
import '../../../../domain/entities/sales_order.dart';

class OrderStatusChip extends StatelessWidget {
  final OrderStatus status;
  final bool showLabel;

  const OrderStatusChip({
    super.key,
    required this.status,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final statusData = _getStatusData(status);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusData.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: statusData.color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusData.icon,
            size: 16,
            color: statusData.color,
          ),
          if (showLabel) ...[
            const SizedBox(width: 6),
            Text(
              statusData.label,
              style: TextStyle(
                color: statusData.color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  _StatusData _getStatusData(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return _StatusData(
          label: 'Pendiente',
          color: Colors.orange,
          icon: Icons.schedule,
        );
      case OrderStatus.confirmed:
        return _StatusData(
          label: 'Confirmado',
          color: Colors.blue,
          icon: Icons.check_circle_outline,
        );
      case OrderStatus.shipped:
        return _StatusData(
          label: 'Enviado',
          color: Colors.purple,
          icon: Icons.local_shipping,
        );
      case OrderStatus.delivered:
        return _StatusData(
          label: 'Entregado',
          color: Colors.green,
          icon: Icons.check_circle,
        );
      case OrderStatus.cancelled:
        return _StatusData(
          label: 'Cancelado',
          color: Colors.red,
          icon: Icons.cancel,
        );
    }
  }
}

class _StatusData {
  final String label;
  final Color color;
  final IconData icon;

  const _StatusData({
    required this.label,
    required this.color,
    required this.icon,
  });
}
