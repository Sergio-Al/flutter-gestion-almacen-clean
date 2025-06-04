import 'package:flutter/material.dart';

class SettingsTileWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? iconColor;
  final bool enabled;
  final bool showDivider;

  const SettingsTileWidget({
    Key? key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.iconColor,
    this.enabled = true,
    this.showDivider = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Column(
      children: [
        InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor?.withOpacity(0.1) ?? 
                           colorScheme.primaryContainer.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    size: 24,
                    color: enabled 
                        ? iconColor ?? colorScheme.primary
                        : colorScheme.onSurface.withOpacity(0.38),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: enabled 
                              ? colorScheme.onSurface
                              : colorScheme.onSurface.withOpacity(0.38),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: enabled 
                                ? colorScheme.onSurfaceVariant
                                : colorScheme.onSurface.withOpacity(0.38),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: 8),
                  trailing!,
                ],
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: 64,
            color: colorScheme.outlineVariant,
          ),
      ],
    );
  }
}

// Widget especializado para configuraciones con switch
class SettingsSwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color? iconColor;
  final bool enabled;

  const SettingsSwitchTile({
    Key? key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.value,
    this.onChanged,
    this.iconColor,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SettingsTileWidget(
      icon: icon,
      title: title,
      subtitle: subtitle,
      iconColor: iconColor,
      enabled: enabled,
      trailing: Switch(
        value: value,
        onChanged: enabled ? onChanged : null,
      ),
      onTap: enabled ? () => onChanged?.call(!value) : null,
    );
  }
}

// Widget especializado para configuraciones con selección
class SettingsSelectionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String currentValue;
  final VoidCallback? onTap;
  final Color? iconColor;
  final bool enabled;

  const SettingsSelectionTile({
    Key? key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.currentValue,
    this.onTap,
    this.iconColor,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SettingsTileWidget(
      icon: icon,
      title: title,
      subtitle: subtitle,
      iconColor: iconColor,
      enabled: enabled,
      onTap: onTap,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            currentValue,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: enabled 
                  ? colorScheme.primary
                  : colorScheme.onSurface.withOpacity(0.38),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.chevron_right,
            size: 20,
            color: enabled 
                ? colorScheme.onSurfaceVariant
                : colorScheme.onSurface.withOpacity(0.38),
          ),
        ],
      ),
    );
  }
}
