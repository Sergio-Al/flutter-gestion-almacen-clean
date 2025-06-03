import 'package:flutter/material.dart';
import '../../../../domain/entities/stock_batch.dart';
import '../../../../core/utils/date_formatter.dart';

class BatchCardWidget extends StatelessWidget {
  final StockBatch batch;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const BatchCardWidget({
    Key? key,
    required this.batch,
    this.onTap,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isExpired = batch.expiryDate?.isBefore(DateTime.now()) ?? false;
    final isNearExpiry = batch.expiryDate != null &&
        batch.expiryDate!.isAfter(DateTime.now()) &&
        batch.expiryDate!.isBefore(DateTime.now().add(const Duration(days: 30)));

    Color _getBatchStatusColor() {
      if (isExpired) return Colors.red;
      if (isNearExpiry) return Colors.orange;
      if (batch.quantity <= 0) return Colors.grey;
      return Colors.green;
    }

    IconData _getBatchStatusIcon() {
      if (isExpired) return Icons.warning;
      if (isNearExpiry) return Icons.schedule;
      if (batch.quantity <= 0) return Icons.inventory_2_outlined;
      return Icons.check_circle;
    }

    String _getBatchStatusText() {
      if (isExpired) return 'Vencido';
      if (isNearExpiry) return 'Próximo a Vencer';
      if (batch.quantity <= 0) return 'Sin Stock';
      return 'Disponible';
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with batch number and actions
              Row(
                children: [
                  Expanded(
                    child: Text(
                      batch.batchNumber,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getBatchStatusColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _getBatchStatusColor().withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getBatchStatusIcon(),
                          size: 16,
                          color: _getBatchStatusColor(),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getBatchStatusText(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: _getBatchStatusColor(),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (onEdit != null || onDelete != null)
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit' && onEdit != null) {
                          onEdit!();
                        } else if (value == 'delete' && onDelete != null) {
                          onDelete!();
                        }
                      },
                      itemBuilder: (context) => [
                        if (onEdit != null)
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 20),
                                SizedBox(width: 8),
                                Text('Editar'),
                              ],
                            ),
                          ),
                        if (onDelete != null)
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 20, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Eliminar', style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Batch details
              Row(
                children: [
                  Expanded(
                    child: _buildInfoRow(
                      'Cantidad',
                      '${batch.quantity}',
                      Icons.inventory,
                      context,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildInfoRow(
                      'Recibido',
                      DateFormatter.formatDate(batch.receivedDate),
                      Icons.event_available,
                      context,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              if (batch.expiryDate != null) ...[
                const SizedBox(height: 8),
                _buildInfoRow(
                  'Vencimiento',
                  DateFormatter.formatDate(batch.expiryDate!),
                  Icons.event,
                  context,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
