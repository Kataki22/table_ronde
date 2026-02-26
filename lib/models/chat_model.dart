enum MessageType { text, sticker, gif, image, video, document, voice }

class MessageModel {
  final String id;
  String text;
  final DateTime timestamp;
  bool isRead;
  final MessageType type;
  final String? attachmentUrl;
  final String? attachmentName;
  final String? stickerUrl;
  final String? gifUrl;
  final String? replyToId;
  final int? voiceDuration;
  bool isEdited;
  bool isDeleted;
  final String? chatId;
  final String? senderId;
  final String? senderName;

  final Map<String, int> reactions;

  MessageModel({
    String? id,
    this.text = '',
    required this.timestamp,
    this.isRead = false,
    this.type = MessageType.text,
    this.attachmentUrl,
    this.attachmentName,
    this.stickerUrl,
    this.gifUrl,
    this.replyToId,
    this.voiceDuration,
    this.isEdited = false,
    this.isDeleted = false,
    this.chatId,
    this.senderId,
    this.senderName,
    this.reactions = const {},
  }) : id = id ?? DateTime.now().microsecondsSinceEpoch.toString();

  /// Calcule si le message a été envoyé par l'utilisateur actuel
  /// Doit être appelé avec l'ID de l'utilisateur connecté
  bool isSentBy(String currentUserId) {
    return senderId == currentUserId;
  }

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String,
      text: json['text'] as String? ?? '',
      timestamp: DateTime.parse(json['timestamp'] as String),
      isRead: json['isRead'] as bool? ?? false,
      type: MessageType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MessageType.text,
      ),
      attachmentUrl: json['attachmentUrl'] as String?,
      attachmentName: json['attachmentName'] as String?,
      stickerUrl: json['stickerUrl'] as String?,
      gifUrl: json['gifUrl'] as String?,
      replyToId: json['replyToId'] as String?,
      voiceDuration: json['voiceDuration'] as int?,
      isEdited: json['isEdited'] as bool? ?? false,
      isDeleted: json['isDeleted'] as bool? ?? false,
      chatId: json['chatId'] as String?,
      senderId: json['senderId'] as String?,
      senderName: json['senderName'] as String?,
      reactions: Map<String, int>.from(json['reactions'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'type': type.name,
      'attachmentUrl': attachmentUrl,
      'attachmentName': attachmentName,
      'stickerUrl': stickerUrl,
      'gifUrl': gifUrl,
      'replyToId': replyToId,
      'voiceDuration': voiceDuration,
      'isEdited': isEdited,
      'isDeleted': isDeleted,
      'chatId': chatId,
      'senderId': senderId,
      'senderName': senderName,
      'reactions': reactions,
    };
  }
}

class ChatModel {
  final String id;
  final String name;
  final String? avatarUrl;
  final bool isOnline;
  String? lastMessage;
  DateTime? lastMessageTime;
  int unreadCount;
  final String? bio;
  final String? phone;
  final String? username;
  final DateTime? createdAt;
  final String? currentActivity;

  ChatModel({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.isOnline = false,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
    this.bio,
    this.phone,
    this.username,
    this.createdAt,
    this.currentActivity,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['id'] as String,
      name: json['name'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      isOnline: json['isOnline'] as bool? ?? false,
      lastMessage: json['lastMessage'] as String?,
      lastMessageTime: json['lastMessageTime'] != null
          ? DateTime.parse(json['lastMessageTime'] as String)
          : null,
      unreadCount: json['unreadCount'] as int? ?? 0,
      bio: json['bio'] as String?,
      phone: json['phone'] as String?,
      username: json['username'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      currentActivity: json['currentActivity'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatarUrl': avatarUrl,
      'isOnline': isOnline,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime?.toIso8601String(),
      'unreadCount': unreadCount,
      'bio': bio,
      'phone': phone,
      'username': username,
      'createdAt': createdAt?.toIso8601String(),
      'currentActivity': currentActivity,
    };
  }
}
