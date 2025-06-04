import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'widgets/settings_tile_widget.dart';
import 'widgets/backup_progress_widget.dart';

class BackupRestorePage extends ConsumerStatefulWidget {
  const BackupRestorePage({Key? key}) : super(key: key);

  @override
  ConsumerState<BackupRestorePage> createState() => _BackupRestorePageState();
}

class _BackupRestorePageState extends ConsumerState<BackupRestorePage>
    with TickerProviderStateMixin {
  bool _autoBackupEnabled = true;
  bool _backupOnWifiOnly = true;
  bool _includeImages = true;
  String _backupFrequency = 'Diaria';
  String _cloudProvider = 'Google Drive';
  
  BackupStatus _currentBackupStatus = BackupStatus.idle;
  double _backupProgress = 0.0;
  String? _currentTask;
  String? _errorMessage;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Respaldo y Restauración'),
        backgroundColor: colorScheme.surfaceVariant,
        actions: [
          IconButton(
            onPressed: _showBackupInfo,
            icon: const Icon(Icons.info_outline),
            tooltip: 'Información',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildBackupActionsSection(theme),
          const SizedBox(height: 24),
          if (_currentBackupStatus != BackupStatus.idle) ...[
            _buildBackupProgressSection(theme),
            const SizedBox(height: 24),
          ],
          _buildAutoBackupSection(theme),
          const SizedBox(height: 24),
          _buildCloudSettingsSection(theme),
          const SizedBox(height: 24),
          _buildBackupHistorySection(theme),
          const SizedBox(height: 24),
          _buildAdvancedSettingsSection(theme),
        ],
      ),
    );
  }

  Widget _buildBackupActionsSection(ThemeData theme) {
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Acciones de Respaldo',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    context,
                    icon: Icons.cloud_upload,
                    title: 'Crear Respaldo',
                    subtitle: 'Respaldar datos ahora',
                    color: colorScheme.primary,
                    onTap: _startBackup,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    context,
                    icon: Icons.cloud_download,
                    title: 'Restaurar',
                    subtitle: 'Restaurar datos',
                    color: colorScheme.secondary,
                    onTap: _showRestoreOptions,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return ScaleTransition(
      scale: _scaleAnimation,
      child: InkWell(
        onTap: () {
          _animationController.forward().then((_) {
            _animationController.reverse();
          });
          onTap();
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withOpacity(0.3),
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackupProgressSection(ThemeData theme) {
    return BackupProgressWidget(
      status: _currentBackupStatus,
      progress: _backupProgress,
      currentTask: _currentTask,
      errorMessage: _errorMessage,
      onCancel: _cancelBackup,
      onRetry: _retryBackup,
      onClose: _closeBackupProgress,
    );
  }

  Widget _buildAutoBackupSection(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Respaldo Automático',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SettingsSwitchTile(
            icon: Icons.schedule,
            title: 'Respaldo automático',
            subtitle: 'Crear respaldos de forma automática',
            value: _autoBackupEnabled,
            onChanged: (value) {
              setState(() {
                _autoBackupEnabled = value;
              });
            },
          ),
          SettingsSelectionTile(
            icon: Icons.repeat,
            title: 'Frecuencia',
            subtitle: 'Con qué frecuencia crear respaldos',
            currentValue: _backupFrequency,
            enabled: _autoBackupEnabled,
            onTap: _showFrequencySelector,
          ),
          SettingsSwitchTile(
            icon: Icons.wifi,
            title: 'Solo con WiFi',
            subtitle: 'Crear respaldos solo con conexión WiFi',
            value: _backupOnWifiOnly,
            enabled: _autoBackupEnabled,
            onChanged: (value) {
              setState(() {
                _backupOnWifiOnly = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCloudSettingsSection(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Configuración de Nube',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SettingsSelectionTile(
            icon: Icons.cloud,
            title: 'Proveedor de nube',
            subtitle: 'Donde almacenar los respaldos',
            currentValue: _cloudProvider,
            onTap: _showCloudProviderSelector,
          ),
          SettingsTileWidget(
            icon: Icons.storage,
            title: 'Espacio usado',
            subtitle: '2.5 GB de 15 GB utilizados',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: 0.17, // 2.5/15
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right),
              ],
            ),
            onTap: _showStorageDetails,
          ),
          SettingsTileWidget(
            icon: Icons.account_circle,
            title: 'Cuenta conectada',
            subtitle: 'usuario@gmail.com',
            trailing: const Icon(Icons.chevron_right),
            onTap: _manageCloudAccount,
            showDivider: false,
          ),
        ],
      ),
    );
  }

  Widget _buildBackupHistorySection(ThemeData theme) {
    final backups = [
      {
        'date': '2024-01-15',
        'time': '14:30',
        'size': '1.2 GB',
        'type': 'Automático',
        'status': 'Completado',
      },
      {
        'date': '2024-01-14',
        'time': '14:30',
        'size': '1.1 GB',
        'type': 'Automático',
        'status': 'Completado',
      },
      {
        'date': '2024-01-13',
        'time': '09:15',
        'size': '1.1 GB',
        'type': 'Manual',
        'status': 'Completado',
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Historial de Respaldos',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: _showFullHistory,
                  child: const Text('Ver todo'),
                ),
              ],
            ),
          ),
          ...backups.take(3).map((backup) {
            final isLast = backup == backups.last;
            return _buildBackupHistoryItem(theme, backup, !isLast);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildBackupHistoryItem(
    ThemeData theme,
    Map<String, String> backup,
    bool showDivider,
  ) {
    final colorScheme = theme.colorScheme;

    return SettingsTileWidget(
      icon: backup['type'] == 'Automático'
          ? Icons.schedule
          : Icons.touch_app,
      title: '${backup['date']} - ${backup['time']}',
      subtitle: '${backup['size']} • ${backup['type']}',
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              backup['status']!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, size: 20),
        ],
      ),
      showDivider: showDivider,
      onTap: () => _showBackupDetails(backup),
    );
  }

  Widget _buildAdvancedSettingsSection(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Configuración Avanzada',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SettingsSwitchTile(
            icon: Icons.image,
            title: 'Incluir imágenes',
            subtitle: 'Respaldar fotos de productos',
            value: _includeImages,
            onChanged: (value) {
              setState(() {
                _includeImages = value;
              });
            },
          ),
          SettingsTileWidget(
            icon: Icons.security,
            title: 'Cifrado',
            subtitle: 'Configurar cifrado de respaldos',
            trailing: const Icon(Icons.chevron_right),
            onTap: _showEncryptionSettings,
          ),
          SettingsTileWidget(
            icon: Icons.delete_outline,
            title: 'Retención de respaldos',
            subtitle: 'Mantener respaldos por 30 días',
            trailing: const Icon(Icons.chevron_right),
            onTap: _showRetentionSettings,
            showDivider: false,
          ),
        ],
      ),
    );
  }

  // Métodos de acción
  void _startBackup() {
    setState(() {
      _currentBackupStatus = BackupStatus.preparing;
      _backupProgress = 0.0;
      _currentTask = 'Preparando respaldo...';
      _errorMessage = null;
    });

    // Simular proceso de respaldo
    Future.delayed(const Duration(seconds: 2), () {
      if (_currentBackupStatus == BackupStatus.preparing) {
        setState(() {
          _currentBackupStatus = BackupStatus.inProgress;
          _currentTask = 'Respaldando productos...';
        });
        _simulateBackupProgress();
      }
    });
  }

  void _simulateBackupProgress() {
    final tasks = [
      'Respaldando productos...',
      'Respaldando inventario...',
      'Respaldando ventas...',
      'Respaldando usuarios...',
      'Finalizando respaldo...',
    ];

    int currentTaskIndex = 0;

    void updateProgress() {
      if (_currentBackupStatus != BackupStatus.inProgress) return;

      setState(() {
        _backupProgress += 0.2;
        if (currentTaskIndex < tasks.length) {
          _currentTask = tasks[currentTaskIndex];
          currentTaskIndex++;
        }
      });

      if (_backupProgress >= 1.0) {
        setState(() {
          _currentBackupStatus = BackupStatus.completed;
          _currentTask = null;
        });
      } else {
        Future.delayed(const Duration(seconds: 2), updateProgress);
      }
    }

    updateProgress();
  }

  void _cancelBackup() {
    setState(() {
      _currentBackupStatus = BackupStatus.cancelled;
      _currentTask = null;
    });
  }

  void _retryBackup() {
    _startBackup();
  }

  void _closeBackupProgress() {
    setState(() {
      _currentBackupStatus = BackupStatus.idle;
      _backupProgress = 0.0;
      _currentTask = null;
      _errorMessage = null;
    });
  }

  void _showRestoreOptions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.cloud_download),
                      const SizedBox(width: 12),
                      const Text(
                        'Restaurar Datos',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Lista de respaldos disponibles para restaurar
                      _buildRestoreOption(
                        '15 Enero 2024',
                        '14:30',
                        '1.2 GB',
                        'Respaldo completo',
                      ),
                      _buildRestoreOption(
                        '14 Enero 2024',
                        '14:30',
                        '1.1 GB',
                        'Respaldo completo',
                      ),
                      _buildRestoreOption(
                        '13 Enero 2024',
                        '09:15',
                        '1.1 GB',
                        'Respaldo manual',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRestoreOption(
    String date,
    String time,
    String size,
    String type,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.restore),
        title: Text('$date - $time'),
        subtitle: Text('$size • $type'),
        trailing: FilledButton(
          onPressed: () => _confirmRestore(date, time),
          child: const Text('Restaurar'),
        ),
      ),
    );
  }

  void _confirmRestore(String date, String time) {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Restauración'),
        content: Text(
          '¿Estás seguro de que quieres restaurar el respaldo del $date a las $time?\n\n'
          'Esta acción reemplazará todos los datos actuales.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _startRestore(date, time);
            },
            child: const Text('Restaurar'),
          ),
        ],
      ),
    );
  }

  void _startRestore(String date, String time) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Iniciando restauración del respaldo del $date'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Métodos de configuración
  void _showFrequencySelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Frecuencia de Respaldo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            'Diaria',
            'Semanal',
            'Mensual',
          ].map((frequency) => RadioListTile<String>(
            title: Text(frequency),
            value: frequency,
            groupValue: _backupFrequency,
            onChanged: (value) {
              setState(() {
                _backupFrequency = value!;
              });
              Navigator.pop(context);
            },
          )).toList(),
        ),
      ),
    );
  }

  void _showCloudProviderSelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Proveedor de Nube'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            'Google Drive',
            'iCloud',
            'Dropbox',
            'OneDrive',
          ].map((provider) => RadioListTile<String>(
            title: Text(provider),
            value: provider,
            groupValue: _cloudProvider,
            onChanged: (value) {
              setState(() {
                _cloudProvider = value!;
              });
              Navigator.pop(context);
            },
          )).toList(),
        ),
      ),
    );
  }

  void _showStorageDetails() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Detalles de Almacenamiento'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Espacio total: 15 GB'),
            Text('Espacio usado: 2.5 GB'),
            Text('Espacio disponible: 12.5 GB'),
            SizedBox(height: 16),
            Text('Desglose por categoría:'),
            Text('• Productos: 1.2 GB'),
            Text('• Imágenes: 800 MB'),
            Text('• Ventas: 300 MB'),
            Text('• Otros: 200 MB'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _manageCloudAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gestionar Cuenta'),
        content: const Text(
          '¿Qué acción quieres realizar con tu cuenta de nube?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cuenta desconectada'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Desconectar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Reconectando cuenta...'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Reconectar'),
          ),
        ],
      ),
    );
  }

  void _showFullHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const BackupHistoryPage(),
      ),
    );
  }

  void _showBackupDetails(Map<String, String> backup) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Detalles del Respaldo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Fecha: ${backup['date']}'),
            Text('Hora: ${backup['time']}'),
            Text('Tamaño: ${backup['size']}'),
            Text('Tipo: ${backup['type']}'),
            Text('Estado: ${backup['status']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _confirmRestore(backup['date']!, backup['time']!);
            },
            child: const Text('Restaurar'),
          ),
        ],
      ),
    );
  }

  void _showEncryptionSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Configuración de Cifrado'),
        content: const Text(
          'Los respaldos se cifran automáticamente usando AES-256. '
          '¿Quieres configurar una clave personalizada?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Configuración de cifrado actualizada'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Configurar'),
          ),
        ],
      ),
    );
  }

  void _showRetentionSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Retención de Respaldos'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            '7 días',
            '30 días',
            '90 días',
            'Para siempre',
          ].map((retention) => RadioListTile<String>(
            title: Text(retention),
            value: retention,
            groupValue: '30 días',
            onChanged: (value) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Retención configurada a $value'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          )).toList(),
        ),
      ),
    );
  }

  void _showBackupInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Información de Respaldos'),
        content: const Text(
          'Los respaldos incluyen:\n\n'
          '• Datos de productos e inventario\n'
          '• Historial de ventas\n'
          '• Configuración de usuarios\n'
          '• Imágenes de productos (opcional)\n\n'
          'Los respaldos se cifran y almacenan de forma segura en la nube.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }
}

// Página adicional para el historial completo
class BackupHistoryPage extends StatelessWidget {
  const BackupHistoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Respaldos'),
      ),
      body: const Center(
        child: Text('Lista completa de respaldos'),
      ),
    );
  }
}
