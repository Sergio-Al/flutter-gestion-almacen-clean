import 'package:flutter/material.dart';

enum BackupStatus {
  idle,
  preparing,
  inProgress,
  completed,
  error,
  cancelled,
}

class BackupProgressWidget extends StatelessWidget {
  final BackupStatus status;
  final double progress;
  final String? currentTask;
  final String? errorMessage;
  final VoidCallback? onCancel;
  final VoidCallback? onRetry;
  final VoidCallback? onClose;

  const BackupProgressWidget({
    Key? key,
    required this.status,
    this.progress = 0.0,
    this.currentTask,
    this.errorMessage,
    this.onCancel,
    this.onRetry,
    this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildStatusIcon(colorScheme),
          const SizedBox(height: 16),
          _buildStatusText(theme),
          if (currentTask != null && status == BackupStatus.inProgress) ...[
            const SizedBox(height: 8),
            Text(
              currentTask!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          if (status == BackupStatus.inProgress) ...[
            const SizedBox(height: 16),
            _buildProgressIndicator(colorScheme, theme),
          ],
          if (errorMessage != null && status == BackupStatus.error) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: colorScheme.onErrorContainer,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      errorMessage!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          _buildActionButtons(context, theme),
        ],
      ),
    );
  }

  Widget _buildStatusIcon(ColorScheme colorScheme) {
    IconData icon;
    Color color;

    switch (status) {
      case BackupStatus.idle:
        icon = Icons.cloud_upload_outlined;
        color = colorScheme.primary;
        break;
      case BackupStatus.preparing:
        icon = Icons.hourglass_empty;
        color = colorScheme.primary;
        break;
      case BackupStatus.inProgress:
        icon = Icons.cloud_sync;
        color = colorScheme.primary;
        break;
      case BackupStatus.completed:
        icon = Icons.cloud_done;
        color = colorScheme.primary;
        break;
      case BackupStatus.error:
        icon = Icons.cloud_off;
        color = colorScheme.error;
        break;
      case BackupStatus.cancelled:
        icon = Icons.cancel_outlined;
        color = colorScheme.onSurfaceVariant;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: 48,
        color: color,
      ),
    );
  }

  Widget _buildStatusText(ThemeData theme) {
    String title;
    String subtitle;

    switch (status) {
      case BackupStatus.idle:
        title = 'Listo para respaldar';
        subtitle = 'Inicia el proceso de respaldo cuando estés listo';
        break;
      case BackupStatus.preparing:
        title = 'Preparando respaldo...';
        subtitle = 'Analizando datos y preparando archivos';
        break;
      case BackupStatus.inProgress:
        title = 'Respaldando datos...';
        subtitle = '${(progress * 100).toInt()}% completado';
        break;
      case BackupStatus.completed:
        title = 'Respaldo completado';
        subtitle = 'Tus datos han sido respaldados exitosamente';
        break;
      case BackupStatus.error:
        title = 'Error en el respaldo';
        subtitle = 'Ocurrió un problema durante el proceso';
        break;
      case BackupStatus.cancelled:
        title = 'Respaldo cancelado';
        subtitle = 'El proceso fue cancelado por el usuario';
        break;
    }

    return Column(
      children: [
        Text(
          title,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildProgressIndicator(ColorScheme colorScheme, ThemeData theme) {
    return Column(
      children: [
        LinearProgressIndicator(
          value: progress,
          backgroundColor: colorScheme.surfaceVariant,
          valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${(progress * 100).toInt()}%',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (status == BackupStatus.inProgress)
              Text(
                'Respaldando...',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.primary,
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, ThemeData theme) {
    switch (status) {
      case BackupStatus.idle:
        return const SizedBox.shrink();
      case BackupStatus.preparing:
      case BackupStatus.inProgress:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (onCancel != null)
              TextButton(
                onPressed: onCancel,
                child: const Text('Cancelar'),
              ),
          ],
        );
      case BackupStatus.completed:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (onClose != null)
              FilledButton(
                onPressed: onClose,
                child: const Text('Cerrar'),
              ),
          ],
        );
      case BackupStatus.error:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            if (onClose != null)
              TextButton(
                onPressed: onClose,
                child: const Text('Cerrar'),
              ),
            if (onRetry != null)
              FilledButton(
                onPressed: onRetry,
                child: const Text('Reintentar'),
              ),
          ],
        );
      case BackupStatus.cancelled:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (onClose != null)
              FilledButton(
                onPressed: onClose,
                child: const Text('Cerrar'),
              ),
          ],
        );
    }
  }
}

// Widget simplificado para mostrar el progreso en línea
class InlineBackupProgress extends StatelessWidget {
  final double progress;
  final String? status;
  final bool isActive;

  const InlineBackupProgress({
    Key? key,
    this.progress = 0.0,
    this.status,
    this.isActive = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (!isActive && status == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  value: isActive ? null : progress,
                  valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  status ?? 'Procesando...',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (!isActive)
                Text(
                  '${(progress * 100).toInt()}%',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          if (!isActive) ...[
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: colorScheme.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
            ),
          ],
        ],
      ),
    );
  }
}
