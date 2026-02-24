import 'dart:io';
import 'package:flutter/material.dart';
import 'sticker_model.dart';
import 'sticker_creator.dart';
import '../../models/custom_sticker_model.dart';
import '../../services/sticker_manager.dart';
import '../../utils/app_theme.dart';
import '../../utils/theme_extensions.dart';

class StickerPicker extends StatefulWidget {
  const StickerPicker({super.key});

  @override
  State<StickerPicker> createState() => _StickerPickerState();
}

class _StickerPickerState extends State<StickerPicker> {
  final TextEditingController _searchCtrl = TextEditingController();
  int _selectedPack = 0;
  List<StickerModel> _filtered = [];
  List<CustomStickerModel> _customStickers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCustomStickers();
    _filtered = sampleStickerPacks[0].stickers;
    _searchCtrl.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchCtrl.removeListener(_onSearch);
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadCustomStickers() async {
    await StickerManager().initialize();
    setState(() {
      _customStickers = StickerManager().customStickers;
      _isLoading = false;
    });
  }

  void _onSearch() {
    final q = _searchCtrl.text.trim().toLowerCase();
    setState(() {
      if (q.isEmpty) {
        _filtered = sampleStickerPacks[_selectedPack].stickers;
      } else {
        _filtered = sampleStickerPacks
            .expand((p) => p.stickers)
            .where(
                (s) => s.name.toLowerCase().contains(q) || s.emoji.contains(q))
            .toList();
      }
    });
  }

  void _switchPack(int index) {
    setState(() {
      _selectedPack = index;
      _searchCtrl.clear();
      _filtered = sampleStickerPacks[index].stickers;
    });
  }

  Future<void> _createNewSticker() async {
    final result = await showModalBottomSheet<CustomStickerModel>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const StickerCreator(),
    );

    if (result != null) {
      await _loadCustomStickers();
    }
  }

  Future<void> _deleteCustomSticker(CustomStickerModel sticker) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.themeColors.bgSurface,
        title: Text(
          'Supprimer le sticker?',
          style: TextStyle(color: context.themeColors.textPrimary),
        ),
        content: Text(
          'Voulez-vous vraiment supprimer "${sticker.name}"?',
          style: TextStyle(color: context.themeColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Annuler',
              style: TextStyle(color: context.themeColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Supprimer',
              style: TextStyle(color: context.themeColors.colorDanger),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await StickerManager().deleteSticker(sticker.id);
      await _loadCustomStickers();
    }
  }

  void _showCustomStickerOptions(CustomStickerModel sticker) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: context.themeColors.bgSurfaceDark,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: context.themeColors.textDisabled,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading:
                    Icon(Icons.send, color: context.themeColors.colorPrimary),
                title: Text(
                  'Envoyer',
                  style: TextStyle(color: context.themeColors.textPrimary),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pop(this.context, sticker);
                },
              ),
              ListTile(
                leading:
                    Icon(Icons.delete, color: context.themeColors.colorDanger),
                title: Text(
                  'Supprimer',
                  style: TextStyle(color: context.themeColors.textPrimary),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _deleteCustomSticker(sticker);
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.55,
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          const SizedBox(height: 10),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.textSecondary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 38,
              decoration: BoxDecoration(
                color: AppTheme.backgroundDark,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 14),
                  const Icon(Icons.search,
                      color: AppTheme.textSecondary, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: const InputDecoration(
                        hintText: 'Search stickers…',
                        hintStyle: TextStyle(
                            color: AppTheme.textSecondary, fontSize: 14),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Pack tabs with custom stickers section
          if (_searchCtrl.text.trim().isEmpty)
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount:
                    sampleStickerPacks.length + 1, // +1 for custom stickers
                itemBuilder: (ctx, i) {
                  // Custom stickers pack (first item)
                  if (i == 0) {
                    final selected = _selectedPack == -1;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedPack = -1;
                          _searchCtrl.clear();
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppTheme.primaryBlue.withOpacity(0.2)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: selected
                                ? AppTheme.primaryBlue
                                : Colors.transparent,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.star,
                              color: selected
                                  ? Colors.white
                                  : AppTheme.textSecondary,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Mes stickers',
                              style: TextStyle(
                                color: selected
                                    ? Colors.white
                                    : AppTheme.textSecondary,
                                fontSize: 13,
                                fontWeight: selected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  // Regular packs
                  final packIndex = i - 1;
                  final selected = packIndex == _selectedPack;
                  return GestureDetector(
                    onTap: () => _switchPack(packIndex),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppTheme.primaryBlue.withOpacity(0.2)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: selected
                              ? AppTheme.primaryBlue
                              : Colors.transparent,
                        ),
                      ),
                      child: Text(
                        '${sampleStickerPacks[packIndex].thumbEmoji}  ${sampleStickerPacks[packIndex].packName}',
                        style: TextStyle(
                          color:
                              selected ? Colors.white : AppTheme.textSecondary,
                          fontSize: 13,
                          fontWeight:
                              selected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

          // Sticker grid
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildStickerGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildStickerGrid() {
    // Show custom stickers
    if (_selectedPack == -1) {
      return GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
        itemCount: _customStickers.length + 1, // +1 for "create new" button
        itemBuilder: (ctx, i) {
          // Create new sticker button
          if (i == 0) {
            return GestureDetector(
              onTap: _createNewSticker,
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.primaryBlue.withOpacity(0.5),
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, color: AppTheme.primaryBlue, size: 36),
                    SizedBox(height: 4),
                    Text(
                      'Créer',
                      style: TextStyle(
                        color: AppTheme.primaryBlue,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          final sticker = _customStickers[i - 1];
          return GestureDetector(
            onTap: () => Navigator.of(ctx).pop(sticker),
            onLongPress: () => _showCustomStickerOptions(sticker),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.backgroundDark.withOpacity(0.6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(sticker.filePath),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.broken_image,
                        color: AppTheme.textSecondary);
                  },
                ),
              ),
            ),
          );
        },
      );
    }

    // Show regular sticker packs
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: _filtered.length,
      itemBuilder: (ctx, i) {
        final sticker = _filtered[i];
        return GestureDetector(
          onTap: () => Navigator.of(ctx).pop(sticker),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.backgroundDark.withOpacity(0.6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(sticker.emoji, style: const TextStyle(fontSize: 30)),
                const SizedBox(height: 2),
                Text(
                  sticker.name,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 9,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
