/// Model representing conversation-specific settings
/// 
/// This model stores user preferences for individual conversations including
/// wallpaper, notifications, pin status, and archive status.
/// 
/// Validates: Requirements 4.1, 4.2, 10.1
class ConversationSettings {
  /// Unique identifier for the chat/conversation
  final String chatId;
  
  /// URL of the custom wallpaper for this conversation (null = default)
  final String? wallpaperUrl;
  
  /// Whether notifications are enabled for this conversation
  final bool notificationsEnabled;
  
  /// ID of the custom notification sound (null = default sound)
  final String? notificationSoundId;
  
  /// Whether this conversation is pinned to the top of the chat list
  final bool isPinned;
  
  /// Whether this conversation is archived
  final bool isArchived;

  ConversationSettings({
    required this.chatId,
    this.wallpaperUrl,
    this.notificationsEnabled = true,
    this.notificationSoundId,
    this.isPinned = false,
    this.isArchived = false,
  });

  /// Serialization for shared_preferences persistence
  Map<String, dynamic> toJson() {
    return {
      'chatId': chatId,
      'wallpaperUrl': wallpaperUrl,
      'notificationsEnabled': notificationsEnabled,
      'notificationSoundId': notificationSoundId,
      'isPinned': isPinned,
      'isArchived': isArchived,
    };
  }

  /// Deserialization from shared_preferences
  factory ConversationSettings.fromJson(Map<String, dynamic> json) {
    return ConversationSettings(
      chatId: json['chatId'] as String,
      wallpaperUrl: json['wallpaperUrl'] as String?,
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      notificationSoundId: json['notificationSoundId'] as String?,
      isPinned: json['isPinned'] as bool? ?? false,
      isArchived: json['isArchived'] as bool? ?? false,
    );
  }

  /// Copy with for immutability - creates a new instance with updated values
  ConversationSettings copyWith({
    String? wallpaperUrl,
    bool? notificationsEnabled,
    String? notificationSoundId,
    bool? isPinned,
    bool? isArchived,
  }) {
    return ConversationSettings(
      chatId: chatId,
      wallpaperUrl: wallpaperUrl ?? this.wallpaperUrl,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      notificationSoundId: notificationSoundId ?? this.notificationSoundId,
      isPinned: isPinned ?? this.isPinned,
      isArchived: isArchived ?? this.isArchived,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is ConversationSettings &&
        other.chatId == chatId &&
        other.wallpaperUrl == wallpaperUrl &&
        other.notificationsEnabled == notificationsEnabled &&
        other.notificationSoundId == notificationSoundId &&
        other.isPinned == isPinned &&
        other.isArchived == isArchived;
  }

  @override
  int get hashCode {
    return Object.hash(
      chatId,
      wallpaperUrl,
      notificationsEnabled,
      notificationSoundId,
      isPinned,
      isArchived,
    );
  }

  @override
  String toString() {
    return 'ConversationSettings('
        'chatId: $chatId, '
        'wallpaperUrl: $wallpaperUrl, '
        'notificationsEnabled: $notificationsEnabled, '
        'notificationSoundId: $notificationSoundId, '
        'isPinned: $isPinned, '
        'isArchived: $isArchived'
        ')';
  }
}
