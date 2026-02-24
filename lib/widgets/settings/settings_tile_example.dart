import 'package:flutter/material.dart';
import 'settings_tile.dart';

/// Exemple d'utilisation du widget SettingsTile
///
/// Ce fichier démontre les trois types d'interactions supportés :
/// - Toggle : Switch activable/désactivable
/// - Navigation : Chevron pour naviguer vers un autre écran
/// - Action : Action directe sans trailing widget
class SettingsTileExample extends StatefulWidget {
  const SettingsTileExample({super.key});

  @override
  State<SettingsTileExample> createState() => _SettingsTileExampleState();
}

class _SettingsTileExampleState extends State<SettingsTileExample> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SettingsTile Examples'),
      ),
      body: ListView(
        children: [
          // Section: Toggle Examples
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'TOGGLE EXAMPLES',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          SettingsTile(
            icon: Icons.notifications,
            title: 'Notifications',
            subtitle: 'Recevoir des notifications push',
            type: SettingsTileType.toggle,
            toggleValue: _notificationsEnabled,
            onToggleChanged: (value) {
              setState(() => _notificationsEnabled = value);
            },
          ),
          SettingsTile(
            icon: Icons.dark_mode,
            title: 'Mode sombre',
            subtitle: 'Activer le thème sombre',
            type: SettingsTileType.toggle,
            toggleValue: _darkModeEnabled,
            onToggleChanged: (value) {
              setState(() => _darkModeEnabled = value);
            },
          ),

          const Divider(height: 32),

          // Section: Navigation Examples
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'NAVIGATION EXAMPLES',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          SettingsTile(
            icon: Icons.palette,
            title: 'Apparence',
            subtitle: 'Personnaliser le thème',
            type: SettingsTileType.navigation,
            onTap: () {
              // Navigation vers l'écran d'apparence
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Navigation vers Apparence')),
              );
            },
          ),
          SettingsTile(
            icon: Icons.person,
            title: 'Profil',
            subtitle: 'Modifier vos informations',
            type: SettingsTileType.navigation,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Navigation vers Profil')),
              );
            },
          ),
          SettingsTile(
            icon: Icons.language,
            title: 'Langue',
            type: SettingsTileType.navigation,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Navigation vers Langue')),
              );
            },
          ),

          const Divider(height: 32),

          // Section: Action Examples
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'ACTION EXAMPLES',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          SettingsTile(
            icon: Icons.refresh,
            title: 'Actualiser',
            subtitle: 'Recharger les données',
            type: SettingsTileType.action,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Actualisation...')),
              );
            },
          ),
          SettingsTile(
            icon: Icons.logout,
            title: 'Déconnexion',
            type: SettingsTileType.action,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Déconnexion...')),
              );
            },
          ),

          const Divider(height: 32),

          // Section: Destructive Action Example
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'DESTRUCTIVE ACTION EXAMPLE',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          SettingsTile(
            icon: Icons.delete,
            title: 'Supprimer le compte',
            subtitle: 'Cette action est irréversible',
            type: SettingsTileType.action,
            isDestructive: true,
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Confirmer la suppression'),
                  content: const Text(
                    'Êtes-vous sûr de vouloir supprimer votre compte ?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Annuler'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Compte supprimé'),
                          ),
                        );
                      },
                      child: const Text(
                        'Supprimer',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          const Divider(height: 32),

          // Section: Custom Icon Color Example
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'CUSTOM ICON COLOR EXAMPLE',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          SettingsTile(
            icon: Icons.star,
            title: 'Favoris',
            subtitle: 'Vos éléments favoris',
            type: SettingsTileType.navigation,
            iconColor: Colors.amber,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Navigation vers Favoris')),
              );
            },
          ),
        ],
      ),
    );
  }
}
