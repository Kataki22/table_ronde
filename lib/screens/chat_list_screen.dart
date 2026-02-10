import 'package:flutter/material.dart';
import 'package:tableronde_app/models/chat_model.dart';
import 'package:tableronde_app/utils/theme_extensions.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final List<ChatModel> _allChats = [
    ChatModel(
      id: '1',
      name: 'T4zor',
      lastMessage: 'Il me dit f*ck you mdr.',
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 2)),
      avatarUrl: 'assets/images/Avatar1.png',
      isOnline: true,
      unreadCount: 1,
    ),
    ChatModel(
      id: '2',
      name: 'Tk-Porky',
      lastMessage: 'Seigneur.💔🙌 !!',
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 4)),
      avatarUrl: 'assets/images/Avatar2.png',
      isOnline: false,
      unreadCount: 0,
    ),
    ChatModel(
      id: '3',
      name: 'AlistairJr',
      lastMessage: 'N\'oubliez pas de mettre à jour...',
      lastMessageTime: DateTime.now().subtract(const Duration(days: 1)),
      avatarUrl: '',
      isOnline: true,
      unreadCount: 3,
    ),
  ];

  List<ChatModel> _filteredChats = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredChats = _allChats;
    _searchController.addListener(_filterChats);
  }

  void _filterChats() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredChats = _allChats.where((chat) {
        return chat.name.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _showConversationMenu(BuildContext context, ChatModel chat) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.themeColors.bgSurfaceDark,
      builder: (builder) {
        return Wrap(
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.notifications_off,
                  color: context.themeColors.textSecondary),
              title: Text('Désactiver les notifications',
                  style: TextStyle(color: context.themeColors.textPrimary)),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement mute notifications
              },
            ),
            ListTile(
              leading:
                  Icon(Icons.block, color: context.themeColors.textSecondary),
              title: Text('Bloquer',
                  style: TextStyle(color: context.themeColors.textPrimary)),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement block user
              },
            ),
            ListTile(
              leading:
                  Icon(Icons.delete, color: context.themeColors.colorDanger),
              title: Text('Supprimer',
                  style: TextStyle(color: context.themeColors.colorDanger)),
              onTap: () {
                setState(() {
                  _allChats.remove(chat);
                  _filterChats();
                });
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.themeColors.bgPrimary,
      appBar: AppBar(
        title: Text('Chats',
            style: TextStyle(color: context.themeColors.textPrimary)),
        backgroundColor: context.themeColors.bgSurface,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              // Handle menu selection
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'mark_all_read',
                child: Text('Tous marqués comme lu'),
              ),
              const PopupMenuItem<String>(
                value: 'important',
                child: Text('Importants'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher...',
                hintStyle: TextStyle(color: context.themeColors.textSecondary),
                prefixIcon: Icon(Icons.search,
                    color: context.themeColors.textSecondary),
                filled: true,
                fillColor: context.themeColors.bgInput,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              style: TextStyle(color: context.themeColors.textPrimary),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredChats.length,
              itemBuilder: (context, index) {
                final chat = _filteredChats[index];
                return Card(
                  color: context.themeColors.bgSurface,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    leading: Stack(
                      children: [
                        CircleAvatar(
                          backgroundImage: (chat.avatarUrl != null &&
                                  chat.avatarUrl!.isNotEmpty)
                              ? AssetImage(chat.avatarUrl!)
                              : null,
                          child: (chat.avatarUrl == null ||
                                  chat.avatarUrl!.isEmpty)
                              ? Text(chat.name[0],
                                  style: TextStyle(
                                      color: context.themeColors.textPrimary))
                              : null,
                        ),
                        if (chat.isOnline)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: context.themeColors.colorOnline,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: context.themeColors.bgSurface,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    title: Text(chat.name,
                        style:
                            TextStyle(color: context.themeColors.textPrimary)),
                    subtitle: Text(
                      chat.lastMessage ?? '',
                      style:
                          TextStyle(color: context.themeColors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          chat.lastMessageTime != null
                              ? '${chat.lastMessageTime!.hour}:${chat.lastMessageTime!.minute.toString().padLeft(2, '0')}'
                              : '',
                          style: TextStyle(
                              color: context.themeColors.textSecondary,
                              fontSize: 12),
                        ),
                        if (chat.unreadCount > 0) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: context.themeColors.colorPrimary,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${chat.unreadCount}',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12),
                            ),
                          ),
                        ]
                      ],
                    ),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/chat',
                        arguments: chat,
                      );
                    },
                    onLongPress: () {
                      _showConversationMenu(context, chat);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Mock new chat dialog
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: context.themeColors.bgSurface,
              title: Text('Nouveau Chat',
                  style: TextStyle(color: context.themeColors.textPrimary)),
              content: Text('Fonctionnalité de nouveau chat à venir',
                  style: TextStyle(color: context.themeColors.textSecondary)),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Fermer'),
                ),
              ],
            ),
          );
        },
        backgroundColor: context.themeColors.colorPrimary,
        child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
      ),
    );
  }
}
