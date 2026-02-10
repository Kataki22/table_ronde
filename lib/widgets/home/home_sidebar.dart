import 'package:flutter/material.dart';
import '../../models/chat_model.dart';
import '../../utils/app_theme.dart';
import '../../utils/theme_extensions.dart';
import '../settings/settings_dialog.dart';

class HomeSidebar extends StatelessWidget {
  final bool isMobile;
  final int selectedIndex;
  final Function(int) onIndexChanged;

  HomeSidebar({
    super.key,
    this.isMobile = false,
    required this.selectedIndex,
    required this.onIndexChanged,
  });

  final List<ChatModel> _privateMessages = [
    ChatModel(id: 'pm1', name: 'T4zor', lastMessage: '...', isOnline: false),
    ChatModel(id: 'pm2', name: 'Ralphon', lastMessage: '...', isOnline: true),
    ChatModel(id: 'pm3', name: 'Kevin', lastMessage: '...', isOnline: true),
    ChatModel(id: 'pm4', name: 'Tedy', lastMessage: '...', isOnline: false),
    ChatModel(id: 'pm5', name: 'Tk-Porky', lastMessage: '...', isOnline: false),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isMobile ? null : 280,
      decoration: BoxDecoration(
        color: context.themeColors.bgSurface,
        border: isMobile
            ? null
            : Border(
                right: BorderSide(
                  color: context.themeColors.bgSurfaceDark,
                  width: 1,
                ),
              ),
      ),
      child: Column(
        children: [
          // Header with logo
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.group_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'TableRonde',
                  style: AppTheme.headingMedium.copyWith(
                      fontSize: 18, color: context.themeColors.textPrimary),
                ),
              ],
            ),
          ),

          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: context.themeColors.bgPrimary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.search,
                      color: context.themeColors.textSecondary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Recherche Rapide',
                    style: AppTheme.bodySmall.copyWith(
                      color: context.themeColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Navigation items
          _buildNavItem(
            context,
            0,
            Icons.home_rounded,
            'Fil d\'actualités',
            badge: '+9 Posts',
          ),
          _buildNavItem(context, 1, Icons.campaign_rounded, 'Annonces'),
          _buildNavItem(context, 2, Icons.people_rounded, 'Membres'),
          _buildNavItem(context, 3, Icons.timeline_rounded, 'Activités'),

          const SizedBox(height: 24),

          // Messages section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Messages Privés',
                  style: AppTheme.bodySmall.copyWith(
                    color: context.themeColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.add,
                    color: context.themeColors.textSecondary,
                    size: 18,
                  ),
                  onPressed: () {},
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Message list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: _privateMessages.length,
              itemBuilder: (context, index) {
                return _buildMessageItem(context, _privateMessages[index]);
              },
            ),
          ),

          // Bottom user profile
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.themeColors.bgSurfaceDark.withOpacity(0.5),
              border: Border(
                top: BorderSide(
                    color: context.themeColors.bgSurfaceDark, width: 1),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.pink.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(Icons.person, color: Colors.pink, size: 18),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Vous',
                        style: AppTheme.bodySmall.copyWith(
                          color: context.themeColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.settings,
                      size: 18, color: context.themeColors.textSecondary),
                  color: context.themeColors.textSecondary,
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => const SettingsDialog(),
                    );
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
      BuildContext context, int index, IconData icon, String label,
      {String? badge}) {
    final isSelected = selectedIndex == index;

    return InkWell(
      onTap: () => onIndexChanged(index),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? context.themeColors.bgSurfaceDark
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? context.themeColors.textPrimary
                  : context.themeColors.textSecondary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: AppTheme.bodyMedium.copyWith(
                  color: isSelected
                      ? context.themeColors.textPrimary
                      : context.themeColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: context.themeColors.colorPrimary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badge,
                  style: AppTheme.bodySmall.copyWith(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageItem(BuildContext context, ChatModel chat) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, '/chat', arguments: chat);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        margin: const EdgeInsets.only(bottom: 2),
        child: Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: context.themeColors.colorPrimary.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      chat.name.substring(0, 1),
                      style: AppTheme.bodyMedium.copyWith(
                        color: context.themeColors.colorPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                if (chat.isOnline)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: context.themeColors.colorSuccess,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: context.themeColors.bgSurface, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                chat.name,
                style: AppTheme.bodyMedium.copyWith(
                  color: context.themeColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
