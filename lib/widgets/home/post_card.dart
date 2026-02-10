import 'package:flutter/material.dart';
import '../../../utils/app_theme.dart';
import '../../../utils/theme_extensions.dart';

class PostCard extends StatefulWidget {
  final Map<String, dynamic> post;

  const PostCard({super.key, required this.post});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  late bool _isLiked;
  late int _likeCount;
  late int _commentCount;

  @override
  void initState() {
    super.initState();
    _isLiked = false;
    _likeCount = widget.post['likes'] ?? 0;
    _commentCount = widget.post['comments'] ?? 0;
  }

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
      _likeCount += _isLiked ? 1 : -1;
    });
  }

  void _showComments() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _CommentsSheet(
        onCommentAdded: () => setState(() => _commentCount++),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = widget.post['imageUrl'];
    return Container(
      margin: const EdgeInsets.only(bottom: 1),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.themeColors.bgSurface,
        border: Border(
          bottom:
              BorderSide(color: context.themeColors.bgSurfaceDark, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post header
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: context.themeColors.colorPrimary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    widget.post['avatar'],
                    style: AppTheme.bodyLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          widget.post['author'],
                          style: AppTheme.bodyLarge.copyWith(
                            color: context.themeColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.verified,
                          size: 16,
                          color: context.themeColors.colorPrimary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.post['username'],
                          style: AppTheme.bodySmall.copyWith(
                            color: context.themeColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                widget.post['time'],
                style: AppTheme.bodySmall.copyWith(
                  color: context.themeColors.textSecondary,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.more_horiz),
                color: context.themeColors.textSecondary,
                onPressed: () {},
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Post content
          Text(
            widget.post['content'],
            style: AppTheme.bodyMedium.copyWith(
              color: context.themeColors.textPrimary,
              height: 1.5,
            ),
          ),

          if (imageUrl != null) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: imageUrl is String
                  ? Image.asset(
                      imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 200,
                          color: AppTheme.surfaceDark,
                          child: const Center(
                            child: Icon(Icons.broken_image,
                                size: 48, color: Colors.white24),
                          ),
                        );
                      },
                    )
                  : Image.file(
                      imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 200,
                          color: AppTheme.surfaceDark,
                          child: const Center(
                            child: Icon(Icons.broken_image,
                                size: 48, color: Colors.white24),
                          ),
                        );
                      },
                    ),
            ),
          ],

          const SizedBox(height: 16),

          // Post actions
          Row(
            children: [
              _buildPostAction(
                _isLiked ? Icons.favorite : Icons.favorite_border,
                _likeCount.toString(),
                onTap: _toggleLike,
                color: _isLiked ? context.themeColors.colorDanger : null,
              ),
              const SizedBox(width: 24),
              _buildPostAction(
                Icons.chat_bubble_outline,
                _commentCount.toString(),
                onTap: _showComments,
              ),
              const SizedBox(width: 24),
              _buildPostAction(Icons.share_outlined, '', onTap: () {}),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPostAction(
    IconData icon,
    String count, {
    required VoidCallback onTap,
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon,
              size: 18, color: color ?? context.themeColors.textSecondary),
          if (count.isNotEmpty) ...[
            const SizedBox(width: 6),
            Text(
              count,
              style: AppTheme.bodySmall.copyWith(
                color: context.themeColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CommentsSheet extends StatefulWidget {
  final VoidCallback onCommentAdded;

  const _CommentsSheet({required this.onCommentAdded});

  @override
  State<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<_CommentsSheet> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _comments = [
    "Super post ! 🔥",
    "Intéressant 🤔",
    "J'adore le design !",
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      decoration: BoxDecoration(
        color: context.themeColors.bgSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[600],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Commentaires',
            style: AppTheme.headingSmall
                .copyWith(color: context.themeColors.textPrimary),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _comments.length,
              itemBuilder: (context, index) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: context.themeColors.bgSurfaceDark,
                  child: Icon(Icons.person,
                      color: context.themeColors.textSecondary),
                ),
                title: Text(
                  'Utilisateur',
                  style: AppTheme.bodyMedium.copyWith(
                      color: context.themeColors.textPrimary,
                      fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  _comments[index],
                  style: AppTheme.bodyMedium.copyWith(
                      color: context.themeColors.textPrimary.withOpacity(0.7)),
                ),
              ),
            ),
          ),
          Divider(color: context.themeColors.borderLight),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: TextStyle(color: context.themeColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Ajouter un commentaire...',
                      hintStyle:
                          TextStyle(color: context.themeColors.textSecondary),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon:
                      Icon(Icons.send, color: context.themeColors.colorPrimary),
                  onPressed: () {
                    if (_controller.text.trim().isNotEmpty) {
                      setState(() {
                        _comments.add(_controller.text);
                        _controller.clear();
                      });
                      widget.onCommentAdded();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
