import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/chat_model.dart';
import '../../../utils/theme_extensions.dart';
import '../../../providers/auth_provider.dart';

/// Widget to display a deleted message bubble
class DeletedMessageBubble extends StatelessWidget {
  final MessageModel message;

  const DeletedMessageBubble({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final currentUserId = authProvider.currentUser?.id ?? '';
    final isSentByMe = message.isSentBy(currentUserId);

    return Align(
      alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
        child: Row(
          mainAxisAlignment:
              isSentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            if (!isSentByMe) const SizedBox(width: 24 + 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSentByMe
                    ? context.themeColors.colorPrimary.withOpacity(0.6)
                    : context.themeColors.bgSurface.withOpacity(0.6),
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
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.block,
                    size: 16,
                    color: context.themeColors.textInverse.withOpacity(0.6),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Ce message a été supprimé',
                    style: TextStyle(
                      color: context.themeColors.textInverse.withOpacity(0.6),
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            if (isSentByMe) const SizedBox(width: 6),
          ],
        ),
      ),
    );
  }
}
