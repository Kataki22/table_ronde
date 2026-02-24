import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/message_search_provider.dart';
import '../../models/chat_model.dart';
import 'filter_chips.dart';

/// Exemple d'utilisation du widget FilterChips
/// 
/// Démontre comment intégrer les chips de filtrage dans une interface
/// de recherche de messages avec le MessageSearchProvider.
class FilterChipsExample extends StatefulWidget {
  const FilterChipsExample({super.key});

  @override
  State<FilterChipsExample> createState() => _FilterChipsExampleState();
}

class _FilterChipsExampleState extends State<FilterChipsExample> {
  final TextEditingController _searchController = TextEditingController();
  final List<MessageModel> _mockMessages = [
    MessageModel(
      text: 'Bonjour, comment ça va ?',
      isSentByMe: false,
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      type: MessageType.text,
    ),
    MessageModel(
      text: 'Voici une photo',
      isSentByMe: true,
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      type: MessageType.image,
      attachmentUrl: 'https://example.com/photo.jpg',
    ),
    MessageModel(
      text: 'Regarde cette vidéo',
      isSentByMe: false,
      timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
      type: MessageType.video,
      attachmentUrl: 'https://example.com/video.mp4',
    ),
    MessageModel(
      text: 'Document important',
      isSentByMe: true,
      timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
      type: MessageType.document,
      attachmentUrl: 'https://example.com/doc.pdf',
      attachmentName: 'rapport.pdf',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    final provider = context.read<MessageSearchProvider>();
    provider.search(query, 'example-chat-id', _mockMessages);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exemple FilterChips'),
      ),
      body: Column(
        children: [
          // Barre de recherche
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher dans les messages...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          context.read<MessageSearchProvider>().clear();
                          setState(() {});
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                _performSearch(value);
                setState(() {});
              },
            ),
          ),

          // Chips de filtrage
          const FilterChips(),

          // Résultats de recherche
          Expanded(
            child: Consumer<MessageSearchProvider>(
              builder: (context, provider, child) {
                if (provider.query.isEmpty) {
                  return const Center(
                    child: Text('Entrez un terme de recherche'),
                  );
                }

                if (provider.results.isEmpty) {
                  return const Center(
                    child: Text('Aucun résultat trouvé'),
                  );
                }

                return Column(
                  children: [
                    // Compteur de résultats
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        '${provider.resultCount} résultat(s) trouvé(s)',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),

                    // Liste des résultats
                    Expanded(
                      child: ListView.builder(
                        itemCount: provider.results.length,
                        itemBuilder: (context, index) {
                          final result = provider.results[index];
                          final message = result.message;
                          return ListTile(
                            leading: Icon(_getIconForType(message.type)),
                            title: Text(
                              message.text.isNotEmpty
                                  ? message.text
                                  : _getTypeLabel(message.type),
                            ),
                            subtitle: Text(
                              _formatTimestamp(message.timestamp),
                            ),
                            trailing: Icon(
                              message.isSentByMe
                                  ? Icons.arrow_forward
                                  : Icons.arrow_back,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForType(MessageType type) {
    switch (type) {
      case MessageType.text:
        return Icons.text_fields;
      case MessageType.image:
        return Icons.image;
      case MessageType.video:
        return Icons.videocam;
      case MessageType.document:
        return Icons.description;
      case MessageType.voice:
        return Icons.mic;
      case MessageType.sticker:
        return Icons.emoji_emotions;
      case MessageType.gif:
        return Icons.gif;
    }
  }

  String _getTypeLabel(MessageType type) {
    switch (type) {
      case MessageType.text:
        return 'Message texte';
      case MessageType.image:
        return 'Image';
      case MessageType.video:
        return 'Vidéo';
      case MessageType.document:
        return 'Document';
      case MessageType.voice:
        return 'Message vocal';
      case MessageType.sticker:
        return 'Sticker';
      case MessageType.gif:
        return 'GIF';
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return 'Il y a ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Il y a ${difference.inHours} h';
    } else {
      return 'Il y a ${difference.inDays} j';
    }
  }
}
