import 'package:flutter/material.dart';
import '../../../models/gif_model.dart';
import '../../../utils/theme_extensions.dart';

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
    final stickers = gifsByCategory(category);

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
          child: Image.asset(
            sticker.assetPath,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: context.themeColors.bgSurface,
                child: Center(
                  child: Text(
                    sticker.thumbEmoji,
                    style: const TextStyle(fontSize: 48),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
