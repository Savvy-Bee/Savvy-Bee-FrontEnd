import 'package:flutter/material.dart';

class AppColors {
  // Base colors
  static const white = Color(0xFFFFFFFF);
  static const black = Color(0xFF000000);
  static const grey = Color(0xFFF5F5F5);
  static const greyDark = Color(0xFF999999);
  static const greyLight = Color(0xFFF5F5F5);

  static const bgBlue = Color(0xFFADE1F9);

  // Primary Colors
  static const Color primary = Color(0xFFFFB800);
  static const Color primaryDark = Color(0xFFE6A600);
  static const Color primaryLight = Color(0xFFFFCC33);
  static const Color primaryFaded = Color(0xFFFFEFB5);

  // Secondary Colors
  static const Color secondary = Color(0xFF000000);
  static const Color secondaryDark = Color(0xFF1A1A1A);
  static const Color secondaryLight = Color(0xFF333333);

  // Background Colors
  static const Color background = Color(0xFFFFFFFF);
  static const Color backgroundDark = Color(0xFFF5F5F5);
  static const Color backgroundLight = Color(0xFFFAFAFA);

  // Text Colors
  static const Color textPrimary = Color(0xFF000000);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textLight = Color(0xFF999999);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);

  // Button Colors
  static const Color buttonPrimary = primary;
  static const Color buttonSecondary = secondary;
  static const Color buttonDisabled = Color(0xFFCCCCCC);

  // Border Colors
  static const Color border = Color(0xFFE0E0E0);
  static const Color borderDark = Color(0xFFBDBDBD);
  static const Color borderLight = Color(0xFFF0F0F0);

  // Overlay Colors
  static const Color overlay = Color(0x80000000);
  static const Color overlayLight = Color(0x40000000);

  // Gradient Colors
  static const List<Color> primaryGradient = [primary, primaryLight];

  static const List<Color> secondaryGradient = [secondary, secondaryLight];
}
