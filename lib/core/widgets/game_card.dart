import 'package:flutter/material.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_card.dart';

class GameCard extends StatelessWidget {
  final EdgeInsetsGeometry? padding;
  final Widget child;

  const GameCard({super.key, this.padding, required this.child});

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      padding: padding,
      hasShadow: true,
      shadow: [
        BoxShadow(
          offset: Offset(0, 2),
          blurRadius: 0,
          spreadRadius: 0,
          color: AppColors.black.withValues(alpha: 0.25),
        ),
      ],
      bgColor: AppColors.white,
      borderColor: AppColors.grey,
      child: child,
    );
  }
}
