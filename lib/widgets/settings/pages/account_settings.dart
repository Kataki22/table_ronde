import 'package:flutter/material.dart';
import '../../../utils/app_theme.dart';
import '../../../utils/theme_extensions.dart';
import '../../../utils/user_manager.dart';
import '../../../services/auth_service.dart';

class AccountSettings extends StatefulWidget {
  const AccountSettings({super.key});

  @override
  State<AccountSettings> createState() => _AccountSettingsState();
}

class _AccountSettingsState extends State<AccountSettings> {
  String _name = 'KATAKI.JR';
  String _username = 'kataki_jr';
  String _email = 'ajuju1789@gmail.com';

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
          _name = userData['name']!;
          _username = userData['username'] ?? 'user';
          _email = userData['email'] ?? '';
        });
      }
    }
  }

  Future<void> _handleLogout() async {
    // Afficher une boîte de dialogue de confirmation
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.themeColors.bgSurface,
        title: Text(
          'Se déconnecter',
          style: TextStyle(color: context.themeColors.textPrimary),
        ),
        content: Text(
          'Êtes-vous sûr de vouloir vous déconnecter ?',
          style: TextStyle(color: context.themeColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Annuler',
              style: TextStyle(color: context.themeColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Se déconnecter',
              style: TextStyle(color: context.themeColors.colorDanger),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        // Afficher un indicateur de chargement
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Center(
            child: CircularProgressIndicator(
              color: context.themeColors.colorPrimary,
            ),
          ),
        );

        // Déconnecter l'utilisateur
        await AuthService.logout();

        // Nettoyer les données locales
        await UserManager().logout();

        if (mounted) {
          // Fermer l'indicateur de chargement
          Navigator.of(context).pop();

          // Fermer le dialogue de paramètres
          Navigator.of(context).pop();

          // Naviguer vers l'écran de connexion
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/login',
            (route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          // Fermer l'indicateur de chargement
          Navigator.of(context).pop();

          // Afficher un message d'erreur
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur lors de la déconnexion: $e'),
              backgroundColor: context.themeColors.colorDanger,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.themeColors.bgPrimary,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tabs (Visual only for now, or functioning if needed)
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: context.themeColors.bgSurface,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color:
                            context.themeColors.bgSurfaceDark, // Active looking
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Center(
                        child: Text(
                          'Sécurité',
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: const Center(
                        child: Text(
                          'Statut',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            Text(
              'Informations du compte',
              style: AppTheme.bodySmall.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Account Info List
            Container(
              decoration: BoxDecoration(
                color: context.themeColors.bgSurface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildListTile('Nom d\'utilisateur', _username,
                      showArrow: true),
                  const Divider(height: 1, color: AppTheme.backgroundDark),
                  _buildListTile('Nom d\'affichage', _name, showArrow: true),
                  const Divider(height: 1, color: AppTheme.backgroundDark),
                  _buildListTile('E-mail', _email, showArrow: true),
                  const Divider(height: 1, color: AppTheme.backgroundDark),
                  _buildListTile('Téléphone', '', showArrow: true),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Password Reset Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF2C2F33),
                    Color(0xFF23272A)
                  ], // Dark gradient base
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: context.themeColors.colorPrimary
                        .withValues(alpha: 0.5)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Decorative graphic placeholder
                      const Icon(Icons.key, color: AppTheme.primaryBlue, size: 40),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Oublie ton mot de passe',
                              style: TextStyle(
                                color: context.themeColors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Ajoute une clé d\'accès et connecte-toi d\'une seule pression.',
                              style: TextStyle(
                                  color: AppTheme.textSecondary, fontSize: 13),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.themeColors.colorPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text('Commencer'),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            Text(
              'Comment tu te connectes à ton compte',
              style: AppTheme.bodySmall.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            Container(
              decoration: BoxDecoration(
                color: context.themeColors.bgSurface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildListTile('Mot de passe', '', showArrow: true),
                  const Divider(height: 1, color: AppTheme.backgroundDark),
                  _buildListTile('Clés de sécurité', 'Ajouté : 0',
                      showArrow: true),
                  const Divider(height: 1, color: AppTheme.backgroundDark),
                  _buildListTile(
                      'Activer l\'application d\'authentification', '',
                      showArrow: true),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Bouton de déconnexion
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: context.themeColors.bgSurface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: InkWell(
                onTap: _handleLogout,
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.logout,
                        color: context.themeColors.colorDanger,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Se déconnecter',
                        style: TextStyle(
                          color: context.themeColors.colorDanger,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40), // Bottom padding
          ],
        ),
      ),
    );
  }

  Widget _buildListTile(String title, String subtitle,
      {bool showArrow = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (subtitle.isNotEmpty)
            Text(
              subtitle,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
              ),
            ),
          if (showArrow) ...[
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right,
                color: AppTheme.textSecondary, size: 20),
          ]
        ],
      ),
    );
  }
}
