import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../utils/app_theme.dart';
import '../utils/theme_extensions.dart';
import '../models/chat_model.dart';
import '../data/sample_chats_data.dart';
import '../widgets/video_player_screen.dart';
import '../widgets/chat/message_media/sticker_message.dart';
import '../widgets/chat/message_media/image_message.dart';
import '../widgets/chat/message_media/video_message.dart';
import '../widgets/chat/message_media/document_message.dart';
import '../widgets/chat/message_media/voice_message.dart';
import '../widgets/chat/message_media/gif_message.dart';

import '../widgets/chat/message_bubble/deleted_message_bubble.dart';
import '../widgets/chat/input/gif_sticker_picker_sheet.dart';
import '../providers/group_chat_provider.dart';
import '../providers/auth_provider.dart';
import '../screens/groups/group_info_bottom_sheet.dart';
import '../providers/profile_provider.dart';
import '../screens/profiles/profile_screen.dart';
import '../providers/message_search_provider.dart';
import '../widgets/search/chat_search_bar.dart';
import '../widgets/search/search_results_list.dart';
import '../models/search/search_result.dart';
import '../providers/conversation_settings_provider.dart';
import '../screens/settings/conversation_settings_bottom_sheet.dart';
import '../screens/media/media_gallery_bottom_sheet.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // ── controllers ──────────────────────────────────────────────────────────
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isRecording = false;
  late final AudioRecorder _audioRecorder;
  Timer? _recordingTimer;
  int _recordingDuration = 0;

  // ── state ────────────────────────────────────────────────────────────────
  final List<MessageModel> _messages = [];
  late ChatModel _chat;
  bool _isTyping = false;
  bool _hasText = false;

  // LIMITATION: L'application utilise actuellement un userId hardcodé dans GroupChatProvider.
  // Pour permettre de se connecter avec différents comptes et répondre aux messages:
  // 1. Implémenter un système d'authentification complet (voir AUTH_GUIDE.md)
  // 2. Remplacer le userId hardcodé par l'utilisateur authentifié
  // 3. Persister les messages dans db.json via l'API
  // 4. Ajouter la gestion des sessions utilisateur

  // ── edit / reply state ───────────────────────────────────────────────────
  MessageModel? _replyTo; // message currently being replied to
  MessageModel? _editingMsg; // message currently being edited

  // ── search state ─────────────────────────────────────────────────────────
  bool _isSearchOpen = false;

  // ──────────────────────────────────────────────────────────────────────────
  // LIFECYCLE
  // ──────────────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _audioRecorder = AudioRecorder();
    _messageController.addListener(_onTextChanged);
    
    // Load data from API after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final groupProvider = context.read<GroupChatProvider>();
      // Load groups first
      groupProvider.loadGroups();
    });
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    _recordingTimer?.cancel();
    _messageController.removeListener(_onTextChanged);
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final routeArgs = ModalRoute.of(context)?.settings.arguments;

    // Fallback to first sample chat if arguments are missing (e.g. on web reload)
    final ChatModel args = (routeArgs is ChatModel)
        ? routeArgs
        : SampleChatsData.getSampleChats().first;

    _chat = ChatModel(
      id: args.id,
      name: args.name,
      avatarUrl: args.avatarUrl,
      isOnline: args.isOnline,
      lastMessage: args.lastMessage,
      lastMessageTime: args.lastMessageTime,
      unreadCount: args.unreadCount,
      bio: args.bio ?? 'Description de bio vide',
      phone: args.phone,
      username: args.username ?? '@kev',
      createdAt: args.createdAt ?? DateTime(2026, 2, 1),
      currentActivity: args.currentActivity ?? 'Joue à Chess.com',
    );

    // Load messages for this chat from API
    _loadMessagesFromApi();
  }

  /// Load messages from API for the current chat
  Future<void> _loadMessagesFromApi() async {
    final groupProvider = context.read<GroupChatProvider>();
    
    try {
      await groupProvider.loadMessages(_chat.id);
      // Les messages sont maintenant dans le provider, pas besoin de les copier localement
      // La liste _messages locale est maintenant synchronisée via le Consumer dans build()
      if (mounted) {
        _scrollToBottom();
      }
    } catch (e) {
      // Si l'API échoue, charger les données d'exemple en fallback
      if (mounted) {
        setState(() {
          _messages.clear();
          _messages.addAll(SampleChatsData.getSampleMessages('default'));
        });
      }
    }
  }

  void _onTextChanged() {
    final hasText = _messageController.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  // Helper to get correct image provider (asset vs network)
  ImageProvider? _getImageProvider(String? url) {
    if (url == null || url.isEmpty) return null;

    // Check if it's an asset path
    if (url.startsWith('assets/')) {
      return AssetImage(url);
    }

    // Check if it's a network URL
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return NetworkImage(url);
    }

    // Assume it's a file path if it starts with /
    if (url.startsWith('/')) {
      return FileImage(File(url));
    }

    // Default to asset
    return AssetImage(url);
  }

  // ──────────────────────────────────────────────────────────────────────────
  // SEND / EDIT ACTIONS
  // ──────────────────────────────────────────────────────────────────────────

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    if (_editingMsg != null) {
      setState(() {
        _editingMsg!.text = text;
        _editingMsg!.isEdited = true;
        _editingMsg = null;
      });
      _messageController.clear();
      return;
    }

    // Récupérer l'utilisateur actuel depuis AuthProvider
    final authProvider = context.read<AuthProvider>();
    final currentUser = authProvider.currentUser;
    
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur: Utilisateur non connecté')),
      );
      return;
    }

    // Créer le nouveau message avec tous les champs requis
    final newMessage = MessageModel(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      text: text,
      timestamp: DateTime.now(),
      isRead: false,
      replyToId: _replyTo?.id,
      chatId: _chat.id,
      senderId: currentUser.id,
      senderName: currentUser.name,
    );

    // Envoyer via le provider pour synchronisation avec l'API
    final groupProvider = context.read<GroupChatProvider>();
    groupProvider.sendMessage(_chat.id, newMessage);

    setState(() {
      _replyTo = null;
      _chat.lastMessage = text;
      _chat.lastMessageTime = DateTime.now();
    });
    _messageController.clear();
    _scrollToBottom();
  }

  /// Helper to get current user ID from AuthProvider
  String? _getCurrentUserId() {
    final authProvider = context.read<AuthProvider>();
    return authProvider.currentUser?.id;
  }

  void _deleteMessage(MessageModel msg) {
    setState(() {
      msg.isDeleted = true;
      msg.text = '';
    });
  }

  void _startEdit(MessageModel msg) {
    setState(() {
      _editingMsg = msg;
      _replyTo = null;
      _messageController.text = msg.text;
    });
  }

  void _startReply(MessageModel msg) {
    setState(() {
      _replyTo = msg;
      _editingMsg = null;
      _messageController.clear();
    });
    Future.microtask(() => FocusManager.instance.primaryFocus?.requestFocus());
  }

  void _cancelEditOrReply() {
    setState(() {
      _editingMsg = null;
      _replyTo = null;
      _messageController.clear();
    });
  }

  // ──────────────────────────────────────────────────────────────────────────
  // ATTACHMENTS
  // ──────────────────────────────────────────────────────────────────────────

  Future<void> _pickFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;
    _addAttachment(
      type: MessageType.image,
      url: file.path,
      name: file.name,
    );
  }

  Future<void> _pickFromCamera() async {
    final ImagePicker picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: ImageSource.camera);
    if (file == null) return;
    _addAttachment(
      type: MessageType.image,
      url: file.path,
      name: file.name,
    );
  }

  Future<void> _pickDocument() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(allowMultiple: false);
    if (result == null) return;
    final file = result.files.single;
    _addAttachment(
      type: MessageType.document,
      url: file.path!,
      name: file.name,
    );
  }

  Future<void> _pickVideo() async {
    final ImagePicker picker = ImagePicker();
    final XFile? file = await picker.pickVideo(source: ImageSource.gallery);
    if (file == null) return;
    _addAttachment(
      type: MessageType.video,
      url: file.path,
      name: file.name,
    );
  }

  void _addAttachment({
    required MessageType type,
    required String url,
    required String name,
  }) {
    if (!mounted) return;
    
    // Get current user
    final authProvider = context.read<AuthProvider>();
    final currentUser = authProvider.currentUser;
    
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur: Utilisateur non connecté')),
      );
      return;
    }
    
    setState(() {
      _messages.add(
        MessageModel(
          text: name,
          timestamp: DateTime.now(),
          type: type,
          attachmentUrl: url,
          attachmentName: name,
          replyToId: _replyTo?.id,
          chatId: _chat.id,
          senderId: currentUser.id,
          senderName: currentUser.name,
        ),
      );

      _replyTo = null;
      _chat.lastMessage = type == MessageType.image
          ? 'Image'
          : (type == MessageType.video
              ? 'Vidéo'
              : (type == MessageType.document ? 'Document' : name));
      _chat.lastMessageTime = DateTime.now();
    });
    _scrollToBottom();
  }

  // ──────────────────────────────────────────────────────────────────────────
  // USER PROFILE
  // ──────────────────────────────────────────────────────────────────────────

  /// Navigate to the full profile screen for a user
  void _navigateToProfile(String userId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProfileScreen(userId: userId),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // SEARCH
  // ──────────────────────────────────────────────────────────────────────────

  void _toggleSearch() {
    setState(() {
      _isSearchOpen = !_isSearchOpen;
    });

    // Si on ferme la recherche, effacer les résultats
    if (!_isSearchOpen) {
      final searchProvider = context.read<MessageSearchProvider>();
      searchProvider.clear();
    }
  }

  void _handleSearchChanged(String query) {
    final searchProvider = context.read<MessageSearchProvider>();
    final groupProvider = context.read<GroupChatProvider>();
    final messages = groupProvider.getGroupMessages(_chat.id);
    final displayMessages = messages.isNotEmpty ? messages : _messages;
    searchProvider.search(query, _chat.id, displayMessages);
  }

  void _handleSearchResultTap(SearchResult result) {
    // Fermer la recherche
    setState(() {
      _isSearchOpen = false;
    });

    // Effacer les résultats
    final searchProvider = context.read<MessageSearchProvider>();
    searchProvider.clear();

    // Scroller vers le message
    final messageIndex = result.matchIndex;
    final groupProvider = context.read<GroupChatProvider>();
    final messages = groupProvider.getGroupMessages(_chat.id);
    final displayMessages = messages.isNotEmpty ? messages : _messages;
    
    if (messageIndex >= 0 && messageIndex < displayMessages.length) {
      // Calculer la position approximative dans la liste
      final itemHeight = 100.0; // Hauteur approximative d'un message
      final targetPosition = messageIndex * itemHeight;

      // Scroller vers la position
      _scrollController.animateTo(
        targetPosition,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // SETTINGS
  // ──────────────────────────────────────────────────────────────────────────

  void _openSettings() {
    ConversationSettingsBottomSheet.show(
      context: context,
      chatId: _chat.id,
      chatName: _chat.name,
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // MEDIA GALLERY
  // ──────────────────────────────────────────────────────────────────────────

  void _openMediaGallery() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => MediaGalleryBottomSheet(
        chatId: _chat.id,
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // SCROLL
  // ──────────────────────────────────────────────────────────────────────────

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ──────────────────────────────────────────────────────────────────────────
  // VIDEO PLAYBACK
  // ──────────────────────────────────────────────────────────────────────────

  void _playVideo(String videoPath) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoPlayerScreen(
          videoPath: videoPath,
          videoName: videoPath.split('/').last,
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // BUILD – root
  // ──────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // Get the wallpaper setting for this conversation
    final settingsProvider = context.watch<ConversationSettingsProvider>();
    final settings = settingsProvider.getSettings(_chat.id);
    final wallpaperUrl = settings.wallpaperUrl;

    // Watch GroupChatProvider for loading and error states
    final groupProvider = context.watch<GroupChatProvider>();
    final isLoading = groupProvider.isLoading;
    final error = groupProvider.error;
    
    // Utiliser les messages du provider au lieu de la liste locale
    final messages = groupProvider.getGroupMessages(_chat.id);
    // Fallback sur la liste locale si le provider n'a pas de messages (pour compatibilité)
    final displayMessages = messages.isNotEmpty ? messages : _messages;

    return Scaffold(
      backgroundColor:
          wallpaperUrl == null ? context.themeColors.bgPrimary : null,
      body: Container(
        decoration: wallpaperUrl != null
            ? BoxDecoration(
                image: DecorationImage(
                  image: _getImageProvider(wallpaperUrl)!,
                  fit: BoxFit.cover,
                ),
              )
            : null,
        child: Column(
          children: [
            // AppBar as a custom widget since we need it inside the Container
            _buildCustomAppBar(),

            Expanded(
              child: Stack(
                children: [
                  // Loading state
                  if (isLoading && displayMessages.isEmpty)
                    Center(
                      child: CircularProgressIndicator(
                        color: context.themeColors.colorPrimary,
                      ),
                    )
                  // Error state
                  else if (error != null && displayMessages.isEmpty)
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: context.themeColors.colorDanger,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Erreur de chargement',
                            style: AppTheme.bodyLarge.copyWith(
                              color: context.themeColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Text(
                              error,
                              style: AppTheme.bodyMedium.copyWith(
                                color: context.themeColors.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () => _loadMessagesFromApi(),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Réessayer'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: context.themeColors.colorPrimary,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    )
                  // Chat principal
                  else
                    Column(
                      children: [
                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: () => _loadMessagesFromApi(),
                            color: context.themeColors.colorPrimary,
                            child: ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 16),
                              itemCount: displayMessages.length,
                              itemBuilder: (context, index) {
                                final message = displayMessages[index];
                                final showDateSep = index == 0 ||
                                    !_isSameDay(message.timestamp,
                                        displayMessages[index - 1].timestamp);
                                return Column(
                                  children: [
                                    if (showDateSep)
                                      _buildDateSeparator(message.timestamp),
                                    _buildMessageBubble(message),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                        if (_replyTo != null || _editingMsg != null)
                          _buildReplyOrEditBar(),
                        _buildMessageInput(),
                      ],
                    ),

                  // Overlay de résultats de recherche
                  if (_isSearchOpen)
                    Positioned.fill(
                      child: Container(
                        color: context.themeColors.bgPrimary,
                        child: SearchResultsList(
                          onResultTap: _handleSearchResultTap,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Custom AppBar widget to use inside the Container
  Widget _buildCustomAppBar() {
    return Container(
      color: context.themeColors.bgSurface,
      child: SafeArea(
        bottom: false,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          constraints: const BoxConstraints(minHeight: 56),
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back,
                    color: context.themeColors.textPrimary),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: _isSearchOpen
                    ? ChatSearchBar(
                        isOpen: _isSearchOpen,
                        onSearchChanged: _handleSearchChanged,
                        onClose: _toggleSearch,
                      )
                    : InkWell(
                        onTap: () {
                          // Navigate to profile screen for 1-to-1 chats
                          final groupProvider =
                              context.read<GroupChatProvider>();
                          final group = groupProvider.getGroupById(_chat.id);

                          if (group == null) {
                            // It's a 1-to-1 chat, navigate to profile
                            // Try to find the user ID from the profile provider
                            final profileProvider =
                                context.read<ProfileProvider>();
                            final profile =
                                profileProvider.getProfileByName(_chat.name);
                            if (profile != null) {
                              _navigateToProfile(profile.id);
                            }
                          } else {
                            // It's a group, show group info
                            GroupInfoBottomSheet.show(context, group);
                          }
                        },
                        child: Row(
                          children: [
                            Builder(
                              builder: (context) {
                                // Get profile ID for hero tag
                                final profileProvider =
                                    context.read<ProfileProvider>();
                                final profile = profileProvider
                                    .getProfileByName(_chat.name);
                                final heroTag = profile != null
                                    ? 'profile_avatar_${profile.id}'
                                    : 'profile_avatar_${_chat.id}';

                                return Stack(
                                  children: [
                                    Hero(
                                      tag: heroTag,
                                      child: CircleAvatar(
                                        backgroundImage:
                                            _getImageProvider(_chat.avatarUrl),
                                        child: _chat.avatarUrl == null ||
                                                _chat.avatarUrl!.isEmpty
                                            ? Text(_chat.name[0])
                                            : null,
                                        radius: 20,
                                      ),
                                    ),
                                    if (_chat.isOnline)
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: Container(
                                          width: 12,
                                          height: 12,
                                          decoration: BoxDecoration(
                                            color:
                                                context.themeColors.colorOnline,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                color: context
                                                    .themeColors.bgSurface,
                                                width: 2),
                                          ),
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          _chat.name,
                                          style: AppTheme.bodyLarge.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color:
                                                context.themeColors.textPrimary,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        if (_isTyping)
                                          Text(
                                            'typing...',
                                            style: AppTheme.bodySmall.copyWith(
                                              color: context
                                                  .themeColors.colorPrimary,
                                              fontStyle: FontStyle.italic,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          )
                                        else
                                          Text(
                                            _chat.isOnline
                                                ? 'online'
                                                : 'last seen recently',
                                            style: AppTheme.bodySmall.copyWith(
                                              color: context
                                                  .themeColors.textSecondary,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(Icons.chevron_right, size: 20),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
              // ── Bouton appel dépliable (1-to-1 uniquement) ───────────────
              if (!_isSearchOpen)
                Builder(
                  builder: (context) {
                    final groupProvider = context.watch<GroupChatProvider>();
                    final group = groupProvider.getGroupById(_chat.id);
                    if (group != null) return const SizedBox.shrink();

                    return PopupMenuButton<String>(
                      tooltip: 'Appeler',
                      icon: Icon(
                        Icons.call,
                        color: context.themeColorsNoWatch.colorPrimary,
                      ),
                      color: context.themeColorsNoWatch.bgSurface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onSelected: (value) {
                        if (value == 'voice') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Appel vocal (Simulation)')),
                          );
                        } else if (value == 'video') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Appel vidéo (Simulation)')),
                          );
                        }
                      },
                      itemBuilder: (menuCtx) => [
                        PopupMenuItem(
                          value: 'voice',
                          child: Row(
                            children: [
                              Icon(Icons.phone,
                                  color:
                                      menuCtx.themeColorsNoWatch.colorPrimary,
                                  size: 20),
                              const SizedBox(width: 12),
                              Text('Appel vocal',
                                  style: TextStyle(
                                      color: menuCtx
                                          .themeColorsNoWatch.textPrimary)),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'video',
                          child: Row(
                            children: [
                              Icon(Icons.videocam,
                                  color:
                                      menuCtx.themeColorsNoWatch.colorPrimary,
                                  size: 20),
                              const SizedBox(width: 12),
                              Text('Appel vidéo',
                                  style: TextStyle(
                                      color: menuCtx
                                          .themeColorsNoWatch.textPrimary)),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),

              // ── Menu 3 points ─────────────────────────────────────────────
              if (!_isSearchOpen)
                Builder(
                  builder: (context) {
                    final groupProvider = context.watch<GroupChatProvider>();
                    final group = groupProvider.getGroupById(_chat.id);

                    return PopupMenuButton<String>(
                      tooltip: 'Plus d\'options',
                      icon: Icon(
                        Icons.more_vert,
                        color: context.themeColorsNoWatch.textPrimary,
                      ),
                      color: context.themeColorsNoWatch.bgSurface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onSelected: (value) {
                        switch (value) {
                          case 'search':
                            _toggleSearch();
                            break;
                          case 'gallery':
                            _openMediaGallery();
                            break;
                          case 'settings':
                            _openSettings();
                            break;
                          case 'group_info':
                            if (group != null) {
                              GroupInfoBottomSheet.show(context, group);
                            }
                            break;
                        }
                      },
                      itemBuilder: (menuCtx) {
                        // Récupère le groupe depuis le contexte valide du popup
                        final grp = context
                            .read<GroupChatProvider>()
                            .getGroupById(_chat.id);
                        return [
                          PopupMenuItem(
                            value: 'search',
                            child: Row(
                              children: [
                                Icon(Icons.search,
                                    color:
                                        menuCtx.themeColorsNoWatch.textPrimary,
                                    size: 20),
                                const SizedBox(width: 12),
                                Text('Rechercher',
                                    style: TextStyle(
                                        color: menuCtx
                                            .themeColorsNoWatch.textPrimary)),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'gallery',
                            child: Row(
                              children: [
                                Icon(Icons.photo_library_outlined,
                                    color:
                                        menuCtx.themeColorsNoWatch.textPrimary,
                                    size: 20),
                                const SizedBox(width: 12),
                                Text('Galerie de médias',
                                    style: TextStyle(
                                        color: menuCtx
                                            .themeColorsNoWatch.textPrimary)),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'settings',
                            child: Row(
                              children: [
                                Icon(Icons.settings_outlined,
                                    color:
                                        menuCtx.themeColorsNoWatch.textPrimary,
                                    size: 20),
                                const SizedBox(width: 12),
                                Text('Paramètres',
                                    style: TextStyle(
                                        color: menuCtx
                                            .themeColorsNoWatch.textPrimary)),
                              ],
                            ),
                          ),
                          if (grp != null)
                            PopupMenuItem(
                              value: 'group_info',
                              child: Row(
                                children: [
                                  Icon(Icons.info_outline,
                                      color: menuCtx
                                          .themeColorsNoWatch.textPrimary,
                                      size: 20),
                                  const SizedBox(width: 12),
                                  Text('Infos du groupe',
                                      style: TextStyle(
                                          color: menuCtx
                                              .themeColorsNoWatch.textPrimary)),
                                ],
                              ),
                            ),
                        ];
                      },
                    );
                  },
                ),
              const SizedBox(width: 4),
            ],
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // REPLY / EDIT BAR
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildReplyOrEditBar() {
    final isReply = _replyTo != null;
    final msg = isReply ? _replyTo! : _editingMsg!;
    final currentUserId = _getCurrentUserId() ?? '';

    return Container(
      color: context.themeColors.bgSurface,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 42,
            decoration: BoxDecoration(
              color: isReply
                  ? context.themeColors.colorPrimary
                  : context.themeColors.colorWarning,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isReply
                      ? 'Replying to ${msg.isSentBy(currentUserId) ? "you" : _chat.name}'
                      : 'Editing message',
                  style: TextStyle(
                    color: isReply
                        ? context.themeColors.colorPrimary
                        : context.themeColors.colorWarning,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  msg.isDeleted
                      ? 'This message was deleted'
                      : (msg.text.isNotEmpty ? msg.text : _typeLabel(msg.type)),
                  style: TextStyle(
                      color: context.themeColors.textSecondary, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _cancelEditOrReply,
            child: Icon(Icons.close,
                color: context.themeColors.textSecondary, size: 22),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // DATE SEPARATOR
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildDateSeparator(DateTime date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: context.themeColors.bgSurface.withOpacity(0.8),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _formatDate(date),
            style: AppTheme.bodySmall.copyWith(
              color: context.themeColors.textSecondary,
              fontSize: 11,
            ),
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // MESSAGE BUBBLE
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildMessageBubble(MessageModel message) {
    if (message.isDeleted) return _buildDeletedBubble(message);

    final currentUserId = _getCurrentUserId() ?? '';
    final isSentByMe = message.isSentBy(currentUserId);

    // Note: Le message de réponse (repliedMsg) pourrait être affiché ici
    // mais n'est pas encore implémenté dans l'UI actuelle

    return Align(
      alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment:
              isSentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            if (!isSentByMe) ...[
              GestureDetector(
                onTap: () {
                  // Navigate to profile screen
                  final profileProvider = context.read<ProfileProvider>();
                  final profile = profileProvider.getProfileByName(_chat.name);
                  if (profile != null) {
                    _navigateToProfile(profile.id);
                  }
                },
                child: Builder(
                  builder: (context) {
                    // Get profile ID for hero tag
                    final profileProvider = context.read<ProfileProvider>();
                    final profile =
                        profileProvider.getProfileByName(_chat.name);
                    final heroTag = profile != null
                        ? 'profile_avatar_${profile.id}'
                        : 'profile_avatar_${_chat.id}';

                    return Stack(
                      children: [
                        Hero(
                          tag: heroTag,
                          child: CircleAvatar(
                            backgroundImage: _getImageProvider(_chat.avatarUrl),
                            child: _chat.avatarUrl == null ||
                                    _chat.avatarUrl!.isEmpty
                                ? Text(_chat.name[0])
                                : null,
                            radius: 18,
                          ),
                        ),
                        if (_chat.isOnline)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: context.themeColors.colorOnline,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: context.themeColors.bgPrimary,
                                    width: 2),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Column(
                crossAxisAlignment: isSentByMe
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  if (!isSentByMe)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 3, left: 10),
                      child: Text(
                        _chat.name,
                        style: AppTheme.bodySmall.copyWith(
                          color: context.themeColors.textSecondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  GestureDetector(
                    onLongPress: () => _showMessageOptions(message),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.65,
                          ),
                          decoration: (message.type == MessageType.sticker ||
                                  message.type == MessageType.gif ||
                                  message.type == MessageType.image ||
                                  message.type == MessageType.video)
                              ? null
                              : BoxDecoration(
                                  color: isSentByMe
                                      ? context.themeColors.msgBubbleSent
                                      : context.themeColors.msgBubbleReceived,
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(18),
                                    topRight: const Radius.circular(18),
                                    bottomLeft: isSentByMe
                                        ? const Radius.circular(18)
                                        : const Radius.circular(4),
                                    bottomRight: isSentByMe
                                        ? const Radius.circular(4)
                                        : const Radius.circular(18),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          const Color.fromRGBO(0, 0, 0, 0.15),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Conditional padding: no padding for media types
                              (message.type == MessageType.sticker ||
                                      message.type == MessageType.gif ||
                                      message.type == MessageType.image ||
                                      message.type == MessageType.video)
                                  ? _buildBubbleBody(message)
                                  : Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 8),
                                      child: _buildBubbleBody(message),
                                    ),

                              Padding(
                                padding: (message.type == MessageType.sticker ||
                                        message.type == MessageType.gif ||
                                        message.type == MessageType.image ||
                                        message.type == MessageType.video)
                                    ? const EdgeInsets.all(
                                        4) // Small padding for media
                                    : const EdgeInsets.only(
                                        left: 14, right: 14, bottom: 6),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Container(
                                      padding: (message.type ==
                                                  MessageType.sticker ||
                                              message.type == MessageType.gif ||
                                              message.type ==
                                                  MessageType.image ||
                                              message.type == MessageType.video)
                                          ? const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 2)
                                          : EdgeInsets.zero,
                                      decoration: (message.type ==
                                                  MessageType.sticker ||
                                              message.type == MessageType.gif ||
                                              message.type ==
                                                  MessageType.image ||
                                              message.type == MessageType.video)
                                          ? BoxDecoration(
                                              color: context
                                                  .themeColors.bgSurfaceDark
                                                  .withOpacity(0.7),
                                              borderRadius:
                                                  BorderRadius.circular(12))
                                          : null,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (message.isEdited)
                                            Text(
                                              'edited ',
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: context
                                                    .themeColors.textInverse
                                                    .withOpacity(0.55),
                                                fontStyle: FontStyle.italic,
                                              ),
                                            ),
                                          Text(
                                            _formatTime(message.timestamp),
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: context
                                                  .themeColors.textSecondary
                                                  .withOpacity(0.7),
                                            ),
                                          ),
                                          if (isSentByMe) ...[
                                            const SizedBox(width: 4),
                                            Icon(
                                              message.isRead
                                                  ? Icons.done_all
                                                  : Icons.done,
                                              size: 15,
                                              color: message.isRead
                                                  ? context
                                                      .themeColors.colorPrimary
                                                      .withOpacity(0.8)
                                                  : context
                                                      .themeColors.textDisabled
                                                      .withOpacity(0.9),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (message.reactions.isNotEmpty)
                          Positioned(
                            bottom: -10,
                            right: isSentByMe ? null : -10,
                            left: isSentByMe ? -10 : null,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: context.themeColors.bgSurfaceDark,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: context.themeColors.borderDark),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: message.reactions.entries.map((e) {
                                  return Text('${e.key} ${e.value}',
                                      style: TextStyle(
                                          fontSize: 10,
                                          color: context
                                              .themeColors.textSecondary));
                                }).toList(),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (isSentByMe) const SizedBox(width: 6),
          ],
        ),
      ),
    );
  }

  Widget _buildDeletedBubble(MessageModel message) {
    return DeletedMessageBubble(message: message);
  }

  Widget _buildBubbleBody(MessageModel msg) {
    switch (msg.type) {
      case MessageType.sticker:
        return _buildStickerBody(msg);
      case MessageType.gif:
        return _buildGifBody(msg);
      case MessageType.image:
        return _buildImageBody(msg);
      case MessageType.video:
        return _buildVideoBody(msg);
      case MessageType.document:
        return _buildDocumentBody(msg);
      case MessageType.voice:
        return _buildVoiceBody(msg);
      case MessageType.text:
        return Text(
          msg.text,
          style: TextStyle(
              color: context.themeColors.textPrimary,
              fontSize: 15,
              height: 1.4),
        );
    }
  }

  Widget _buildStickerBody(MessageModel msg) {
    return StickerMessage(message: msg);
  }

  Widget _buildGifBody(MessageModel msg) {
    return GifMessage(message: msg);
  }

  Widget _buildImageBody(MessageModel msg) {
    return ImageMessage(message: msg);
  }

  Widget _buildVideoBody(MessageModel msg) {
    return VideoMessage(
      message: msg,
      onVideoTap: _playVideo,
    );
  }

  Widget _buildDocumentBody(MessageModel msg) {
    final currentUserId = _getCurrentUserId() ?? '';
    return DocumentMessage(
      message: msg,
      isSentByMe: msg.isSentBy(currentUserId),
    );
  }

  Widget _buildVoiceBody(MessageModel msg) {
    return VoiceMessage(message: msg);
  }

  // ──────────────────────────────────────────────────────────────────────────
  // LONG-PRESS CONTEXT MENU
  // ──────────────────────────────────────────────────────────────────────────

  void _showMessageOptions(MessageModel msg) {
    if (msg.isDeleted) return;

    final currentUserId = _getCurrentUserId() ?? '';
    final isSentByMe = msg.isSentBy(currentUserId);

    final actions = <_OptionItem>[
      _OptionItem(Icons.reply, 'Répondre', () => _startReply(msg)),
      _OptionItem(Icons.copy, 'Copier', () {
        Clipboard.setData(ClipboardData(text: msg.text));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Copié'), duration: Duration(seconds: 1)),
        );
      }),
    ];

    if (isSentByMe && msg.type == MessageType.text) {
      actions.add(_OptionItem(Icons.edit, 'Modifier', () => _startEdit(msg)));
    }
    if (isSentByMe) {
      actions.add(_OptionItem(
          Icons.delete_outline, 'Supprimer', () => _deleteMessage(msg),
          isDestructive: true));
    }

    // Add Reaction Row to the top of the sheet content in builder, but for now let's just add it to the actions if possible or as a header.
    // Better to modify the builder:

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.textSecondary.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                // Reaction Row
                SizedBox(
                  height: 50,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: ['👍', '❤️', '😂', '😮', '😢', '😡'].map((emoji) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.pop(ctx);
                          setState(() {
                            final current = msg.reactions[emoji] ?? 0;
                            msg.reactions[emoji] = current + 1;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: const BoxDecoration(
                            color: AppTheme.surfaceDark,
                            shape: BoxShape.circle,
                          ),
                          child:
                              Text(emoji, style: const TextStyle(fontSize: 24)),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const Divider(color: Colors.white24, height: 24),
                ...actions.map((action) => ListTile(
                      leading: Icon(
                        action.icon,
                        color: action.isDestructive
                            ? Colors.redAccent
                            : Colors.white70,
                      ),
                      title: Text(
                        action.label,
                        style: TextStyle(
                          color: action.isDestructive
                              ? Colors.redAccent
                              : Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(ctx);
                        action.onTap();
                      },
                    )),
              ],
            ),
          ),
        );
      },
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // INPUT ROW
  // ──────────────────────────────────────────────────────────────────────────

  void _sendMediaMessage(String path, MessageType type) {
    // Get current user
    final authProvider = context.read<AuthProvider>();
    final currentUser = authProvider.currentUser;
    
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur: Utilisateur non connecté')),
      );
      return;
    }
    
    setState(() {
      _messages.add(
        MessageModel(
          text: type == MessageType.sticker ? 'Sticker' : 'GIF',
          timestamp: DateTime.now(),
          type: type,
          stickerUrl: type == MessageType.sticker ? path : null,
          gifUrl: type == MessageType.gif ? path : null,
          isRead: false,
          chatId: _chat.id,
          senderId: currentUser.id,
          senderName: currentUser.name,
        ),
      );
      _chat.lastMessage = type == MessageType.sticker ? 'Sticker' : 'GIF';
      _chat.lastMessageTime = DateTime.now();
    });
    _scrollToBottom();
  }

  Widget _buildMessageInput() {
    final bool hasText = _messageController.text.trim().isNotEmpty;

    if (_isRecording) {
      return _buildRecordingInput();
    }

    return Container(
      color: context.themeColors.bgSurface,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: context.themeColors.bgInput,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: Icon(Icons.emoji_emotions,
                          color: context.themeColors.colorPrimary),
                      onPressed: _showPlusMenu,
                    ),
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        style:
                            TextStyle(color: context.themeColors.textPrimary),
                        minLines: 1,
                        maxLines: 5,
                        textInputAction: TextInputAction.newline,
                        decoration: InputDecoration(
                          hintText: 'Message',
                          hintStyle: TextStyle(
                              color: context.themeColors.textSecondary),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          isDense: true,
                        ),
                      ),
                    ),
                    IconButton(
                        icon: Icon(Icons.add_circle_outline,
                            color: context.themeColors.textSecondary),
                        onPressed: _showAttachmentOptions),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: hasText
                  ? _sendMessage
                  : null, // Disable tap if no text (mic is handled by long press)
              onLongPress: hasText ? null : _startRecording,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: context.themeColors.colorPrimary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  hasText ? Icons.send : Icons.mic,
                  color: context.themeColors.textInverse,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPlusMenu() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => GifStickerPickerSheet(
        messageController: _messageController,
        onGifSelected: (gifUrl) {
          Navigator.pop(context);
          _sendMediaMessage(gifUrl, MessageType.gif);
        },
        onStickerSelected: (stickerPath) {
          Navigator.pop(context);
          _sendMediaMessage(stickerPath, MessageType.sticker);
        },
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // ATTACHMENT BOTTOM SHEET
  // ──────────────────────────────────────────────────────────────────────────

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.themeColorsNoWatch.bgSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.themeColors.textSecondary.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _attachOption(Icons.photo_library, 'Galerie', Colors.purple,
                        () {
                      Navigator.pop(ctx);
                      _pickFromGallery();
                    }),
                    _attachOption(Icons.camera_alt, 'Appareil', Colors.pink,
                        () {
                      Navigator.pop(ctx);
                      _pickFromCamera();
                    }),
                    _attachOption(
                        Icons.insert_drive_file, 'Document', Colors.blue, () {
                      Navigator.pop(ctx);
                      _pickDocument();
                    }),
                    _attachOption(Icons.video_library, 'Vidéo', Colors.green,
                        () {
                      Navigator.pop(ctx);
                      _pickVideo();
                    }),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _attachOption(
      IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(29),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 8),
          Text(label,
              style: AppTheme.bodySmall.copyWith(color: AppTheme.textPrimary)),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // FORMATTERS / HELPERS
  // ──────────────────────────────────────────────────────────────────────────

  String _formatTime(DateTime ts) {
    final diff = DateTime.now().difference(ts);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inHours < 1) return '${diff.inMinutes}m';
    if (diff.inHours < 24) {
      return '${ts.hour.toString().padLeft(2, '0')}:${ts.minute.toString().padLeft(2, '0')}';
    }
    return '${ts.day}/${ts.month}';
  }

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays == 0) return 'Aujourd’hui';
    if (diff.inDays == 1) return 'Hier';
    if (diff.inDays < 7) {
      return [
        'Lun',
        'Mar',
        'Mer',
        'Jeu',
        'Ven',
        'Sam',
        'Dim'
      ][date.weekday - 1];
    }
    return '${date.day}/${date.month}/${date.year}';
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _typeLabel(MessageType type) {
    switch (type) {
      case MessageType.sticker:
        return 'Sticker';
      case MessageType.gif:
        return 'GIF';
      case MessageType.image:
        return 'Image';
      case MessageType.video:
        return 'Vidéo';
      case MessageType.document:
        return 'Document';
      case MessageType.voice:
        return 'Vocal';
      case MessageType.text:
        return '';
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // VOICE RECORDING UI
  // ──────────────────────────────────────────────────────────────────────────

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final directory = await getApplicationDocumentsDirectory();
        final path =
            '${directory.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';

        await _audioRecorder.start(const RecordConfig(), path: path);

        _recordingDuration = 0;
        _startTimer();

        HapticFeedback.heavyImpact();
        setState(() {
          _isRecording = true;
        });
      }
    } catch (e) {
      debugPrint('Error starting recording: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      _stopTimer();
      final path = await _audioRecorder.stop();
      setState(() {
        _isRecording = false;
      });

      if (path != null && _recordingDuration > 0) {
        _sendVoiceMessage(path, _recordingDuration);
      }
    } catch (e) {
      debugPrint('Error stopping recording: $e');
      setState(() {
        _isRecording = false;
      });
    }
  }

  Future<void> _cancelRecording() async {
    try {
      _stopTimer();
      await _audioRecorder.stop();
      // Optionally delete the file if created
    } catch (e) {
      debugPrint('Error cancelling recording: $e');
    }
    setState(() {
      _isRecording = false;

      _recordingDuration = 0;
    });
  }

  void _startTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _recordingDuration++;
      });
    });
  }

  void _stopTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = null;
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${_formatNumber(minutes)}:${_formatNumber(remainingSeconds)}';
  }

  String _formatNumber(int number) {
    if (number < 10) {
      return '0$number';
    }
    return number.toString();
  }

  void _sendVoiceMessage(String path, int duration) {
    if (duration < 1) return; // Don't send empty messages

    // Get current user
    final authProvider = context.read<AuthProvider>();
    final currentUser = authProvider.currentUser;
    
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur: Utilisateur non connecté')),
      );
      return;
    }

    setState(() {
      _messages.add(
        MessageModel(
          text: '', // Voice messages don't need text
          timestamp: DateTime.now(),
          type: MessageType.voice,
          voiceDuration: duration,
          attachmentUrl: path, // Use attachmentUrl to store local path
          isRead: false,
          chatId: _chat.id,
          senderId: currentUser.id,
          senderName: currentUser.name,
        ),
      );
      _chat.lastMessage = 'Vocal';
      _chat.lastMessageTime = DateTime.now();
    });
    _scrollToBottom();
  }

  Widget _buildRecordingInput() {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color:
            context.themeColors.bgInput, // Ensure visibility against background
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SafeArea(
        child: Row(
          children: [
            const Icon(Icons.mic, color: Colors.redAccent),
            const SizedBox(width: 12),
            Text(
              _formatDuration(_recordingDuration),
              style: TextStyle(
                color: context.themeColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Glisser pour annuler',
              style: TextStyle(
                color: context.themeColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: _cancelRecording,
              child: Text(
                'Annuler',
                style: TextStyle(
                  color: context.themeColors.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            GestureDetector(
              onTap: _stopRecording,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: context.themeColors.colorPrimary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.send,
                  color: context.themeColors.textInverse,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  _OptionItem(this.icon, this.label, this.onTap, {this.isDestructive = false});
}
