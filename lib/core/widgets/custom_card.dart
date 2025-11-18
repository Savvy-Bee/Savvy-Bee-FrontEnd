/// Custom Outlined Card Widget
library;

import 'package:flutter/material.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final double borderRadius;
  final bool hasShadow;
  final Color? bgColor;
  final Color? borderColor;
  final double? width;
  final double? height;
  final double? borderWidth;
  final List<BoxShadow>? shadow;


  const CustomCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.borderRadius = 16.0,
    this.hasShadow = false,
    this.bgColor,
    this.borderColor,
    this.width,
    this.height,
    this.borderWidth,
    this.shadow,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        height: height,
        width: width,
        clipBehavior: Clip.hardEdge,
        padding: padding ?? const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: borderColor ?? AppColors.black.withValues(alpha: 0.5),
            width: borderWidth ?? 1,
          ),
          boxShadow: hasShadow
              ? shadow ?? [
                  BoxShadow(
                    color: AppColors.black.withValues(alpha: 0.1),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  ),
                ]
              : null,
          color: bgColor ?? (hasShadow ? AppColors.white : null),
        ),
        child: child,
      ),
    );
  }
}
