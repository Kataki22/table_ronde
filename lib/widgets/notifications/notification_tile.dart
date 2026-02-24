import 'package:flutter/material.dart';
import '../../models/notifications/notification_model.dart';
import '../../utils/app_theme.dart';
import '../../utils/accessibility_helpers.dart';

/// A tile widget for displaying a single notification
/// 
/// Features:
/// - Displays notification icon, title, body, and timestamp
/// - Shows read/unread indicator
/// - Supports swipe actions (mark read, delete) with 250ms animation
/// - Tap to navigate to content
/// - Avatar display if available
/// - Slide-in animation on appearance (200ms)
/// 
/// **Validates: Requirements 6.2, 6.4, 6.5, 8.3**
class NotificationTile extends StatefulWidget {
  /// The notification to display
  final NotificationModel notification;

  /// Callback when the tile is tapped
  final VoidCallback onTap;

  /// Callback when mark as read/unread is triggered
  final VoidCallback onMarkRead;

  /// Callback when delete is triggered
  final VoidCallback onDelete;

  const NotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
    required this.onMarkRead,
    required this.onDelete,
  });

  @override
  State<NotificationTile> createState() => _NotificationTileState();
}

class _NotificationTileState extends State<NotificationTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    // Slide-in animation: 200ms as per requirement 8.3
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0), // Start from right
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));
    
    // Start the slide-in animation
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final timestampFormatted = _formatTimestamp(widget.notification.timestamp);

    return Semantics(
      label: AccessibilityHelpers.notificationLabel(
        title: widget.notification.title,
        body: widget.notification.body,
        isRead: widget.notification.isRead,
        timestamp: timestampFormatted,
      ),
      hint: 'Appuyer pour ouvrir, glisser pour marquer comme lu ou supprimer',
      button: true,
      enabled: true,
      child: SlideTransition(
        position: _slideAnimation,
        child: Dismissible(
        key: Key(widget.notification.id),
        // Swipe animation duration: 250ms as per requirement 8.3
        movementDuration: const Duration(milliseconds: 250),
        resizeDuration: const Duration(milliseconds: 250),
        background: _buildSwipeBackground(
          context,
          alignment: Alignment.centerLeft,
          color: AppTheme.primaryBlue,
          icon: widget.notification.isRead ? Icons.mark_email_unread : Icons.mark_email_read,
          label: widget.notification.isRead ? 'Non lu' : 'Lu',
        ),
        secondaryBackground: _buildSwipeBackground(
          context,
          alignment: Alignment.centerRight,
          color: AppTheme.errorColor,
          icon: Icons.delete,
          label: 'Supprimer',
        ),
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.startToEnd) {
            // Mark as read/unread
            widget.onMarkRead();
            return false; // Don't dismiss
          } else {
            // Delete
            widget.onDelete();
            return true; // Dismiss
          }
        },
        child: _ScaleTapTile(
          onTap: widget.onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingMedium,
              vertical: AppTheme.spacingSmall,
            ),
            decoration: BoxDecoration(
              color: widget.notification.isRead
                  ? Colors.transparent
                  : (isDark
                      ? AppTheme.primaryBlue.withValues(alpha: 0.05)
                      : AppTheme.primaryBlue.withValues(alpha: 0.03)),
              border: Border(
                bottom: BorderSide(
                  color: isDark ? AppTheme.cardDark : Colors.grey.shade200,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar or Icon
                _buildLeadingWidget(isDark),
                const SizedBox(width: AppTheme.spacingMedium),
                
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title and timestamp
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.notification.title,
                              style: TextStyle(
                                color: isDark ? AppTheme.textPrimary : AppTheme.textDark,
                                fontSize: 15,
                                fontWeight: widget.notification.isRead
                                    ? FontWeight.normal
                                    : FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: AppTheme.spacingSmall),
                          Text(
                            _formatTimestamp(widget.notification.timestamp),
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.spacingXSmall),
                      
                      // Body
                      Text(
                        widget.notification.body,
                        style: TextStyle(
                          color: isDark ? AppTheme.textSecondary : Colors.grey.shade700,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                
                // Unread indicator
                if (!widget.notification.isRead) ...[
                  const SizedBox(width: AppTheme.spacingSmall),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildLeadingWidget(bool isDark) {
    if (widget.notification.avatarUrl != null && widget.notification.avatarUrl!.isNotEmpty) {
      // Show avatar with type icon badge
      return Stack(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage: NetworkImage(widget.notification.avatarUrl!),
            backgroundColor: isDark ? AppTheme.cardDark : Colors.grey.shade200,
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: widget.notification.color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? AppTheme.surfaceDark : Colors.white,
                  width: 2,
                ),
              ),
              child: Icon(
                widget.notification.icon,
                size: 12,
                color: Colors.white,
              ),
            ),
          ),
        ],
      );
    } else {
      // Show type icon only
      return Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: widget.notification.color.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(
          widget.notification.icon,
          color: widget.notification.color,
          size: 24,
        ),
      );
    }
  }

  Widget _buildSwipeBackground(
    BuildContext context, {
    required Alignment alignment,
    required Color color,
    required IconData icon,
    required String label,
  }) {
    return Container(
      color: color,
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLarge),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'À l\'instant';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}j';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '${weeks}sem';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '${months}mois';
    } else {
      final years = (difference.inDays / 365).floor();
      return '${years}an${years > 1 ? 's' : ''}';
    }
  }
}

/// Internal widget that provides scale animation on tap with ripple effect
class _ScaleTapTile extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _ScaleTapTile({
    required this.child,
    required this.onTap,
  });

  @override
  State<_ScaleTapTile> createState() => _ScaleTapTileState();
}

class _ScaleTapTileState extends State<_ScaleTapTile>
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
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _handleTapCancel() {
    _controller.reverse();
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
            splashColor: Colors.grey.withValues(alpha: 0.2),
            highlightColor: Colors.grey.withValues(alpha: 0.1),
            hoverColor: _isHovered 
                ? Colors.grey.withValues(alpha: 0.05)
                : null,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
