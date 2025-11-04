import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';
import 'package:savvy_bee_mobile/core/utils/number_formatter.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';

import '../../../../core/widgets/outlined_card.dart';

class BudgetAnalysisWidget extends StatelessWidget {
  const BudgetAnalysisWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 1.1,
      child: OutlinedCard(
        hasShadow: true,
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
              child: const Text(
                'BUDGET ANALYSIS',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const Divider(height: 0),
            const Gap(24.0),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox.square(
                        dimension: 220,
                        child: CircularProgressIndicator(
                          strokeWidth: 35,
                          strokeCap: StrokeCap.round,
                          value: 0.2,
                          backgroundColor: AppColors.primaryFaint,
                        ),
                      ),
                      Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withValues(alpha: 0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '38%',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.secondaryLight,
                              ),
                            ),
                            Text(
                              NumberFormatter.formatCurrency(
                                192000,
                                decimalDigits: 0,
                              ),
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w500,
                                fontFamily: Constants.neulisNeueFontFamily,
                              ),
                            ),
                            Text(
                              '${NumberFormatter.formatCurrency(600000, decimalDigits: 0)} budget',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Gap(24.0),
                  _buildBudgetWidget(
                    title: 'Dining & drinks',
                    totalAmount: 100000,
                    totalSpent: 10000,
                    color: AppColors.primary,
                  ),
                  const Gap(8.0),
                  _buildBudgetWidget(
                    title: 'Dining & drinks',
                    totalAmount: 100000,
                    totalSpent: 10000,
                    color: AppColors.success,
                  ),
                  const Gap(24.0),
                  SizedBox(
                    width: double.infinity,
                    child: CustomOutlinedButton(
                      text: 'Edit budget',
                      icon: Icon(
                        Icons.arrow_forward,
                        size: 16,
                        color: Colors.black,
                      ),
                      onPressed: () {},
                    ),
                  ),
                  const Gap(8.0),
                  CustomElevatedButton(
                    text: 'Get more insights',
                    onPressed: () {},
                    buttonColor: CustomButtonColor.black,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetWidget({
    required String title,
    required double totalAmount,
    required double totalSpent,
    required Color color,
  }) {
    return OutlinedCard(
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
            value: totalSpent / totalAmount,
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
                '${(totalSpent / totalAmount * 100).toStringAsFixed(2)}%',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
              Text.rich(
                TextSpan(
                  text: NumberFormatter.formatCurrency(
                    totalSpent,
                    decimalDigits: 0,
                  ),
                  children: [
                    TextSpan(
                      text:
                          ' of ${NumberFormatter.formatCurrency(totalAmount, decimalDigits: 0)}',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  fontFamily: Constants.neulisNeueFontFamily,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
