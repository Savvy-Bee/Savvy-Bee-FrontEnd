import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/utils/number_formatter.dart';
import '../../../../core/widgets/charts/custom_donut_chart.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../../tools/presentation/widgets/insight_card.dart';
import '../../domain/models/dashboard_data.dart';

class SpendingCategoryWidget extends StatelessWidget {
  final SpendCategoryBreakdown spendingData;

  const SpendingCategoryWidget({super.key, required this.spendingData});

  @override
  Widget build(BuildContext context) {
    final categories = spendingData.categories.map((cat) {
      return ExpenseCategory(
        name: cat.name,
        amount: cat.amount,
        color: _getCategoryColor(cat.name),
        icon: _getCategoryIcon(cat.name),
      );
    }).toList();

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
                  if (categories.isNotEmpty)
                    CustomDonutChart(categories: categories, total: total)
                  else
                    Text('No spending data available'),
                  const Gap(20),
                  ...categories
                      .take(2)
                      .map((cat) => _buildExpenseCategoryTile(cat)),
                  const Gap(12),
                  if (categories.length > 2)
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
                  if (spendingData.insight.isNotEmpty)
                    InsightCard(
                      text: spendingData.insight,
                      insightType: InsightType.nahlInsight,
                      isExpandable: true,
                    ),
                  const Gap(8),
                  if (spendingData.nextAction.isNotEmpty)
                    InsightCard(
                      text: spendingData.nextAction,
                      insightType: InsightType.nextBestAction,
                      isExpandable: true,
                    ),
                  const Gap(8),
                  if (spendingData.alerts.isNotEmpty)
                    InsightCard(
                      text: spendingData.alerts,
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

  Color _getCategoryColor(String categoryName) {
    final colors = {
      'Auto & transport': const Color(0xFFFF3B30),
      'Shopping': const Color(0xFFFFCC00),
      'Entertainment': const Color(0xFF8BC34A),
      'Food & Dining': const Color(0xFFE4B5FF),
      'Bills & Utilities': const Color(0xFF2196F3),
      'Travel': const Color(0xFFFF9800),
      'Health': const Color(0xFF4CAF50),
      'Education': const Color(0xFF9C27B0),
    };
    return colors[categoryName] ?? Colors.grey;
  }

  IconData _getCategoryIcon(String categoryName) {
    final icons = {
      'Auto & transport': Icons.directions_car,
      'Shopping': Icons.shopping_bag,
      'Entertainment': Icons.movie,
      'Food & Dining': Icons.restaurant,
      'Bills & Utilities': Icons.receipt,
      'Travel': Icons.flight,
      'Health': Icons.medical_services,
      'Education': Icons.school,
    };
    return icons[categoryName] ?? Icons.category;
  }
}

// Helper class for chart compatibility
class ExpenseCategory {
  final String name;
  final double amount;
  final Color color;
  final IconData icon;

  ExpenseCategory({
    required this.name,
    required this.amount,
    required this.color,
    required this.icon,
  });
}
