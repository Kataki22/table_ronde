import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../../models/gif_model.dart';
import '../../../utils/theme_extensions.dart';
import '../../../services/sticker_manager.dart';

/// Grid view for displaying local stickers
class StickerGridView extends StatelessWidget {
  final Function(String stickerPath) onStickerSelected;
  final String category;

  const StickerGridView({
    super.key,
    required this.onStickerSelected,
    this.category = 'trending',
  });

  @override
  Widget build(BuildContext context) {
    // Get stickers for selected category
    List<GifModel> stickers;

    if (category == 'Mes stickers') {
      stickers = StickerManager()
          .customStickers
          .map((s) => GifModel(
                id: s.id,
                title: s.name,
                category: 'Mes stickers',
                assetPath: s.filePath,
                thumbEmoji: '⭐',
              ))
          .toList();
    } else {
      stickers = gifsByCategory(category);
    }

    if (stickers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '🎭',
              style: TextStyle(
                fontSize: 64,
                color: context.themeColors.textPrimary.withOpacity(0.3),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No stickers in this category',
              style: TextStyle(
                color: context.themeColors.textPrimary.withOpacity(0.5),
                fontSize: 15,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(6),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
        childAspectRatio: 1.0,
      ),
      itemCount: stickers.length,
      itemBuilder: (context, index) {
        final sticker = stickers[index];
        return _StickerGridItem(
          sticker: sticker,
          onTap: () => onStickerSelected(sticker.assetPath),
        );
      },
    );
  }
}

/// Individual sticker grid item
class _StickerGridItem extends StatelessWidget {
  final GifModel sticker;
  final VoidCallback onTap;

  const _StickerGridItem({
    required this.sticker,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: context.themeColors.bgSurface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: context.themeColors.textPrimary.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: sticker.assetPath.startsWith('assets/')
              ? Image.asset(
                  sticker.assetPath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildErrorWidget(context);
                  },
                )
              : (!kIsWeb
                  ? Image.file(
                      File(sticker.assetPath),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildErrorWidget(context);
                      },
                    )
                  : _buildErrorWidget(
                      context)), // Fallback for web if not asset
        ),
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context) {
    return Container(
      color: context.themeColors.bgSurface,
      child: Center(
        child: Text(
          sticker.thumbEmoji,
          style: const TextStyle(fontSize: 48),
        ),
      ),
    );
  }
}
