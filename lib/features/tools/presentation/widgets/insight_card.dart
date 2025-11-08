import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';

import '../../../../core/utils/assets/app_icons.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/widgets/outlined_card.dart';

enum InsightType { nahlInsight, nextBestAction, alert }

class InsightCard extends StatelessWidget {
  final String text;
  final InsightType insightType;
  final bool isExpandable, showText;

  const InsightCard({
    super.key,
    required this.text,
    required this.insightType,
    this.isExpandable = false,
    this.showText = true,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedCard(
      bgColor: switch (insightType) {
        InsightType.alert => AppColors.error,
        InsightType.nahlInsight => AppColors.primary,
        InsightType.nextBestAction => AppColors.bgBlue,
      }.withValues(alpha: 0.1),
      borderColor: switch (insightType) {
        InsightType.alert => AppColors.error,
        InsightType.nahlInsight => AppColors.primary,
        InsightType.nextBestAction => AppColors.bgBlue,
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppIcon(
            switch (insightType) {
              InsightType.alert => AppIcons.infoIcon,
              InsightType.nahlInsight => AppIcons.sparklesIcon,
              InsightType.nextBestAction => AppIcons.zapIcon,
            },
            color: switch (insightType) {
              InsightType.alert => AppColors.error,
              InsightType.nahlInsight => AppColors.primary,
              InsightType.nextBestAction => AppColors.bgBlue,
            },
          ),
          const Gap(10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                fontFamily: Constants.neulisNeueFontFamily,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
