import 'package:flutter/material.dart';

class Breakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobile;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= mobile &&
      MediaQuery.of(context).size.width < tablet;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= desktop;

  static double contentMaxWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= desktop) return desktop - 48; // 24px padding on each side
    if (width >= tablet) return tablet - 48;
    return width - 32; // 16px padding on each side for mobile
  }

  static EdgeInsets screenPadding(BuildContext context) {
    if (isDesktop(context)) {
      return const EdgeInsets.symmetric(horizontal: 24, vertical: 32);
    }
    if (isTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 24, vertical: 24);
    }
    return const EdgeInsets.symmetric(horizontal: 16, vertical: 16);
  }

  static double imageSize(BuildContext context) {
    if (isDesktop(context)) return 400;
    if (isTablet(context)) return 300;
    return 250;
  }

  static double get buttonMaxWidth => 400;

  static double screenWidth(BuildContext context) {
    return MediaQuery.sizeOf(context).width;
  }

  static double screenHeight(BuildContext context) {
    return MediaQuery.sizeOf(context).height;
  }
}
