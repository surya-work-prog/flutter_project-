import 'package:flutter/material.dart';

class Responsive {
  // Breakpoints
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 1024;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1024;

  // Screen size helpers
  static double screenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double screenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  // Useful layout helpers
  static double horizontalPadding(BuildContext context) {
    if (isMobile(context)) return 16;
    if (isTablet(context)) return 24;
    return 40;
  }

  static double maxContentWidth(BuildContext context) {
    if (isDesktop(context)) return 1200;
    return double.infinity;
  }

  static int galleryColumns(BuildContext context) {
    if (isMobile(context)) return 2;
    if (isTablet(context)) return 3;
    return 4;
  }

  static double heroTitleSize(BuildContext context) {
    if (isMobile(context)) return 28;
    if (isTablet(context)) return 38;
    return 48;
  }

  static double heroSubtitleSize(BuildContext context) {
    if (isMobile(context)) return 14;
    if (isTablet(context)) return 16;
    return 18;
  }

  static double heroHeight(BuildContext context) {
    if (isMobile(context)) return 260;
    if (isTablet(context)) return 320;
    return 380;
  }

  static double serviceCardWidth(BuildContext context) {
    if (isMobile(context)) return double.infinity;
    if (isTablet(context)) return 220;
    return 250;
  }

  static double imageBoxSize(BuildContext context) {
    if (isMobile(context)) return 110;
    if (isTablet(context)) return 140;
    return 180;
  }
}