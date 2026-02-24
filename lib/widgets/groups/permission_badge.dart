import 'package:flutter/material.dart';
import '../../models/groups/group_permission.dart';
import '../../utils/theme_extensions.dart';
import '../../utils/app_theme.dart';
import '../../utils/accessibility_helpers.dart';

/// A reusable widget that displays a visual badge for group permission levels
/// 
/// Displays a small, clean badge with distinct colors for each permission level:
/// - Admin: Red badge
/// - Moderator: Blue badge
/// - Member: Gray badge
/// 
/// The badge follows Discord/Telegram design style with rounded corners,
/// subtle background, and border.
/// 
/// **Validates: Requirements 1.5, 9.2**
class PermissionBadge extends StatelessWidget {
  /// The permission level to display
  final GroupPermission permission;
  
  /// Optional custom size for the badge (affects padding and font size)
  final BadgeSize size;

  const PermissionBadge({
    super.key,
    required this.permission,
    this.size = BadgeSize.medium,
  });

  @override
  Widget build(BuildContext context) {
    final badgeConfig = _getBadgeConfig(context);
    final sizeConfig = _getSizeConfig();
    
    return Semantics(
      label: badgeConfig.semanticLabel,
      readOnly: true,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: sizeConfig.horizontalPadding,
          vertical: sizeConfig.verticalPadding,
        ),
        decoration: BoxDecoration(
          color: badgeConfig.color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: badgeConfig.color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Text(
          badgeConfig.text,
          style: AppTheme.bodySmall.copyWith(
            color: badgeConfig.color,
            fontSize: sizeConfig.fontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// Gets the badge configuration (color and text) based on permission level
  _BadgeConfig _getBadgeConfig(BuildContext context) {
    switch (permission) {
      case GroupPermission.admin:
        return _BadgeConfig(
          color: const Color(0xFFE74C3C), // Red for admin
          text: 'Admin',
          semanticLabel: AccessibilityHelpers.admin,
        );
      case GroupPermission.moderator:
        return _BadgeConfig(
          color: const Color(0xFF3498DB), // Blue for moderator
          text: 'Modo',
          semanticLabel: AccessibilityHelpers.moderator,
        );
      case GroupPermission.member:
        return _BadgeConfig(
          color: context.themeColors.textSecondary, // Gray for member
          text: 'Membre',
          semanticLabel: AccessibilityHelpers.member,
        );
    }
  }

  /// Gets the size configuration based on the badge size
  _SizeConfig _getSizeConfig() {
    switch (size) {
      case BadgeSize.small:
        return _SizeConfig(
          horizontalPadding: 6,
          verticalPadding: 2,
          fontSize: 10,
        );
      case BadgeSize.medium:
        return _SizeConfig(
          horizontalPadding: 8,
          verticalPadding: 3,
          fontSize: 11,
        );
      case BadgeSize.large:
        return _SizeConfig(
          horizontalPadding: 10,
          verticalPadding: 4,
          fontSize: 12,
        );
    }
  }
}

/// Size options for the permission badge
enum BadgeSize {
  /// Small badge (compact)
  small,
  
  /// Medium badge (default)
  medium,
  
  /// Large badge (prominent)
  large,
}

/// Internal configuration for badge appearance
class _BadgeConfig {
  final Color color;
  final String text;
  final String semanticLabel;

  _BadgeConfig({
    required this.color,
    required this.text,
    required this.semanticLabel,
  });
}

/// Internal configuration for badge sizing
class _SizeConfig {
  final double horizontalPadding;
  final double verticalPadding;
  final double fontSize;

  _SizeConfig({
    required this.horizontalPadding,
    required this.verticalPadding,
    required this.fontSize,
  });
}
