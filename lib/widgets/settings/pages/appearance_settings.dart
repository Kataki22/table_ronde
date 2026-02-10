import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/app_theme_data.dart';
import '../../../providers/theme_provider.dart';

class AppearanceSettings extends StatelessWidget {
  const AppearanceSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Apparence',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.currentTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Personnalisez l\'apparence de l\'application',
                style: TextStyle(
                  fontSize: 14,
                  color: themeProvider.currentTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'THÈME',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.currentTheme.textMuted,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: AppThemeData.allThemes.map((theme) {
                  return _buildThemeCard(
                    theme,
                    themeProvider.currentTheme.id == theme.id,
                    () => themeProvider.setTheme(theme),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeCard(
    AppThemeData theme,
    bool isSelected,
    VoidCallback onTap,
  ) {
    // Get representative colors from the theme
    final colors = [
      theme.colorBrand,
      theme.bgPrimary,
      theme.bgSecondary,
    ];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 300,
        height: 100,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.bgSurface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? theme.colorPrimary : theme.borderLight,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Theme preview circles
            Row(
              children: [
                _colorCircle(colors[0]),
                const SizedBox(width: 4),
                _colorCircle(colors[1]),
                const SizedBox(width: 4),
                _colorCircle(colors[2]),
                const Spacer(),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: theme.colorPrimary,
                    size: 20,
                  ),
              ],
            ),
            const Spacer(),
            // Theme name & Progress bar visual
            Row(
              children: [
                Text(
                  theme.name,
                  style: TextStyle(
                    color: theme.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                // Fake progress bar purely for visual matching the design
                Container(
                  width: 100,
                  height: 6,
                  decoration: BoxDecoration(
                    color: theme.bgTertiary,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        decoration: BoxDecoration(
                          color: colors[0],
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      Container(
                        width: 40,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? theme.colorSuccess
                              : theme.textPrimary,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _colorCircle(Color color) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
    );
  }
}
