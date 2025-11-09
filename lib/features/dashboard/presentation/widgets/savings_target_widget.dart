import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/widgets/insight_card.dart';

import '../../../../core/widgets/outlined_card.dart';

class SavingsTargetWidget extends StatelessWidget {
  const SavingsTargetWidget({super.key});

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
                  const Text('Semi Circular Progress indicator'),

                  const Gap(24.0),
                  CustomElevatedButton(
                    text: 'Get more insights',
                    onPressed: () {},
                    buttonColor: CustomButtonColor.black,
                  ),
                  const Gap(24.0),
                  InsightCard(
                    text:
                        "I'm having trouble analyzing your spending patterns right now",
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
