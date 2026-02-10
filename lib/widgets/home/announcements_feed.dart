import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';
import '../../utils/theme_extensions.dart';

class AnnouncementsFeed extends StatelessWidget {
  final List<Map<String, dynamic>> announcements;

  const AnnouncementsFeed({
    super.key,
    required this.announcements,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: announcements.length,
      itemBuilder: (context, index) {
        return _AnnouncementCard(announcement: announcements[index]);
      },
    );
  }
}

class _AnnouncementCard extends StatefulWidget {
  final Map<String, dynamic> announcement;

  const _AnnouncementCard({required this.announcement});

  @override
  State<_AnnouncementCard> createState() => _AnnouncementCardState();
}

class _AnnouncementCardState extends State<_AnnouncementCard> {
  late bool _isLiked;
  late int _likeCount;
  late int _commentCount;

  @override
  void initState() {
    super.initState();
    _isLiked = false;
    _likeCount = widget.announcement['likes'] ?? 0;
    _commentCount = widget.announcement['comments'] ?? 0;
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
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: context.themeColors.bgSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.themeColors.bgSurfaceDark,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header avec badge et infos
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: context.themeColors.bgSurfaceDark,
                  width: 1,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (widget.announcement['badge'] != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getBadgeColor(
                              context, widget.announcement['badge']),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          widget.announcement['badge'],
                          style: AppTheme.bodySmall.copyWith(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.announcement['title'] ?? 'Annonce',
                        style: AppTheme.headingSmall.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    // Avatar
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color:
                            context.themeColors.colorPrimary.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          widget.announcement['author']?.substring(0, 1) ?? 'A',
                          style: AppTheme.bodyMedium.copyWith(
                            color: context.themeColors.colorPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.announcement['author'] ?? 'Admin Team',
                            style: AppTheme.bodyMedium.copyWith(
                              color: context.themeColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            widget.announcement['date'] ?? '1 février 2024',
                            style: AppTheme.bodySmall.copyWith(
                              color: context.themeColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Contenu
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.announcement['content'] ?? '',
                  style: AppTheme.bodyMedium.copyWith(
                    color: context.themeColors.textPrimary,
                    height: 1.6,
                  ),
                ),
                if (widget.announcement['imageUrl'] != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        widget.announcement['imageUrl'],
                        fit: BoxFit.cover,
                        height: 200,
                        width: double.infinity,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Actions (likes, comments)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: context.themeColors.bgSurfaceDark,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionButton(
                  _isLiked ? Icons.favorite : Icons.favorite_outline,
                  '$_likeCount',
                  _toggleLike,
                  color: _isLiked ? context.themeColors.colorDanger : null,
                ),
                _buildActionButton(
                  Icons.comment_outlined,
                  '$_commentCount',
                  _showComments,
                ),
                _buildActionButton(
                  Icons.share_outlined,
                  'Partager',
                  () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    IconData icon,
    String label,
    VoidCallback onTap, {
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            icon,
            color: color ?? context.themeColors.textSecondary,
            size: 18,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTheme.bodySmall.copyWith(
              color: context.themeColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Color _getBadgeColor(BuildContext context, String badge) {
    switch (badge.toUpperCase()) {
      case 'URGENT':
        return context.themeColors.colorDanger;
      case 'IMPORTANT':
        return context.themeColors.colorWarning;
      case 'INFO':
        return context.themeColors.colorPrimary;
      default:
        return context.themeColors.colorPrimary;
    }
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
    "Merci pour l'info !",
    "Hâte de voir ça",
    "Top 👍",
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
                  'Membre',
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
