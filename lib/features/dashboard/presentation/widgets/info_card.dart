import 'package:flutter/material.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';

import '../../../../core/widgets/custom_card.dart';

class InfoCard extends StatelessWidget {
  final String title;
  final String description;
  final String? avatar;
  final VoidCallback? onTap;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;

  const InfoCard({
    super.key,
    required this.title,
    required this.description,
    this.avatar,
    this.onTap,
    this.borderRadius = 16.0,
    this.backgroundColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      onTap: onTap,
      borderRadius: borderRadius,
      bgColor: backgroundColor,
      borderColor: borderColor,
      padding: EdgeInsets.fromLTRB(24, 16, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
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
                Text(description, style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
          if (avatar != null)
            Image.asset(
              avatar!,
              height: 50,
              width: 50,
              alignment: Alignment.centerRight,
            ),
        ],
      ),
    );
  }
}
