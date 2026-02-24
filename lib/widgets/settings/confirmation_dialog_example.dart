import 'package:flutter/material.dart';
import 'confirmation_dialog.dart';

/// Exemple d'utilisation du ConfirmationDialog
///
/// Ce fichier démontre comment utiliser le widget ConfirmationDialog
/// pour confirmer des actions importantes.
class ConfirmationDialogExample extends StatelessWidget {
  const ConfirmationDialogExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exemples de dialogues de confirmation'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Exemple 1: Action normale
              ElevatedButton(
                onPressed: () => _showNormalConfirmation(context),
                child: const Text('Quitter le groupe'),
              ),
              const SizedBox(height: 16),

              // Exemple 2: Action destructive
              ElevatedButton(
                onPressed: () => _showDestructiveConfirmation(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text('Supprimer la conversation'),
              ),
              const SizedBox(height: 16),

              // Exemple 3: Bloquer un utilisateur
              ElevatedButton(
                onPressed: () => _showBlockConfirmation(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                ),
                child: const Text('Bloquer l\'utilisateur'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Affiche une confirmation normale (quitter un groupe)
  void _showNormalConfirmation(BuildContext context) {
    ConfirmationDialog.show(
      context: context,
      title: 'Quitter le groupe',
      message: 'Êtes-vous sûr de vouloir quitter ce groupe ? '
          'Vous ne recevrez plus les messages du groupe.',
      confirmText: 'Quitter',
      isDestructive: false,
    ).then((confirmed) {
      if (confirmed == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vous avez quitté le groupe')),
        );
      }
    });
  }

  /// Affiche une confirmation destructive (supprimer une conversation)
  void _showDestructiveConfirmation(BuildContext context) {
    ConfirmationDialog.show(
      context: context,
      title: 'Supprimer la conversation',
      message: 'Cette action est irréversible. Tous les messages '
          'de cette conversation seront définitivement supprimés.',
      confirmText: 'Supprimer',
      isDestructive: true,
    ).then((confirmed) {
      if (confirmed == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Conversation supprimée')),
        );
      }
    });
  }

  /// Affiche une confirmation pour bloquer un utilisateur
  void _showBlockConfirmation(BuildContext context) {
    ConfirmationDialog.show(
      context: context,
      title: 'Bloquer cet utilisateur',
      message: 'Cet utilisateur ne pourra plus vous envoyer de messages '
          'ni voir votre profil.',
      confirmText: 'Bloquer',
      isDestructive: true,
    ).then((confirmed) {
      if (confirmed == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Utilisateur bloqué')),
        );
      }
    });
  }
}
