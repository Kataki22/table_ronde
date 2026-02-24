import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/notification_provider.dart';
import '../../models/notifications/notification_type.dart';
import '../../widgets/settings/settings_tile.dart';
import '../../utils/theme_extensions.dart';

/// Screen for configuring notification preferences
/// 
/// Features:
/// - Display list of all notification types
/// - Toggle switches to enable/disable each type
/// - Automatic persistence of preferences
/// 
/// **Validates: Requirements 6.7**
class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.themeColors.bgPrimary,
      appBar: AppBar(
        title: const Text('Paramètres de notifications'),
        backgroundColor: context.themeColors.bgSecondary,
        elevation: 0,
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          final settings = provider.notificationSettings;

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              // Section header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  'Types de notifications',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: context.themeColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),

              // Messages
              SettingsTile(
                icon: Icons.message,
                title: 'Messages',
                subtitle: 'Notifications pour les nouveaux messages',
                type: SettingsTileType.toggle,
                toggleValue: settings[NotificationType.message] ?? true,
                onToggleChanged: (value) => _updateSetting(
                  provider,
                  NotificationType.message,
                  value,
                ),
                iconColor: Colors.blue,
              ),

              // Mentions
              SettingsTile(
                icon: Icons.alternate_email,
                title: 'Mentions',
                subtitle: 'Notifications quand vous êtes mentionné',
                type: SettingsTileType.toggle,
                toggleValue: settings[NotificationType.mention] ?? true,
                onToggleChanged: (value) => _updateSetting(
                  provider,
                  NotificationType.mention,
                  value,
                ),
                iconColor: Colors.purple,
              ),

              // Likes
              SettingsTile(
                icon: Icons.favorite,
                title: 'Likes',
                subtitle: 'Notifications pour les likes sur vos publications',
                type: SettingsTileType.toggle,
                toggleValue: settings[NotificationType.like] ?? true,
                onToggleChanged: (value) => _updateSetting(
                  provider,
                  NotificationType.like,
                  value,
                ),
                iconColor: Colors.red,
              ),

              // Comments
              SettingsTile(
                icon: Icons.comment,
                title: 'Commentaires',
                subtitle: 'Notifications pour les commentaires',
                type: SettingsTileType.toggle,
                toggleValue: settings[NotificationType.comment] ?? true,
                onToggleChanged: (value) => _updateSetting(
                  provider,
                  NotificationType.comment,
                  value,
                ),
                iconColor: Colors.green,
              ),

              // Announcements
              SettingsTile(
                icon: Icons.campaign,
                title: 'Annonces',
                subtitle: 'Notifications pour les annonces importantes',
                type: SettingsTileType.toggle,
                toggleValue: settings[NotificationType.announcement] ?? true,
                onToggleChanged: (value) => _updateSetting(
                  provider,
                  NotificationType.announcement,
                  value,
                ),
                iconColor: Colors.orange,
              ),

              // Activities
              SettingsTile(
                icon: Icons.notifications_active,
                title: 'Activités',
                subtitle: 'Notifications pour les activités générales',
                type: SettingsTileType.toggle,
                toggleValue: settings[NotificationType.activity] ?? true,
                onToggleChanged: (value) => _updateSetting(
                  provider,
                  NotificationType.activity,
                  value,
                ),
                iconColor: Colors.teal,
              ),

              // Info section
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Les paramètres sont sauvegardés automatiquement et s\'appliquent immédiatement.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.themeColors.textSecondary,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Updates a notification setting and persists it
  void _updateSetting(
    NotificationProvider provider,
    NotificationType type,
    bool enabled,
  ) {
    provider.updateNotificationSetting(type, enabled);
  }
}
