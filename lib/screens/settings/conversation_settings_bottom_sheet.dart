import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/conversation_settings_provider.dart';
import '../../widgets/settings/settings_tile.dart';
import '../../widgets/settings/confirmation_dialog.dart';
import '../../utils/theme_extensions.dart';
import '../../utils/app_theme.dart';
import '../../utils/responsive_layout.dart';
import 'wallpaper_picker_screen.dart';

/// Bottom sheet for conversation settings
/// 
/// Displays settings options:
/// - Wallpaper selection
/// - Notifications toggle
/// - Pin conversation
/// - Archive conversation
/// - Block user (destructive)
/// - Report user (destructive)
/// - Delete conversation (destructive)
/// 
/// **Validates: Requirements 4.1, 4.3, 4.5, 4.6, 4.7, 4.8, 4.9**
class ConversationSettingsBottomSheet extends StatelessWidget {
  /// The ID of the conversation
  final String chatId;
  
  /// The name of the conversation/user
  final String chatName;

  const ConversationSettingsBottomSheet({
    super.key,
    required this.chatId,
    required this.chatName,
  });

  /// Shows the bottom sheet with slide up animation (300ms)
  /// 
  /// On mobile: shows as bottom sheet
  /// On desktop: shows as dialog
  /// 
  /// **Validates: Requirements 8.3**
  static Future<void> show({
    required BuildContext context,
    required String chatId,
    required String chatName,
  }) {
    return ResponsiveLayout.showAdaptiveModal(
      context: context,
      builder: (context) => ConversationSettingsBottomSheet(
        chatId: chatId,
        chatName: chatName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveLayout.shouldUseDesktopLayout(context);
    
    return Consumer<ConversationSettingsProvider>(
      builder: (context, settingsProvider, child) {
        final settings = settingsProvider.getSettings(chatId);

        // On desktop, show as dialog
        if (isDesktop) {
          return Dialog(
            child: Container(
              width: 500,
              constraints: const BoxConstraints(maxHeight: 700),
              decoration: BoxDecoration(
                color: context.themeColors.bgPrimary,
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Paramètres de conversation',
                                style: AppTheme.headingSmall.copyWith(
                                  color: context.themeColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                chatName,
                                style: AppTheme.bodyMedium.copyWith(
                                  color: context.themeColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(context).pop(),
                          color: context.themeColors.textSecondary,
                        ),
                      ],
                    ),
                  ),

                  const Divider(height: 1),

                  // Settings list
                  Flexible(
                    child: _buildSettingsList(context, settings),
                  ),
                ],
              ),
            ),
          );
        }

        // On mobile, show as bottom sheet
        return Container(
          decoration: BoxDecoration(
            color: context.themeColors.bgPrimary,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppTheme.radiusLarge),
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.themeColors.borderMedium,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Paramètres de conversation',
                              style: AppTheme.headingSmall.copyWith(
                                color: context.themeColors.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              chatName,
                              style: AppTheme.bodyMedium.copyWith(
                                color: context.themeColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                        color: context.themeColors.textSecondary,
                      ),
                    ],
                  ),
                ),

                // Settings list
                Flexible(
                  child: _buildSettingsList(context, settings),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Builds the settings list (shared between mobile and desktop)
  Widget _buildSettingsList(BuildContext context, settings) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Wallpaper
          SettingsTile(
            icon: Icons.wallpaper,
            title: 'Fond d\'écran',
            subtitle: settings.wallpaperUrl != null
                ? 'Personnalisé'
                : 'Par défaut',
            type: SettingsTileType.navigation,
            onTap: () => _navigateToWallpaperPicker(context),
          ),

          const Divider(height: 1),

          // Notifications
          SettingsTile(
            icon: settings.notificationsEnabled
                ? Icons.notifications_active
                : Icons.notifications_off,
            title: 'Notifications',
            subtitle: settings.notificationsEnabled
                ? 'Activées'
                : 'Désactivées',
            type: SettingsTileType.toggle,
            toggleValue: settings.notificationsEnabled,
            onToggleChanged: (value) =>
                _toggleNotifications(context),
          ),

          const Divider(height: 1),

          // Pin conversation
          SettingsTile(
            icon: settings.isPinned
                ? Icons.push_pin
                : Icons.push_pin_outlined,
            title: settings.isPinned
                ? 'Désépingler'
                : 'Épingler',
            subtitle: settings.isPinned
                ? 'Conversation épinglée en haut'
                : 'Épingler en haut de la liste',
            type: SettingsTileType.action,
            onTap: () => _togglePin(context),
          ),

          const Divider(height: 1),

          // Archive conversation
          SettingsTile(
            icon: settings.isArchived
                ? Icons.unarchive
                : Icons.archive_outlined,
            title: settings.isArchived
                ? 'Désarchiver'
                : 'Archiver',
            subtitle: settings.isArchived
                ? 'Conversation archivée'
                : 'Masquer de la liste principale',
            type: SettingsTileType.action,
            onTap: () => _toggleArchive(context),
          ),

          const SizedBox(height: 16),

          // Destructive actions section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Actions',
              style: AppTheme.bodySmall.copyWith(
                color: context.themeColors.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Block user
          SettingsTile(
            icon: Icons.block,
            title: 'Bloquer',
            subtitle: 'Ne plus recevoir de messages',
            type: SettingsTileType.action,
            isDestructive: true,
            onTap: () => _blockUser(context),
          ),

          const Divider(height: 1),

          // Report user
          SettingsTile(
            icon: Icons.flag_outlined,
            title: 'Signaler',
            subtitle: 'Signaler un comportement inapproprié',
            type: SettingsTileType.action,
            isDestructive: true,
            onTap: () => _reportUser(context),
          ),

          const Divider(height: 1),

          // Delete conversation
          SettingsTile(
            icon: Icons.delete_outline,
            title: 'Supprimer la conversation',
            subtitle: 'Supprimer tous les messages',
            type: SettingsTileType.action,
            isDestructive: true,
            onTap: () => _deleteConversation(context),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // Action handlers

  void _navigateToWallpaperPicker(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => WallpaperPickerScreen(chatId: chatId),
      ),
    );
  }

  Future<void> _toggleNotifications(BuildContext context) async {
    try {
      await context.read<ConversationSettingsProvider>().toggleNotifications(chatId);
      
      final settings = context.read<ConversationSettingsProvider>().getSettings(chatId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              settings.notificationsEnabled
                  ? 'Notifications activées'
                  : 'Notifications désactivées',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: context.themeColors.colorDanger,
          ),
        );
      }
    }
  }

  Future<void> _togglePin(BuildContext context) async {
    try {
      final settings = context.read<ConversationSettingsProvider>().getSettings(chatId);
      
      if (settings.isPinned) {
        await context.read<ConversationSettingsProvider>().unpinConversation(chatId);
      } else {
        await context.read<ConversationSettingsProvider>().pinConversation(chatId);
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              settings.isPinned
                  ? 'Conversation désépinglée'
                  : 'Conversation épinglée',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: context.themeColors.colorDanger,
          ),
        );
      }
    }
  }

  Future<void> _toggleArchive(BuildContext context) async {
    try {
      final settings = context.read<ConversationSettingsProvider>().getSettings(chatId);
      
      if (settings.isArchived) {
        await context.read<ConversationSettingsProvider>().unarchiveConversation(chatId);
      } else {
        await context.read<ConversationSettingsProvider>().archiveConversation(chatId);
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              settings.isArchived
                  ? 'Conversation désarchivée'
                  : 'Conversation archivée',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: context.themeColors.colorDanger,
          ),
        );
      }
    }
  }

  Future<void> _blockUser(BuildContext context) async {
    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: 'Bloquer cet utilisateur',
      message: 'Êtes-vous sûr de vouloir bloquer $chatName ? '
          'Vous ne recevrez plus de messages de cette personne.',
      confirmText: 'Bloquer',
      isDestructive: true,
    );

    if (confirmed == true && context.mounted) {
      try {
        await context.read<ConversationSettingsProvider>().blockUser(chatId);
        
        if (context.mounted) {
          Navigator.of(context).pop(); // Close bottom sheet
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$chatName a été bloqué'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: ${e.toString()}'),
              backgroundColor: context.themeColors.colorDanger,
            ),
          );
        }
      }
    }
  }

  Future<void> _reportUser(BuildContext context) async {
    // Show reason selection dialog
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Signaler cet utilisateur'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Sélectionnez une raison :'),
            const SizedBox(height: 16),
            ...[
              'Spam',
              'Harcèlement',
              'Contenu inapproprié',
              'Usurpation d\'identité',
              'Autre',
            ].map((r) => ListTile(
              title: Text(r),
              onTap: () => Navigator.of(context).pop(r),
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );

    if (reason != null && context.mounted) {
      try {
        await context.read<ConversationSettingsProvider>().reportUser(chatId, reason);
        
        if (context.mounted) {
          Navigator.of(context).pop(); // Close bottom sheet
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$chatName a été signalé pour: $reason'),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: ${e.toString()}'),
              backgroundColor: context.themeColors.colorDanger,
            ),
          );
        }
      }
    }
  }

  Future<void> _deleteConversation(BuildContext context) async {
    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: 'Supprimer la conversation',
      message: 'Êtes-vous sûr de vouloir supprimer cette conversation avec $chatName ? '
          'Tous les messages seront définitivement supprimés.',
      confirmText: 'Supprimer',
      isDestructive: true,
    );

    if (confirmed == true && context.mounted) {
      try {
        await context.read<ConversationSettingsProvider>().deleteConversation(chatId);
        
        if (context.mounted) {
          Navigator.of(context).pop(); // Close bottom sheet
          Navigator.of(context).pop(); // Close chat screen
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Conversation supprimée'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: ${e.toString()}'),
              backgroundColor: context.themeColors.colorDanger,
            ),
          );
        }
      }
    }
  }
}
