import 'package:flutter/material.dart';
import 'media_gallery_bottom_sheet.dart';

/// Exemple d'utilisation de MediaGalleryBottomSheet
/// 
/// Ce fichier montre comment ouvrir la galerie de médias depuis un écran de chat
class MediaGalleryExample extends StatelessWidget {
  const MediaGalleryExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exemple Galerie Médias'),
        actions: [
          // Bouton pour ouvrir la galerie de médias
          IconButton(
            icon: const Icon(Icons.photo_library),
            onPressed: () => _openMediaGallery(context),
            tooltip: 'Médias partagés',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Exemple d\'utilisation de la galerie de médias',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _openMediaGallery(context),
              icon: const Icon(Icons.photo_library),
              label: const Text('Ouvrir la galerie'),
            ),
          ],
        ),
      ),
    );
  }

  /// Ouvre le bottom sheet de la galerie de médias
  void _openMediaGallery(BuildContext context) {
    // Note: MediaGalleryBottomSheet will call loadMediaForChat(chatId) when opened
    // No need to initialize the provider manually
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const MediaGalleryBottomSheet(
        // Utiliser un ID de chat de test depuis les données mockées
        chatId: 'chat_1',
      ),
    );
  }
}

/// Fonction helper pour ouvrir la galerie depuis n'importe où
/// 
/// Usage dans ChatScreen ou GroupChatScreen:
/// ```dart
/// IconButton(
///   icon: Icon(Icons.photo_library),
///   onPressed: () => showMediaGallery(context, chatId),
/// )
/// ```
void showMediaGallery(BuildContext context, String chatId) {
  // Note: MediaGalleryBottomSheet will call loadMediaForChat(chatId) when opened
  // The provider loads data on-demand, no manual initialization needed
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => MediaGalleryBottomSheet(
      chatId: chatId,
    ),
  );
}
