/// Responsive utility class for adaptive layouts
///
/// Provides breakpoints and helper methods to build responsive UIs
/// that adapt between mobile and desktop layouts.
///
/// Usage:
/// ```dart
/// if (ResponsiveUtils.isMobile(context)) {
///   return MobileLayout();
/// } else {
///   return DesktopLayout();
/// }
/// ```

import 'package:flutter/material.dart';

class ResponsiveUtils {
  /// Private constructor to prevent instantiation
  ResponsiveUtils._();

  /// Breakpoints
  static const double mobileMaxWidth = 600.0;
  static const double tabletMaxWidth = 1024.0;
  static const double desktopMinWidth = 1025.0;

  /// Check if current screen is mobile sized
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileMaxWidth;
  }

  /// Check if current screen is tablet sized
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileMaxWidth && width < tabletMaxWidth;
  }

  /// Check if current screen is desktop sized
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktopMinWidth;
  }

  /// Get responsive value based on screen size
  static T responsive<T>({
    required BuildContext context,
    required T mobile,
    T? tablet,
    required T desktop,
  }) {
    if (isDesktop(context)) return desktop;
    if (isTablet(context)) return tablet ?? mobile;
    return mobile;
  }

  /// Get screen width
  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Get screen height
  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// Get responsive padding
  static double getResponsivePadding(BuildContext context) {
    if (isDesktop(context)) return 32.0;
    if (isTablet(context)) return 24.0;
    return 16.0;
  }

  /// Get responsive column count for grid
  static int getGridColumnCount(BuildContext context) {
    if (isDesktop(context)) return 3;
    if (isTablet(context)) return 2;
    return 1;
  }

  /// Get max content width for desktop (centered layout)
  static double getMaxContentWidth(BuildContext context) {
    return isDesktop(context) ? 1200.0 : screenWidth(context);
  }

  /// Wrap content with max width for desktop
  static Widget constrainWidth({
    required BuildContext context,
    required Widget child,
    double? maxWidth,
  }) {
    if (!isDesktop(context)) return child;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? getMaxContentWidth(context),
        ),
        child: child,
      ),
    );
  }
}

/// Responsive builder widget for conditional layouts
class ResponsiveBuilder extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    if (ResponsiveUtils.isDesktop(context)) return desktop;
    if (ResponsiveUtils.isTablet(context)) return tablet ?? mobile;
    return mobile;
  }
}
