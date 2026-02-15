import 'package:flutter/material.dart';
import '../../../models/chat_model.dart';

/// Widget to display a sticker message
class StickerMessage extends StatelessWidget {
  final MessageModel message;

  const StickerMessage({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 150,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: message.stickerUrl != null && message.stickerUrl!.isNotEmpty
          ? Image.asset(
              message.stickerUrl!,
              fit: BoxFit.contain, // Ensure sticker is not cropped
              errorBuilder: (context, error, stackTrace) {
                return Center(
                  child: Text(
                    '🏷️ ${message.text}',
                    style: const TextStyle(fontSize: 64),
                  ),
                );
              },
            )
          : Center(
              child: Text(
                '🏷️ ${message.text}',
                style: const TextStyle(fontSize: 64),
              ),
            ),
    );
  }
}
