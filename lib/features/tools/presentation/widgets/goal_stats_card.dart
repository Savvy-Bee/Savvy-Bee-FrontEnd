import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/assets/assets.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';
import 'package:savvy_bee_mobile/core/utils/number_formatter.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_card.dart';

class GoalStatsCard extends StatelessWidget {
  final String title;
  final double amountSaved, totalTarget;
  final int daysLeft;
  final bool isDebt;

  const GoalStatsCard({
    super.key,
    required this.title,
    required this.amountSaved,
    required this.totalTarget,
    required this.daysLeft,
    this.isDebt = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primaryFaint,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Image.asset(Assets.honeyJar4, height: 50, width: 50),
          ),
          const Gap(24),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: Constants.neulisNeueFontFamily,
                  ),
                ),
                const Gap(8),
                Row(
                  spacing: 14,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    buildStatItem(
                      NumberFormatter.compactCurrency(amountSaved),
                      isDebt ? 'Paid' : 'Saved',
                    ),
                    buildStatItem(
                      NumberFormatter.compactCurrency(totalTarget),
                      'Total Target',
                    ),
                    buildStatItem(daysLeft.toString(), 'Days Left'),
                  ],
                ),
                const Gap(8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: totalTarget == 0 ? 0 : amountSaved / totalTarget,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const Gap(4),
                    Text(
                      '${((amountSaved / totalTarget) * 100).toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 8,
                        fontFamily: Constants.neulisNeueFontFamily,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildStatItem(String title, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            fontFamily: Constants.neulisNeueFontFamily,
          ),
        ),
        Text(
          value,
          style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
