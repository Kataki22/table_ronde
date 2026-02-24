import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'notification_provider.dart';
import '../models/notifications/notification_type.dart';

/// Exemple d'utilisation du NotificationProvider
/// 
/// Ce fichier démontre comment utiliser le NotificationProvider dans l'application
/// pour gérer les notifications, les filtrer, et interagir avec elles.

class NotificationProviderUsageExample extends StatelessWidget {
  const NotificationProviderUsageExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          // Badge avec compteur de notifications non lues
          Consumer<NotificationProvider>(
            builder: (context, provider, child) {
              final unreadCount = provider.unreadCount;
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications),
                    onPressed: () {
                      // Navigation vers le centre de notifications
                    },
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          unreadCount > 99 ? '99+' : '$unreadCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtres par type de notification
          _buildFilterChips(context),
          
          // Liste des notifications
          Expanded(
            child: _buildNotificationList(context),
          ),
        ],
      ),
    );
  }

  /// Construit les chips de filtrage
  Widget _buildFilterChips(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, provider, child) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.all(8),
          child: Row(
            children: NotificationType.values.map((type) {
              final isActive = provider.activeFilters.contains(type);
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: FilterChip(
                  label: Text(_getTypeLabel(type)),
                  selected: isActive,
                  onSelected: (selected) {
                    if (selected) {
                      provider.applyFilter(type);
                    } else {
                      provider.removeFilter(type);
                    }
                  },
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  /// Construit la liste des notifications
  Widget _buildNotificationList(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, provider, child) {
        final notifications = provider.filteredNotifications;

        if (notifications.isEmpty) {
          return const Center(
            child: Text('Aucune notification'),
          );
        }

        return ListView.builder(
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            final notification = notifications[index];
            return Dismissible(
              key: Key(notification.id),
              background: Container(
                color: Colors.blue,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 20),
                child: const Icon(Icons.mark_email_read, color: Colors.white),
              ),
              secondaryBackground: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              confirmDismiss: (direction) async {
                if (direction == DismissDirection.startToEnd) {
                  // Marquer comme lu/non lu
                  if (notification.isRead) {
                    provider.markAsUnread(notification.id);
                  } else {
                    provider.markAsRead(notification.id);
                  }
                  return false;
                } else {
                  // Supprimer
                  return true;
                }
              },
              onDismissed: (direction) {
                provider.deleteNotification(notification.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Notification supprimée')),
                );
              },
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: notification.color.withOpacity(0.2),
                  child: Icon(notification.icon, color: notification.color),
                ),
                title: Text(
                  notification.title,
                  style: TextStyle(
                    fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                  ),
                ),
                subtitle: Text(notification.body),
                trailing: Text(
                  _formatTimestamp(notification.timestamp),
                  style: const TextStyle(fontSize: 12),
                ),
                onTap: () {
                  final success = provider.navigateToContent(notification);
                  if (!success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Le contenu n\'est plus disponible'),
                      ),
                    );
                  }
                },
              ),
            );
          },
        );
      },
    );
  }

  /// Retourne le label pour un type de notification
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

  /// Formate le timestamp de la notification
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'À l\'instant';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}j';
    } else {
      return '${timestamp.day}/${timestamp.month}';
    }
  }
}

/// Exemple de paramètres de notifications
class NotificationSettingsExample extends StatelessWidget {
  const NotificationSettingsExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres de notifications'),
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          return ListView(
            children: NotificationType.values.map((type) {
              final isEnabled = provider.notificationSettings[type] ?? true;
              return SwitchListTile(
                title: Text(_getTypeLabel(type)),
                subtitle: Text(_getTypeDescription(type)),
                value: isEnabled,
                onChanged: (value) {
                  provider.updateNotificationSetting(type, value);
                },
              );
            }).toList(),
          );
        },
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

  String _getTypeDescription(NotificationType type) {
    switch (type) {
      case NotificationType.message:
        return 'Recevoir des notifications pour les nouveaux messages';
      case NotificationType.mention:
        return 'Recevoir des notifications quand vous êtes mentionné';
      case NotificationType.like:
        return 'Recevoir des notifications pour les likes';
      case NotificationType.comment:
        return 'Recevoir des notifications pour les commentaires';
      case NotificationType.announcement:
        return 'Recevoir les annonces importantes';
      case NotificationType.activity:
        return 'Recevoir des notifications d\'activité';
    }
  }
}
