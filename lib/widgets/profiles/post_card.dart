import 'package:flutter/material.dart';
import '../../models/profiles/user_post.dart';
import '../../utils/theme_extensions.dart';
import '../../utils/app_theme.dart';

/// Widget displaying a user post with content, images, and engagement metrics
/// 
/// Displays:
/// - Post content (text)
/// - Attached images in a grid or carousel layout
/// - Like and comment counters
/// - Formatted timestamp
/// 
/// **Validates: Requirements 2.4**
class PostCard extends StatefulWidget {
  /// The user post to display
  final UserPost post;
  
  /// Optional callback when the card is tapped
  final VoidCallback? onTap;
  
  /// Optional callback when the like button is tapped
  final VoidCallback? onLikeTap;
  
  /// Optional callback when the comment button is tapped
  final VoidCallback? onCommentTap;

  const PostCard({
    super.key,
    required this.post,
    this.onTap,
    this.onLikeTap,
    this.onCommentTap,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap != null) {
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onTap != null) {
      _controller.reverse();
    }
  }

  void _handleTapCancel() {
    if (widget.onTap != null) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            borderRadius: BorderRadius.circular(12),
            splashColor: Colors.grey.withValues(alpha: 0.2),
            highlightColor: Colors.grey.withValues(alpha: 0.1),
            hoverColor: _isHovered 
                ? Colors.grey.withValues(alpha: 0.05)
                : null,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.themeColors.bgSecondary,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: context.themeColors.borderSubtle,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Post content
                  if (widget.post.content.isNotEmpty) ...[
                    Text(
                      widget.post.content,
                      style: AppTheme.bodyMedium.copyWith(
                        color: context.themeColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  
                  // Images grid/carousel
                  if (widget.post.imageUrls.isNotEmpty) ...[
                    _buildImagesSection(context),
                    const SizedBox(height: 12),
                  ],
                  
                  // Engagement metrics and timestamp
                  Row(
                    children: [
                      // Like counter
                      _buildEngagementButton(
                        context: context,
                        icon: Icons.favorite_outline,
                        count: widget.post.likesCount,
                        onTap: widget.onLikeTap,
                      ),
                      const SizedBox(width: 16),
                      
                      // Comment counter
                      _buildEngagementButton(
                        context: context,
                        icon: Icons.comment_outlined,
                        count: widget.post.commentsCount,
                        onTap: widget.onCommentTap,
                      ),
                      
                      const Spacer(),
                      
                      // Timestamp
                      Text(
                        _formatTimestamp(widget.post.createdAt),
                        style: AppTheme.bodySmall.copyWith(
                          color: context.themeColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the images section with appropriate layout based on image count
  Widget _buildImagesSection(BuildContext context) {
    final imageCount = widget.post.imageUrls.length;
    
    if (imageCount == 1) {
      // Single image - full width
      return _buildSingleImage(context, widget.post.imageUrls[0]);
    } else if (imageCount == 2) {
      // Two images - side by side
      return _buildTwoImagesGrid(context);
    } else if (imageCount == 3) {
      // Three images - one large, two small
      return _buildThreeImagesGrid(context);
    } else {
      // Four or more images - 2x2 grid with overflow indicator
      return _buildMultipleImagesGrid(context);
    }
  }

  /// Builds a single image display
  Widget _buildSingleImage(BuildContext context, String imageUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildImagePlaceholder(context);
          },
        ),
      ),
    );
  }

  /// Builds a two-image grid layout
  Widget _buildTwoImagesGrid(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Row(
        children: [
          Expanded(
            child: _buildGridImage(context, widget.post.imageUrls[0]),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _buildGridImage(context, widget.post.imageUrls[1]),
          ),
        ],
      ),
    );
  }

  /// Builds a three-image grid layout (1 large + 2 small)
  Widget _buildThreeImagesGrid(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: _buildGridImage(context, widget.post.imageUrls[0]),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: _buildGridImage(context, widget.post.imageUrls[1]),
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: _buildGridImage(context, widget.post.imageUrls[2]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a grid for 4+ images with overflow indicator
  Widget _buildMultipleImagesGrid(BuildContext context) {
    final displayImages = widget.post.imageUrls.take(4).toList();
    final remainingCount = widget.post.imageUrls.length - 4;
    
    return SizedBox(
      height: 200,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemCount: displayImages.length,
        itemBuilder: (context, index) {
          final isLast = index == 3 && remainingCount > 0;
          return Stack(
            fit: StackFit.expand,
            children: [
              _buildGridImage(context, displayImages[index]),
              if (isLast)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '+$remainingCount',
                      style: AppTheme.headingMedium.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  /// Builds a single grid image with rounded corners
  Widget _buildGridImage(BuildContext context, String imageUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildImagePlaceholder(context);
        },
      ),
    );
  }

  /// Builds a placeholder for failed image loads
  Widget _buildImagePlaceholder(BuildContext context) {
    return Container(
      color: context.themeColors.bgTertiary,
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: 48,
          color: context.themeColors.textSecondary,
        ),
      ),
    );
  }

  /// Builds an engagement button (like or comment)
  Widget _buildEngagementButton({
    required BuildContext context,
    required IconData icon,
    required int count,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: context.themeColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              _formatCount(count),
              style: AppTheme.bodySmall.copyWith(
                color: context.themeColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Formats large numbers with K/M suffixes
  String _formatCount(int count) {
    if (count < 1000) {
      return count.toString();
    } else if (count < 1000000) {
      final k = count / 1000;
      return '${k.toStringAsFixed(k >= 10 ? 0 : 1)}K';
    } else {
      final m = count / 1000000;
      return '${m.toStringAsFixed(m >= 10 ? 0 : 1)}M';
    }
  }

  /// Formats the timestamp to a human-readable format
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inSeconds < 60) {
      return 'À l\'instant';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return 'Il y a $minutes minute${minutes > 1 ? 's' : ''}';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return 'Il y a $hours heure${hours > 1 ? 's' : ''}';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return 'Il y a $days jour${days > 1 ? 's' : ''}';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return 'Il y a $weeks semaine${weeks > 1 ? 's' : ''}';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return 'Il y a $months mois';
    } else {
      final years = (difference.inDays / 365).floor();
      return 'Il y a $years an${years > 1 ? 's' : ''}';
    }
  }
}
