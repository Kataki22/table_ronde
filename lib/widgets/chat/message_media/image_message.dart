import 'dart:io';
import 'package:flutter/material.dart';
import '../../../models/chat_model.dart';
import '../../../utils/theme_extensions.dart';

/// Widget to display an image message
class ImageMessage extends StatelessWidget {
  final MessageModel message;

  const ImageMessage({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        maxWidth: 250,
        maxHeight: 250,
      ),
      child: message.attachmentUrl != null && message.attachmentUrl!.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(message.attachmentUrl!),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 220,
                    height: 180,
                    decoration: BoxDecoration(
                      color: context.themeColors.bgSurface.withOpacity(0.35),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.broken_image,
                            color: context.themeColors.textInverse
                                .withOpacity(0.7),
                            size: 60,
                          ),
                          const SizedBox(height: 12),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              message.attachmentName ?? 'Photo',
                              style: TextStyle(
                                color: context.themeColors.textInverse
                                    .withOpacity(0.7),
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            )
          : Container(
              width: 220,
              height: 180,
              decoration: BoxDecoration(
                color: context.themeColors.bgSurface.withOpacity(0.35),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image,
                        color: context.themeColors.textInverse.withOpacity(0.7),
                        size: 60),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        message.attachmentName ?? 'Photo',
                        style: TextStyle(
                          color:
                              context.themeColors.textInverse.withOpacity(0.7),
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
