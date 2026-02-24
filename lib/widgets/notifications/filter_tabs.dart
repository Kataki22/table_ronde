import 'package:flutter/material.dart';
import '../../models/notifications/notification_type.dart';
import '../../utils/app_theme.dart';

/// A tab bar widget for filtering notifications by type
/// 
/// Features:
/// - Displays tabs for each notification type
/// - Shows count per type
/// - Handles selection and filtering
/// - Smooth animations between tabs
/// 
/// **Validates: Requirements 6.6**
class FilterTabs extends StatelessWidget {
  /// The currently selected notification type filter (null = all)
  final NotificationType? selectedType;

  /// Callback when a tab is selected
  final ValueChanged<NotificationType?> onTypeSelected;

  /// Map of notification counts per type
  final Map<NotificationType, int> countsByType;

  /// Total count of all notifications
  final int totalCount;

  const FilterTabs({
    super.key,
    required this.selectedType,
    required this.onTypeSelected,
    required this.countsByType,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppTheme.cardDark : Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingSmall),
        children: [
          _buildTab(
            context,
            label: 'Tous',
            count: totalCount,
            isSelected: selectedType == null,
            onTap: () => onTypeSelected(null),
          ),
          ...NotificationType.values.map((type) {
            return _buildTab(
              context,
              label: _getTypeLabel(type),
              count: countsByType[type] ?? 0,
              isSelected: selectedType == type,
              onTap: () => onTypeSelected(type),
              icon: _getTypeIcon(type),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTab(
    BuildContext context, {
    required String label,
    required int count,
    required bool isSelected,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final backgroundColor = isSelected
        ? (isDark ? AppTheme.primaryBlue.withOpacity(0.2) : AppTheme.primaryBlue.withOpacity(0.1))
        : Colors.transparent;

    final textColor = isSelected
        ? AppTheme.primaryBlue
        : (isDark ? AppTheme.textSecondary : Colors.grey.shade600);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingXSmall,
        vertical: AppTheme.spacingXSmall,
      ),
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          child: AnimatedContainer(
            duration: AppTheme.fastAnimation,
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingMedium,
              vertical: AppTheme.spacingSmall,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              border: isSelected
                  ? Border.all(color: AppTheme.primaryBlue, width: 1.5)
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    size: 16,
                    color: textColor,
                  ),
                  const SizedBox(width: AppTheme.spacingXSmall),
                ],
                Text(
                  label,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                if (count > 0) ...[
                  const SizedBox(width: AppTheme.spacingXSmall),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primaryBlue
                          : (isDark ? AppTheme.cardDark : Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      count > 99 ? '99+' : count.toString(),
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : (isDark ? AppTheme.textSecondary : Colors.grey.shade700),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getTypeLabel(NotificationType type) {
    switch (type) {
      case NotificationType.message:
        return 'Messages';
      case NotificationType.mention:
        return 'Mentions';
      case NotificationType.like:
        return 'Likes';
      case NotificationType.comment:
        return 'Commentaires';
      case NotificationType.announcement:
        return 'Annonces';
      case NotificationType.activity:
        return 'Activités';
    }
  }

  IconData _getTypeIcon(NotificationType type) {
    switch (type) {
      case NotificationType.message:
        return Icons.message;
      case NotificationType.mention:
        return Icons.alternate_email;
      case NotificationType.like:
        return Icons.favorite;
      case NotificationType.comment:
        return Icons.comment;
      case NotificationType.announcement:
        return Icons.campaign;
      case NotificationType.activity:
        return Icons.notifications_active;
    }
  }
}
