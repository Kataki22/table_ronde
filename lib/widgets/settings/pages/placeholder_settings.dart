import 'package:flutter/material.dart';
import '../../../utils/app_theme.dart';
import '../../../utils/theme_extensions.dart';

class PlaceholderSettings extends StatelessWidget {
  final String title;

  const PlaceholderSettings({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: context.themeColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.backgroundDark,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: context.themeColors.colorWarning.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.construction,
                    color: context.themeColors.colorWarning),
                const SizedBox(width: 12),
                Text(
                  'Cette section est en cours de développement',
                  style: TextStyle(
                      color: context.themeColors.textPrimary.withOpacity(0.7)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
