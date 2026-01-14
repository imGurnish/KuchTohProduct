import 'package:flutter/material.dart';

/// Responsive Breakpoints for Mindspace
///
/// Defines screen size breakpoints for responsive layouts.
abstract class Breakpoints {
  /// Mobile phones (< 600)
  static const double mobile = 600;

  /// Tablets (600-900)
  static const double tablet = 900;

  /// Desktop (900-1200)
  static const double desktop = 1200;

  /// Large desktop (> 1200)
  static const double largeDesktop = 1200;
}

/// Screen type enum for responsive layouts
enum ScreenType { mobile, tablet, desktop }

/// Responsive Layout Builder
///
/// Builds different layouts based on screen size.
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(
    BuildContext context,
    ScreenType screenType,
    BoxConstraints constraints,
  )
  builder;

  const ResponsiveBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenType = _getScreenType(constraints.maxWidth);
        return builder(context, screenType, constraints);
      },
    );
  }

  static ScreenType _getScreenType(double width) {
    if (width < Breakpoints.mobile) {
      return ScreenType.mobile;
    } else if (width < Breakpoints.tablet) {
      return ScreenType.tablet;
    } else {
      return ScreenType.desktop;
    }
  }
}

/// Extension to easily check screen type
extension ScreenTypeExtension on BuildContext {
  ScreenType get screenType {
    final width = MediaQuery.of(this).size.width;
    if (width < Breakpoints.mobile) {
      return ScreenType.mobile;
    } else if (width < Breakpoints.tablet) {
      return ScreenType.tablet;
    } else {
      return ScreenType.desktop;
    }
  }

  bool get isMobile => screenType == ScreenType.mobile;
  bool get isTablet => screenType == ScreenType.tablet;
  bool get isDesktop => screenType == ScreenType.desktop;

  /// Get responsive value based on screen type
  T responsive<T>({required T mobile, T? tablet, T? desktop}) {
    switch (screenType) {
      case ScreenType.mobile:
        return mobile;
      case ScreenType.tablet:
        return tablet ?? mobile;
      case ScreenType.desktop:
        return desktop ?? tablet ?? mobile;
    }
  }
}

/// Responsive padding values
abstract class ResponsivePadding {
  static EdgeInsets horizontal(BuildContext context) {
    return EdgeInsets.symmetric(
      horizontal: context.responsive(mobile: 24.0, tablet: 48.0, desktop: 64.0),
    );
  }

  static EdgeInsets all(BuildContext context) {
    return EdgeInsets.all(
      context.responsive(mobile: 16.0, tablet: 24.0, desktop: 32.0),
    );
  }
}

/// Responsive sizing values
abstract class ResponsiveSizing {
  static double maxContentWidth(BuildContext context) {
    return context.responsive(
      mobile: double.infinity,
      tablet: 500.0,
      desktop: 480.0,
    );
  }

  static double logoSize(BuildContext context) {
    return context.responsive(mobile: 64.0, tablet: 72.0, desktop: 80.0);
  }

  static double titleSize(BuildContext context) {
    return context.responsive(mobile: 28.0, tablet: 32.0, desktop: 36.0);
  }

  static double buttonHeight(BuildContext context) {
    return context.responsive(mobile: 52.0, tablet: 56.0, desktop: 56.0);
  }
}
