import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../utils/constants.dart';
import 'custom_card.dart';

class ArticleCard extends StatelessWidget {
  final String title;
  final Color backgroundColor;
  final String imagePath;
  final String subtitle;
  final VoidCallback onTap;

  const ArticleCard({
    super.key,
    required this.title,
    required this.backgroundColor,
    required this.imagePath,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width / 1.7;

    return CustomCard(
      width: width,
      bgColor: backgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              height: 1.1,
              fontFamily: Constants.neulisNeueFontFamily,
            ),
          ),
          const Gap(4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              height: 1.1,
              fontWeight: FontWeight.w500,
              fontFamily: Constants.neulisNeueFontFamily,
            ),
          ),
          const Gap(16),
          Image.asset(imagePath, height: 130, width: 130, fit: BoxFit.contain),
        ],
      ),
    );
  }
}
