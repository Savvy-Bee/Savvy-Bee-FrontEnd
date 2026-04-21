import 'package:flutter/material.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/spending_flow_theme.dart';

class EmotionalInsightBanner extends StatelessWidget {
  final VoidCallback? onTap;

  const EmotionalInsightBanner({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.coralLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.coralSoft),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('🧠', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Emotional insight',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.coral,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'You spend 30% more when stressed. Most occurs on weekday evenings.',
                    style: AppTextStyles.bodyMedium.copyWith(height: 1.45),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        'View patterns ',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.coral,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        size: 14,
                        color: AppColors.coral,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
