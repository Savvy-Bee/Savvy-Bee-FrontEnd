import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/utils/assets/app_icons.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/widgets/outlined_card.dart';

class InsightCard extends StatelessWidget {
  final String iconPath;
  final String text;
  final Color color;

  const InsightCard({
    super.key,
    required this.iconPath,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedCard(
      bgColor: color.withValues(alpha: 0.1),
      borderColor: color,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppIcon(iconPath, color: color),
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
