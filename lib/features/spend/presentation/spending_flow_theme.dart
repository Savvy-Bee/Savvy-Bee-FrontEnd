import 'package:flutter/material.dart';

class AppColors {
  // Base
  static const background = Color(0xFFFFFEFA);
  static const cardWhite = Color(0xFFFFFFFF);
  static const borderLight = Color(0xFFF0F0F0);
  static const textPrimary = Color(0xFF000000);
  static const textSecondary = Color(0xFF666666);
  static const textMuted = Color(0xFF999999);
  static const progressBg = Color(0xFFF0F0F0);

  // Category colors
  static const foodAmber = Color(0xFFE8A838);
  static const foodAmberLight = Color(0xFFFFF8EC);
  static const transportBlue = Color(0xFF3B82F6);
  static const transportBlueLight = Color(0xFFEFF6FF);
  static const billsPurple = Color(0xFF8B5CF6);
  static const billsPurpleLight = Color(0xFFF5F3FF);
  static const entertainmentGreen = Color(0xFF10B981);
  static const entertainmentGreenLight = Color(0xFFECFDF5);

  // Emotional insight colors
  static const coral = Color(0xFFE8623A);
  static const coralLight = Color(0xFFFFF4F1);
  static const coralSoft = Color(0xFFFED9CF);
  static const stressRed = Color(0xFFEF4444);
  static const stressRedLight = Color(0xFFFFF5F5);
  static const impulseBlue = Color(0xFF3B82F6);
  static const impulseBlueLight = Color(0xFFEFF6FF);
}

class AppTextStyles {
  static const displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    fontFamily: 'GeneralSans',
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );
  static const displayMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    fontFamily: 'GeneralSans',
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
  );
  static const headingMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    fontFamily: 'GeneralSans',
    color: AppColors.textPrimary,
  );
  static const bodyMedium = TextStyle(
    fontSize: 14,
    fontFamily: 'GeneralSans',
    color: AppColors.textPrimary,
  );
  static const bodySmall = TextStyle(
    fontSize: 13,
    fontFamily: 'GeneralSans',
    color: AppColors.textSecondary,
  );
  static const labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    fontFamily: 'GeneralSans',
    color: AppColors.textSecondary,
    letterSpacing: 0.3,
  );
  static const labelSmall = TextStyle(
    fontSize: 11,
    fontFamily: 'GeneralSans',
    color: AppColors.textMuted,
  );
  static const amountLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    fontFamily: 'GeneralSans',
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );
  static const amountMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    fontFamily: 'GeneralSans',
    color: AppColors.textPrimary,
  );
  static const amountSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    fontFamily: 'GeneralSans',
    color: AppColors.textPrimary,
  );
}

class CategoryInfo {
  final String icon;
  final Color iconBgColor;
  final Color progressColor;
  final String label;
  final String amount;
  final String percentage;

  const CategoryInfo({
    required this.icon,
    required this.iconBgColor,
    required this.progressColor,
    required this.label,
    required this.amount,
    required this.percentage,
  });
}
