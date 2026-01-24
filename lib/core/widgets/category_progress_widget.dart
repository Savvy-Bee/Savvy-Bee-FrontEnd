import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../theme/app_colors.dart';
import '../utils/constants.dart';
import '../utils/num_extensions.dart';
import 'custom_card.dart';

class CategoryProgressWidget extends StatelessWidget {
  final String title;
  final double totalAmount;
  final double totalSpent;
  final Color color;

  const CategoryProgressWidget({
    super.key,
    required this.title,
    required this.totalAmount,
    required this.totalSpent,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      borderColor: AppColors.grey.withValues(alpha: 0.7),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            spacing: 8,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(5.0),
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: Icon(
                  Icons.dinner_dining_outlined,
                  size: 20,
                  color: AppColors.white,
                ),
              ),
              Text(
                title,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const Gap(6),
          LinearProgressIndicator(
            value: totalAmount == 0 ? 0 : totalSpent / totalAmount,
            backgroundColor: color.withValues(alpha: 0.2),
            minHeight: 5,
            borderRadius: BorderRadius.circular(10),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
          const Gap(6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                totalAmount == 0
                    ? '0%'
                    : '${(totalSpent / totalAmount * 100).toStringAsFixed(0)}%',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
              Text.rich(
                TextSpan(
                  text: totalSpent.formatCurrency(decimalDigits: 0),
                  children: [
                    TextSpan(
                      text:
                          ' of ${totalAmount.formatCurrency(decimalDigits: 0)}',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
