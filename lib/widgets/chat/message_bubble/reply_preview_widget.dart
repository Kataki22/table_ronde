import 'package:flutter/material.dart';
import '../../../models/chat_model.dart';
import '../../../utils/theme_extensions.dart';

/// Widget to display a preview of the message being replied to
class ReplyPreviewWidget extends StatelessWidget {
  final MessageModel repliedMessage;
  final ChatModel chat;

  const ReplyPreviewWidget({
    super.key,
    required this.repliedMessage,
    required this.chat,
  });

  String _typeLabel(MessageType type) {
    switch (type) {
      case MessageType.sticker:
        return 'Sticker';
      case MessageType.gif:
        return 'GIF';
      case MessageType.image:
        return 'Photo';
      case MessageType.video:
        return 'Vidéo';
      case MessageType.document:
        return 'Document';
      case MessageType.text:
        return '';
      case MessageType.voice:
        return 'Vocal';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 14, right: 14, top: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: context.themeColors.bgSurface.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(
            color: context.themeColors.colorPrimary,
            width: 3,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            repliedMessage.isSentByMe ? 'You' : chat.name,
            style: TextStyle(
              color: context.themeColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            repliedMessage.isDeleted
                ? 'This message was deleted'
                : (repliedMessage.text.isNotEmpty
                    ? repliedMessage.text
                    : _typeLabel(repliedMessage.type)),
            style: TextStyle(
              color: context.themeColors.textSecondary.withOpacity(0.7),
              fontSize: 13,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
