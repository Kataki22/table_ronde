enum MessageType { text, sticker, gif, image, video, document, voice }

class MessageModel {
  final String id;
  String text;
  final bool isSentByMe;
  final DateTime timestamp;
  bool isRead;
  final MessageType type;
  final String? attachmentUrl; // image / video / document local or network path
  final String? attachmentName; // used for documents
  final String? stickerUrl; // sticker asset path
  final String? gifUrl; // gif asset or network URL
  final String? replyToId; // id of the message being replied to
  final int? voiceDuration; // duration in seconds for voice messages
  bool isEdited;
  bool isDeleted;

  final Map<String, int> reactions;

  MessageModel({
    String? id,
    this.text = '',
    required this.isSentByMe,
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
    this.reactions = const {},
  }) : id = id ?? DateTime.now().microsecondsSinceEpoch.toString();
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
}
