# Design Document: Social Chat Enhancements

## Overview

Ce document définit l'architecture et le design technique pour l'implémentation des fonctionnalités sociales et de chat avancées dans l'application TableRonde. Le projet enrichit l'expérience utilisateur avec six modules principaux : groupes de discussion, profils utilisateurs détaillés, recherche dans les messages, paramètres de conversation, galerie de médias partagés et centre de notifications.

L'implémentation respecte l'architecture MVC modulaire existante avec Provider pour la gestion d'état, et maintient la cohérence visuelle avec le design inspiré de Discord et Telegram. Toutes les fonctionnalités utilisent des données mockées sans backend réel.

### Objectifs principaux

- Permettre la création et gestion de groupes de discussion avec système de permissions
- Fournir des profils utilisateurs complets avec édition et actions contextuelles
- Implémenter une recherche performante dans l'historique des messages avec filtres
- Offrir des paramètres de conversation personnalisables (fond d'écran, notifications, etc.)
- Créer une galerie organisée des médias partagés par type de contenu
- Centraliser la gestion des notifications avec filtrage et actions
- Assurer la persistance locale des préférences utilisateur
- Maintenir une interface responsive et fluide (60 FPS minimum)

### Contraintes techniques

- Flutter 3.x avec architecture MVC modulaire existante
- Provider pour la gestion d'état (pas de backend réel)
- Données mockées pour toutes les fonctionnalités
- Design responsive mobile-first avec support desktop
- Animations fluides (200-500ms selon le contexte)
- Réutilisation maximale des composants existants
- Persistance locale avec shared_preferences

## Architecture

### Vue d'ensemble architecturale

L'architecture suit le pattern MVC modulaire existant avec une séparation claire entre les couches :

```
┌─────────────────────────────────────────────────────────────┐
│                        Presentation Layer                    │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   Screens    │  │   Widgets    │  │  Bottom      │      │
│  │              │  │              │  │  Sheets      │      │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘      │
│         │                 │                 │               │
└─────────┼─────────────────┼─────────────────┼───────────────┘
          │                 │                 │
          └─────────────────┼─────────────────┘
                            │
┌───────────────────────────┼───────────────────────────────────┐
│                    Business Logic Layer                       │
│                            │                                  │
│  ┌─────────────────────────▼──────────────────────────────┐  │
│  │              Provider (State Management)               │  │
│  │  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ │  │
│  │  │  Group   │ │ Profile  │ │  Search  │ │  Media   │ │  │
│  │  │ Provider │ │ Provider │ │ Provider │ │ Provider │ │  │
│  │  └──────────┘ └──────────┘ └──────────┘ └──────────┘ │  │
│  │  ┌──────────┐ ┌──────────┐                           │  │
│  │  │Settings  │ │Notif.    │                           │  │
│  │  │Provider  │ │Provider  │                           │  │
│  │  └──────────┘ └──────────┘                           │  │
│  └────────────────────────┬───────────────────────────────┘  │
└───────────────────────────┼───────────────────────────────────┘
                            │
┌───────────────────────────┼───────────────────────────────────┐
│                       Data Layer                              │
│                            │                                  │
│  ┌─────────────────────────▼──────────────────────────────┐  │
│  │                    Models                               │  │
│  │  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ │  │
│  │  │  Group   │ │  User    │ │  Media   │ │Notifica- │ │  │
│  │  │  Model   │ │ Profile  │ │  Item    │ │  tion    │ │  │
│  │  └──────────┘ └──────────┘ └──────────┘ └──────────┘ │  │
│  └────────────────────────┬───────────────────────────────┘  │
│                            │                                  │
│  ┌─────────────────────────▼──────────────────────────────┐  │
│  │              Local Storage (Mock Data)                 │  │
│  │         shared_preferences + in-memory cache           │  │
│  └────────────────────────────────────────────────────────┘  │
└───────────────────────────────────────────────────────────────┘
```

### Principes architecturaux

1. **Séparation des responsabilités** : Chaque Provider gère un domaine fonctionnel spécifique
2. **Unidirectional data flow** : Les widgets écoutent les Providers via Consumer/Selector
3. **Immutabilité** : Les modèles sont immutables, les modifications créent de nouvelles instances
4. **Composition** : Réutilisation maximale des widgets existants (chat bubbles, avatars, etc.)
5. **Lazy loading** : Chargement progressif des médias et messages pour optimiser les performances
6. **Responsive design** : Adaptation automatique mobile/desktop via MediaQuery

### Modules fonctionnels

#### Module 1: Group Chat Management
- **Provider**: GroupChatProvider
- **Models**: GroupChatModel, GroupMemberModel, GroupPermission
- **Screens**: GroupCreationScreen, GroupInfoScreen, GroupMembersScreen
- **Widgets**: GroupChatBubble, MemberListTile, PermissionBadge

#### Module 2: User Profiles
- **Provider**: ProfileProvider
- **Models**: UserProfileModel, UserActivity, UserPost
- **Screens**: ProfileScreen, ProfileEditScreen
- **Widgets**: ProfileHeader, ActivityCard, PostCard, ActionButtons

#### Module 3: Message Search
- **Provider**: MessageSearchProvider
- **Models**: SearchResult, SearchFilter
- **Widgets**: SearchBar, SearchResultsList, FilterChips, ResultHighlight

#### Module 4: Conversation Settings
- **Provider**: ConversationSettingsProvider
- **Models**: ConversationSettings, WallpaperOption, NotificationSettings
- **Screens**: ConversationSettingsScreen, WallpaperPickerScreen
- **Widgets**: SettingsTile, WallpaperGrid, ConfirmationDialog

#### Module 5: Media Gallery
- **Provider**: MediaGalleryProvider
- **Models**: MediaItem, MediaType (enum)
- **Screens**: MediaGalleryScreen, MediaViewerScreen
- **Widgets**: MediaGrid, MediaListTile, TabBar, FullScreenViewer

#### Module 6: Notification Center
- **Provider**: NotificationProvider
- **Models**: NotificationModel, NotificationType (enum)
- **Screens**: NotificationCenterScreen, NotificationSettingsScreen
- **Widgets**: NotificationTile, FilterTabs, BadgeCounter

## Components and Interfaces

### Providers (State Management)

#### GroupChatProvider

```dart
class GroupChatProvider extends ChangeNotifier {
  // State
  List<GroupChatModel> _groups;
  Map<String, List<MessageModel>> _groupMessages;
  
  // Getters
  List<GroupChatModel> get groups;
  GroupChatModel? getGroupById(String id);
  List<MessageModel> getGroupMessages(String groupId);
  
  // Actions
  Future<GroupChatModel> createGroup({
    required String name,
    String? description,
    String? photoUrl,
    required List<String> memberIds,
  });
  
  Future<void> addMember(String groupId, String userId);
  Future<void> removeMember(String groupId, String userId);
  Future<void> updateMemberPermission(
    String groupId,
    String userId,
    GroupPermission permission,
  );
  Future<void> leaveGroup(String groupId);
  Future<void> sendGroupMessage(String groupId, MessageModel message);
}
```

#### ProfileProvider

```dart
class ProfileProvider extends ChangeNotifier {
  // State
  Map<String, UserProfileModel> _profiles;
  UserProfileModel? _currentUserProfile;
  
  // Getters
  UserProfileModel? getProfile(String userId);
  UserProfileModel? get currentUserProfile;
  List<UserActivity> getUserActivities(String userId);
  List<UserPost> getUserPosts(String userId);
  
  // Actions
  Future<void> updateProfile({
    String? bio,
    String? photoUrl,
    String? phone,
  });
  
  Future<void> blockUser(String userId);
  Future<void> unblockUser(String userId);
}
```

#### MessageSearchProvider

```dart
class MessageSearchProvider extends ChangeNotifier {
  // State
  String _query;
  List<SearchResult> _results;
  Set<MessageType> _activeFilters;
  int _currentResultIndex;
  
  // Getters
  String get query;
  List<SearchResult> get results;
  int get resultCount;
  int get currentResultIndex;
  Set<MessageType> get activeFilters;
  
  // Actions
  void search(String query, String chatId);
  void applyFilter(MessageType type);
  void removeFilter(MessageType type);
  void clearFilters();
  void navigateToNext();
  void navigateToPrevious();
  void clear();
}
```

#### ConversationSettingsProvider

```dart
class ConversationSettingsProvider extends ChangeNotifier {
  // State
  Map<String, ConversationSettings> _settings;
  
  // Getters
  ConversationSettings getSettings(String chatId);
  
  // Actions
  Future<void> setWallpaper(String chatId, String wallpaperUrl);
  Future<void> toggleNotifications(String chatId);
  Future<void> setNotificationSound(String chatId, String soundId);
  Future<void> pinConversation(String chatId);
  Future<void> unpinConversation(String chatId);
  Future<void> archiveConversation(String chatId);
  Future<void> unarchiveConversation(String chatId);
  Future<void> deleteConversation(String chatId);
  Future<void> blockUser(String chatId);
  Future<void> reportUser(String chatId, String reason);
  
  // Persistence
  Future<void> _saveSettings(String chatId);
  Future<void> _loadSettings();
}
```

#### MediaGalleryProvider

```dart
class MediaGalleryProvider extends ChangeNotifier {
  // State
  Map<String, List<MediaItem>> _mediaByChat;
  MediaType _selectedTab;
  
  // Getters
  List<MediaItem> getMediaForChat(String chatId, MediaType type);
  List<MediaItem> getPhotos(String chatId);
  List<MediaItem> getVideos(String chatId);
  List<MediaItem> getDocuments(String chatId);
  List<MediaItem> getLinks(String chatId);
  List<MediaItem> getVoiceMessages(String chatId);
  MediaType get selectedTab;
  
  // Actions
  void selectTab(MediaType type);
  Future<void> downloadMedia(MediaItem item);
  void openMediaViewer(MediaItem item, List<MediaItem> gallery);
}
```

#### NotificationProvider

```dart
class NotificationProvider extends ChangeNotifier {
  // State
  List<NotificationModel> _notifications;
  Set<NotificationType> _activeFilters;
  Map<NotificationType, bool> _notificationSettings;
  
  // Getters
  List<NotificationModel> get notifications;
  List<NotificationModel> get filteredNotifications;
  int get unreadCount;
  Map<NotificationType, bool> get notificationSettings;
  
  // Actions
  void markAsRead(String notificationId);
  void markAsUnread(String notificationId);
  void deleteNotification(String notificationId);
  void applyFilter(NotificationType type);
  void removeFilter(NotificationType type);
  void clearFilters();
  Future<void> updateNotificationSetting(NotificationType type, bool enabled);
  void navigateToContent(NotificationModel notification);
  
  // Mock data generation
  void _generateMockNotifications();
}
```

### Key Widgets

#### GroupChatBubble
Widget personnalisé affichant un message de groupe avec avatars multiples et indicateur de lecture.

```dart
class GroupChatBubble extends StatelessWidget {
  final MessageModel message;
  final GroupMemberModel sender;
  final bool showAvatar;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
}
```

#### ProfileHeader
En-tête de profil avec photo, nom, bio et statistiques.

```dart
class ProfileHeader extends StatelessWidget {
  final UserProfileModel profile;
  final bool isCurrentUser;
  final VoidCallback? onEditPressed;
}
```

#### SearchResultsList
Liste des résultats de recherche avec navigation et highlight.

```dart
class SearchResultsList extends StatelessWidget {
  final List<SearchResult> results;
  final int currentIndex;
  final Function(SearchResult) onResultTap;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
}
```

#### MediaGrid
Grille de miniatures pour photos et vidéos.

```dart
class MediaGrid extends StatelessWidget {
  final List<MediaItem> items;
  final Function(MediaItem, int) onItemTap;
  final int crossAxisCount;
}
```

#### NotificationTile
Tuile de notification avec icône, contenu et actions.

```dart
class NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;
  final VoidCallback onMarkRead;
  final VoidCallback onDelete;
}
```

### Navigation Flow

```
Main Screen (Bottom Navigation)
├── Home Tab
│   └── Profile Screen (tap on user)
│       └── Profile Edit Screen (if current user)
│
├── Chat Tab
│   ├── Chat List Screen
│   │   ├── Chat Screen (1-to-1)
│   │   │   ├── Search Bar (in AppBar)
│   │   │   ├── Conversation Settings (Bottom Sheet)
│   │   │   │   ├── Wallpaper Picker
│   │   │   │   └── Confirmation Dialogs
│   │   │   └── Media Gallery (Bottom Sheet/Screen)
│   │   │       └── Media Viewer (Full Screen)
│   │   │
│   │   └── Group Chat Screen
│   │       ├── Group Info (Bottom Sheet)
│   │       │   └── Group Members Screen
│   │       ├── Search Bar (in AppBar)
│   │       ├── Conversation Settings (Bottom Sheet)
│   │       └── Media Gallery (Bottom Sheet/Screen)
│   │
│   └── Group Creation Screen (FAB)
│
└── Notifications Tab
    ├── Notification Center Screen
    │   └── Navigate to content (message, post, etc.)
    └── Notification Settings Screen
```

## Data Models

### GroupChatModel

```dart
enum GroupPermission { admin, moderator, member }

class GroupChatModel {
  final String id;
  final String name;
  final String? description;
  final String? photoUrl;
  final List<GroupMemberModel> members;
  final DateTime createdAt;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final int unreadCount;
  
  GroupChatModel({
    required this.id,
    required this.name,
    this.description,
    this.photoUrl,
    required this.members,
    required this.createdAt,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
  });
  
  // Helper methods
  bool isUserAdmin(String userId);
  bool isUserModerator(String userId);
  bool canUserManageMembers(String userId);
  List<GroupMemberModel> get admins;
  List<GroupMemberModel> get moderators;
}

class GroupMemberModel {
  final String userId;
  final String name;
  final String? avatarUrl;
  final GroupPermission permission;
  final DateTime joinedAt;
  
  GroupMemberModel({
    required this.userId,
    required this.name,
    this.avatarUrl,
    required this.permission,
    required this.joinedAt,
  });
}
```

### UserProfileModel

```dart
class UserProfileModel {
  final String id;
  final String name;
  final String? username;
  final String? bio;
  final String? phone;
  final String? avatarUrl;
  final DateTime createdAt;
  final bool isOnline;
  final String? currentActivity;
  final List<UserActivity> recentActivities;
  final List<UserPost> posts;
  
  UserProfileModel({
    required this.id,
    required this.name,
    this.username,
    this.bio,
    this.phone,
    this.avatarUrl,
    required this.createdAt,
    this.isOnline = false,
    this.currentActivity,
    this.recentActivities = const [],
    this.posts = const [],
  });
  
  // Copy with for immutability
  UserProfileModel copyWith({
    String? name,
    String? username,
    String? bio,
    String? phone,
    String? avatarUrl,
    bool? isOnline,
    String? currentActivity,
  });
}

class UserActivity {
  final String id;
  final String type; // 'post', 'comment', 'like', 'join_group'
  final String description;
  final DateTime timestamp;
  
  UserActivity({
    required this.id,
    required this.type,
    required this.description,
    required this.timestamp,
  });
}

class UserPost {
  final String id;
  final String content;
  final List<String> imageUrls;
  final int likesCount;
  final int commentsCount;
  final DateTime createdAt;
  
  UserPost({
    required this.id,
    required this.content,
    this.imageUrls = const [],
    this.likesCount = 0,
    this.commentsCount = 0,
    required this.createdAt,
  });
}
```

### SearchResult

```dart
class SearchResult {
  final MessageModel message;
  final String chatId;
  final int matchIndex; // Position in the message list
  final List<TextRange> highlightRanges; // Ranges to highlight
  
  SearchResult({
    required this.message,
    required this.chatId,
    required this.matchIndex,
    required this.highlightRanges,
  });
}

class TextRange {
  final int start;
  final int end;
  
  TextRange(this.start, this.end);
}
```

### ConversationSettings

```dart
class ConversationSettings {
  final String chatId;
  final String? wallpaperUrl;
  final bool notificationsEnabled;
  final String? notificationSoundId;
  final bool isPinned;
  final bool isArchived;
  
  ConversationSettings({
    required this.chatId,
    this.wallpaperUrl,
    this.notificationsEnabled = true,
    this.notificationSoundId,
    this.isPinned = false,
    this.isArchived = false,
  });
  
  // Serialization for shared_preferences
  Map<String, dynamic> toJson();
  factory ConversationSettings.fromJson(Map<String, dynamic> json);
  
  // Copy with for immutability
  ConversationSettings copyWith({
    String? wallpaperUrl,
    bool? notificationsEnabled,
    String? notificationSoundId,
    bool? isPinned,
    bool? isArchived,
  });
}
```

### MediaItem

```dart
enum MediaType { photo, video, document, link, voice }

class MediaItem {
  final String id;
  final MediaType type;
  final String url;
  final String? thumbnailUrl;
  final String? fileName;
  final int? fileSize; // in bytes
  final int? duration; // in seconds for video/voice
  final DateTime timestamp;
  final String senderId;
  final String senderName;
  
  MediaItem({
    required this.id,
    required this.type,
    required this.url,
    this.thumbnailUrl,
    this.fileName,
    this.fileSize,
    this.duration,
    required this.timestamp,
    required this.senderId,
    required this.senderName,
  });
  
  // Helper methods
  String get formattedSize;
  String get formattedDuration;
}
```

### NotificationModel

```dart
enum NotificationType {
  message,
  mention,
  like,
  comment,
  announcement,
  activity,
}

class NotificationModel {
  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final DateTime timestamp;
  final bool isRead;
  final String? avatarUrl;
  final String? targetId; // ID of the related content (message, post, etc.)
  final String? targetType; // Type of content ('chat', 'post', 'comment')
  
  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.timestamp,
    this.isRead = false,
    this.avatarUrl,
    this.targetId,
    this.targetType,
  });
  
  // Copy with for immutability
  NotificationModel copyWith({bool? isRead});
  
  // Helper methods
  IconData get icon;
  Color get color;
}
```

### Mock Data Structure

Les données mockées seront organisées dans des fichiers dédiés :

```dart
// lib/data/mock_groups_data.dart
class MockGroupsData {
  static List<GroupChatModel> groups = [...];
  static Map<String, List<MessageModel>> groupMessages = {...};
}

// lib/data/mock_profiles_data.dart
class MockProfilesData {
  static Map<String, UserProfileModel> profiles = {...};
  static Map<String, List<UserActivity>> activities = {...};
  static Map<String, List<UserPost>> posts = {...};
}

// lib/data/mock_media_data.dart
class MockMediaData {
  static Map<String, List<MediaItem>> mediaByChat = {...};
}

// lib/data/mock_notifications_data.dart
class MockNotificationsData {
  static List<NotificationModel> notifications = [...];
}
```


## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system-essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property Reflection

Après analyse des critères d'acceptation, plusieurs propriétés peuvent être consolidées pour éviter la redondance :

- **Persistance locale** : Les propriétés 10.1-10.5 testent toutes la persistance et peuvent être combinées en une seule propriété de round-trip pour les préférences
- **Affichage des permissions** : Les propriétés 1.5 et 9.2 testent la même chose (affichage visuel des permissions)
- **Confirmations** : Les propriétés 1.7, 4.7 et 4.9 testent toutes l'affichage de confirmations et peuvent être généralisées
- **Navigation et affichage** : Plusieurs propriétés testent simplement qu'un élément UI est affiché, ce qui peut être regroupé par module

### Property 1: Group Creation Round-Trip

*For any* valid group data (name, description, photo, member list), creating a group with that data should result in a group that contains all the provided information when retrieved.

**Validates: Requirements 1.2**

### Property 2: Group Member List Completeness

*For any* group chat, accessing the group information should display all members that belong to that group, with no members missing or duplicated.

**Validates: Requirements 1.4**

### Property 3: Permission Visual Indicators

*For any* group member in any group, the UI should display a visual indicator of their permission level (admin, moderator, or member).

**Validates: Requirements 1.5, 9.2**

### Property 4: Admin Management Options Availability

*For any* user with admin permission in any group, the member management interface should display options to add members, remove members, and modify permissions.

**Validates: Requirements 1.6, 9.3**

### Property 5: Permission-Based Access Control

*For any* user attempting to perform a management action, the action should be allowed if and only if the user has sufficient permissions (admin for permission changes, admin/moderator for member removal, any permission for viewing).

**Validates: Requirements 9.3, 9.4, 9.5, 9.6**

### Property 6: Profile Content Completeness

*For any* user profile, the rendered profile page should contain all required sections: photo, bio, username, phone, registration date, recent activities, and posts.

**Validates: Requirements 2.2, 2.3, 2.4**

### Property 7: Profile Action Buttons Context

*For any* profile view, if the profile is the current user's profile, an edit button should be shown; if it's another user's profile, action buttons (Message, Voice Call, Video Call, Block) should be shown instead.

**Validates: Requirements 2.5, 2.6**

### Property 8: Profile Edit Round-Trip

*For any* profile update (bio, photo, phone), saving the changes and then retrieving the profile should return the updated values.

**Validates: Requirements 2.7**

### Property 9: Search Results Accuracy

*For any* search query in any conversation, all returned results should contain the search query as a substring (case-insensitive), and all messages containing the query should be in the results.

**Validates: Requirements 3.2**

### Property 10: Search Filter Correctness

*For any* active content type filter (text, images, videos, documents, links), all search results should match the selected filter types, and no results of unselected types should be included.

**Validates: Requirements 3.3**

### Property 11: Search Result Navigation Bounds

*For any* search with N results, navigating next from result N should wrap to result 1, and navigating previous from result 1 should wrap to result N, ensuring all results are reachable.

**Validates: Requirements 3.5**

### Property 12: Search Result Highlighting

*For any* displayed search result, the matching text should be visually highlighted in the message, with highlight ranges corresponding to the query matches.

**Validates: Requirements 3.6**

### Property 13: Conversation Settings Persistence Round-Trip

*For any* conversation settings change (wallpaper, notifications, sound, pin status, archive status), saving the settings and then loading them should return the same values.

**Validates: Requirements 4.2, 4.3, 4.4, 4.5, 4.6, 10.1, 10.2, 10.3, 10.4, 10.5**

### Property 14: Destructive Action Confirmations

*For any* destructive action (leave group, block user, delete conversation), the system should display a confirmation dialog before executing the action.

**Validates: Requirements 1.7, 4.7, 4.9**

### Property 15: Media Gallery Organization by Type

*For any* conversation, the media gallery should organize all shared media items into the correct tabs (Photos, Videos, Documents, Links, Voice) based on their MediaType.

**Validates: Requirements 5.2**

### Property 16: Media Display Format by Type

*For any* media gallery tab, if the tab is Photos or Videos, items should be displayed in a grid layout; if the tab is Documents or Links, items should be displayed in a list layout.

**Validates: Requirements 5.3, 5.4**

### Property 17: Media Item Download Availability

*For any* media item in the gallery, a download button should be present and functional, triggering a download simulation when clicked.

**Validates: Requirements 5.6, 5.7**

### Property 18: Notification Badge Count Accuracy

*For any* application state, the notification badge count should equal the number of unread notifications, updating immediately when notifications are marked as read or new notifications arrive.

**Validates: Requirements 6.3**

### Property 19: Notification State Toggle

*For any* notification, marking it as read should change its isRead property to true, and marking it as unread should change it to false, with the change persisting in the notification list.

**Validates: Requirements 6.4**

### Property 20: Notification Deletion

*For any* notification, deleting it should remove it from the notification list, and it should not appear in subsequent queries.

**Validates: Requirements 6.5**

### Property 21: Notification Filter Correctness

*For any* active notification type filter, all displayed notifications should match the selected filter type, and no notifications of unselected types should be shown.

**Validates: Requirements 6.6**

### Property 22: Notification Navigation

*For any* notification with associated content (targetId and targetType), selecting the notification should navigate to the correct screen displaying that content.

**Validates: Requirements 6.8**

### Property 23: Provider State Change Notification

*For any* Provider data change, all widgets listening to that Provider should be notified and rebuild with the updated data.

**Validates: Requirements 7.2**

### Property 24: Responsive Layout Adaptation

*For any* screen size (mobile or desktop), the UI components should adapt their layout appropriately: mobile uses single-column layouts and bottom sheets, desktop uses multi-column layouts and side panels where appropriate.

**Validates: Requirements 8.1, 8.2**

### Property 25: Interactive Element Feedback

*For any* interactive UI element (button, list tile, card), user interaction should trigger immediate visual feedback (ripple effect, color change, or scale animation).

**Validates: Requirements 8.5**

## Error Handling

### Input Validation

**Group Creation**
- Empty group name: Display error message "Le nom du groupe est requis"
- Group name too long (>50 chars): Display error message "Le nom du groupe est trop long (maximum 50 caractères)"
- No members selected: Display error message "Sélectionnez au moins un membre"
- Duplicate member selection: Silently deduplicate the list

**Profile Editing**
- Bio too long (>500 chars): Display error message "La bio est trop longue (maximum 500 caractères)"
- Invalid phone format: Display error message "Format de téléphone invalide"
- Empty required fields: Highlight fields in red with inline error messages

**Search**
- Empty search query: Clear results and show placeholder "Rechercher dans la conversation"
- Query too short (<2 chars): Don't trigger search, wait for more input
- No results found: Display "Aucun résultat trouvé pour '[query]'"

### Permission Errors

**Insufficient Permissions**
- Non-admin trying to change permissions: Show SnackBar "Seuls les administrateurs peuvent modifier les permissions"
- Non-admin/moderator trying to remove member: Show SnackBar "Vous n'avez pas la permission de retirer des membres"
- Member trying to access admin settings: Hide the options entirely (preventive)

### State Errors

**Provider Errors**
- Failed to load data: Display retry button with message "Erreur de chargement. Réessayer?"
- Failed to save settings: Show SnackBar "Impossible de sauvegarder les paramètres" with retry option
- Concurrent modification: Last write wins (no conflict resolution needed for mock data)

**Navigation Errors**
- Invalid notification target: Show SnackBar "Le contenu n'est plus disponible" and mark notification as read
- Missing chat/group: Show error screen "Cette conversation n'existe plus" with back button
- Missing profile: Show error screen "Ce profil n'est plus disponible" with back button

### Media Errors

**Media Loading**
- Failed to load thumbnail: Display placeholder icon with media type indicator
- Failed to load full media: Show error overlay "Impossible de charger le média" with retry button
- Invalid media URL: Log error and show placeholder

**Download Simulation**
- Download already in progress: Show SnackBar "Téléchargement déjà en cours"
- Simulated download failure (10% chance): Show SnackBar "Échec du téléchargement" with retry option

### Network Simulation

Since the app uses mock data, we simulate network-like behavior:
- Random delays (100-500ms) for data loading to simulate network latency
- Occasional failures (5% chance) for save operations to test error handling
- Loading states displayed during simulated network operations

### Error Recovery

**Graceful Degradation**
- If media fails to load, show placeholder but allow other functionality
- If notification navigation fails, mark notification as read and stay on current screen
- If settings fail to save, keep UI in sync with last known good state

**User Feedback**
- All errors display user-friendly messages in French
- Critical errors (data loss risk) show confirmation dialogs
- Non-critical errors show dismissible SnackBars
- Loading states prevent user confusion during async operations

## Testing Strategy

### Dual Testing Approach

Cette feature utilisera une approche de test duale combinant tests unitaires et tests basés sur les propriétés (property-based testing) pour assurer une couverture complète.

**Tests unitaires** : Vérifient des exemples spécifiques, cas limites et conditions d'erreur
**Tests de propriétés** : Vérifient les propriétés universelles sur tous les inputs possibles

Les deux approches sont complémentaires et nécessaires :
- Les tests unitaires capturent des bugs concrets et des cas spécifiques
- Les tests de propriétés vérifient la correction générale sur un large éventail d'inputs

### Property-Based Testing Configuration

**Framework** : Nous utiliserons le package **faker** pour la génération de données aléatoires et implémenterons des générateurs personnalisés pour les modèles de domaine.

**Configuration des tests** :
- Minimum 100 itérations par test de propriété (en raison de la randomisation)
- Chaque test de propriété doit référencer sa propriété du document de design
- Format de tag : `// Feature: social-chat-enhancements, Property {number}: {property_text}`

**Générateurs de données** :

```dart
// lib/test/generators/group_generator.dart
class GroupGenerator {
  static GroupChatModel randomGroup({int? memberCount}) {
    final faker = Faker();
    final count = memberCount ?? faker.randomGenerator.integer(10, min: 2);
    return GroupChatModel(
      id: faker.guid.guid(),
      name: faker.company.name(),
      description: faker.lorem.sentence(),
      photoUrl: faker.image.image(random: true),
      members: List.generate(count, (_) => randomMember()),
      createdAt: faker.date.dateTime(minYear: 2020, maxYear: 2024),
    );
  }
  
  static GroupMemberModel randomMember({GroupPermission? permission}) {
    final faker = Faker();
    return GroupMemberModel(
      userId: faker.guid.guid(),
      name: faker.person.name(),
      avatarUrl: faker.image.image(random: true),
      permission: permission ?? _randomPermission(),
      joinedAt: faker.date.dateTime(minYear: 2020, maxYear: 2024),
    );
  }
  
  static GroupPermission _randomPermission() {
    final values = GroupPermission.values;
    return values[Random().nextInt(values.length)];
  }
}

// lib/test/generators/profile_generator.dart
class ProfileGenerator {
  static UserProfileModel randomProfile() {
    final faker = Faker();
    return UserProfileModel(
      id: faker.guid.guid(),
      name: faker.person.name(),
      username: '@${faker.internet.userName()}',
      bio: faker.lorem.sentence(),
      phone: faker.phoneNumber.us(),
      avatarUrl: faker.image.image(random: true),
      createdAt: faker.date.dateTime(minYear: 2020, maxYear: 2024),
      isOnline: faker.randomGenerator.boolean(),
      currentActivity: faker.lorem.words(3).join(' '),
      recentActivities: List.generate(5, (_) => randomActivity()),
      posts: List.generate(10, (_) => randomPost()),
    );
  }
  
  static UserActivity randomActivity() {
    final faker = Faker();
    final types = ['post', 'comment', 'like', 'join_group'];
    return UserActivity(
      id: faker.guid.guid(),
      type: types[Random().nextInt(types.length)],
      description: faker.lorem.sentence(),
      timestamp: faker.date.dateTime(minYear: 2024, maxYear: 2024),
    );
  }
  
  static UserPost randomPost() {
    final faker = Faker();
    return UserPost(
      id: faker.guid.guid(),
      content: faker.lorem.sentences(3).join(' '),
      imageUrls: List.generate(
        faker.randomGenerator.integer(4),
        (_) => faker.image.image(random: true),
      ),
      likesCount: faker.randomGenerator.integer(1000),
      commentsCount: faker.randomGenerator.integer(100),
      createdAt: faker.date.dateTime(minYear: 2024, maxYear: 2024),
    );
  }
}

// lib/test/generators/message_generator.dart
class MessageGenerator {
  static MessageModel randomMessage({MessageType? type}) {
    final faker = Faker();
    final msgType = type ?? _randomMessageType();
    
    return MessageModel(
      id: faker.guid.guid(),
      text: msgType == MessageType.text ? faker.lorem.sentence() : '',
      isSentByMe: faker.randomGenerator.boolean(),
      timestamp: faker.date.dateTime(minYear: 2024, maxYear: 2024),
      isRead: faker.randomGenerator.boolean(),
      type: msgType,
      attachmentUrl: _needsAttachment(msgType) ? faker.image.image(random: true) : null,
      attachmentName: msgType == MessageType.document ? faker.lorem.word() + '.pdf' : null,
    );
  }
  
  static List<MessageModel> randomConversation({int? messageCount}) {
    final count = messageCount ?? Random().nextInt(100) + 10;
    return List.generate(count, (_) => randomMessage());
  }
  
  static MessageType _randomMessageType() {
    final values = MessageType.values;
    return values[Random().nextInt(values.length)];
  }
  
  static bool _needsAttachment(MessageType type) {
    return type == MessageType.image || 
           type == MessageType.video || 
           type == MessageType.document;
  }
}

// lib/test/generators/media_generator.dart
class MediaGenerator {
  static MediaItem randomMedia({MediaType? type}) {
    final faker = Faker();
    final mediaType = type ?? _randomMediaType();
    
    return MediaItem(
      id: faker.guid.guid(),
      type: mediaType,
      url: faker.image.image(random: true),
      thumbnailUrl: _needsThumbnail(mediaType) ? faker.image.image(random: true) : null,
      fileName: _needsFileName(mediaType) ? faker.lorem.word() + _extension(mediaType) : null,
      fileSize: faker.randomGenerator.integer(10000000, min: 1000),
      duration: _needsDuration(mediaType) ? faker.randomGenerator.integer(600, min: 1) : null,
      timestamp: faker.date.dateTime(minYear: 2024, maxYear: 2024),
      senderId: faker.guid.guid(),
      senderName: faker.person.name(),
    );
  }
  
  static List<MediaItem> randomMediaList({int? count, MediaType? type}) {
    final itemCount = count ?? Random().nextInt(50) + 5;
    return List.generate(itemCount, (_) => randomMedia(type: type));
  }
  
  static MediaType _randomMediaType() {
    final values = MediaType.values;
    return values[Random().nextInt(values.length)];
  }
  
  static bool _needsThumbnail(MediaType type) => type == MediaType.video;
  static bool _needsFileName(MediaType type) => type == MediaType.document;
  static bool _needsDuration(MediaType type) => 
    type == MediaType.video || type == MediaType.voice;
  
  static String _extension(MediaType type) {
    switch (type) {
      case MediaType.document: return '.pdf';
      case MediaType.video: return '.mp4';
      case MediaType.voice: return '.m4a';
      default: return '';
    }
  }
}

// lib/test/generators/notification_generator.dart
class NotificationGenerator {
  static NotificationModel randomNotification({NotificationType? type}) {
    final faker = Faker();
    final notifType = type ?? _randomNotificationType();
    
    return NotificationModel(
      id: faker.guid.guid(),
      type: notifType,
      title: _titleForType(notifType, faker),
      body: faker.lorem.sentence(),
      timestamp: faker.date.dateTime(minYear: 2024, maxYear: 2024),
      isRead: faker.randomGenerator.boolean(),
      avatarUrl: faker.image.image(random: true),
      targetId: faker.guid.guid(),
      targetType: _targetTypeForNotification(notifType),
    );
  }
  
  static List<NotificationModel> randomNotificationList({int? count}) {
    final itemCount = count ?? Random().nextInt(50) + 10;
    return List.generate(itemCount, (_) => randomNotification());
  }
  
  static NotificationType _randomNotificationType() {
    final values = NotificationType.values;
    return values[Random().nextInt(values.length)];
  }
  
  static String _titleForType(NotificationType type, Faker faker) {
    switch (type) {
      case NotificationType.message: return 'Nouveau message de ${faker.person.firstName()}';
      case NotificationType.mention: return '${faker.person.firstName()} vous a mentionné';
      case NotificationType.like: return '${faker.person.firstName()} a aimé votre post';
      case NotificationType.comment: return '${faker.person.firstName()} a commenté';
      case NotificationType.announcement: return 'Annonce importante';
      case NotificationType.activity: return 'Nouvelle activité';
    }
  }
  
  static String _targetTypeForNotification(NotificationType type) {
    switch (type) {
      case NotificationType.message: return 'chat';
      case NotificationType.mention: return 'chat';
      case NotificationType.like: return 'post';
      case NotificationType.comment: return 'post';
      case NotificationType.announcement: return 'announcement';
      case NotificationType.activity: return 'activity';
    }
  }
}
```

### Unit Testing Strategy

**Tests par module** :

**Module Group Chat** (15-20 tests unitaires)
- Création de groupe avec données valides
- Validation des champs requis (nom vide, etc.)
- Ajout/retrait de membres
- Changement de permissions
- Cas limite : groupe avec 1 seul membre
- Cas limite : groupe avec 100+ membres
- Quitter un groupe en tant que dernier admin

**Module Profile** (10-15 tests unitaires)
- Affichage de profil complet
- Édition de profil avec validation
- Cas limite : bio vide vs bio maximale
- Cas limite : profil sans posts
- Cas limite : profil sans activités
- Blocage/déblocage d'utilisateur

**Module Search** (15-20 tests unitaires)
- Recherche avec résultats
- Recherche sans résultats (edge case)
- Recherche avec caractères spéciaux
- Filtrage par type de contenu
- Navigation entre résultats
- Cas limite : 1 seul résultat
- Cas limite : 1000+ résultats
- Highlighting de texte avec accents

**Module Settings** (10-15 tests unitaires)
- Changement de fond d'écran
- Toggle notifications
- Épingler/désépingler conversation
- Archiver/désarchiver conversation
- Confirmation de suppression
- Confirmation de blocage
- Persistance après redémarrage

**Module Media Gallery** (10-15 tests unitaires)
- Affichage par type de média
- Grille vs liste selon le type
- Téléchargement simulé
- Cas limite : galerie vide
- Cas limite : 1000+ médias
- Prévisualisation plein écran

**Module Notifications** (10-15 tests unitaires)
- Affichage de notifications
- Marquer comme lu/non lu
- Suppression de notification
- Filtrage par type
- Badge count accuracy
- Navigation vers contenu
- Cas limite : aucune notification
- Cas limite : 1000+ notifications

### Widget Testing

**Tests de widgets** (20-30 tests)
- Rendu correct des composants UI
- Interactions utilisateur (tap, long press, swipe)
- Animations et transitions
- Responsive layout (mobile vs desktop)
- Thème et couleurs
- Accessibilité (semantic labels, contrast)

### Integration Testing

**Scénarios end-to-end** (5-10 tests)
- Créer un groupe → Envoyer un message → Voir dans la galerie
- Modifier profil → Sauvegarder → Vérifier persistance
- Rechercher message → Naviguer résultats → Ouvrir message
- Changer paramètres → Redémarrer app → Vérifier restauration
- Recevoir notification → Cliquer → Naviguer vers contenu

### Performance Testing

**Benchmarks** :
- Temps de chargement de la liste de groupes (< 100ms pour 100 groupes)
- Temps de recherche dans 1000 messages (< 200ms)
- Temps de rendu de la galerie avec 500 médias (< 300ms)
- Frame rate pendant animations (≥ 60 FPS)
- Utilisation mémoire avec données volumineuses (< 200MB)

### Test Coverage Goals

- **Code coverage** : Minimum 80% pour les Providers et modèles
- **Widget coverage** : Minimum 70% pour les widgets personnalisés
- **Property coverage** : 100% des propriétés définies doivent avoir un test
- **Edge case coverage** : Tous les cas limites identifiés doivent être testés

### Continuous Testing

- Tests unitaires exécutés à chaque commit
- Tests de widgets exécutés avant chaque merge
- Tests d'intégration exécutés quotidiennement
- Tests de performance exécutés hebdomadairement
- Property-based tests avec seed aléatoire pour découvrir de nouveaux cas

