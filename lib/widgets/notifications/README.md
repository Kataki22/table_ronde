# Notification Widgets

Ce module fournit des widgets réutilisables pour afficher et gérer les notifications dans l'application TableRonde.

## Widgets disponibles

### 1. NotificationTile

Widget pour afficher une notification individuelle avec support des actions de swipe.

**Fonctionnalités:**
- Affiche l'icône, le titre, le corps et l'horodatage de la notification
- Indicateur visuel pour les notifications non lues
- Swipe vers la droite : marquer comme lu/non lu
- Swipe vers la gauche : supprimer
- Tap pour naviguer vers le contenu associé
- Affichage de l'avatar si disponible

**Exemple d'utilisation:**

```dart
NotificationTile(
  notification: notification,
  onTap: () {
    // Naviguer vers le contenu
    Navigator.push(context, ...);
  },
  onMarkRead: () {
    // Marquer comme lu/non lu
    notificationProvider.markAsRead(notification.id);
  },
  onDelete: () {
    // Supprimer la notification
    notificationProvider.deleteNotification(notification.id);
  },
)
```

### 2. FilterTabs

Barre d'onglets pour filtrer les notifications par type.

**Fonctionnalités:**
- Affiche des onglets pour chaque type de notification
- Affiche le nombre de notifications par type
- Gère la sélection et le filtrage
- Animations fluides entre les onglets

**Exemple d'utilisation:**

```dart
FilterTabs(
  selectedType: selectedType,
  onTypeSelected: (type) {
    setState(() {
      selectedType = type;
    });
  },
  countsByType: {
    NotificationType.message: 5,
    NotificationType.mention: 2,
    NotificationType.like: 10,
  },
  totalCount: 17,
)
```

### 3. BadgeCounter

Badge animé pour afficher le nombre de notifications non lues.

**Fonctionnalités:**
- Affiche un badge circulaire avec un compteur
- Animation d'apparition pour les nouvelles notifications
- Se cache automatiquement quand le compteur est à 0
- Affiche "99+" pour les compteurs supérieurs à 99
- Support des couleurs personnalisées

**Exemple d'utilisation:**

```dart
Stack(
  children: [
    IconButton(
      icon: Icon(Icons.notifications),
      onPressed: () {
        // Ouvrir le centre de notifications
      },
    ),
    Positioned(
      right: 0,
      top: 0,
      child: BadgeCounter(
        count: unreadCount,
      ),
    ),
  ],
)
```

## Exemple complet

Voici un exemple d'utilisation complète des trois widgets ensemble :

```dart
class NotificationCenterScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Notifications'),
            actions: [
              Stack(
                children: [
                  IconButton(
                    icon: Icon(Icons.settings),
                    onPressed: () {
                      // Ouvrir les paramètres
                    },
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: BadgeCounter(
                      count: provider.unreadCount,
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: Column(
            children: [
              FilterTabs(
                selectedType: provider.selectedFilter,
                onTypeSelected: (type) {
                  provider.applyFilter(type);
                },
                countsByType: provider.countsByType,
                totalCount: provider.notifications.length,
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: provider.filteredNotifications.length,
                  itemBuilder: (context, index) {
                    final notification = provider.filteredNotifications[index];
                    return NotificationTile(
                      notification: notification,
                      onTap: () {
                        provider.navigateToContent(notification);
                      },
                      onMarkRead: () {
                        if (notification.isRead) {
                          provider.markAsUnread(notification.id);
                        } else {
                          provider.markAsRead(notification.id);
                        }
                      },
                      onDelete: () {
                        provider.deleteNotification(notification.id);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
```

## Validation des exigences

- **NotificationTile** valide les exigences 6.2, 6.4, 6.5
- **FilterTabs** valide l'exigence 6.6
- **BadgeCounter** valide l'exigence 6.3

## Tests

Les tests unitaires pour ces widgets se trouvent dans `test/widgets/notifications/notification_widgets_test.dart`.

Pour exécuter les tests :

```bash
flutter test test/widgets/notifications/notification_widgets_test.dart
```
