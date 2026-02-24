import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/chat_model.dart';
import '../../providers/message_search_provider.dart';
import '../../utils/theme_extensions.dart';
import 'chat_search_bar.dart';

/// Exemple d'utilisation du ChatSearchBar
/// 
/// Démontre comment intégrer la barre de recherche dans un AppBar
/// et comment gérer les interactions avec le MessageSearchProvider.
class ChatSearchBarExample extends StatefulWidget {
  const ChatSearchBarExample({super.key});

  @override
  State<ChatSearchBarExample> createState() => _ChatSearchBarExampleState();
}

class _ChatSearchBarExampleState extends State<ChatSearchBarExample> {
  bool _isSearchOpen = false;
  
  // Messages mockés pour la démo
  final List<MessageModel> _mockMessages = [
    MessageModel(
      id: '1',
      text: 'Bonjour, comment vas-tu ?',
      isSentByMe: false,
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: true,
      type: MessageType.text,
    ),
    MessageModel(
      id: '2',
      text: 'Très bien merci ! Et toi ?',
      isSentByMe: true,
      timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 55)),
      isRead: true,
      type: MessageType.text,
    ),
    MessageModel(
      id: '3',
      text: 'Super ! Tu as vu le nouveau film ?',
      isSentByMe: false,
      timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 50)),
      isRead: true,
      type: MessageType.text,
    ),
    MessageModel(
      id: '4',
      text: 'Oui, il était génial ! J\'ai adoré.',
      isSentByMe: true,
      timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 45)),
      isRead: true,
      type: MessageType.text,
    ),
    MessageModel(
      id: '5',
      text: 'On pourrait aller voir un autre film ce weekend ?',
      isSentByMe: false,
      timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 40)),
      isRead: true,
      type: MessageType.text,
    ),
  ];

  void _toggleSearch() {
    setState(() {
      _isSearchOpen = !_isSearchOpen;
    });
    
    // Si on ferme la recherche, effacer les résultats
    if (!_isSearchOpen) {
      context.read<MessageSearchProvider>().clear();
    }
  }

  void _handleSearchChanged(String query) {
    final searchProvider = context.read<MessageSearchProvider>();
    searchProvider.search(query, 'demo-chat', _mockMessages);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.themeColors.bgPrimary,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: context.themeColors.bgSurface,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: context.themeColors.textPrimary),
        onPressed: () => Navigator.pop(context),
      ),
      title: _isSearchOpen
          ? ChatSearchBar(
              isOpen: _isSearchOpen,
              onSearchChanged: _handleSearchChanged,
              onClose: _toggleSearch,
            )
          : Text(
              'ChatSearchBar Demo',
              style: TextStyle(
                color: context.themeColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
      actions: [
        if (!_isSearchOpen)
          IconButton(
            icon: Icon(Icons.search, color: context.themeColors.textPrimary),
            onPressed: _toggleSearch,
          ),
      ],
    );
  }

  Widget _buildBody() {
    return Consumer<MessageSearchProvider>(
      builder: (context, searchProvider, _) {
        final hasQuery = searchProvider.query.isNotEmpty;
        final hasResults = searchProvider.resultCount > 0;

        return Column(
          children: [
            // Informations sur la recherche
            if (hasQuery)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: context.themeColors.bgSurface,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recherche: "${searchProvider.query}"',
                      style: TextStyle(
                        color: context.themeColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      hasResults
                          ? '${searchProvider.resultCount} résultat(s) trouvé(s)'
                          : 'Aucun résultat trouvé',
                      style: TextStyle(
                        color: context.themeColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    if (hasResults) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_upward),
                            onPressed: searchProvider.navigateToPrevious,
                            color: context.themeColors.textPrimary,
                          ),
                          IconButton(
                            icon: const Icon(Icons.arrow_downward),
                            onPressed: searchProvider.navigateToNext,
                            color: context.themeColors.textPrimary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Résultat ${searchProvider.currentResultIndex + 1}/${searchProvider.resultCount}',
                            style: TextStyle(
                              color: context.themeColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            
            // Liste des messages
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _mockMessages.length,
                itemBuilder: (context, index) {
                  final message = _mockMessages[index];
                  final isHighlighted = hasResults &&
                      searchProvider.results.any(
                        (result) => result.message.id == message.id,
                      );

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isHighlighted
                          ? context.themeColors.colorPrimary.withOpacity(0.1)
                          : context.themeColors.bgSurface,
                      borderRadius: BorderRadius.circular(8),
                      border: isHighlighted
                          ? Border.all(
                              color: context.themeColors.colorPrimary,
                              width: 2,
                            )
                          : null,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          message.isSentByMe ? 'Vous' : 'Contact',
                          style: TextStyle(
                            color: context.themeColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          message.text,
                          style: TextStyle(
                            color: context.themeColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
