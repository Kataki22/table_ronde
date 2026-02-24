import 'package:flutter/material.dart';
import '../../models/profiles/user_activity.dart';
import '../../utils/theme_extensions.dart';
import '../../utils/app_theme.dart';

/// Widget displaying a user activity item
/// 
/// Displays:
/// - Icon based on activity type (post, comment, like, join_group)
/// - Activity description
/// - Formatted timestamp
/// 
/// **Validates: Requirements 2.3**
class ActivityCard extends StatefulWidget {
  /// The user activity to display
  final UserActivity activity;
  
  /// Optional callback when the card is tapped
  final VoidCallback? onTap;

  const ActivityCard({
    super.key,
    required this.activity,
    this.onTap,
  });

  @override
  State<ActivityCard> createState() => _ActivityCardState();
}

class _ActivityCardState extends State<ActivityCard>
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
            borderRadius: BorderRadius.circular(8),
            splashColor: Colors.grey.withValues(alpha: 0.2),
            highlightColor: Colors.grey.withValues(alpha: 0.1),
            hoverColor: _isHovered 
                ? Colors.grey.withValues(alpha: 0.05)
                : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: context.themeColors.bgSecondary,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: context.themeColors.borderSubtle,
                  width: 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Activity icon
                  _buildActivityIcon(context),
                  const SizedBox(width: 12),
                  
                  // Activity content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Description
                        Text(
                          widget.activity.description,
                          style: AppTheme.bodyMedium.copyWith(
                            color: context.themeColors.textPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        
                        // Timestamp
                        Text(
                          _formatTimestamp(widget.activity.timestamp),
                          style: AppTheme.bodySmall.copyWith(
                            color: context.themeColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the activity icon based on the activity type
  Widget _buildActivityIcon(BuildContext context) {
    final iconData = _getIconForType(widget.activity.type);
    final iconColor = _getColorForType(context, widget.activity.type);
    
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        iconData,
        size: 20,
        color: iconColor,
      ),
    );
  }

  /// Gets the icon for the activity type
  IconData _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'post':
        return Icons.article_outlined;
      case 'comment':
        return Icons.comment_outlined;
      case 'like':
        return Icons.favorite_outline;
      case 'join_group':
        return Icons.group_add_outlined;
      default:
        return Icons.info_outline;
    }
  }

  /// Gets the color for the activity type
  Color _getColorForType(BuildContext context, String type) {
    switch (type.toLowerCase()) {
      case 'post':
        return context.themeColors.colorPrimary;
      case 'comment':
        return context.themeColors.colorInfo ?? context.themeColors.colorPrimary;
      case 'like':
        return context.themeColors.colorDanger;
      case 'join_group':
        return context.themeColors.colorSuccess;
      default:
        return context.themeColors.textSecondary;
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
