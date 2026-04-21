import 'package:flutter/material.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/spending_flow_theme.dart';

class CategoryRow extends StatelessWidget {
  final String icon;
  final Color iconBgColor;
  final String label;
  final String percentage;
  final String amount;
  final Color progressColor;
  final double progressValue;
  final VoidCallback? onTap;
  final bool showDivider;

  const CategoryRow({
    super.key,
    required this.icon,
    required this.iconBgColor,
    required this.label,
    required this.percentage,
    required this.amount,
    required this.progressColor,
    required this.progressValue,
    this.onTap,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Center(
                    child: Text(icon, style: const TextStyle(fontSize: 22)),
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(label, style: AppTextStyles.amountSmall),
                          Text(amount, style: AppTextStyles.amountSmall),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(percentage, style: AppTextStyles.labelSmall),
                      const SizedBox(height: 7),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progressValue,
                          backgroundColor: AppColors.progressBg,
                          valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: AppColors.textMuted,
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(height: 1, color: AppColors.borderLight),
      ],
    );
  }
}
