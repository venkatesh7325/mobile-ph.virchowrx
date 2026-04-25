import 'package:flutter/material.dart';

class Responsive {
  static const double _mobileBreakpoint = 480;
  static const double _tabletBreakpoint = 768;
  static const double _desktopBreakpoint = 1200;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < _mobileBreakpoint;

  static bool isTablet(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return w >= _mobileBreakpoint && w < _desktopBreakpoint;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= _desktopBreakpoint;

  static double screenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double screenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  static EdgeInsets pagePadding(BuildContext context) {
    final w = screenWidth(context);
    if (w >= _desktopBreakpoint) return const EdgeInsets.symmetric(horizontal: 48, vertical: 24);
    if (w >= _tabletBreakpoint) return const EdgeInsets.symmetric(horizontal: 32, vertical: 20);
    return const EdgeInsets.symmetric(horizontal: 16, vertical: 16);
  }

  static int gridCrossAxisCount(BuildContext context) {
    final w = screenWidth(context);
    if (w >= _desktopBreakpoint) return 4;
    if (w >= _tabletBreakpoint) return 3;
    if (w >= _mobileBreakpoint) return 2;
    return 2;
  }

  static double cardWidth(BuildContext context) {
    final w = screenWidth(context);
    if (w >= _desktopBreakpoint) return 280;
    if (w >= _tabletBreakpoint) return 220;
    return (w - 48) / 2;
  }

  static T value<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop(context)) return desktop ?? tablet ?? mobile;
    if (isTablet(context)) return tablet ?? mobile;
    return mobile;
  }
}

class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  static const SizedBox hXs = SizedBox(width: xs);
  static const SizedBox hSm = SizedBox(width: sm);
  static const SizedBox hMd = SizedBox(width: md);
  static const SizedBox hLg = SizedBox(width: lg);

  static const SizedBox vXs = SizedBox(height: xs);
  static const SizedBox vSm = SizedBox(height: sm);
  static const SizedBox vMd = SizedBox(height: md);
  static const SizedBox vLg = SizedBox(height: lg);
  static const SizedBox vXl = SizedBox(height: xl);
  static const SizedBox vXxl = SizedBox(height: xxl);
}
