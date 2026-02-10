import 'package:flutter/material.dart';
import '../../../models/chat_model.dart';
import '../../../utils/theme_extensions.dart';

/// Widget to display a video message with play button
class VideoMessage extends StatelessWidget {
  final MessageModel message;
  final Function(String) onVideoTap;

  const VideoMessage({
    super.key,
    required this.message,
    required this.onVideoTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (message.attachmentUrl != null &&
            message.attachmentUrl!.isNotEmpty) {
          onVideoTap(message.attachmentUrl!);
        }
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 240,
            height: 180,
            decoration: BoxDecoration(
              color: context.themeColors.bgSurface.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: context.themeColors.borderSubtle.withOpacity(0.1),
                  width: 1),
            ),
            child: message.attachmentUrl != null &&
                    message.attachmentUrl!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      children: [
                        // Video thumbnail placeholder
                        Container(
                          color: context.themeColors.bgSurfaceDark,
                          child: Center(
                            child: Icon(
                              Icons.videocam,
                              color: context.themeColors.textDisabled,
                              size: 80,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 8,
                          left: 8,
                          right: 8,
                          child: Text(
                            message.attachmentName ?? 'Vidéo',
                            style: TextStyle(
                              color: context.themeColors.textPrimary,
                              fontSize: 13,
                              shadows: [
                                Shadow(
                                    color: context.themeColors.bgSurfaceDark,
                                    blurRadius: 4)
                              ],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.videocam,
                          color: context.themeColors.textDisabled,
                          size: 60,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          message.attachmentName ?? 'Vidéo',
                          style: TextStyle(
                            color: context.themeColors.textSecondary
                                .withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
          // Play button overlay
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: context.themeColors.colorPrimary.withOpacity(0.9),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.play_arrow,
                color: context.themeColors.textInverse, size: 36),
          ),
        ],
      ),
    );
  }
}
