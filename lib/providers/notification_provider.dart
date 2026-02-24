import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/notifications/notification_model.dart';
import '../models/notifications/notification_type.dart';
import '../data/mock_notifications_data.dart';

/// Provider pour le centre de notifications
/// Gère l'affichage, le filtrage et les actions sur les notifications
class NotificationProvider extends ChangeNotifier {
  // State
  List<NotificationModel> _notifications = [];
  final Set<NotificationType> _activeFilters = {};
  Map<NotificationType, bool> _notificationSettings = {
    NotificationType.message: true,
    NotificationType.mention: true,
    NotificationType.like: true,
    NotificationType.comment: true,
    NotificationType.announcement: true,
    NotificationType.activity: true,
  };

  // Clé pour la persistance
  static const String _settingsKey = 'notification_settings';

  /// Constructeur - charge les données mockées et les paramètres
  NotificationProvider() {
    _generateMockNotifications();
    _loadSettings();
  }

  // Getters

  /// Liste complète des notifications
  List<NotificationModel> get notifications => List.unmodifiable(_notifications);

  /// Liste des notifications filtrées selon les filtres actifs
  List<NotificationModel> get filteredNotifications {
    if (_activeFilters.isEmpty) {
      return List.unmodifiable(_notifications);
    }
    return List.unmodifiable(
      _notifications.where((notif) => _activeFilters.contains(notif.type)).toList(),
    );
  }

  /// Nombre de notifications non lues
  int get unreadCount => _notifications.where((notif) => !notif.isRead).length;

  /// Paramètres de notifications par type
  Map<NotificationType, bool> get notificationSettings =>
      Map.unmodifiable(_notificationSettings);

  /// Filtres actifs
  Set<NotificationType> get activeFilters => Set.unmodifiable(_activeFilters);

  // Actions

  /// Marque une notification comme lue
  void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((notif) => notif.id == notificationId);
    if (index != -1 && !_notifications[index].isRead) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();
    }
  }

  /// Marque une notification comme non lue
  void markAsUnread(String notificationId) {
    final index = _notifications.indexWhere((notif) => notif.id == notificationId);
    if (index != -1 && _notifications[index].isRead) {
      _notifications[index] = _notifications[index].copyWith(isRead: false);
      notifyListeners();
    }
  }

  /// Supprime une notification
  void deleteNotification(String notificationId) {
    _notifications.removeWhere((notif) => notif.id == notificationId);
    notifyListeners();
  }

  /// Applique un filtre par type de notification
  void applyFilter(NotificationType type) {
    if (!_activeFilters.contains(type)) {
      _activeFilters.add(type);
      notifyListeners();
    }
  }

  /// Retire un filtre par type de notification
  void removeFilter(NotificationType type) {
    if (_activeFilters.contains(type)) {
      _activeFilters.remove(type);
      notifyListeners();
    }
  }

  /// Efface tous les filtres
  void clearFilters() {
    if (_activeFilters.isNotEmpty) {
      _activeFilters.clear();
      notifyListeners();
    }
  }

  /// Met à jour un paramètre de notification et le persiste
  Future<void> updateNotificationSetting(NotificationType type, bool enabled) async {
    if (_notificationSettings[type] != enabled) {
      _notificationSettings[type] = enabled;
      await _saveSettings();
      notifyListeners();
    }
  }

  /// Navigue vers le contenu associé à une notification
  /// Retourne true si la navigation est possible, false sinon
  bool navigateToContent(NotificationModel notification) {
    // Marquer la notification comme lue
    markAsRead(notification.id);

    // Vérifier que le contenu cible existe
    if (notification.targetId == null || notification.targetType == null) {
      if (kDebugMode) {
        print('Erreur: Notification sans contenu cible - ID: ${notification.id}');
      }
      return false;
    }

    // Simuler la navigation selon le type de contenu
    // Dans une vraie application, cela déclencherait une navigation réelle
    switch (notification.targetType) {
      case 'chat':
        if (kDebugMode) {
          print('Navigation vers chat: ${notification.targetId}');
        }
        return true;
      case 'post':
        if (kDebugMode) {
          print('Navigation vers post: ${notification.targetId}');
        }
        return true;
      case 'comment':
        if (kDebugMode) {
          print('Navigation vers commentaire: ${notification.targetId}');
        }
        return true;
      case 'announcement':
        if (kDebugMode) {
          print('Navigation vers annonce: ${notification.targetId}');
        }
        return true;
      case 'activity':
        if (kDebugMode) {
          print('Navigation vers activité: ${notification.targetId}');
        }
        return true;
      default:
        if (kDebugMode) {
          print('Erreur: Type de contenu inconnu - ${notification.targetType}');
        }
        return false;
    }
  }

  // Méthodes privées

  /// Génère les notifications mockées au démarrage
  void _generateMockNotifications() {
    _notifications = List.from(MockNotificationsData.notifications);
    // Trier par timestamp décroissant (plus récent en premier)
    _notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  /// Sauvegarde les paramètres de notifications dans shared_preferences
  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = json.encode(
        _notificationSettings.map((key, value) => MapEntry(key.name, value)),
      );
      await prefs.setString(_settingsKey, settingsJson);
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la sauvegarde des paramètres de notifications: $e');
      }
    }
  }

  /// Charge les paramètres de notifications depuis shared_preferences
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString(_settingsKey);
      
      if (settingsJson != null) {
        final Map<String, dynamic> decoded = json.decode(settingsJson);
        _notificationSettings = decoded.map(
          (key, value) => MapEntry(
            NotificationType.values.firstWhere((e) => e.name == key),
            value as bool,
          ),
        );
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors du chargement des paramètres de notifications: $e');
      }
      // En cas d'erreur, garder les paramètres par défaut
    }
  }
}
