import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/app_colors.dart';

class CopyTextIconButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  const CopyTextIconButton({super.key, required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: AppColors.primary,
            ),
          ),
          const Gap(5.0),
          Icon(Icons.copy, size: 14, weight: 2, color: AppColors.primary),
        ],
      ),
    );
  }
}
