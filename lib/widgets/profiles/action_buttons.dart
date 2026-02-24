import 'package:flutter/material.dart';
import '../../models/profiles/user_profile_model.dart';
import '../../utils/theme_extensions.dart';
import '../../utils/app_theme.dart';
import '../../utils/accessibility_helpers.dart';

/// Widget displaying action buttons for user profiles
/// 
/// Displays different buttons based on context:
/// - For other users: Message, Voice Call, Video Call, Block buttons
/// - For current user: Edit button (handled by ProfileHeader)
/// 
/// **Validates: Requirements 2.5, 2.6**
class ActionButtons extends StatelessWidget {
  /// The user profile being viewed
  final UserProfileModel profile;
  
  /// Whether this is the current user's profile
  final bool isCurrentUser;
  
  /// Callback when the message button is tapped
  final VoidCallback? onMessageTap;
  
  /// Callback when the voice call button is tapped
  final VoidCallback? onVoiceCallTap;
  
  /// Callback when the video call button is tapped
  final VoidCallback? onVideoCallTap;
  
  /// Callback when the block button is tapped
  final VoidCallback? onBlockTap;

  const ActionButtons({
    super.key,
    required this.profile,
    required this.isCurrentUser,
    this.onMessageTap,
    this.onVoiceCallTap,
    this.onVideoCallTap,
    this.onBlockTap,
  });

  @override
  Widget build(BuildContext context) {
    // Don't show action buttons for current user's profile
    // (Edit button is handled by ProfileHeader)
    if (isCurrentUser) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: context.themeColors.bgSecondary,
        border: Border(
          bottom: BorderSide(
            color: context.themeColors.borderSubtle,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Message button (primary action)
          Expanded(
            flex: 2,
            child: _buildPrimaryButton(
              context: context,
              icon: Icons.message_outlined,
              label: 'Message',
              onTap: onMessageTap,
            ),
          ),
          const SizedBox(width: 12),
          
          // Voice call button
          Expanded(
            child: _buildSecondaryButton(
              context: context,
              icon: Icons.call_outlined,
              label: 'Appel',
              onTap: onVoiceCallTap,
            ),
          ),
          const SizedBox(width: 12),
          
          // Video call button
          Expanded(
            child: _buildSecondaryButton(
              context: context,
              icon: Icons.videocam_outlined,
              label: 'Vidéo',
              onTap: onVideoCallTap,
            ),
          ),
          const SizedBox(width: 12),
          
          // Block button (destructive action)
          _buildIconButton(
            context: context,
            icon: Icons.block_outlined,
            onTap: onBlockTap,
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  /// Builds the primary action button (Message)
  Widget _buildPrimaryButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    return Semantics(
      label: AccessibilityHelpers.actionButtonLabel(
        action: 'Envoyer un message à',
        targetName: profile.name,
      ),
      hint: AccessibilityHelpers.tapToMessage,
      button: true,
      enabled: onTap != null,
      child: _ScaleTapButton(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: context.themeColors.colorPrimary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: context.themeColors.textInverse,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTheme.bodyMedium.copyWith(
                color: context.themeColors.textInverse,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  /// Builds a secondary action button (Voice/Video call)
  Widget _buildSecondaryButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    final isVoiceCall = icon == Icons.call_outlined;
    final semanticLabel = isVoiceCall
        ? 'Appeler ${profile.name}'
        : 'Appeler ${profile.name} en vidéo';
    final semanticHint = isVoiceCall
        ? AccessibilityHelpers.tapToCall
        : AccessibilityHelpers.tapToVideoCall;
    
    return Semantics(
      label: semanticLabel,
      hint: semanticHint,
      button: true,
      enabled: onTap != null,
      child: _ScaleTapButton(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: context.themeColors.bgTertiary,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: context.themeColors.borderMedium,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: context.themeColors.textPrimary,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTheme.bodySmall.copyWith(
                color: context.themeColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  /// Builds an icon-only button (Block)
  Widget _buildIconButton({
    required BuildContext context,
    required IconData icon,
    VoidCallback? onTap,
    bool isDestructive = false,
  }) {
    return Semantics(
      label: 'Bloquer ${profile.name}',
      hint: AccessibilityHelpers.tapToBlock,
      button: true,
      enabled: onTap != null,
      child: _ScaleTapButton(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isDestructive
              ? context.themeColors.colorDanger.withValues(alpha: 0.1)
              : context.themeColors.bgTertiary,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDestructive
                ? context.themeColors.colorDanger.withValues(alpha: 0.3)
                : context.themeColors.borderMedium,
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isDestructive
              ? context.themeColors.colorDanger
              : context.themeColors.textPrimary,
        ),
      ),
      ),
    );
  }
}

/// Internal widget that provides scale animation on tap with ripple effect
class _ScaleTapButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;

  const _ScaleTapButton({
    required this.child,
    this.onTap,
    this.borderRadius,
  });

  @override
  State<_ScaleTapButton> createState() => _ScaleTapButtonState();
}

class _ScaleTapButtonState extends State<_ScaleTapButton>
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
      end: 0.95,
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
            borderRadius: widget.borderRadius,
            splashColor: Colors.white.withValues(alpha: 0.2),
            highlightColor: Colors.white.withValues(alpha: 0.1),
            hoverColor: _isHovered 
                ? Colors.white.withValues(alpha: 0.05)
                : null,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
