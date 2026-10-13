import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

class Breakpoints {
  static const mobile = 0;
  static const tablet = 600;
  static const desktop = 1100;
}

extension ResponsiveX on BuildContext {
  bool get isMobile => MediaQuery.sizeOf(this).width < Breakpoints.tablet;
  bool get isTablet =>
      MediaQuery.sizeOf(this).width >= Breakpoints.tablet &&
      MediaQuery.sizeOf(this).width < Breakpoints.desktop;
  bool get useRail => MediaQuery.sizeOf(this).width >= Breakpoints.tablet;

  double get contentMaxWidth {
    final w = MediaQuery.sizeOf(this).width;
    if (w >= Breakpoints.desktop) return 960;
    if (w >= Breakpoints.tablet) return 840;
    return w;
  }
}

List<Breakpoint> responsiveBreakpoints() => [
  const Breakpoint(start: 0, end: 599, name: MOBILE),
  const Breakpoint(start: 600, end: 1099, name: TABLET),
  const Breakpoint(start: 1100, end: double.infinity, name: DESKTOP),
];
