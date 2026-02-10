import 'package:flutter/material.dart';
import '../../../utils/app_theme.dart';
import '../../../utils/theme_extensions.dart';

class HomeRightSidebar extends StatelessWidget {
  final bool isMobile;

  const HomeRightSidebar({super.key, this.isMobile = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isMobile ? null : 320,
      decoration: BoxDecoration(
        color: context.themeColors.bgSurface,
        border: isMobile
            ? null
            : Border(
                left: BorderSide(
                    color: context.themeColors.bgSurfaceDark, width: 1),
              ),
      ),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Modules section
          Text(
            'Modules',
            style: AppTheme.headingSmall.copyWith(
              color: context.themeColors.textPrimary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          _buildModuleCard(context, 'Social', Icons.people_rounded,
              context.themeColors.colorPrimary, '/social'),
          _buildModuleCard(
              context,
              'Finance',
              Icons.account_balance_wallet_rounded,
              context.themeColors.colorSuccess,
              '/finance'),
          _buildModuleCard(context, 'Éducation', Icons.school_rounded,
              context.themeColors.colorWarning, '/education'),
          _buildModuleCard(context, 'Jeux', Icons.sports_esports_rounded,
              Colors.purple, '/games'),

          const SizedBox(height: 24),

          // Quick stats
          Text(
            'Statistiques',
            style: AppTheme.headingSmall.copyWith(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          _buildStatItem(context, 'Messages non lus', '12', Icons.chat_bubble),
          _buildStatItem(context, 'Devoirs en attente', '5', Icons.assignment),
          _buildStatItem(context, 'Solde disponible', '150€',
              Icons.account_balance_wallet),
        ],
      ),
    );
  }

  Widget _buildModuleCard(BuildContext context, String title, IconData icon,
      Color color, String route) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, route);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.themeColors.bgSurfaceDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2), width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: AppTheme.bodyMedium.copyWith(
                color: context.themeColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
      BuildContext context, String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.themeColors.bgSurfaceDark,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: context.themeColors.colorPrimary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTheme.bodySmall.copyWith(
                    color: context.themeColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
                Text(
                  value,
                  style: AppTheme.bodyMedium.copyWith(
                    color: context.themeColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
