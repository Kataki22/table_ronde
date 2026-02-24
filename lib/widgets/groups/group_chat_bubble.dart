import 'package:flutter/material.dart';
import '../../models/chat_model.dart';
import '../../models/groups/group_member_model.dart';
import '../../utils/theme_extensions.dart';
import '../../utils/app_theme.dart';
import '../../screens/profiles/profile_screen.dart';
import 'permission_badge.dart';

/// Widget to display a group chat message bubble
/// 
/// Displays a message in a group chat context with:
/// - Sender's avatar
/// - Sender's name (important for group identification)
/// - Optional permission badge for sender
/// - Message content
/// - Tap and long press interactions
/// 
/// **Validates: Requirements 1.3**
class GroupChatBubble extends StatelessWidget {
  /// The message to display
  final MessageModel message;
  
  /// The sender of the message
  final GroupMemberModel sender;
  
  /// Whether to show the avatar (typically false for consecutive messages from same sender)
  final bool showAvatar;
  
  /// Whether to show the permission badge next to the sender's name
  final bool showPermissionBadge;
  
  /// Callback when the message is tapped
  final VoidCallback? onTap;
  
  /// Callback when the message is long pressed
  final VoidCallback? onLongPress;

  const GroupChatBubble({
    super.key,
    required this.message,
    required this.sender,
    this.showAvatar = true,
    this.showPermissionBadge = false,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final isSentByMe = message.isSentByMe;

    return Align(
      alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment:
              isSentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            // Avatar for received messages
            if (!isSentByMe) ...[
              _buildAvatar(context),
              const SizedBox(width: 6),
            ],
            
            // Message content
            Flexible(
              child: Column(
                crossAxisAlignment: isSentByMe
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  // Sender name for group context
                  if (!isSentByMe)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 3, left: 10),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            sender.name,
                            style: AppTheme.bodySmall.copyWith(
                              color: context.themeColors.textSecondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (showPermissionBadge) ...[
                            const SizedBox(width: 6),
                            PermissionBadge(
                              permission: sender.permission,
                              size: BadgeSize.small,
                            ),
                          ],
                        ],
                      ),
                    ),
                  
                  // Message bubble
                  GestureDetector(
                    onTap: onTap,
                    onLongPress: onLongPress,
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.65,
                      ),
                      decoration: _shouldShowBubbleDecoration()
                          ? BoxDecoration(
                              color: isSentByMe
                                  ? context.themeColors.msgBubbleSent
                                  : context.themeColors.msgBubbleReceived,
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(18),
                                topRight: const Radius.circular(18),
                                bottomLeft: isSentByMe
                                    ? const Radius.circular(18)
                                    : const Radius.circular(4),
                                bottomRight: isSentByMe
                                    ? const Radius.circular(4)
                                    : const Radius.circular(18),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color.fromRGBO(0, 0, 0, 0.15),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            )
                          : null,
                      child: _buildMessageContent(context),
                    ),
                  ),
                ],
              ),
            ),
            
            // Spacing for sent messages
            if (isSentByMe) const SizedBox(width: 44),
          ],
        ),
      ),
    );
  }

  /// Builds the avatar widget
  Widget _buildAvatar(BuildContext context) {
    if (!showAvatar) {
      // Return empty space to maintain alignment
      return const SizedBox(width: 36);
    }

    return GestureDetector(
      onTap: () {
        // Navigate to the sender's profile
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ProfileScreen(userId: sender.userId),
          ),
        );
      },
      child: CircleAvatar(
        backgroundImage: sender.avatarUrl != null && sender.avatarUrl!.isNotEmpty
            ? NetworkImage(sender.avatarUrl!)
            : null,
        backgroundColor: context.themeColors.bgSecondary,
        radius: 18,
        child: sender.avatarUrl == null || sender.avatarUrl!.isEmpty
            ? Text(
                sender.name.isNotEmpty ? sender.name[0].toUpperCase() : '?',
                style: AppTheme.bodyMedium.copyWith(
                  color: context.themeColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              )
            : null,
      ),
    );
  }

  /// Determines if the bubble decoration should be shown
  /// Media types (stickers, gifs, images, videos) don't need bubble background
  bool _shouldShowBubbleDecoration() {
    return message.type != MessageType.sticker &&
        message.type != MessageType.gif &&
        message.type != MessageType.image &&
        message.type != MessageType.video;
  }

  /// Builds the message content based on message type
  Widget _buildMessageContent(BuildContext context) {
    final needsPadding = _shouldShowBubbleDecoration();
    
    Widget content;
    
    switch (message.type) {
      case MessageType.text:
        content = _buildTextMessage(context);
        break;
      case MessageType.image:
        content = _buildImageMessage(context);
        break;
      case MessageType.video:
        content = _buildVideoMessage(context);
        break;
      case MessageType.document:
        content = _buildDocumentMessage(context);
        break;
      case MessageType.voice:
        content = _buildVoiceMessage(context);
        break;
      case MessageType.sticker:
        content = _buildStickerMessage(context);
        break;
      case MessageType.gif:
        content = _buildGifMessage(context);
        break;
    }

    if (needsPadding) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: content,
      );
    }
    
    return content;
  }

  /// Builds a text message
  Widget _buildTextMessage(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          message.text,
          style: AppTheme.bodyMedium.copyWith(
            color: context.themeColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        _buildMessageFooter(context),
      ],
    );
  }

  /// Builds an image message
  Widget _buildImageMessage(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (message.attachmentUrl != null)
            Image.network(
              message.attachmentUrl!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  color: context.themeColors.bgSecondary,
                  child: Center(
                    child: Icon(
                      Icons.broken_image,
                      color: context.themeColors.textSecondary,
                      size: 48,
                    ),
                  ),
                );
              },
            ),
          if (message.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                message.text,
                style: AppTheme.bodyMedium.copyWith(
                  color: context.themeColors.textPrimary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Builds a video message
  Widget _buildVideoMessage(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          if (message.attachmentUrl != null)
            Image.network(
              message.attachmentUrl!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  color: context.themeColors.bgSecondary,
                  child: Center(
                    child: Icon(
                      Icons.videocam,
                      color: context.themeColors.textSecondary,
                      size: 48,
                    ),
                  ),
                );
              },
            ),
          Positioned.fill(
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a document message
  Widget _buildDocumentMessage(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: context.themeColors.bgSecondary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.insert_drive_file,
            color: context.themeColors.textSecondary,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message.attachmentName ?? 'Document',
                style: AppTheme.bodyMedium.copyWith(
                  color: context.themeColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              _buildMessageFooter(context),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds a voice message
  Widget _buildVoiceMessage(BuildContext context) {
    final duration = message.voiceDuration ?? 0;
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: context.themeColors.bgSecondary,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.play_arrow,
            color: context.themeColors.textPrimary,
            size: 20,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 2,
                decoration: BoxDecoration(
                  color: context.themeColors.bgSecondary,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                style: AppTheme.bodySmall.copyWith(
                  color: context.themeColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds a sticker message
  Widget _buildStickerMessage(BuildContext context) {
    if (message.stickerUrl == null) {
      return const SizedBox.shrink();
    }
    
    return Image.asset(
      message.stickerUrl!,
      width: 150,
      height: 150,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: 150,
          height: 150,
          color: context.themeColors.bgSecondary,
          child: Icon(
            Icons.emoji_emotions,
            color: context.themeColors.textSecondary,
            size: 48,
          ),
        );
      },
    );
  }

  /// Builds a gif message
  Widget _buildGifMessage(BuildContext context) {
    if (message.gifUrl == null) {
      return const SizedBox.shrink();
    }
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        message.gifUrl!,
        width: 200,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 200,
            height: 200,
            color: context.themeColors.bgSecondary,
            child: Icon(
              Icons.gif,
              color: context.themeColors.textSecondary,
              size: 48,
            ),
          );
        },
      ),
    );
  }

  /// Builds the message footer with timestamp and read status
  Widget _buildMessageFooter(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (message.isEdited)
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Text(
              'modifié',
              style: AppTheme.bodySmall.copyWith(
                color: context.themeColors.textSecondary,
                fontSize: 10,
              ),
            ),
          ),
        Text(
          _formatTime(message.timestamp),
          style: AppTheme.bodySmall.copyWith(
            color: context.themeColors.textSecondary,
            fontSize: 11,
          ),
        ),
        if (message.isSentByMe) ...[
          const SizedBox(width: 4),
          Icon(
            message.isRead ? Icons.done_all : Icons.done,
            size: 14,
            color: message.isRead
                ? context.themeColors.colorOnline
                : context.themeColors.textSecondary,
          ),
        ],
      ],
    );
  }

  /// Formats the timestamp to HH:MM format
  String _formatTime(DateTime timestamp) {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
