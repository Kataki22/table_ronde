import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';
import '../../utils/theme_extensions.dart';

class HomeTopBar extends StatefulWidget {
  final VoidCallback? onCreatePost;

  const HomeTopBar({
    super.key,
    this.onCreatePost,
  });

  @override
  State<HomeTopBar> createState() => _HomeTopBarState();
}

class _HomeTopBarState extends State<HomeTopBar> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showModuleSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.themeColors.bgSurfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Navigation Rapide',
                style: AppTheme.headingMedium
                    .copyWith(color: context.themeColors.textPrimary),
              ),
              const SizedBox(height: 24),
              _buildQuickNavItem(
                context,
                Icons.people_rounded,
                'Module Social',
                'Conversations et communauté',
                context.themeColors.colorPrimary,
                'chat',
              ),
              _buildQuickNavItem(
                context,
                Icons.account_balance_wallet_rounded,
                'Module Finance',
                'Transactions et épargne',
                context.themeColors.colorSuccess,
                '/finance',
              ),
              _buildQuickNavItem(
                context,
                Icons.school_rounded,
                'Module Éducation',
                'Devoirs et documents',
                context.themeColors.colorWarning,
                '/education',
              ),
              _buildQuickNavItem(
                context,
                Icons.sports_esports_rounded,
                'Module Jeux',
                'Classements et défis',
                Colors.purple,
                '/games',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickNavItem(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    Color color,
    String route,
  ) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        Navigator.pushNamed(context, route);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.themeColors.bgSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.bodyLarge.copyWith(
                      color: context.themeColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTheme.bodySmall.copyWith(
                      color: context.themeColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color, size: 16),
          ],
        ),
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: context.themeColors.bgSurfaceDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Rechercher',
            style: AppTheme.headingMedium
                .copyWith(color: context.themeColors.textPrimary),
          ),
          content: TextField(
            controller: _searchController,
            autofocus: true,
            style: AppTheme.bodyMedium
                .copyWith(color: context.themeColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Rechercher des posts, membres...',
              hintStyle: AppTheme.bodyMedium.copyWith(
                color: context.themeColors.textSecondary,
              ),
              prefixIcon:
                  Icon(Icons.search, color: context.themeColors.colorPrimary),
              filled: true,
              fillColor: context.themeColors.bgSurface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Annuler',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: context.themeColors.colorPrimary,
              ),
              child: const Text('Rechercher'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: context.themeColors.bgSurface,
        border: Border(
          bottom:
              BorderSide(color: context.themeColors.bgSurfaceDark, width: 1),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            color: context.themeColors.textPrimary,
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            },
            tooltip: 'Retour',
          ),
          IconButton(
            icon: const Icon(Icons.dashboard_outlined),
            color: context.themeColors.textPrimary,
            onPressed: () => _showModuleSelector(context),
            tooltip: 'Modules',
          ),
          const SizedBox(width: 16),
          if (MediaQuery.of(context).size.width > 1200) ...[
            _buildModuleButton(
              context,
              Icons.people_rounded,
              'Social',
              context.themeColors.colorPrimary,
              '/chat',
            ),
            _buildModuleButton(
              context,
              Icons.account_balance_wallet_rounded,
              'Finance',
              context.themeColors.colorSuccess,
              '/finance',
            ),
            _buildModuleButton(
              context,
              Icons.school_rounded,
              'Éducation',
              context.themeColors.colorWarning,
              '/education',
            ),
            _buildModuleButton(
              context,
              Icons.sports_esports_rounded,
              'Jeux',
              Colors.purple,
              '/games',
            ),
          ],
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.edit_note),
            color: context.themeColors.textPrimary,
            onPressed: widget.onCreatePost,
            tooltip: 'Créer un post',
          ),
          IconButton(
            icon: const Icon(Icons.favorite_border),
            color: context.themeColors.textPrimary,
            onPressed: () {},
            tooltip: 'Favoris',
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            color: context.themeColors.textPrimary,
            onPressed: () {},
            tooltip: 'Notifications',
          ),
          const SizedBox(width: 12),
          InkWell(
            onTap: () => _showSearchDialog(context),
            child: Container(
              width: 200,
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: context.themeColors.bgPrimary,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: context.themeColors.bgSurfaceDark,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Rechercher...',
                      style: AppTheme.bodySmall.copyWith(
                        color: context.themeColors.textSecondary,
                      ),
                    ),
                  ),
                  Icon(Icons.search,
                      color: context.themeColors.textSecondary, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModuleButton(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
    String route,
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, route),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTheme.bodySmall.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
