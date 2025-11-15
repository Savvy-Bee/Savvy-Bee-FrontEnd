import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';

import '../../../../core/utils/assets/app_icons.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/widgets/custom_card.dart';

enum InsightType { nahlInsight, nextBestAction, alert }

class InsightCard extends StatefulWidget {
  final String text;
  final InsightType insightType;
  final bool isExpandable;

  const InsightCard({
    super.key,
    required this.text,
    required this.insightType,
    this.isExpandable = false,
    // this.showText = true,
  });

  @override
  State<InsightCard> createState() => _InsightCardState();
}

class _InsightCardState extends State<InsightCard> {
  bool showText = false;

  @override
  Widget build(BuildContext context) {
    var textStyle = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      fontFamily: Constants.neulisNeueFontFamily,
    );
    return CustomCard(
      onTap: widget.isExpandable
          ? () {
              setState(() {
                showText = !showText;
              });
            }
          : null,
      bgColor: switch (widget.insightType) {
        InsightType.alert => AppColors.error,
        InsightType.nahlInsight => AppColors.primary,
        InsightType.nextBestAction => AppColors.blue,
      }.withValues(alpha: 0.1),
      borderColor: switch (widget.insightType) {
        InsightType.alert => AppColors.error,
        InsightType.nahlInsight => AppColors.primary,
        InsightType.nextBestAction => AppColors.blue,
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppIcon(
                switch (widget.insightType) {
                  InsightType.alert => AppIcons.infoIcon,
                  InsightType.nahlInsight => AppIcons.sparklesIcon,
                  InsightType.nextBestAction => AppIcons.zapIcon,
                },
                color: switch (widget.insightType) {
                  InsightType.alert => AppColors.error,
                  InsightType.nahlInsight => AppColors.primary,
                  InsightType.nextBestAction => AppColors.blue,
                },
              ),
              const Gap(10),
              if (!widget.isExpandable)
                Expanded(child: Text(widget.text, style: textStyle)),
              if (widget.isExpandable)
                Expanded(
                  child: Text(
                    switch (widget.insightType) {
                      InsightType.alert => 'Alert',
                      InsightType.nahlInsight => 'Nahl Insights',
                      InsightType.nextBestAction => 'Next best action',
                    },
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      fontFamily: Constants.neulisNeueFontFamily,
                    ),
                  ),
                ),
              if (widget.isExpandable)
                Icon(
                  showText
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                ),
            ],
          ),
          if (widget.isExpandable && showText) const Gap(4),
          if (widget.isExpandable && showText)
            Text(widget.text, style: textStyle),
        ],
      ),
    );
  }
}
