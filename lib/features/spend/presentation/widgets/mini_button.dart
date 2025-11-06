import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class MiniButton extends StatelessWidget {
  final VoidCallback? onTap;
  final String text;
  final Widget? child;
  MiniButton({super.key, this.onTap, this.text = 'Share', this.child});

  final borderRadius = BorderRadius.circular(8);
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: borderRadius,
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: onTap == null
              ? AppColors.buttonPrimary.withValues(alpha: 0.3)
              : AppColors.buttonPrimary,
          borderRadius: borderRadius,
        ),
        child:
            child ??
            Text(
              text,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: onTap == null ? AppColors.grey : null,
              ),
            ),
      ),
    );
  }
}
