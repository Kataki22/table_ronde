import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/chat_model.dart';
import '../../providers/message_search_provider.dart';
import 'search_results_list.dart';
import 'chat_search_bar.dart';
import 'filter_chips.dart';

/// Exemple d'utilisation du widget SearchResultsList
/// 
/// Démontre comment intégrer la liste des résultats de recherche
/// avec la barre de recherche et les filtres dans une interface de chat.
class SearchResultsListExample extends StatefulWidget {
  const SearchResultsListExample({super.key});

  @override
  State<SearchResultsListExample> createState() =>
      _SearchResultsListExampleState();
}

class _SearchResultsListExampleState extends State<SearchResultsListExample> {
  bool _isSearchOpen = false;
  final List<MessageModel> _mockMessages = [];

  @override
  void initState() {
    super.initState();
    _generateMockMessages();
  }

  void _generateMockMessages() {
    // Générer des messages de test
    final now = DateTime.now();
    _mockMessages.addAll([
      MessageModel(
        text: 'Bonjour, comment vas-tu ?',
        isSentByMe: false,
        timestamp: now.subtract(const Duration(hours: 2)),
        type: MessageType.text,
      ),
      MessageModel(
        text: 'Je vais bien merci ! Et toi ?',
        isSentByMe: true,
        timestamp: now.subtract(const Duration(hours: 1, minutes: 55)),
        type: MessageType.text,
      ),
      MessageModel(
        text: 'Super ! Tu as vu le nouveau film ?',
        isSentByMe: false,
        timestamp: now.subtract(const Duration(hours: 1, minutes: 50)),
        type: MessageType.text,
      ),
      MessageModel(
        text: 'Oui, il était vraiment bien !',
        isSentByMe: true,
        timestamp: now.subtract(const Duration(hours: 1, minutes: 45)),
        type: MessageType.text,
      ),
      MessageModel(
        text: 'On pourrait aller voir un autre film ce weekend ?',
        isSentByMe: false,
        timestamp: now.subtract(const Duration(hours: 1, minutes: 40)),
        type: MessageType.text,
      ),
      MessageModel(
        text: 'Bonne idée ! Quel film tu proposes ?',
        isSentByMe: true,
        timestamp: now.subtract(const Duration(hours: 1, minutes: 35)),
        type: MessageType.text,
      ),
      MessageModel(
        text: 'Il y a un nouveau film d\'action qui vient de sortir',
        isSentByMe: false,
        timestamp: now.subtract(const Duration(hours: 1, minutes: 30)),
        type: MessageType.text,
      ),
      MessageModel(
        text: 'Parfait ! On se retrouve samedi ?',
        isSentByMe: true,
        timestamp: now.subtract(const Duration(hours: 1, minutes: 25)),
        type: MessageType.text,
      ),
      MessageModel(
        text: 'Oui, samedi ça me va bien',
        isSentByMe: false,
        timestamp: now.subtract(const Duration(hours: 1, minutes: 20)),
        type: MessageType.text,
      ),
      MessageModel(
        text: 'Super, à samedi alors !',
        isSentByMe: true,
        timestamp: now.subtract(const Duration(hours: 1, minutes: 15)),
        type: MessageType.text,
      ),
    ]);
  }

  void _handleSearchChanged(String query) {
    final provider = context.read<MessageSearchProvider>();
    provider.search(query, 'example-chat-id', _mockMessages);
  }

  void _handleResultTap(result) {
    // Naviguer vers le message dans le chat
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Navigation vers le message: "${result.message.text}"',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearchOpen
            ? ChatSearchBar(
                isOpen: _isSearchOpen,
                onSearchChanged: _handleSearchChanged,
                onClose: () {
                  setState(() {
                    _isSearchOpen = false;
                  });
                  context.read<MessageSearchProvider>().clear();
                },
              )
            : const Text('Recherche de messages'),
        actions: [
          if (!_isSearchOpen)
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                setState(() {
                  _isSearchOpen = true;
                });
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Filtres (affichés uniquement si la recherche est ouverte)
          if (_isSearchOpen)
            Consumer<MessageSearchProvider>(
              builder: (context, provider, _) {
                return Column(
                  children: [
                    const FilterChips(),
                    // Relancer la recherche quand les filtres changent
                    if (provider.query.isNotEmpty)
                      Builder(
                        builder: (context) {
                          // Relancer la recherche après le build
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            provider.search(
                              provider.query,
                              'example-chat-id',
                              _mockMessages,
                            );
                          });
                          return const SizedBox.shrink();
                        },
                      ),
                  ],
                );
              },
            ),

          // Liste des résultats
          Expanded(
            child: _isSearchOpen
                ? SearchResultsList(
                    onResultTap: _handleResultTap,
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Appuyez sur l\'icône de recherche',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'pour rechercher dans les messages',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

/// Point d'entrée pour tester l'exemple
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => MessageSearchProvider(),
      child: MaterialApp(
        title: 'SearchResultsList Example',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const SearchResultsListExample(),
      ),
    ),
  );
}
