import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';
import 'package:savvy_bee_mobile/core/widgets/charts/arc_progress_indicator.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/widgets/insight_card.dart';

import '../../../../core/widgets/outlined_card.dart';

class FinancialHealthWidget extends StatelessWidget {
  const FinancialHealthWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 1.25,
      child: OutlinedCard(
        hasShadow: true,
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
              child: const Text(
                'FINANCIAL HEALTH STATUS',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const Divider(height: 0),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  ArcProgressIndicator(progress: 0.7, color: AppColors.primary),
                  Text(
                    'Your financial health is Thriving!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: Constants.neulisNeueFontFamily,
                    ),
                  ),
                  const Gap(16.0),
                  Text(
                    "You've hit a strong balance between saving and spending and you're actively growing wealth",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: Constants.neulisNeueFontFamily,
                    ),
                  ),
                  const Gap(24.0),
                  InsightCard(
                    text:
                        "I'm having trouble analyzing your spending patterns right now",
                    insightType: InsightType.nahlInsight,
                    isExpandable: true,
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
