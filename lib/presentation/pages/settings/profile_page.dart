import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'widgets/settings_tile_widget.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: 'Juan Pérez');
  final _emailController = TextEditingController(text: 'juan.perez@email.com');
  final _phoneController = TextEditingController(text: '+1 234 567 8900');
  final _positionController = TextEditingController(text: 'Administrador de Almacén');
  final _companyController = TextEditingController(text: 'Mi Empresa S.A.');

  bool _isEditing = false;
  bool _emailNotifications = true;
  bool _pushNotifications = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _positionController.dispose();
    _companyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        backgroundColor: colorScheme.surfaceVariant,
        actions: [
          if (_isEditing) ...[
            TextButton(
              onPressed: _cancelEditing,
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: _saveProfile,
              child: const Text('Guardar'),
            ),
          ] else
            IconButton(
              onPressed: () => setState(() => _isEditing = true),
              icon: const Icon(Icons.edit),
              tooltip: 'Editar perfil',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildProfileHeader(colorScheme, theme),
            const SizedBox(height: 24),
            _buildPersonalInfoSection(theme),
            const SizedBox(height: 24),
            _buildNotificationSettings(theme),
            const SizedBox(height: 24),
            _buildAccountActions(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(ColorScheme colorScheme, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer,
            colorScheme.primaryContainer.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.primary,
                  border: Border.all(
                    color: colorScheme.surface,
                    width: 4,
                  ),
                ),
                child: Icon(
                  Icons.person,
                  size: 50,
                  color: colorScheme.onPrimary,
                ),
              ),
              if (_isEditing)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: colorScheme.secondary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colorScheme.surface,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      size: 16,
                      color: colorScheme.onSecondary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _nameController.text,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _positionController.text,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onPrimaryContainer.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            _companyController.text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onPrimaryContainer.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection(ThemeData theme) {
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
              'Información Personal',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (_isEditing) _buildEditForm() else _buildViewMode(),
        ],
      ),
    );
  }

  Widget _buildEditForm() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre completo',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'El nombre es requerido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Correo electrónico',
                prefixIcon: Icon(Icons.email_outlined),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'El correo es requerido';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
                  return 'Ingresa un correo válido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Teléfono',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _positionController,
              decoration: const InputDecoration(
                labelText: 'Cargo',
                prefixIcon: Icon(Icons.work_outline),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _companyController,
              decoration: const InputDecoration(
                labelText: 'Empresa',
                prefixIcon: Icon(Icons.business_outlined),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewMode() {
    return Column(
      children: [
        SettingsTileWidget(
          icon: Icons.person_outline,
          title: 'Nombre',
          subtitle: _nameController.text,
          showDivider: true,
        ),
        SettingsTileWidget(
          icon: Icons.email_outlined,
          title: 'Correo electrónico',
          subtitle: _emailController.text,
          showDivider: true,
        ),
        SettingsTileWidget(
          icon: Icons.phone_outlined,
          title: 'Teléfono',
          subtitle: _phoneController.text,
          showDivider: true,
        ),
        SettingsTileWidget(
          icon: Icons.work_outline,
          title: 'Cargo',
          subtitle: _positionController.text,
          showDivider: true,
        ),
        SettingsTileWidget(
          icon: Icons.business_outlined,
          title: 'Empresa',
          subtitle: _companyController.text,
          showDivider: false,
        ),
      ],
    );
  }

  Widget _buildNotificationSettings(ThemeData theme) {
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
              'Notificaciones',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SettingsSwitchTile(
            icon: Icons.email_outlined,
            title: 'Notificaciones por correo',
            subtitle: 'Recibir actualizaciones por email',
            value: _emailNotifications,
            onChanged: (value) {
              setState(() {
                _emailNotifications = value;
              });
            },
          ),
          SettingsSwitchTile(
            icon: Icons.notifications_outlined,
            title: 'Notificaciones push',
            subtitle: 'Recibir notificaciones en el dispositivo',
            value: _pushNotifications,
            onChanged: (value) {
              setState(() {
                _pushNotifications = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAccountActions(ThemeData theme) {
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
              'Cuenta',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SettingsTileWidget(
            icon: Icons.lock_outline,
            title: 'Cambiar contraseña',
            subtitle: 'Actualizar tu contraseña de acceso',
            onTap: _showChangePasswordDialog,
            trailing: const Icon(Icons.chevron_right),
          ),
          SettingsTileWidget(
            icon: Icons.security,
            title: 'Verificación en dos pasos',
            subtitle: 'Configurar autenticación adicional',
            onTap: _showTwoFactorDialog,
            trailing: const Icon(Icons.chevron_right),
          ),
          SettingsTileWidget(
            icon: Icons.download_outlined,
            title: 'Descargar mis datos',
            subtitle: 'Exportar información de la cuenta',
            onTap: _showDataExportDialog,
            trailing: const Icon(Icons.chevron_right),
            showDivider: false,
          ),
        ],
      ),
    );
  }

  void _cancelEditing() {
    setState(() {
      _isEditing = false;
      // Restaurar valores originales si es necesario
      _nameController.text = 'Juan Pérez';
      _emailController.text = 'juan.perez@email.com';
      _phoneController.text = '+1 234 567 8900';
      _positionController.text = 'Administrador de Almacén';
      _companyController.text = 'Mi Empresa S.A.';
    });
  }

  void _saveProfile() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isEditing = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil actualizado correctamente'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cambiar Contraseña'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Contraseña actual',
                prefixIcon: Icon(Icons.lock_outline),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Nueva contraseña',
                prefixIcon: Icon(Icons.lock_outline),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Confirmar nueva contraseña',
                prefixIcon: Icon(Icons.lock_outline),
              ),
              obscureText: true,
            ),
          ],
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
                  content: Text('Contraseña actualizada correctamente'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showTwoFactorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Verificación en Dos Pasos'),
        content: const Text(
          'La verificación en dos pasos añade una capa extra de seguridad a tu cuenta. '
          '¿Quieres activar esta función?',
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
                  content: Text('Verificación en dos pasos configurada'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Activar'),
          ),
        ],
      ),
    );
  }

  void _showDataExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Descargar Datos'),
        content: const Text(
          'Se preparará un archivo con toda tu información personal y datos de la cuenta. '
          'El proceso puede tomar unos minutos.',
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
                  content: Text('Preparando descarga de datos...'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Descargar'),
          ),
        ],
      ),
    );
  }
}
