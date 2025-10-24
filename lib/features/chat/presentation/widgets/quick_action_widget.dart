import 'package:flutter/material.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';

class QuickActionWidget extends StatelessWidget {
  final Widget icon;
  final String label;
  final VoidCallback? onTap;

  const QuickActionWidget({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.0),
      child: Container(
        constraints: BoxConstraints(minWidth: 100.0),
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 3.0,
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryFaint,
              ),
              child: icon,
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
