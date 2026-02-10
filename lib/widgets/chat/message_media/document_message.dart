import 'package:flutter/material.dart';
import '../../../models/chat_model.dart';
import '../../../utils/theme_extensions.dart';

/// Widget to display a document/file message
class DocumentMessage extends StatelessWidget {
  final MessageModel message;
  final bool isSentByMe;

  const DocumentMessage({
    super.key,
    required this.message,
    required this.isSentByMe,
  });

  @override
  Widget build(BuildContext context) {
    final fileName = message.attachmentName ?? 'Document';
    final fileExt = fileName.contains('.')
        ? fileName.split('.').last.toUpperCase()
        : 'FILE';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSentByMe
            ? context.themeColors.bgSurface.withOpacity(0.1)
            : context.themeColors.bgSurface.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _getFileColor(fileExt),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                fileExt.length > 4 ? fileExt.substring(0, 4) : fileExt,
                style: TextStyle(
                  color: context.themeColors.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  style: TextStyle(
                    color: context.themeColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  _getFileSize(message.attachmentUrl),
                  style: TextStyle(
                    color: context.themeColors.textSecondary.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.download,
            color: context.themeColors.textSecondary.withOpacity(0.7),
            size: 20,
          ),
        ],
      ),
    );
  }

  Color _getFileColor(String ext) {
    switch (ext.toLowerCase()) {
      case 'pdf':
        return const Color(0xFFE74C3C);
      case 'doc':
      case 'docx':
        return const Color(0xFF2980B9);
      case 'xls':
      case 'xlsx':
        return const Color(0xFF27AE60);
      case 'ppt':
      case 'pptx':
        return const Color(0xFFE67E22);
      case 'zip':
      case 'rar':
        return const Color(0xFF95A5A6);
      default:
        return const Color(0xFF34495E);
    }
  }

  String _getFileSize(String? path) {
    // Placeholder - in real app, get actual file size
    return 'Document';
  }
}
