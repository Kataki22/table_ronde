import 'package:flutter/material.dart';
import '../../../utils/app_theme.dart';
import '../../../utils/theme_extensions.dart';
import '../../../utils/user_manager.dart';

class ProfileSettings extends StatefulWidget {
  const ProfileSettings({super.key});

  @override
  State<ProfileSettings> createState() => _ProfileSettingsState();
}

class _ProfileSettingsState extends State<ProfileSettings> {
  String _displayName = 'KATAKI.JR';
  String _username = 'kataki_jr';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userData = await UserManager().getUser();
    if (userData['name'] != null && userData['name']!.isNotEmpty) {
      if (mounted) {
        setState(() {
          _displayName = userData['name']!;
          _username = userData['username'] ?? 'user';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.themeColors.bgPrimary,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Blue Banner
            Container(
              height: 120,
              color: context.themeColors.colorPrimary,
            ),

            // Profile Info Section (Negative offset to overlap banner)
            Transform.translate(
              offset: const Offset(0, -50),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar with Status
                    Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6), // Border thickness
                          decoration: BoxDecoration(
                            color: context.themeColors
                                .bgPrimary, // Match bg to create "cutout" effect
                            shape: BoxShape.circle,
                          ),
                          child: CircleAvatar(
                            radius: 40,
                            backgroundColor: const Color(0xFF999999),
                            backgroundImage: const AssetImage(
                                'assets/images/default_avatar.png'),
                          ),
                        ),
                        Positioned(
                          bottom: 5,
                          right: 5,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: AppTheme.successColor,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: context.themeColors.bgPrimary,
                                  width: 4),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // User Name
                    Row(
                      children: [
                        Text(
                          _displayName,
                          style: AppTheme.headingMedium
                              .copyWith(color: context.themeColors.textPrimary),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.keyboard_arrow_down,
                            color: context.themeColors.textPrimary),
                      ],
                    ),
                    Text(
                      '@$_username',
                      style: AppTheme.bodyMedium
                          .copyWith(color: AppTheme.textSecondary),
                    ),

                    const SizedBox(height: 24),

                    // Edit Profile Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.themeColors.colorPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(25), // Pill shape
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.edit, size: 18),
                            SizedBox(width: 8),
                            Text('Modifier le profil'),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Info Cards
                    _buildInfoCard(
                      title: 'Membre depuis',
                      content: Row(
                        children: [
                          const Icon(Icons.discord,
                              color: AppTheme.textSecondary, size: 20),
                          const SizedBox(width: 8),
                          Text('13 mars 2024',
                              style: AppTheme.bodyMedium
                                  .copyWith(color: AppTheme.textPrimary)),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Amis (Friends)
                    _buildNavCard(
                      label: 'Amis',
                      onTap: () {},
                    ),

                    const SizedBox(height: 12),

                    // Note
                    _buildInfoCard(
                      title: 'Note (seulement visible par toi)',
                      trailing: const Icon(Icons.add_card_outlined,
                          color: AppTheme.textSecondary),
                      content: const SizedBox(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
      {required String title, Widget? content, Widget? trailing}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.themeColors.bgSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTheme.bodySmall
                    .copyWith(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              if (trailing != null) trailing,
            ],
          ),
          if (content != null) ...[
            const SizedBox(height: 8),
            content,
          ]
        ],
      ),
    );
  }

  Widget _buildNavCard({required String label, required VoidCallback onTap}) {
    return Material(
      color: context.themeColors.bgSurface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textPrimary, fontWeight: FontWeight.w500),
              ),
              const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
