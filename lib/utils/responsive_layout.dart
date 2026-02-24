import 'package:flutter/material.dart';

/// Utility class for responsive layout adaptations
/// 
/// Provides breakpoints and helper methods to determine screen size
/// and adapt layouts accordingly.
/// 
/// **Mobile**: single-column layouts, bottom sheets
/// **Desktop**: multi-column layouts, side panels
/// 
/// **Validates: Requirements 8.1, 8.2**
class ResponsiveLayout {
  // Breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  /// Returns true if the screen width is considered mobile
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  /// Returns true if the screen width is considered tablet
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < desktopBreakpoint;
  }

  /// Returns true if the screen width is considered desktop
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktopBreakpoint;
  }

  /// Returns true if the screen should use desktop layouts (tablet or larger)
  static bool shouldUseDesktopLayout(BuildContext context) {
    return MediaQuery.of(context).size.width >= tabletBreakpoint;
  }

  /// Returns the number of columns for grid layouts based on screen size
  static int getGridColumns(BuildContext context) {
    if (isDesktop(context)) return 4;
    if (isTablet(context)) return 3;
    return 2; // mobile
  }

  /// Returns appropriate padding based on screen size
  static EdgeInsets getScreenPadding(BuildContext context) {
    if (isDesktop(context)) {
      return const EdgeInsets.symmetric(horizontal: 48, vertical: 24);
    }
    if (isTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 32, vertical: 20);
    }
    return const EdgeInsets.symmetric(horizontal: 16, vertical: 16);
  }

  /// Returns appropriate content width for centered layouts on desktop
  static double? getMaxContentWidth(BuildContext context) {
    if (isDesktop(context)) {
      return 1200;
    }
    return null; // No max width for mobile/tablet
  }

  /// Shows a modal as either a bottom sheet (mobile) or dialog (desktop)
  static Future<T?> showAdaptiveModal<T>({
    required BuildContext context,
    required Widget Function(BuildContext) builder,
    bool isScrollControlled = true,
  }) {
    if (shouldUseDesktopLayout(context)) {
      // Show as dialog on desktop
      return showDialog<T>(
        context: context,
        builder: (context) => Dialog(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 600,
              maxHeight: 800,
            ),
            child: builder(context),
          ),
        ),
      );
    } else {
      // Show as bottom sheet on mobile
      return showModalBottomSheet<T>(
        context: context,
        isScrollControlled: isScrollControlled,
        backgroundColor: Colors.transparent,
        builder: builder,
      );
    }
  }

  /// Returns appropriate dialog width based on screen size
  static double getDialogWidth(BuildContext context) {
    if (isDesktop(context)) return 600;
    if (isTablet(context)) return 500;
    return MediaQuery.of(context).size.width * 0.9;
  }

  /// Returns appropriate side panel width for desktop layouts
  static double getSidePanelWidth(BuildContext context) {
    if (isDesktop(context)) return 400;
    if (isTablet(context)) return 350;
    return MediaQuery.of(context).size.width; // Full width on mobile
  }

  /// Builds a responsive layout with optional side panel
  /// 
  /// On mobile: shows only main content
  /// On desktop: shows main content with optional side panel
  static Widget buildResponsiveLayout({
    required BuildContext context,
    required Widget mainContent,
    Widget? sidePanel,
    double? sidePanelWidth,
  }) {
    if (sidePanel == null || !shouldUseDesktopLayout(context)) {
      // Mobile: single column
      return mainContent;
    }

    // Desktop: two columns
    final panelWidth = sidePanelWidth ?? getSidePanelWidth(context);
    
    return Row(
      children: [
        Expanded(child: mainContent),
        Container(
          width: panelWidth,
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: Theme.of(context).dividerColor,
                width: 1,
              ),
            ),
          ),
          child: sidePanel,
        ),
      ],
    );
  }

  /// Returns appropriate font size scale based on screen size
  static double getFontScale(BuildContext context) {
    if (isDesktop(context)) return 1.1;
    if (isTablet(context)) return 1.05;
    return 1.0;
  }

  /// Returns appropriate icon size based on screen size
  static double getIconSize(BuildContext context, {double baseSize = 24}) {
    if (isDesktop(context)) return baseSize * 1.2;
    if (isTablet(context)) return baseSize * 1.1;
    return baseSize;
  }
}
