# Notification Center Screen

## Overview

The `NotificationCenterScreen` is the main screen for displaying and managing user notifications in the TableRonde app.

## Features

- **FilterTabs**: Horizontal tabs at the top for filtering notifications by type (Messages, Mentions, Likes, Comments, Announcements, Activities)
- **Notification List**: Scrollable list of notification tiles with swipe actions
- **Mark as Read/Unread**: Swipe right on a notification to toggle read status
- **Delete**: Swipe left on a notification to delete it
- **Navigation**: Tap on a notification to navigate to the related content
- **Empty State**: Shows appropriate message when there are no notifications
- **Mark All as Read**: Button in the app bar to mark all notifications as read at once

## Usage

### Basic Navigation

```dart
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => const NotificationCenterScreen(),
  ),
);
```

### Integration with Bottom Navigation

To add the notification center to the main navigation:

1. Add the screen to the `_screens` list in `MainScreen`:

```dart
_screens = [
  const HomeScreen(),
  const ChatListScreen(),
  const NotificationCenterScreen(), // Add this
];
```

2. Update the `CustomBottomNavBar` to include a notifications tab with badge counter:

```dart
Consumer<NotificationProvider>(
  builder: (context, provider, child) {
    return Badge(
      label: Text('${provider.unreadCount}'),
      isLabelVisible: provider.unreadCount > 0,
      child: Icon(Icons.notifications),
    );
  },
)
```

## Requirements Validated

- **6.1**: Displays dedicated notification center page
- **6.2**: Shows all notification types (Messages, Mentions, Likes, Comments, Announcements, Activities)
- **6.4**: Allows marking notifications as read/unread
- **6.5**: Allows deleting individual notifications
- **6.6**: Provides filtering by notification type
- **6.8**: Navigates to associated content when notification is tapped

## Dependencies

- `NotificationProvider`: State management for notifications
- `FilterTabs`: Widget for type filtering
- `NotificationTile`: Widget for displaying individual notifications
- `NotificationModel`: Data model for notifications
- `NotificationType`: Enum for notification types

## State Management

The screen uses `Consumer<NotificationProvider>` to listen to notification state changes:

- `filteredNotifications`: List of notifications based on active filters
- `unreadCount`: Number of unread notifications
- `activeFilters`: Currently active notification type filters

## Actions

### Swipe Actions

- **Swipe Right**: Toggle read/unread status
- **Swipe Left**: Delete notification (with confirmation)

### Tap Actions

- **Tap Notification**: Navigate to related content and mark as read
- **Tap Filter Tab**: Filter notifications by type
- **Tap "Mark All as Read"**: Mark all unread notifications as read

## Error Handling

- Shows error message if navigation to content fails (content no longer available)
- Provides undo option when deleting notifications (TODO: implement undo functionality)
- Displays appropriate empty state messages based on filter status

## Customization

The screen follows the app's theme using:
- `context.themeColors` for dynamic theming
- `AppTheme` constants for consistent spacing and typography
- Smooth animations for filter changes and list updates

## Future Enhancements

- [ ] Implement undo functionality for deleted notifications
- [ ] Add pull-to-refresh to reload notifications
- [ ] Add notification grouping by date
- [ ] Add search functionality within notifications
- [ ] Add notification settings quick access
