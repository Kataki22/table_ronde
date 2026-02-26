import 'package:flutter/material.dart';

/// Utility class providing interactive visual feedback for UI elements
/// 
/// Implements requirement 8.5: Interactive element feedback
/// - Ripple effects on all buttons
/// - Color changes on hover (desktop)
/// - Scale animations on tap
/// 
/// **Validates: Requirements 8.5**
class InteractiveFeedback {
  /// Wraps a widget with interactive feedback (ripple, hover, scale)
  /// 
  /// Parameters:
  /// - [child]: The widget to wrap
  /// - [onTap]: Callback when tapped
  /// - [borderRadius]: Border radius for ripple effect
  /// - [enableHover]: Whether to enable hover effects (default: true)
  /// - [enableScale]: Whether to enable scale animation on tap (default: true)
  /// - [hoverColor]: Color overlay on hover (optional)
  /// - [splashColor]: Color for ripple effect (optional)
  static Widget wrap({
    required Widget child,
    VoidCallback? onTap,
    BorderRadius? borderRadius,
    bool enableHover = true,
    bool enableScale = true,
    Color? hoverColor,
    Color? splashColor,
  }) {
    if (!enableScale) {
      // Simple InkWell without scale animation
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          hoverColor: hoverColor,
          splashColor: splashColor,
          child: child,
        ),
      );
    }

    // With scale animation
    return _ScaleTapWidget(
      onTap: onTap,
      borderRadius: borderRadius,
      hoverColor: hoverColor,
      splashColor: splashColor,
      child: child,
    );
  }
}

/// Internal widget that provides scale animation on tap
class _ScaleTapWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;
  final Color? hoverColor;
  final Color? splashColor;

  const _ScaleTapWidget({
    required this.child,
    this.onTap,
    this.borderRadius,
    this.hoverColor,
    this.splashColor,
  });

  @override
  State<_ScaleTapWidget> createState() => _ScaleTapWidgetState();
}

class _ScaleTapWidgetState extends State<_ScaleTapWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

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
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          onTapDown: _handleTapDown,
          onTapUp: _handleTapUp,
          onTapCancel: _handleTapCancel,
          borderRadius: widget.borderRadius,
          hoverColor: widget.hoverColor,
          splashColor: widget.splashColor,
          child: widget.child,
        ),
      ),
    );
  }
}

/// Mixin that provides interactive feedback functionality to StatefulWidgets
/// 
/// Usage:
/// ```dart
/// class MyWidget extends StatefulWidget {
///   // ...
/// }
/// 
/// class _MyWidgetState extends State<MyWidget> 
///     with SingleTickerProviderStateMixin, InteractiveFeedbackMixin {
///   
///   @override
///   void initState() {
///     super.initState();
///     initInteractiveFeedback(this);
///   }
///   
///   @override
///   Widget build(BuildContext context) {
///     return wrapWithFeedback(
///       child: MyChildWidget(),
///       onTap: () => print('Tapped!'),
///     );
///   }
/// }
/// ```
mixin InteractiveFeedbackMixin on TickerProviderStateMixin {
  late AnimationController _feedbackController;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  /// Initialize the interactive feedback animations
  /// Must be called in initState()
  void initInteractiveFeedback(TickerProvider vsync) {
    _feedbackController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: vsync,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _feedbackController,
      curve: Curves.easeInOut,
    ));
  }

  /// Dispose the feedback controller
  /// Must be called in dispose()
  void disposeInteractiveFeedback() {
    _feedbackController.dispose();
  }

  /// Wraps a widget with interactive feedback
  Widget wrapWithFeedback({
    required Widget child,
    VoidCallback? onTap,
    BorderRadius? borderRadius,
    Color? hoverColor,
    Color? splashColor,
  }) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            onTapDown: (_) => _feedbackController.forward(),
            onTapUp: (_) => _feedbackController.reverse(),
            onTapCancel: () => _feedbackController.reverse(),
            borderRadius: borderRadius,
            hoverColor: hoverColor,
            splashColor: splashColor,
            child: child,
          ),
        ),
      ),
    );
  }

  /// Whether the widget is currently hovered
  bool get isHovered => _isHovered;

  /// The scale animation value
  Animation<double> get scaleAnimation => _scaleAnimation;
}
