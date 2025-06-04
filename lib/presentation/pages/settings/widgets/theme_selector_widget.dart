import 'package:flutter/material.dart';

enum AppThemeMode {
  light,
  dark,
  system,
}

class ThemeSelectorWidget extends StatelessWidget {
  final AppThemeMode currentTheme;
  final ValueChanged<AppThemeMode> onThemeChanged;
  final bool showSystemOption;

  const ThemeSelectorWidget({
    Key? key,
    required this.currentTheme,
    required this.onThemeChanged,
    this.showSystemOption = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.palette_outlined,
                color: colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Tema de la aplicación',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildThemeOption(
                  context,
                  AppThemeMode.light,
                  Icons.light_mode,
                  'Claro',
                  'Tema claro para mejor visibilidad',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildThemeOption(
                  context,
                  AppThemeMode.dark,
                  Icons.dark_mode,
                  'Oscuro',
                  'Tema oscuro para reducir fatiga visual',
                ),
              ),
            ],
          ),
          if (showSystemOption) ...[
            const SizedBox(height: 12),
            _buildThemeOption(
              context,
              AppThemeMode.system,
              Icons.settings_brightness,
              'Sistema',
              'Sigue la configuración del sistema',
              isWide: true,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    AppThemeMode themeMode,
    IconData icon,
    String title,
    String subtitle, {
    bool isWide = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSelected = currentTheme == themeMode;

    return InkWell(
      onTap: () => onThemeChanged(themeMode),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primaryContainer
              : colorScheme.surfaceVariant.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outline.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: isWide
            ? Row(
                children: [
                  _buildThemeIcon(colorScheme, icon, isSelected),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildThemeText(
                      theme,
                      colorScheme,
                      title,
                      subtitle,
                      isSelected,
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.check_circle,
                      color: colorScheme.primary,
                      size: 20,
                    ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildThemeIcon(colorScheme, icon, isSelected),
                      if (isSelected)
                        Icon(
                          Icons.check_circle,
                          color: colorScheme.primary,
                          size: 20,
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildThemeText(
                    theme,
                    colorScheme,
                    title,
                    subtitle,
                    isSelected,
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildThemeIcon(ColorScheme colorScheme, IconData icon, bool isSelected) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isSelected
            ? colorScheme.primary.withOpacity(0.2)
            : colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        icon,
        color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
        size: 24,
      ),
    );
  }

  Widget _buildThemeText(
    ThemeData theme,
    ColorScheme colorScheme,
    String title,
    String subtitle,
    bool isSelected,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            color: isSelected ? colorScheme.primary : colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: isSelected
                ? colorScheme.onPrimaryContainer
                : colorScheme.onSurfaceVariant,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

// Widget compacto para usar en listas de configuración
class CompactThemeSelector extends StatelessWidget {
  final AppThemeMode currentTheme;
  final ValueChanged<AppThemeMode> onThemeChanged;

  const CompactThemeSelector({
    Key? key,
    required this.currentTheme,
    required this.onThemeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButton<AppThemeMode>(
      value: currentTheme,
      onChanged: (AppThemeMode? newTheme) {
        if (newTheme != null) {
          onThemeChanged(newTheme);
        }
      },
      underline: const SizedBox.shrink(),
      items: AppThemeMode.values.map((AppThemeMode themeMode) {
        return DropdownMenuItem<AppThemeMode>(
          value: themeMode,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getThemeIcon(themeMode),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(_getThemeName(themeMode)),
            ],
          ),
        );
      }).toList(),
    );
  }

  IconData _getThemeIcon(AppThemeMode themeMode) {
    switch (themeMode) {
      case AppThemeMode.light:
        return Icons.light_mode;
      case AppThemeMode.dark:
        return Icons.dark_mode;
      case AppThemeMode.system:
        return Icons.settings_brightness;
    }
  }

  String _getThemeName(AppThemeMode themeMode) {
    switch (themeMode) {
      case AppThemeMode.light:
        return 'Claro';
      case AppThemeMode.dark:
        return 'Oscuro';
      case AppThemeMode.system:
        return 'Sistema';
    }
  }
}

// Preview de temas para mostrar cómo se ven
class ThemePreviewWidget extends StatelessWidget {
  final AppThemeMode themeMode;
  final bool isSelected;
  final VoidCallback onTap;

  const ThemePreviewWidget({
    Key? key,
    required this.themeMode,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = themeMode == AppThemeMode.dark ||
        (themeMode == AppThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    final backgroundColor = isDark ? Colors.grey[900]! : Colors.white;
    final surfaceColor = isDark ? Colors.grey[800]! : Colors.grey[100]!;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final textColor = isDark ? Colors.white : Colors.black;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 120,
        height: 160,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? primaryColor : Colors.grey.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            // Preview del tema
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    // App bar simulado
                    Container(
                      height: 24,
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                      ),
                    ),
                    // Contenido simulado
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 8,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: textColor.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              height: 6,
                              width: 60,
                              decoration: BoxDecoration(
                                color: textColor.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              height: 20,
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Nombre del tema
            Text(
              _getThemeName(themeMode),
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? primaryColor : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getThemeName(AppThemeMode themeMode) {
    switch (themeMode) {
      case AppThemeMode.light:
        return 'Claro';
      case AppThemeMode.dark:
        return 'Oscuro';
      case AppThemeMode.system:
        return 'Sistema';
    }
  }
}
