import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tableronde_app/models/chat_model.dart';
import 'package:tableronde_app/utils/theme_extensions.dart';
import 'package:tableronde_app/data/sample_chats_data.dart';
import 'package:tableronde_app/providers/group_chat_provider.dart';
import 'package:tableronde_app/providers/profile_provider.dart';
import 'package:tableronde_app/screens/groups/group_creation_screen.dart';
import 'package:tableronde_app/screens/profiles/profile_screen.dart';
import 'package:tableronde_app/screens/users/all_users_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  late List<ChatModel> _allChats;
  List<ChatModel> _filteredChats = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Charger les conversations depuis le service de données
    _allChats = SampleChatsData.getSampleChats();
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

  /// Navigate to the profile screen for a user
  void _navigateToProfile(String userId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProfileScreen(userId: userId),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final groupProvider = context.watch<GroupChatProvider>();
    final groups = groupProvider.groups;
    
    return Scaffold(
      backgroundColor: context.themeColors.bgPrimary,
      appBar: AppBar(
        title: Text('Chats',
            style: TextStyle(color: context.themeColors.textPrimary)),
        backgroundColor: context.themeColors.bgSurface,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.people),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AllUsersScreen(),
                ),
              );
            },
            tooltip: 'Tous les membres',
          ),
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
            child: ListView(
              children: [
                // Afficher les groupes en premier
                if (groups.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      'Groupes',
                      style: TextStyle(
                        color: context.themeColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  ...groups.map((group) => _buildGroupTile(context, group)),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      'Conversations',
                      style: TextStyle(
                        color: context.themeColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
                // Afficher les conversations 1-to-1
                ..._filteredChats.map((chat) => _buildChatTile(context, chat)),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'chat_list_fab',
        onPressed: () {
          // Naviguer vers l'écran de création de groupe
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const GroupCreationScreen(),
            ),
          );
        },
        backgroundColor: context.themeColors.colorPrimary,
        child: const Icon(Icons.group_add, color: Colors.white),
      ),
    );
  }

  Widget _buildGroupTile(BuildContext context, group) {
    return Card(
      color: context.themeColors.bgSurface,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: Stack(
          children: [
            CircleAvatar(
              backgroundImage: (group.photoUrl != null && group.photoUrl!.isNotEmpty)
                  ? AssetImage(group.photoUrl!)
                  : null,
              child: (group.photoUrl == null || group.photoUrl!.isEmpty)
                  ? Icon(Icons.group, color: context.themeColors.textPrimary)
                  : null,
            ),
          ],
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                group.name,
                style: TextStyle(color: context.themeColors.textPrimary),
              ),
            ),
            Icon(
              Icons.group,
              size: 16,
              color: context.themeColors.textSecondary,
            ),
          ],
        ),
        subtitle: Text(
          group.lastMessage ?? '${group.members.length} membres',
          style: TextStyle(color: context.themeColors.textSecondary),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (group.lastMessageTime != null)
              Text(
                '${group.lastMessageTime!.hour}:${group.lastMessageTime!.minute.toString().padLeft(2, '0')}',
                style: TextStyle(
                  color: context.themeColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            if (group.unreadCount > 0) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: context.themeColors.colorPrimary,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${group.unreadCount}',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ]
          ],
        ),
        onTap: () {
          // Naviguer vers le chat de groupe
          Navigator.pushNamed(
            context,
            '/chat',
            arguments: ChatModel(
              id: group.id,
              name: group.name,
              avatarUrl: group.photoUrl,
              isOnline: false,
              lastMessage: group.lastMessage,
              lastMessageTime: group.lastMessageTime,
              unreadCount: group.unreadCount,
              bio: group.description,
            ),
          );
        },
        onLongPress: () {
          _showConversationMenu(context, ChatModel(
            id: group.id,
            name: group.name,
            avatarUrl: group.photoUrl,
            isOnline: false,
            lastMessage: group.lastMessage,
            lastMessageTime: group.lastMessageTime,
            unreadCount: group.unreadCount,
          ));
        },
      ),
    );
  }

  Widget _buildChatTile(BuildContext context, ChatModel chat) {
    return Card(
      color: context.themeColors.bgSurface,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: GestureDetector(
          onTap: () {
            // Navigate to profile for 1-to-1 chats
            final profileProvider = context.read<ProfileProvider>();
            final profile = profileProvider.getProfileByName(chat.name);
            if (profile != null) {
              _navigateToProfile(profile.id);
            }
          },
          child: Stack(
            children: [
              CircleAvatar(
                backgroundImage: (chat.avatarUrl != null && chat.avatarUrl!.isNotEmpty)
                    ? AssetImage(chat.avatarUrl!)
                    : null,
                child: (chat.avatarUrl == null || chat.avatarUrl!.isEmpty)
                    ? Text(chat.name[0],
                        style: TextStyle(color: context.themeColors.textPrimary))
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
        ),
        title: Text(chat.name,
            style: TextStyle(color: context.themeColors.textPrimary)),
        subtitle: Text(
          chat.lastMessage ?? '',
          style: TextStyle(color: context.themeColors.textSecondary),
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
                  color: context.themeColors.textSecondary, fontSize: 12),
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
                  style: const TextStyle(color: Colors.white, fontSize: 12),
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
  }
}
