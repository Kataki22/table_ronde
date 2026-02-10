import 'package:flutter/material.dart';
import 'sticker_model.dart';
import '../../utils/app_theme.dart';

class StickerPicker extends StatefulWidget {
  const StickerPicker({super.key});

  @override
  State<StickerPicker> createState() => _StickerPickerState();
}

class _StickerPickerState extends State<StickerPicker> {
  final TextEditingController _searchCtrl = TextEditingController();
  int _selectedPack = 0;
  List<StickerModel> _filtered = [];

  @override
  void initState() {
    super.initState();
    _filtered = sampleStickerPacks[0].stickers;
    _searchCtrl.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchCtrl.removeListener(_onSearch);
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearch() {
    final q = _searchCtrl.text.trim().toLowerCase();
    setState(() {
      if (q.isEmpty) {
        _filtered = sampleStickerPacks[_selectedPack].stickers;
      } else {
        _filtered = sampleStickerPacks
            .expand((p) => p.stickers)
            .where((s) => s.name.toLowerCase().contains(q) || s.emoji.contains(q))
            .toList();
      }
    });
  }

  void _switchPack(int index) {
    setState(() {
      _selectedPack = index;
      _searchCtrl.clear(); // clear triggers listener → resets to pack stickers
      _filtered = sampleStickerPacks[index].stickers;
    });
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
          // ── drag handle ──
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

          // ── search bar ──
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
                  const Icon(Icons.search, color: AppTheme.textSecondary, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: const InputDecoration(
                        hintText: 'Search stickers…',
                        hintStyle: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
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

          // ── pack tabs (horizontal scroll) ──
          if (_searchCtrl.text.trim().isEmpty)
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: sampleStickerPacks.length,
                itemBuilder: (ctx, i) {
                  final selected = i == _selectedPack;
                  return GestureDetector(
                    onTap: () => _switchPack(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppTheme.primaryBlue.withOpacity(0.2)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: selected ? AppTheme.primaryBlue : Colors.transparent,
                        ),
                      ),
                      child: Text(
                        '${sampleStickerPacks[i].thumbEmoji}  ${sampleStickerPacks[i].packName}',
                        style: TextStyle(
                          color: selected ? Colors.white : AppTheme.textSecondary,
                          fontSize: 13,
                          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

          // ── sticker grid ──
          Expanded(
            child: GridView.builder(
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
                        // Try asset first; fall back to emoji
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
            ),
          ),
        ],
      ),
    );
  }
}
