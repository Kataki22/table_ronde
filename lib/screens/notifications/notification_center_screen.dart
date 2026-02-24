import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/notification_provider.dart';
import '../../models/notifications/notification_type.dart';
import '../../widgets/notifications/filter_tabs.dart';
import '../../widgets/notifications/notification_tile.dart';
import '../../utils/theme_extensions.dart';
import '../../utils/app_theme.dart';
import '../../utils/responsive_layout.dart';
import 'notification_settings_screen.dart';

/// Screen displaying the notification center with all user notifications
/// 
/// Features:
/// - FilterTabs at the top for filtering by notification type
/// - List of NotificationTile widgets
/// - Tap to navigate to related content
/// - Swipe actions (mark read/unread, delete)
/// - Empty state when no notifications
/// 
/// **Validates: Requirements 6.1, 6.2, 6.4, 6.5, 6.6, 6.8**
class NotificationCenterScreen extends StatelessWidget {
  const NotificationCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.themeColors.bgPrimary,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: context.themeColors.bgSecondary,
        elevation: 0,
        actions: [
          // Settings button
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Paramètres de notifications',
            onPressed: () => _openSettings(context),
          ),
          // Mark all as read button
          Consumer<NotificationProvider>(
            builder: (context, provider, child) {
              final hasUnread = provider.unreadCount > 0;
              return IconButton(
                icon: const Icon(Icons.done_all),
                tooltip: 'Tout marquer comme lu',
                onPressed: hasUnread
                    ? () => _markAllAsRead(context, provider)
                    : null,
              );
            },
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          final notifications = provider.filteredNotifications;
          final selectedType = provider.activeFilters.isEmpty
              ? null
              : provider.activeFilters.first;

          // Calculate counts by type
          final countsByType = <NotificationType, int>{};
          for (final type in NotificationType.values) {
            countsByType[type] = provider.notifications
                .where((notif) => notif.type == type)
                .length;
          }

          // Use responsive layout
          if (ResponsiveLayout.shouldUseDesktopLayout(context)) {
            return _buildDesktopLayout(
              context,
              provider,
              notifications,
              selectedType,
              countsByType,
            );
          } else {
            return _buildMobileLayout(
              context,
              provider,
              notifications,
              selectedType,
              countsByType,
            );
          }
        },
      ),
    );
  }

  /// Builds the list of notifications
  Widget _buildNotificationsList(
    BuildContext context,
    NotificationProvider provider,
    List<dynamic> notifications,
  ) {
    return ListView.builder(
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return NotificationTile(
          notification: notification,
          onTap: () => _handleNotificationTap(context, provider, notification),
          onMarkRead: () => _handleMarkReadToggle(provider, notification),
          onDelete: () => _handleDelete(context, provider, notification),
        );
      },
    );
  }

  /// Mobile layout: single column with filter tabs at top
  Widget _buildMobileLayout(
    BuildContext context,
    NotificationProvider provider,
    List<dynamic> notifications,
    NotificationType? selectedType,
    Map<NotificationType, int> countsByType,
  ) {
    return Column(
      children: [
        // Filter tabs
        FilterTabs(
          selectedType: selectedType,
          onTypeSelected: (type) => _handleFilterChange(provider, type),
          countsByType: countsByType,
          totalCount: provider.notifications.length,
        ),

        // Notifications list or empty state
        Expanded(
          child: notifications.isEmpty
              ? _buildEmptyState(context, selectedType)
              : _buildNotificationsList(context, provider, notifications),
        ),
      ],
    );
  }

  /// Desktop layout: side panel with filters, main content with notifications
  Widget _buildDesktopLayout(
    BuildContext context,
    NotificationProvider provider,
    List<dynamic> notifications,
    NotificationType? selectedType,
    Map<NotificationType, int> countsByType,
  ) {
    return Row(
      children: [
        // Left panel: Filters (vertical layout)
        Container(
          width: 280,
          decoration: BoxDecoration(
            color: context.themeColors.bgSecondary,
            border: Border(
              right: BorderSide(color: context.themeColors.borderMedium),
            ),
          ),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Filtres',
                style: AppTheme.headingSmall.copyWith(
                  color: context.themeColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // All notifications
              _buildFilterTile(
                context,
                icon: Icons.notifications,
                label: 'Toutes',
                count: provider.notifications.length,
                isSelected: selectedType == null,
                onTap: () => _handleFilterChange(provider, null),
              ),

              const Divider(height: 24),

              // Filter by type
              ...NotificationType.values.map((type) {
                return _buildFilterTile(
                  context,
                  icon: _getIconForType(type),
                  label: _getLabelForType(type),
                  count: countsByType[type] ?? 0,
                  isSelected: selectedType == type,
                  onTap: () => _handleFilterChange(provider, type),
                );
              }),
            ],
          ),
        ),

        // Right content: Notifications list
        Expanded(
          child: notifications.isEmpty
              ? _buildEmptyState(context, selectedType)
              : _buildNotificationsList(context, provider, notifications),
        ),
      ],
    );
  }

  /// Builds a filter tile for desktop layout
  Widget _buildFilterTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int count,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? context.themeColors.colorPrimary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: isSelected
              ? Border.all(color: context.themeColors.colorPrimary)
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? context.themeColors.colorPrimary
                  : context.themeColors.textSecondary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: AppTheme.bodyMedium.copyWith(
                  color: isSelected
                      ? context.themeColors.colorPrimary
                      : context.themeColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            if (count > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? context.themeColors.colorPrimary
                      : context.themeColors.bgPrimary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  count.toString(),
                  style: AppTheme.bodySmall.copyWith(
                    color: isSelected
                        ? Colors.white
                        : context.themeColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Gets icon for notification type
  IconData _getIconForType(NotificationType type) {
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
        return Icons.local_activity;
    }
  }

  /// Gets label for notification type
  String _getLabelForType(NotificationType type) {
    switch (type) {
      case NotificationType.message:
        return 'Messages';
      case NotificationType.mention:
        return 'Mentions';
      case NotificationType.like:
        return 'J\'aime';
      case NotificationType.comment:
        return 'Commentaires';
      case NotificationType.announcement:
        return 'Annonces';
      case NotificationType.activity:
        return 'Activités';
    }
  }

  /// Builds the empty state when there are no notifications
  Widget _buildEmptyState(BuildContext context, NotificationType? filterType) {
    final String message;
    final IconData icon;

    if (filterType != null) {
      // Filtered but no results
      message = 'Aucune notification de ce type';
      icon = Icons.filter_list_off;
    } else {
      // No notifications at all
      message = 'Aucune notification';
      icon = Icons.notifications_none;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: context.themeColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: AppTheme.bodyLarge.copyWith(
              color: context.themeColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          if (filterType != null) ...[
            const SizedBox(height: 8),
            Text(
              'Essayez de changer le filtre',
              style: AppTheme.bodyMedium.copyWith(
                color: context.themeColors.textSecondary.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  // Action handlers

  /// Handles filter change
  void _handleFilterChange(NotificationProvider provider, NotificationType? type) {
    if (type == null) {
      // Clear all filters
      provider.clearFilters();
    } else {
      // Apply single filter (clear others first)
      provider.clearFilters();
      provider.applyFilter(type);
    }
  }

  /// Handles notification tap - navigates to related content
  void _handleNotificationTap(
    BuildContext context,
    NotificationProvider provider,
    dynamic notification,
  ) {
    final success = provider.navigateToContent(notification);
    
    if (!success) {
      // Show error if navigation failed
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Le contenu n\'est plus disponible'),
          backgroundColor: context.themeColors.colorDanger,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      // Show success feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Navigation vers ${_getContentTypeLabel(notification.targetType)}'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  /// Handles mark as read/unread toggle
  void _handleMarkReadToggle(NotificationProvider provider, dynamic notification) {
    if (notification.isRead) {
      provider.markAsUnread(notification.id);
    } else {
      provider.markAsRead(notification.id);
    }
  }

  /// Handles notification deletion
  void _handleDelete(
    BuildContext context,
    NotificationProvider provider,
    dynamic notification,
  ) {
    provider.deleteNotification(notification.id);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Notification supprimée'),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'Annuler',
          onPressed: () {
            // TODO: Implement undo functionality
            // This would require keeping a temporary copy of deleted notifications
          },
        ),
      ),
    );
  }

  /// Marks all notifications as read
  void _markAllAsRead(BuildContext context, NotificationProvider provider) {
    final unreadNotifications = provider.notifications
        .where((notif) => !notif.isRead)
        .toList();
    
    for (final notification in unreadNotifications) {
      provider.markAsRead(notification.id);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${unreadNotifications.length} notification(s) marquée(s) comme lue(s)'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Opens the notification settings screen
  void _openSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NotificationSettingsScreen(),
      ),
    );
  }

  /// Gets a user-friendly label for content type
  String _getContentTypeLabel(String? targetType) {
    switch (targetType) {
      case 'chat':
        return 'conversation';
      case 'post':
        return 'publication';
      case 'comment':
        return 'commentaire';
      case 'announcement':
        return 'annonce';
      case 'activity':
        return 'activité';
      default:
        return 'contenu';
    }
  }
}
