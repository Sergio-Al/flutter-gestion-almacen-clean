import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'widgets/settings_tile_widget.dart';
import 'profile_page.dart';
import 'backup_restore_page.dart';
import 'database_info_page.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  bool _biometricEnabled = false;
  String _selectedLanguage = 'Español';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
        backgroundColor: theme.colorScheme.surfaceVariant,
        actions: [
          IconButton(
            onPressed: _showAboutDialog,
            icon: const Icon(Icons.info_outline),
            tooltip: 'Acerca de',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Section
          _buildSectionHeader('Perfil'),
          SettingsTileWidget(
            icon: Icons.person,
            title: 'Mi Perfil',
            subtitle: 'Información personal y cuenta',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ProfilePage(),
              ),
            ),
            trailing: const Icon(Icons.chevron_right),
          ),
          const SizedBox(height: 24),

          // App Preferences
          _buildSectionHeader('Preferencias de la App'),
          SettingsTileWidget(
            icon: Icons.notifications,
            title: 'Notificaciones',
            subtitle: 'Recibir alertas y recordatorios',
            trailing: Switch(
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
                _showSnackBar('Notificaciones ${value ? 'activadas' : 'desactivadas'}');
              },
            ),
          ),
          SettingsTileWidget(
            icon: Icons.dark_mode,
            title: 'Modo Oscuro',
            subtitle: 'Cambiar tema de la aplicación',
            trailing: Switch(
              value: _darkModeEnabled,
              onChanged: (value) {
                setState(() {
                  _darkModeEnabled = value;
                });
                _showSnackBar('Modo ${value ? 'oscuro' : 'claro'} activado');
              },
            ),
          ),
          SettingsTileWidget(
            icon: Icons.language,
            title: 'Idioma',
            subtitle: _selectedLanguage,
            onTap: _showLanguageSelector,
            trailing: const Icon(Icons.chevron_right),
          ),
          const SizedBox(height: 24),

          // Security
          _buildSectionHeader('Seguridad'),
          SettingsTileWidget(
            icon: Icons.fingerprint,
            title: 'Autenticación Biométrica',
            subtitle: 'Usar huella dactilar o Face ID',
            trailing: Switch(
              value: _biometricEnabled,
              onChanged: (value) {
                setState(() {
                  _biometricEnabled = value;
                });
                _showSnackBar('Autenticación biométrica ${value ? 'activada' : 'desactivada'}');
              },
            ),
          ),
          SettingsTileWidget(
            icon: Icons.lock,
            title: 'Cambiar Contraseña',
            subtitle: 'Actualizar contraseña de acceso',
            onTap: _showChangePasswordDialog,
            trailing: const Icon(Icons.chevron_right),
          ),
          const SizedBox(height: 24),

          // Data Management
          _buildSectionHeader('Gestión de Datos'),
          SettingsTileWidget(
            icon: Icons.backup,
            title: 'Respaldo y Restauración',
            subtitle: 'Gestionar copias de seguridad',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const BackupRestorePage(),
              ),
            ),
            trailing: const Icon(Icons.chevron_right),
          ),
          SettingsTileWidget(
            icon: Icons.cloud_sync,
            title: 'Sincronización',
            subtitle: 'Sincronizar datos en la nube',
            onTap: _showSyncOptions,
            trailing: const Icon(Icons.chevron_right),
          ),
          SettingsTileWidget(
            icon: Icons.storage,
            title: 'Almacenamiento',
            subtitle: 'Gestionar espacio en el dispositivo',
            onTap: _showStorageInfo,
            trailing: const Icon(Icons.chevron_right),
          ),
          const SizedBox(height: 24),

          // Support
          _buildSectionHeader('Soporte'),
          SettingsTileWidget(
            icon: Icons.help,
            title: 'Ayuda y FAQ',
            subtitle: 'Preguntas frecuentes y guías',
            onTap: _showHelpCenter,
            trailing: const Icon(Icons.chevron_right),
          ),
          SettingsTileWidget(
            icon: Icons.feedback,
            title: 'Enviar Comentarios',
            subtitle: 'Reportar problemas o sugerencias',
            onTap: _showFeedbackDialog,
            trailing: const Icon(Icons.chevron_right),
          ),
          SettingsTileWidget(
            icon: Icons.contact_support,
            title: 'Contactar Soporte',
            subtitle: 'Obtener ayuda técnica',
            onTap: _contactSupport,
            trailing: const Icon(Icons.chevron_right),
          ),
          
          // Debug section (only visible in debug mode)
          ...() {
            List<Widget> debugWidgets = [];
            assert(() {
              debugWidgets.addAll([
                const SizedBox(height: 24),
                _buildSectionHeader('Desarrollo (Debug)'),
                SettingsTileWidget(
                  icon: Icons.storage,
                  title: 'Información de Base de Datos',
                  subtitle: 'Ver ubicación y detalles de la BD',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DatabaseInfoPage(),
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                ),
              ]);
              return true;
            }());
            return debugWidgets;
          }(),
          
          const SizedBox(height: 24),

          // Danger Zone
          _buildSectionHeader('Zona de Peligro'),
          SettingsTileWidget(
            icon: Icons.delete_forever,
            title: 'Eliminar Todos los Datos',
            subtitle: 'Borrar toda la información local',
            onTap: _showDeleteAllDataDialog,
            trailing: const Icon(Icons.chevron_right),
          ),
          SettingsTileWidget(
            icon: Icons.logout,
            title: 'Cerrar Sesión',
            subtitle: 'Salir de la aplicación',
            onTap: _showLogoutDialog,
            trailing: const Icon(Icons.chevron_right),
          ),
          const SizedBox(height: 32),

          // Version Info
          Center(
            child: Column(
              children: [
                Text(
                  'Gestión de Almacén',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Versión 1.0.0 (Build 1)',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showLanguageSelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seleccionar Idioma'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Español'),
              value: 'Español',
              groupValue: _selectedLanguage,
              onChanged: (value) {
                setState(() {
                  _selectedLanguage = value!;
                });
                Navigator.pop(context);
                _showSnackBar('Idioma cambiado a Español');
              },
            ),
            RadioListTile<String>(
              title: const Text('English'),
              value: 'English',
              groupValue: _selectedLanguage,
              onChanged: (value) {
                setState(() {
                  _selectedLanguage = value!;
                });
                Navigator.pop(context);
                _showSnackBar('Language changed to English');
              },
            ),
            RadioListTile<String>(
              title: const Text('Português'),
              value: 'Português',
              groupValue: _selectedLanguage,
              onChanged: (value) {
                setState(() {
                  _selectedLanguage = value!;
                });
                Navigator.pop(context);
                _showSnackBar('Idioma alterado para Português');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cambiar Contraseña'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Contraseña Actual',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Nueva Contraseña',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirmar Nueva Contraseña',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement password change logic
              Navigator.pop(context);
              _showSnackBar('Contraseña actualizada exitosamente');
            },
            child: const Text('Actualizar'),
          ),
        ],
      ),
    );
  }

  void _showSyncOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Opciones de Sincronización'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: Icon(Icons.cloud_upload),
              title: Text('Subir a la Nube'),
              subtitle: Text('Sincronizar datos locales'),
            ),
            ListTile(
              leading: Icon(Icons.cloud_download),
              title: Text('Descargar de la Nube'),
              subtitle: Text('Obtener últimos datos'),
            ),
            ListTile(
              leading: Icon(Icons.sync),
              title: Text('Sincronización Automática'),
              subtitle: Text('Activar sync en tiempo real'),
            ),
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

  void _showStorageInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Información de Almacenamiento'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Uso de almacenamiento:'),
            const SizedBox(height: 16),
            _buildStorageItem('Base de datos', '45.2 MB'),
            _buildStorageItem('Imágenes', '12.8 MB'),
            _buildStorageItem('Documentos', '8.5 MB'),
            _buildStorageItem('Caché', '3.2 MB'),
            const Divider(),
            _buildStorageItem('Total', '69.7 MB', isBold: true),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnackBar('Caché limpiado exitosamente');
            },
            child: const Text('Limpiar Caché'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildStorageItem(String label, String size, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            size,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  void _showHelpCenter() {
    _showSnackBar('Abriendo centro de ayuda...');
  }

  void _showFeedbackDialog() {
    final feedbackController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enviar Comentarios'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Ayúdanos a mejorar la aplicación:'),
            const SizedBox(height: 16),
            TextField(
              controller: feedbackController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Describe tu experiencia o reporta un problema...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnackBar('Comentarios enviados. ¡Gracias!');
            },
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
  }

  void _contactSupport() {
    _showSnackBar('Abriendo contacto de soporte...');
  }

  void _showDeleteAllDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar Todos los Datos?'),
        content: const Text(
          'Esta acción eliminará permanentemente todos los datos locales de la aplicación. Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnackBar('Todos los datos han sido eliminados');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Cerrar Sesión?'),
        content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnackBar('Sesión cerrada exitosamente');
            },
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'Gestión de Almacén',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(
        Icons.warehouse,
        size: 48,
        color: Colors.blue,
      ),
      children: const [
        Text('Sistema integral de gestión de inventario y almacén.'),
        SizedBox(height: 16),
        Text('Desarrollado por Sergio Alejandro Machaca Lamas en Flutter.'),
      ],
    );
  }
}
