import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/widgets/insight_card.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/charts/arc_progress_indicator.dart';
import '../../../../core/widgets/custom_card.dart';

class SavingsTargetWidget extends StatelessWidget {
  final String savingsInsight;

  const SavingsTargetWidget({super.key, required this.savingsInsight});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 1.25,
      child: CustomCard(
        hasShadow: true,
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
              child: const Text(
                'SAVINGS TARGET',
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
                  ArcProgressIndicator(
                    progress: 0.7, // This should come from actual savings data
                    color: AppColors.success,
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Gap(16),
                        Text(
                          '80%',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '₦160,000',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'of ₦200,000',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Gap(24.0),
                  CustomElevatedButton(
                    text: 'Get more insights',
                    onPressed: () {},
                    buttonColor: CustomButtonColor.black,
                  ),
                  const Gap(24.0),
                  if (savingsInsight.isNotEmpty)
                    InsightCard(
                      text: savingsInsight,
                      insightType: InsightType.nextBestAction,
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
