import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/feed_provider.dart';
import 'advanced_create_post_widget.dart';

/// Exemple d'intégration du widget de création de post avancé
/// 
/// Montre comment utiliser le AdvancedCreatePostWidget dans une application
class AdvancedCreatePostIntegrationExample extends StatelessWidget {
  const AdvancedCreatePostIntegrationExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer un post'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Widget de création de post avancé
            AdvancedCreatePostWidget(
              onPostCreated: () {
                // Callback appelé après la création du post
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Post créé avec succès !'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              placeholder: 'Partagez vos pensées...',
              enableScheduling: true,
              enablePolls: true,
              enableDrafts: true,
            ),
            
            // Espace supplémentaire pour le scroll
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

/// Version compacte pour utilisation dans un feed
class CompactCreatePostExample extends StatelessWidget {
  const CompactCreatePostExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: AdvancedCreatePostWidget(
        isCompact: true,
        onPostCreated: () {
          // Rafraîchir le feed après création
          context.read<FeedProvider>().refreshFeed();
        },
        placeholder: 'Quoi de neuf ?',
        enableScheduling: false, // Désactivé en mode compact
        enablePolls: true,
        enableDrafts: false, // Désactivé en mode compact
      ),
    );
  }
}

/// Version modale pour ouverture en popup
class ModalCreatePostExample extends StatelessWidget {
  const ModalCreatePostExample({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ModalCreatePostExample(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle pour glisser
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // En-tête
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Text(
                  'Créer un post',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          
          // Widget de création
          Expanded(
            child: SingleChildScrollView(
              child: AdvancedCreatePostWidget(
                onPostCreated: () {
                  Navigator.pop(context);
                  context.read<FeedProvider>().refreshFeed();
                },
                placeholder: 'Partagez quelque chose d\'intéressant...',
                enableScheduling: true,
                enablePolls: true,
                enableDrafts: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}