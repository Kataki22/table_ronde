import 'package:flutter/material.dart';
import '../../models/gif_model.dart';
import '../../utils/app_theme.dart';

class GifPicker extends StatefulWidget {
  const GifPicker({super.key});

  @override
  State<GifPicker> createState() => _GifPickerState();
}

class _GifPickerState extends State<GifPicker> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _activeCategory = gifCategories.first;
  List<GifModel> _displayed = [];

  @override
  void initState() {
    super.initState();
    _displayed = gifsByCategory(_activeCategory);
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
        _displayed = gifsByCategory(_activeCategory);
      } else {
        _displayed = sampleGifs
            .where((g) =>
                g.title.toLowerCase().contains(q) ||
                g.category.toLowerCase().contains(q) ||
                g.thumbEmoji.contains(q))
            .toList();
      }
    });
  }

  void _switchCategory(String cat) {
    setState(() {
      _activeCategory = cat;
      _searchCtrl.clear();
      _displayed = gifsByCategory(cat);
    });
  }

  @override
  Widget build(BuildContext context) {
    final categories = gifCategories;

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
                        hintText: 'Search GIFs…',
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

          // ── category tabs ──
          if (_searchCtrl.text.trim().isEmpty)
            SizedBox(
              height: 36,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: categories.length,
                itemBuilder: (ctx, i) {
                  final cat = categories[i];
                  final active = cat == _activeCategory;
                  return GestureDetector(
                    onTap: () => _switchCategory(cat),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: active
                            ? AppTheme.primaryBlue.withOpacity(0.2)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: active ? AppTheme.primaryBlue : Colors.transparent,
                        ),
                      ),
                      child: Text(
                        cat.capitalize,
                        style: TextStyle(
                          color: active ? Colors.white : AppTheme.textSecondary,
                          fontSize: 13,
                          fontWeight: active ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

          // ── GIF grid ──
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1,
              ),
              itemCount: _displayed.length,
              itemBuilder: (ctx, i) {
                final gif = _displayed[i];
                return GestureDetector(
                  onTap: () => Navigator.of(ctx).pop(gif),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundDark,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Animated emoji as placeholder until real GIF assets are added
                        Text(gif.thumbEmoji, style: const TextStyle(fontSize: 42)),
                        const SizedBox(height: 4),
                        Text(
                          gif.title,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 11,
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

// small extension so we can capitalise category names nicely
extension StringExt on String {
  String get capitalize =>
      isEmpty ? this : this[0].toUpperCase() + substring(1);
}
