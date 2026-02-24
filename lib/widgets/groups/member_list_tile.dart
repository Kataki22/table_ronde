import 'package:flutter/material.dart';
import '../../models/groups/group_member_model.dart';
import '../../models/groups/group_permission.dart';
import '../../utils/theme_extensions.dart';
import '../../utils/app_theme.dart';
import '../../utils/accessibility_helpers.dart';
import '../../screens/profiles/profile_screen.dart';
import 'permission_badge.dart';

/// Widget to display a group member in a list
/// 
/// Displays member information including:
/// - Avatar with fallback to initials
/// - Name and permission badge
/// - Join date
/// - Contextual actions for admins (remove, change permission)
/// - Fade out animation (200ms) when member is removed
/// 
/// **Validates: Requirements 1.4, 1.5, 9.2, 8.3**
class MemberListTile extends StatefulWidget {
  /// The member to display
  final GroupMemberModel member;
  
  /// Whether the current user can manage this member (admin/moderator permissions)
  final bool canManage;
  
  /// Whether the current user is an admin (can change permissions)
  final bool isCurrentUserAdmin;
  
  /// Callback when remove member is selected
  final VoidCallback? onRemove;
  
  /// Callback when change permission is selected
  final Function(GroupPermission)? onChangePermission;
  
  /// Callback when the tile is tapped
  final VoidCallback? onTap;

  const MemberListTile({
    super.key,
    required this.member,
    this.canManage = false,
    this.isCurrentUserAdmin = false,
    this.onRemove,
    this.onChangePermission,
    this.onTap,
  });

  @override
  State<MemberListTile> createState() => _MemberListTileState();
}

class _MemberListTileState extends State<MemberListTile> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isRemoving = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Triggers the fade out animation before calling onRemove
  Future<void> _handleRemoveWithAnimation() async {
    if (_isRemoving) return;
    
    setState(() {
      _isRemoving = true;
    });
    
    await _animationController.forward();
    
    if (mounted) {
      widget.onRemove?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final permissionLabel = _getPermissionLabel(widget.member.permission);
    final joinDateFormatted = _formatJoinDate(widget.member.joinedAt);
    
    return Semantics(
      label: AccessibilityHelpers.memberLabel(
        name: widget.member.name,
        permission: permissionLabel,
        joinDate: joinDateFormatted,
      ),
      hint: AccessibilityHelpers.navigateToProfile,
      button: true,
      enabled: true,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: _ScaleTapTile(
          onTap: widget.onTap ?? () {
            // Default action: navigate to member's profile
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ProfileScreen(userId: widget.member.userId),
              ),
            );
          },
          child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Avatar
              _buildAvatar(context),
              const SizedBox(width: 12),
              
              // Name, permission badge, and join date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Name
                        Flexible(
                          child: Text(
                            widget.member.name,
                            style: AppTheme.bodyMedium.copyWith(
                              color: context.themeColors.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        
                        // Permission badge
                        PermissionBadge(permission: widget.member.permission),
                      ],
                    ),
                    const SizedBox(height: 4),
                    
                    // Join date
                    Text(
                      'Membre depuis ${_formatJoinDate(widget.member.joinedAt)}',
                      style: AppTheme.bodySmall.copyWith(
                        color: context.themeColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Actions menu (if user can manage)
              if (widget.canManage || widget.isCurrentUserAdmin)
                _buildActionsMenu(context),
            ],
          ),
        ),
      ),
      ),
    );
  }

  /// Gets the permission label for accessibility
  String _getPermissionLabel(GroupPermission permission) {
    switch (permission) {
      case GroupPermission.admin:
        return AccessibilityHelpers.admin;
      case GroupPermission.moderator:
        return AccessibilityHelpers.moderator;
      case GroupPermission.member:
        return AccessibilityHelpers.member;
    }
  }

  /// Builds the avatar widget
  Widget _buildAvatar(BuildContext context) {
    return CircleAvatar(
      backgroundImage: widget.member.avatarUrl != null && widget.member.avatarUrl!.isNotEmpty
          ? NetworkImage(widget.member.avatarUrl!)
          : null,
      backgroundColor: context.themeColors.bgSecondary,
      radius: 24,
      child: widget.member.avatarUrl == null || widget.member.avatarUrl!.isEmpty
          ? Text(
              widget.member.name.isNotEmpty ? widget.member.name[0].toUpperCase() : '?',
              style: AppTheme.bodyLarge.copyWith(
                color: context.themeColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            )
          : null,
    );
  }

  /// Builds the actions menu button
  Widget _buildActionsMenu(BuildContext context) {
    return Semantics(
      label: 'Menu d\'actions pour ${widget.member.name}',
      hint: AccessibilityHelpers.tapToOpen,
      button: true,
      child: PopupMenuButton<String>(
        icon: Icon(
          Icons.more_vert,
          color: context.themeColors.textSecondary,
        ),
        onSelected: (value) => _handleMenuAction(context, value),
        itemBuilder: (context) => _buildMenuItems(context),
      ),
    );
  }

  /// Builds the menu items based on permissions
  List<PopupMenuEntry<String>> _buildMenuItems(BuildContext context) {
    final items = <PopupMenuEntry<String>>[];
    final themeColors = context.themeColorsNoWatch; // Use read instead of watch in callback
    
    // Change permission options (admin only)
    if (widget.isCurrentUserAdmin && widget.member.permission != GroupPermission.admin) {
      items.add(
        PopupMenuItem<String>(
          value: 'promote_admin',
          child: Row(
            children: [
              Icon(
                Icons.admin_panel_settings,
                size: 20,
                color: themeColors.textPrimary,
              ),
              const SizedBox(width: 12),
              Text(
                'Promouvoir admin',
                style: AppTheme.bodyMedium.copyWith(
                  color: themeColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    if (widget.isCurrentUserAdmin && widget.member.permission != GroupPermission.moderator) {
      items.add(
        PopupMenuItem<String>(
          value: 'promote_moderator',
          child: Row(
            children: [
              Icon(
                Icons.shield,
                size: 20,
                color: themeColors.textPrimary,
              ),
              const SizedBox(width: 12),
              Text(
                'Promouvoir modérateur',
                style: AppTheme.bodyMedium.copyWith(
                  color: themeColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    if (widget.isCurrentUserAdmin && widget.member.permission != GroupPermission.member) {
      items.add(
        PopupMenuItem<String>(
          value: 'demote_member',
          child: Row(
            children: [
              Icon(
                Icons.person,
                size: 20,
                color: themeColors.textPrimary,
              ),
              const SizedBox(width: 12),
              Text(
                'Rétrograder membre',
                style: AppTheme.bodyMedium.copyWith(
                  color: themeColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    // Add divider if there are permission items
    if (items.isNotEmpty && widget.canManage) {
      items.add(const PopupMenuDivider());
    }
    
    // Remove member option (admin and moderator)
    if (widget.canManage) {
      items.add(
        PopupMenuItem<String>(
          value: 'remove',
          child: Row(
            children: [
              const Icon(
                Icons.person_remove,
                size: 20,
                color: Color(0xFFE74C3C),
              ),
              const SizedBox(width: 12),
              Text(
                'Retirer du groupe',
                style: AppTheme.bodyMedium.copyWith(
                  color: const Color(0xFFE74C3C),
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    return items;
  }

  /// Handles menu action selection
  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'promote_admin':
        widget.onChangePermission?.call(GroupPermission.admin);
        break;
      case 'promote_moderator':
        widget.onChangePermission?.call(GroupPermission.moderator);
        break;
      case 'demote_member':
        widget.onChangePermission?.call(GroupPermission.member);
        break;
      case 'remove':
        _handleRemoveWithAnimation();
        break;
    }
  }

  /// Formats the join date to a readable format
  String _formatJoinDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays < 1) {
      return "aujourd'hui";
    } else if (difference.inDays < 7) {
      return 'il y a ${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return 'il y a $weeks semaine${weeks > 1 ? 's' : ''}';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return 'il y a $months mois';
    } else {
      // Format as dd/MM/yyyy
      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      final year = date.year.toString();
      return '$day/$month/$year';
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
