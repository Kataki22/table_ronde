import 'package:flutter/material.dart';
import '../../utils/theme_extensions.dart';
import '../../utils/app_theme.dart';
import '../../utils/accessibility_helpers.dart';

/// Type d'interaction pour un SettingsTile
enum SettingsTileType {
  /// Affiche un switch toggle
  toggle,

  /// Affiche un chevron et navigue vers un autre écran
  navigation,

  /// Exécute une action directe sans trailing widget
  action,
}

/// Widget réutilisable pour afficher une option de paramètres
///
/// Supporte trois types d'interactions :
/// - Toggle : Affiche un switch qui peut être activé/désactivé
/// - Navigation : Affiche un chevron et navigue vers un autre écran
/// - Action : Exécute une action au tap (pas de trailing widget)
class SettingsTile extends StatelessWidget {
  /// Icône affichée à gauche
  final IconData icon;

  /// Titre principal
  final String title;

  /// Sous-titre optionnel
  final String? subtitle;

  /// Type d'interaction
  final SettingsTileType type;

  /// Callback appelé lors du tap (pour navigation et action)
  final VoidCallback? onTap;

  /// Valeur du toggle (requis si type == toggle)
  final bool? toggleValue;

  /// Callback appelé lors du changement du toggle (requis si type == toggle)
  final ValueChanged<bool>? onToggleChanged;

  /// Couleur de l'icône (optionnel, utilise textSecondary par défaut)
  final Color? iconColor;

  /// Indique si c'est une action destructive (affiche en rouge)
  final bool isDestructive;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.type,
    this.onTap,
    this.toggleValue,
    this.onToggleChanged,
    this.iconColor,
    this.isDestructive = false,
  }) : assert(
          type != SettingsTileType.toggle ||
              (toggleValue != null && onToggleChanged != null),
          'toggleValue and onToggleChanged are required when type is toggle',
        );

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;

    // Couleur du texte selon si c'est destructif
    final textColor = isDestructive ? colors.colorDanger : colors.textPrimary;
    final subtitleColor =
        isDestructive ? colors.colorDanger.withValues(alpha: 0.7) : colors.textSecondary;
    final effectiveIconColor =
        iconColor ?? (isDestructive ? colors.colorDanger : colors.textSecondary);

    // Create semantic label
    final semanticLabel = AccessibilityHelpers.settingsTileLabel(
      title: title,
      subtitle: subtitle,
      toggleValue: type == SettingsTileType.toggle ? toggleValue : null,
    );
    
    final semanticHint = type == SettingsTileType.toggle
        ? AccessibilityHelpers.toggleNotifications
        : (type == SettingsTileType.navigation
            ? AccessibilityHelpers.tapToOpen
            : null);

    return Semantics(
      label: semanticLabel,
      hint: semanticHint,
      button: type != SettingsTileType.toggle,
      toggled: type == SettingsTileType.toggle ? toggleValue : null,
      enabled: true,
      child: _ScaleTapTile(
        onTap: type == SettingsTileType.toggle ? null : onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingMedium,
          vertical: AppTheme.spacingSmall,
        ),
        child: Row(
          children: [
            // Icône
            Icon(
              icon,
              color: effectiveIconColor,
              size: 24,
            ),
            const SizedBox(width: AppTheme.spacingMedium),

            // Titre et sous-titre
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: AppTheme.bodyLarge.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: AppTheme.bodySmall.copyWith(
                        color: subtitleColor,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Trailing widget selon le type
            const SizedBox(width: AppTheme.spacingSmall),
            _buildTrailing(context, colors),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildTrailing(BuildContext context, dynamic colors) {
    switch (type) {
      case SettingsTileType.toggle:
        return Switch(
          value: toggleValue!,
          onChanged: onToggleChanged,
          activeTrackColor: colors.colorPrimary,
        );

      case SettingsTileType.navigation:
        return Icon(
          Icons.chevron_right,
          color: colors.textSecondary,
          size: 20,
        );

      case SettingsTileType.action:
        return const SizedBox.shrink();
    }
  }
}

/// Internal widget that provides scale animation on tap with ripple effect
class _ScaleTapTile extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;

  const _ScaleTapTile({
    required this.child,
    this.onTap,
    this.borderRadius,
  });

  @override
  State<_ScaleTapTile> createState() => _ScaleTapTileState();
}

class _ScaleTapTileState extends State<_ScaleTapTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap != null) {
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onTap != null) {
      _controller.reverse();
    }
  }

  void _handleTapCancel() {
    if (widget.onTap != null) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.onTap == null) {
      // No interaction, just return the child
      return widget.child;
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            borderRadius: widget.borderRadius,
            splashColor: Colors.grey.withValues(alpha: 0.2),
            highlightColor: Colors.grey.withValues(alpha: 0.1),
            hoverColor: _isHovered 
                ? Colors.grey.withValues(alpha: 0.05)
                : null,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
