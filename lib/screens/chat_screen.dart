import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';

import '../utils/app_theme.dart';
import '../utils/theme_extensions.dart';
import '../models/chat_model.dart';
import '../data/sample_chats_data.dart';
import '../widgets/chat/sticker_model.dart';
import '../models/gif_model.dart';
import '../widgets/chat/sticker_picker.dart';
import '../widgets/chat/gif_picker.dart';
import '../widgets/chat/user_profile_sheet.dart';
import '../widgets/video_player_screen.dart';
import '../widgets/chat/message_media/sticker_message.dart';
import '../widgets/chat/message_media/image_message.dart';
import '../widgets/chat/message_media/video_message.dart';
import '../widgets/chat/message_media/document_message.dart';
import '../widgets/chat/message_media/voice_message.dart';
import '../widgets/chat/message_media/gif_message.dart';

import '../widgets/chat/message_bubble/deleted_message_bubble.dart';
import '../widgets/chat/input/gif_sticker_picker_sheet.dart';

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

  // ── edit / reply state ───────────────────────────────────────────────────
  MessageModel? _replyTo; // message currently being replied to
  MessageModel? _editingMsg; // message currently being edited

  // ──────────────────────────────────────────────────────────────────────────
  // LIFECYCLE
  // ──────────────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _audioRecorder = AudioRecorder();
    _loadSampleMessages();
    _messageController.addListener(_onTextChanged);
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
    final args = ModalRoute.of(context)!.settings.arguments as ChatModel;
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
  // SAMPLE DATA
  // ──────────────────────────────────────────────────────────────────────────

  void _loadSampleMessages() {
    // Charger les messages depuis le service de données
    // Utiliser l'ID du chat courant si disponible, sinon utiliser un ID par défaut
    _messages.addAll(SampleChatsData.getSampleMessages('default'));
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

    setState(() {
      _messages.add(
        MessageModel(
          text: text,
          isSentByMe: true,
          timestamp: DateTime.now(),
          isRead: false,
          replyToId: _replyTo?.id,
        ),
      );

      _replyTo = null;
      _chat.lastMessage = text;
      _chat.lastMessageTime = DateTime.now();
    });
    _messageController.clear();
    _scrollToBottom();
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
  // STICKER / GIF
  // ──────────────────────────────────────────────────────────────────────────

  Future<void> _openStickerPicker() async {
    final StickerModel? sticker = await showModalBottomSheet<StickerModel>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const StickerPicker(),
    );
    if (sticker != null && mounted) {
      setState(() {
        _messages.add(
          MessageModel(
            text: sticker.name,
            isSentByMe: true,
            timestamp: DateTime.now(),
            type: MessageType.sticker,
            stickerUrl: sticker.assetPath,
            replyToId: _replyTo?.id,
          ),
        );
        _replyTo = null;
      });
      _scrollToBottom();
    }
  }

  Future<void> _openGifPicker() async {
    final GifModel? gif = await showModalBottomSheet<GifModel>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const GifPicker(),
    );
    if (gif != null && mounted) {
      setState(() {
        _messages.add(
          MessageModel(
            text: gif.title,
            isSentByMe: true,
            timestamp: DateTime.now(),
            type: MessageType.gif,
            gifUrl: gif.assetPath,
            replyToId: _replyTo?.id,
          ),
        );
        _replyTo = null;
      });
      _scrollToBottom();
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // MEDIA & FUN PICKER (nouveau menu +)
  // ──────────────────────────────────────────────────────────────────────────

  void _showMediaAndFunPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: context.themeColors.bgSurfaceDark,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: context.themeColors.textDisabled,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _funOption(
                      icon: Icons.sticky_note_2_rounded,
                      label: "Stickers",
                      color: Colors.purpleAccent,
                      onTap: () {
                        Navigator.pop(context);
                        _openStickerPicker();
                      },
                    ),
                    _funOption(
                      icon: Icons.gif_box_rounded,
                      label: "GIFs",
                      color: Colors.orangeAccent,
                      onTap: () {
                        Navigator.pop(context);
                        _openGifPicker();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _funOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: color, size: 36),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: context.themeColors.textPrimary.withOpacity(0.7),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
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
    setState(() {
      _messages.add(
        MessageModel(
          text: name,
          isSentByMe: true,
          timestamp: DateTime.now(),
          type: type,
          attachmentUrl: url,
          attachmentName: name,
          replyToId: _replyTo?.id,
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

  void _showUserProfile() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => UserProfileSheet(chat: _chat),
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
    return Scaffold(
      backgroundColor: context.themeColors.bgPrimary,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final showDateSep = index == 0 ||
                    !_isSameDay(
                        message.timestamp, _messages[index - 1].timestamp);
                return Column(
                  children: [
                    if (showDateSep) _buildDateSeparator(message.timestamp),
                    _buildMessageBubble(message),
                  ],
                );
              },
            ),
          ),
          if (_replyTo != null || _editingMsg != null) _buildReplyOrEditBar(),
          _buildMessageInput(),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // APP BAR
  // ──────────────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: context.themeColors.bgSurface,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: context.themeColors.textPrimary),
        onPressed: () => Navigator.pop(context),
      ),
      title: InkWell(
        onTap: () {},
        child: Row(
          children: [
            GestureDetector(
              onTap: _showUserProfile,
              child: Stack(
                children: [
                  CircleAvatar(
                    backgroundImage: _getImageProvider(_chat.avatarUrl),
                    child: _chat.avatarUrl == null || _chat.avatarUrl!.isEmpty
                        ? Text(_chat.name[0])
                        : null,
                    radius: 20,
                  ),
                  if (_chat.isOnline)
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
                              color: context.themeColors.bgSurface, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _chat.name,
                        style: AppTheme.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                          color: context.themeColors.textPrimary,
                        ),
                      ),
                      if (_isTyping)
                        Text(
                          'typing...',
                          style: AppTheme.bodySmall.copyWith(
                            color: context.themeColors.colorPrimary,
                            fontStyle: FontStyle.italic,
                          ),
                        )
                      else
                        Text(
                          _chat.isOnline ? 'online' : 'last seen recently',
                          style: AppTheme.bodySmall.copyWith(
                            color: context.themeColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.chevron_right, size: 20),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.phone),
          color: context.themeColors.textPrimary,
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Appel vocal (Simulation)')),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.videocam),
          color: context.themeColors.textPrimary,
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Appel vidéo (Simulation)')),
            );
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // REPLY / EDIT BAR
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildReplyOrEditBar() {
    final isReply = _replyTo != null;
    final msg = isReply ? _replyTo! : _editingMsg!;

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
                      ? 'Replying to ${msg.isSentByMe ? "you" : _chat.name}'
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

    final isSentByMe = message.isSentByMe;

    MessageModel? repliedMsg;
    if (message.replyToId != null) {
      repliedMsg = _messages.firstWhere(
        (m) => m.id == message.replyToId,
        orElse: () => MessageModel(
          id: 'ghost',
          text: 'Original message was deleted',
          isSentByMe: false,
          timestamp: DateTime.now(),
          isDeleted: true,
        ),
      );
    }

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
                onTap: _showUserProfile,
                child: Stack(
                  children: [
                    CircleAvatar(
                      backgroundImage: _getImageProvider(_chat.avatarUrl),
                      child: _chat.avatarUrl == null || _chat.avatarUrl!.isEmpty
                          ? Text(_chat.name[0])
                          : null,
                      radius: 18,
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
                                color: context.themeColors.bgPrimary, width: 2),
                          ),
                        ),
                      ),
                  ],
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
    return DocumentMessage(
      message: msg,
      isSentByMe: msg.isSentByMe,
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

    if (msg.isSentByMe && msg.type == MessageType.text) {
      actions.add(_OptionItem(Icons.edit, 'Modifier', () => _startEdit(msg)));
    }
    if (msg.isSentByMe) {
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
    setState(() {
      _messages.add(
        MessageModel(
          text: type == MessageType.sticker ? 'Sticker' : 'GIF',
          isSentByMe: true,
          timestamp: DateTime.now(),
          type: type,
          stickerUrl: type == MessageType.sticker ? path : null,
          gifUrl: type == MessageType.gif ? path : null,
          isRead: false,
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
      padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8, top: 8),
      child: SafeArea(
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

    setState(() {
      _messages.add(
        MessageModel(
          text: '', // Voice messages don't need text
          isSentByMe: true,
          timestamp: DateTime.now(),
          type: MessageType.voice,
          voiceDuration: duration,
          attachmentUrl: path, // Use attachmentUrl to store local path
          isRead: false,
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
