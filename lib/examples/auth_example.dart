import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import '../widgets/auth/auth_guard.dart';

/// Exemple d'utilisation du système d'authentification
class AuthExample extends StatelessWidget {
  const AuthExample({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthGuard(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Exemple Authentification'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => _showLogoutDialog(context),
              tooltip: 'Se déconnecter',
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Informations utilisateur
              CurrentUserWidget(
                builder: (context, user) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundImage: user.avatarUrl != null
                                ? AssetImage(user.avatarUrl!)
                                : null,
                            child: user.avatarUrl == null
                                ? Text(
                                    user.name[0].toUpperCase(),
                                    style: const TextStyle(fontSize: 32),
                                  )
                                : null,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            user.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (user.username != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              user.username!,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                          const SizedBox(height: 8),
                          Text(
                            user.email,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          if (user.bio != null) ...[
                            const SizedBox(height: 12),
                            Text(
                              user.bio!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.circle,
                                size: 12,
                                color: user.isOnline ? Colors.green : Colors.grey,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                user.isOnline
                                    ? (user.currentActivity ?? 'En ligne')
                                    : 'Hors ligne',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Actions
              const Text(
                'Actions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Modifier le profil
              ElevatedButton.icon(
                onPressed: () => _showEditProfileDialog(context),
                icon: const Icon(Icons.edit),
                label: const Text('Modifier le profil'),
              ),
              const SizedBox(height: 8),

              // Changer le mot de passe
              ElevatedButton.icon(
                onPressed: () => _showChangePasswordDialog(context),
                icon: const Icon(Icons.lock),
                label: const Text('Changer le mot de passe'),
              ),
              const SizedBox(height: 8),

              // Changer le statut
              ElevatedButton.icon(
                onPressed: () => _showChangeStatusDialog(context),
                icon: const Icon(Icons.circle),
                label: const Text('Changer le statut'),
              ),
              const SizedBox(height: 24),

              // Informations de session
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Consumer<AuthProvider>(
                    builder: (context, authProvider, _) {
                      final user = authProvider.currentUser;
                      if (user == null) return const SizedBox.shrink();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Informations de session',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildInfoRow('ID', user.id),
                          _buildInfoRow('Email', user.email),
                          _buildInfoRow('Téléphone', user.phone ?? 'Non renseigné'),
                          _buildInfoRow(
                            'Membre depuis',
                            _formatDate(user.createdAt),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Voulez-vous vraiment vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<AuthProvider>().logout();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.currentUser!;
    
    final nameController = TextEditingController(text: user.name);
    final usernameController = TextEditingController(text: user.username);
    final bioController = TextEditingController(text: user.bio);
    final phoneController = TextEditingController(text: user.phone);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier le profil'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nom'),
              ),
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
              ),
              TextField(
                controller: bioController,
                decoration: const InputDecoration(labelText: 'Bio'),
                maxLines: 3,
              ),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Téléphone'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              final success = await authProvider.updateProfile(
                name: nameController.text,
                username: usernameController.text,
                bio: bioController.text,
                phone: phoneController.text,
              );

              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Profil mis à jour !'
                          : 'Erreur: ${authProvider.error}',
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Changer le mot de passe'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldPasswordController,
              decoration: const InputDecoration(
                labelText: 'Ancien mot de passe',
              ),
              obscureText: true,
            ),
            TextField(
              controller: newPasswordController,
              decoration: const InputDecoration(
                labelText: 'Nouveau mot de passe',
              ),
              obscureText: true,
            ),
            TextField(
              controller: confirmPasswordController,
              decoration: const InputDecoration(
                labelText: 'Confirmer le mot de passe',
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              if (newPasswordController.text != confirmPasswordController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Les mots de passe ne correspondent pas'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              final authProvider = context.read<AuthProvider>();
              final success = await authProvider.changePassword(
                oldPassword: oldPasswordController.text,
                newPassword: newPasswordController.text,
              );

              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Mot de passe changé !'
                          : 'Erreur: ${authProvider.error}',
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            child: const Text('Changer'),
          ),
        ],
      ),
    );
  }

  void _showChangeStatusDialog(BuildContext context) {
    final statusController = TextEditingController(
      text: context.read<AuthProvider>().currentUser?.currentActivity,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Changer le statut'),
        content: TextField(
          controller: statusController,
          decoration: const InputDecoration(
            labelText: 'Statut',
            hintText: 'Ex: En train de coder',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              final authProvider = context.read<AuthProvider>();
              final success = await authProvider.updateProfile(
                currentActivity: statusController.text,
              );

              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Statut mis à jour !'
                          : 'Erreur: ${authProvider.error}',
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }
}
