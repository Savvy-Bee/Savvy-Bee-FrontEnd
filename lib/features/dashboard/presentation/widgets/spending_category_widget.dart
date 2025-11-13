import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/utils/number_formatter.dart';
import '../../../../core/widgets/charts/custom_donut_chart.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../../tools/presentation/widgets/insight_card.dart';
import '../screens/dashboard_screen.dart';

class SpendingCategoryWidget extends ConsumerWidget {
  const SpendingCategoryWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(expenseCategoriesProvider);
    final total = categories.fold<double>(0, (sum, cat) => sum + cat.amount);

    return SizedBox(
      width: MediaQuery.of(context).size.width / 1.25,
      child: CustomCard(
        hasShadow: true,
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
              child: const Text(
                'SPENDING CATEGORY BREAKDOWN',
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
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Gap(10),
                  CustomDonutChart(categories: categories, total: total),
                  const Gap(20),
                  ...categories
                      .take(2)
                      .map((cat) => _buildExpenseCategoryTile(cat)),
                  const Gap(12),
                  SizedBox(
                    width: double.infinity,
                    child: CustomOutlinedButton(
                      text: 'See all',
                      icon: Icon(
                        Icons.arrow_forward,
                        size: 16,
                        color: Colors.black,
                      ),
                      onPressed: () {},
                    ),
                  ),
                  const Gap(8),
                  InsightCard(
                    text:
                        "I'm having trouble analyzing your spending patterns right now",
                    insightType: InsightType.nahlInsight,
                    isExpandable: true,
                  ),
                  const Gap(8),
                  InsightCard(
                    text:
                        "I'm having trouble analyzing your spending patterns right now",
                    insightType: InsightType.nextBestAction,
                    isExpandable: true,
                  ),
                  const Gap(8),
                  InsightCard(
                    text:
                        "I'm having trouble analyzing your spending patterns right now",
                    insightType: InsightType.alert,
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

  Widget _buildExpenseCategoryTile(ExpenseCategory category) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(5.0),
            decoration: BoxDecoration(
              color: category.color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(category.icon, color: category.color, size: 20),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: Constants.neulisNeueFontFamily,
                  ),
                ),
                const Text(
                  '\$0 last month',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Text(
            NumberFormatter.formatCurrency(category.amount, decimalDigits: 0),
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
