import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';
import '../../utils/accessibility_helpers.dart';

/// A badge widget that displays a counter for unread notifications
/// 
/// Features:
/// - Displays a circular badge with a count
/// - Animates appearance of new notifications
/// - Hides when count is 0
/// - Supports custom colors and sizes
/// 
/// **Validates: Requirements 6.3**
class BadgeCounter extends StatefulWidget {
  /// The count to display in the badge
  final int count;

  /// The color of the badge background
  final Color? backgroundColor;

  /// The color of the badge text
  final Color? textColor;

  /// The size of the badge (diameter)
  final double size;

  /// Whether to animate when the count changes
  final bool animate;

  const BadgeCounter({
    super.key,
    required this.count,
    this.backgroundColor,
    this.textColor,
    this.size = 20.0,
    this.animate = true,
  });

  @override
  State<BadgeCounter> createState() => _BadgeCounterState();
}

class _BadgeCounterState extends State<BadgeCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  int _previousCount = 0;

  @override
  void initState() {
    super.initState();
    _previousCount = widget.count;
    // Animation duration: 300ms as per requirement 8.3
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    // Scale pulse animation with elastic curve for bounce effect
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    if (widget.count > 0) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(BadgeCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Animate when count increases
    if (widget.animate && widget.count > _previousCount && widget.count > 0) {
      _controller.forward(from: 0.7);
    } else if (widget.count > 0 && _previousCount == 0) {
      // Animate appearance when going from 0 to any count
      _controller.forward(from: 0.0);
    } else if (widget.count == 0 && _previousCount > 0) {
      // Animate disappearance when going to 0
      _controller.reverse();
    }
    
    _previousCount = widget.count;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.count <= 0) {
      return const SizedBox.shrink();
    }

    final backgroundColor = widget.backgroundColor ?? AppTheme.errorColor;
    final textColor = widget.textColor ?? Colors.white;
    
    // Format count: show "99+" for counts over 99
    final displayText = widget.count > 99 ? '99+' : widget.count.toString();
    
    // Create semantic label
    final semanticLabel = widget.count == 1
        ? '1 notification non lue'
        : '${widget.count} notifications non lues';

    return Semantics(
      label: semanticLabel,
      liveRegion: true,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
        constraints: BoxConstraints(
          minWidth: widget.size,
          minHeight: widget.size,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: widget.size * 0.25,
          vertical: widget.size * 0.1,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(widget.size / 2),
          boxShadow: [
            BoxShadow(
              color: backgroundColor.withValues(alpha: 0.4),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            displayText,
            style: TextStyle(
              color: textColor,
              fontSize: widget.size * 0.55,
              fontWeight: FontWeight.bold,
              height: 1.0,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
      ),
    );
  }
}
