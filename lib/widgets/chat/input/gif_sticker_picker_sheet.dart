import 'package:flutter/material.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import '../../../../utils/theme_extensions.dart';
import '../input/gif_grid_view.dart';
import '../input/sticker_grid_view.dart';
import '../../../services/tenor_gif_service.dart';

class GifStickerPickerSheet extends StatefulWidget {
  final Function(String) onGifSelected;
  final Function(String) onStickerSelected;
  final TextEditingController? messageController;

  const GifStickerPickerSheet({
    super.key,
    required this.onGifSelected,
    required this.onStickerSelected,
    this.messageController,
  });

  @override
  State<GifStickerPickerSheet> createState() => _GifStickerPickerSheetState();
}

class _GifStickerPickerSheetState extends State<GifStickerPickerSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'Trending';

  // Categories for the bottom bar
  final List<String> _categories = [
    'Trending',
    'Funny',
    'Love',
    'Happy',
    'Sad',
    'Angry',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // Rebuild to hide/show header based on index
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
    });
  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
      _searchQuery = category == 'Trending' ? '' : category;
      _searchController.text = _searchQuery;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        color: context.themeColors.bgSurfaceDark,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with Search and Tabs (Hide search for Emoji tab - index 0)
          _buildHeader(),

          // Content Area
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Emoji Tab
                EmojiPicker(
                  textEditingController: widget.messageController,
                  config: Config(
                    emojiViewConfig: EmojiViewConfig(
                      columns: 8,
                      emojiSizeMax: 32 * 1.0,
                      backgroundColor: context.themeColors.bgSurfaceDark,
                      buttonMode: ButtonMode.MATERIAL,
                    ),
                    categoryViewConfig: CategoryViewConfig(
                      initCategory: Category.RECENT,
                      backgroundColor: context.themeColors.bgSurfaceDark,
                      indicatorColor: context.themeColors.colorPrimary,
                      iconColor: context.themeColors.textSecondary,
                      iconColorSelected: context.themeColors.colorPrimary,
                      backspaceColor: context.themeColors.colorPrimary,
                    ),
                    skinToneConfig: SkinToneConfig(
                      dialogBackgroundColor: context.themeColors.bgSurface,
                      indicatorColor: context.themeColors.textSecondary,
                    ),
                  ),
                ),

                // GIF Tab
                GifGridView(
                  onGifSelected: widget.onGifSelected,
                  searchQuery: _searchQuery,
                ),

                // Stickers Tab
                StickerGridView(
                  onStickerSelected: widget.onStickerSelected,
                  category: _searchQuery.isEmpty ? 'trending' : _searchQuery,
                ),
              ],
            ),
          ),

          // Bottom Category Bar (only separate specific Categories, maybe hide for Emoji)
          if (_tabController.index != 0) _buildCategoryBar(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        border:
            Border(bottom: BorderSide(color: context.themeColors.bgSurface)),
      ),
      child: Column(
        children: [
          // Search Bar - Hide for Emoji (index 0)
          if (_tabController.index != 0) ...[
            Container(
              height: 40,
              decoration: BoxDecoration(
                color: context.themeColors.bgSurface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                style: TextStyle(color: context.themeColors.textPrimary),
                decoration: InputDecoration(
                  hintText: _tabController.index == 1
                      ? 'Search GIFs'
                      : 'Search Stickers',
                  hintStyle: TextStyle(
                      color: context.themeColors.textPrimary.withOpacity(0.3)),
                  prefixIcon: Icon(
                    Icons.search,
                    color: context.themeColors.textPrimary.withOpacity(0.3),
                    size: 20,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          color:
                              context.themeColors.textPrimary.withOpacity(0.3),
                          onPressed: () {
                            _searchController.clear();
                            _onSearchChanged('');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],

          // Tab Bar
          TabBar(
            controller: _tabController,
            indicatorColor: context.themeColors.colorPrimary,
            indicatorWeight: 3,
            labelColor: context.themeColors.colorPrimary,
            unselectedLabelColor:
                context.themeColors.textPrimary.withOpacity(0.5),
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            onTap: (index) {
              // FocusScope.of(context).unfocus(); // Optional
            },
            tabs: const [
              Tab(text: 'Simley'),
              Tab(text: 'GIF'),
              Tab(text: 'Stickers'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBar() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: context.themeColors.bgSurface)),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = category == _selectedCategory;

          return GestureDetector(
            onTap: () => _onCategorySelected(category),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: isSelected
                    ? Border(
                        top: BorderSide(
                            color: context.themeColors.colorPrimary, width: 2))
                    : null,
                color: isSelected
                    ? context.themeColors.bgSurface
                    : Colors.transparent,
              ),
              child: Text(
                category,
                style: TextStyle(
                  color: isSelected
                      ? context.themeColors.textPrimary
                      : context.themeColors.textPrimary.withOpacity(0.5),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
