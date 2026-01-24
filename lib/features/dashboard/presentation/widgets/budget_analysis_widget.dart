import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';
import 'package:savvy_bee_mobile/core/utils/num_extensions.dart';
import 'package:savvy_bee_mobile/core/widgets/category_progress_widget.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';

import '../../../../core/widgets/custom_card.dart';

class BudgetAnalysisWidget extends StatelessWidget {
  const BudgetAnalysisWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 1.1,
      child: CustomCard(
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
                              192000.formatCurrency(decimalDigits: 0),
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '${6000.formatCurrency(decimalDigits: 0)} budget',
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
                  CategoryProgressWidget(
                    title: 'Dining & drinks',
                    totalAmount: 100000,
                    totalSpent: 10000,
                    color: AppColors.primary,
                  ),
                  const Gap(8.0),
                  CategoryProgressWidget(
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
}
