import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';
import '../../utils/theme_extensions.dart';
import 'pages/appearance_settings.dart';
import 'pages/placeholder_settings.dart';
import 'pages/profile_settings.dart';
import 'pages/account_settings.dart';

class SettingsDialog extends StatefulWidget {
  const SettingsDialog({super.key});

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  int _selectedIndex = 0; // Default to Profile
  bool _showContentOnMobile = false;

  // Menu Definition
  // 'type': 'item' | 'header'
  final List<Map<String, dynamic>> _menuItems = [
    // Header for Menu (Not needed in list, handled separately)

    // Group 1: Account Settings
    {'type': 'header', 'label': 'Paramètres du compte'},
    {'type': 'item', 'icon': Icons.person, 'label': 'Mon Profil', 'page': 0},
    {
      'type': 'item',
      'icon': Icons.card_giftcard,
      'label': 'Obtenir Nitro',
      'page': -1
    },
    {
      'type': 'item',
      'icon': Icons.person_outline,
      'label': 'Compte',
      'page': 1
    },
    {
      'type': 'item',
      'icon': Icons.shield_outlined,
      'label': 'Confidentialité',
      'page': -1
    },

    // Group 2: App Settings
    {'type': 'header', 'label': 'Paramètres de l\'appli'},
    {
      'type': 'item',
      'icon': Icons.palette_outlined,
      'label': 'Apparence',
      'page': 2
    },
    {
      'type': 'item',
      'icon': Icons.notifications_none,
      'label': 'Notifications',
      'page': 3
    },
    {
      'type': 'item',
      'icon': Icons.accessibility_new_outlined,
      'label': 'Accessibilité',
      'page': 5
    },
    {'type': 'item', 'icon': Icons.language, 'label': 'Langue', 'page': -1},
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 800;

        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding:
              isMobile ? const EdgeInsets.all(10) : const EdgeInsets.all(40),
          child: Container(
            width: isMobile ? double.infinity : 1000,
            height: isMobile ? double.infinity : 700,
            constraints: BoxConstraints(
              maxWidth: 1000,
              maxHeight: isMobile ? double.infinity : 700,
            ),
            decoration: BoxDecoration(
              color: context.themeColors.bgPrimary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: isMobile ? _buildMobileLayout() : _buildDesktopLayout(),
          ),
        );
      },
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // ── Sidebar ─────────────────────────────────────────────────
        Container(
          width: 250,
          decoration: BoxDecoration(
            color: context.themeColors.bgSurface,
            borderRadius: BorderRadius.horizontal(left: Radius.circular(8)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSidebarHeader(),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: _buildSearchBar(),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _menuItems.length,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  itemBuilder: (context, index) {
                    return _buildMenuRow(index);
                  },
                ),
              ),
              _buildCloseButton(),
            ],
          ),
        ),

        // ── Content ─────────────────────────────────────────────────
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: context.themeColors.bgPrimary,
              borderRadius: BorderRadius.horizontal(right: Radius.circular(8)),
            ),
            child: _buildContent(),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        if (_showContentOnMobile) ...[
          // Mobile Content Header with Back Button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.themeColors.bgSurface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back,
                      color: context.themeColors.textPrimary),
                  onPressed: () => setState(() => _showContentOnMobile = false),
                ),
                Expanded(
                  child: Text(
                    _getCurrentLabel(),
                    style: AppTheme.headingMedium.copyWith(fontSize: 18),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close,
                      color: context.themeColors.textSecondary),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Expanded(child: _buildContent()),
        ] else ...[
          // Mobile Menu List
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            decoration: BoxDecoration(
              color: context.themeColors.bgSurface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Paramètres',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: context.themeColors.textPrimary),
                    ),
                    IconButton(
                      icon: Icon(Icons.close,
                          color: context.themeColors.textSecondary),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _buildSearchBar(),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _menuItems.length,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              itemBuilder: (context, index) {
                return _buildMenuRow(index, isMobile: true);
              },
            ),
          ),
        ],
      ],
    );
  }

  String _getCurrentLabel() {
    // Find the menu item that corresponds to the selected index
    final item = _menuItems.firstWhere(
      (element) => element['page'] == _selectedIndex,
      orElse: () => {'label': 'Paramètres'},
    );
    return item['label'];
  }

  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Rechercher',
        prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary),
        filled: true,
        fillColor: AppTheme.backgroundDark,
        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide.none,
        ),
        hintStyle: AppTheme.bodyMedium,
      ),
      style: TextStyle(color: context.themeColors.textPrimary),
    );
  }

  Widget _buildSidebarHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Text(
        'Paramètres',
        style: AppTheme.headingMedium.copyWith(fontSize: 20),
      ),
    );
  }

  Widget _buildCloseButton() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: TextButton.icon(
        onPressed: () => Navigator.pop(context),
        icon:
            Icon(Icons.close, color: context.themeColors.colorDanger, size: 20),
        label: Text(
          'Fermer',
          style: TextStyle(
              color: context.themeColors.colorDanger,
              fontWeight: FontWeight.bold),
        ),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          alignment: Alignment.centerLeft,
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: EdgeInsets.zero,
      child: _currentContentWidget(),
    );
  }

  Widget _currentContentWidget() {
    switch (_selectedIndex) {
      case 0:
        return const ProfileSettings();
      case 1:
        return const AccountSettings();
      case 2:
        return const AppearanceSettings();
      default:
        return PlaceholderSettings(title: _getCurrentLabel());
    }
  }

  Widget _buildMenuRow(int index, {bool isMobile = false}) {
    final item = _menuItems[index];

    if (item['type'] == 'header') {
      return Padding(
        padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
        child: Text(
          item['label'].toUpperCase(),
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    // Normal Item
    final int pageIndex = item['page'];
    final bool isSelected = _selectedIndex == pageIndex && !isMobile;

    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: InkWell(
        onTap: () {
          if (pageIndex != -1) {
            setState(() {
              _selectedIndex = pageIndex;
              if (isMobile) {
                _showContentOnMobile = true;
              }
            });
          }
        },
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? context.themeColors.bgSurfaceDark
                : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              Icon(
                item['icon'],
                color:
                    isSelected ? AppTheme.textPrimary : AppTheme.textSecondary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item['label'],
                  style: TextStyle(
                    color: isSelected
                        ? AppTheme.textPrimary
                        : AppTheme.textSecondary,
                    fontWeight: isSelected ? FontWeight.w500 : FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
              ),
              if (isMobile)
                const Icon(
                  Icons.chevron_right,
                  color: AppTheme.textSecondary,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
