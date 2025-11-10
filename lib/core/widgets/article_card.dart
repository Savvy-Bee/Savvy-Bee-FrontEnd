import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../utils/constants.dart';
import 'outlined_card.dart';

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
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: 200,
        width: MediaQuery.sizeOf(context).width / 1.7,
        child: OutlinedCard(
          padding: EdgeInsets.zero,
          bgColor: backgroundColor,
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.0),
                    topRight: Radius.circular(16.0),
                  ),
                ),
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    height: 1.1,
                    fontFamily: Constants.neulisNeueFontFamily,
                  ),
                ),
              ),

              Positioned(
                bottom: 0,
                right: 0,
                child: Image.asset(
                  imagePath,
                  height: 130,
                  width: 130,
                  fit: BoxFit.contain,
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  width: 100,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.1,
                        fontWeight: FontWeight.w500,
                        fontFamily: Constants.neulisNeueFontFamily,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
