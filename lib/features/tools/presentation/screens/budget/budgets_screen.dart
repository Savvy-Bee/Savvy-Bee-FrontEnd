import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/assets/app_icons.dart';
import 'package:savvy_bee_mobile/core/utils/num_extensions.dart';
import 'package:savvy_bee_mobile/core/widgets/bottom_sheets/budget_category_bottom_sheet.dart';
import 'package:savvy_bee_mobile/core/widgets/bottom_sheets/edit_budget_bottom_sheet.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_error_widget.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_loading_widget.dart';
import 'package:savvy_bee_mobile/features/tools/domain/models/budget.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/providers/budget_provider.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/screens/budget/set_budget_screen.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/screens/budget/set_income_screen.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/widgets/insight_card.dart';

/// Main Budgets Screen matching the new design
/// Features: Month selector, spending card, budget basics, category breakdown
class BudgetsScreen extends ConsumerStatefulWidget {
  static const String path = '/budgets';

  const BudgetsScreen({super.key});

  @override
  ConsumerState<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends ConsumerState<BudgetsScreen> {
  int _selectedMonthIndex = DateTime.now().month - 1; // Current month

  final List<String> _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'groceries':
        return Icons.shopping_cart;
      case 'auto & transport':
        return Icons.directions_car;
      case 'electricity':
        return Icons.bolt;
      case 'other':
        return Icons.category;
      default:
        return Icons.circle;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'groceries':
        return const Color(0xFFFF006E);
      case 'auto & transport':
        return const Color(0xFFFF6B35);
      case 'electricity':
        return const Color(0xFFFFBE0B);
      case 'other':
        return const Color(0xFF06D6A0);
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final budgetState = ref.watch(budgetHomeNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Budgets',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            fontFamily: 'GeneralSans',
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
      ),
      body: budgetState.when(
        loading: () =>
            const CustomLoadingWidget(text: 'Loading your budgets...'),
        error: (error, stack) => CustomErrorWidget(
          icon: Icons.savings_outlined,
          title: 'Unable to Load Budgets',
          subtitle:
              'We couldn\'t fetch your budgets. Please check your connection and try again.',
          actionButtonText: 'Retry',
          onActionPressed: () {
            ref.invalidate(budgetHomeNotifierProvider);
          },
        ),
        data: (data) {
          final totalBudget = data.budgets.fold<num>(
            0,
            (prev, budget) => prev + budget.targetAmountMonthly,
          );
          final totalSpent = data.budgets.fold<num>(
            0,
            (prev, budget) => prev + budget.balance,
          );
          final monthlySavings = data.totalEarnings - totalBudget;
          final safeToSpend = totalBudget - totalSpent;

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(budgetHomeNotifierProvider);
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Month Selector
                _buildMonthSelector(),
                const Gap(16),

                // Alert Insight Card
                // InsightCard(
                //   insightType: InsightType.nahlInsight,
                //   text:
                //       "You've spent 15% more on transport this month. Try adjusting your allocation.",
                //   // backgroundColor: const Color(0xFFE3F2FD),
                // ),
                // const Gap(24),

                // Spending Card
                _buildSpendingCard(safeToSpend, totalSpent, totalBudget),
                const Gap(32),

                // Budget Basics Section
                const Text(
                  'BUDGET BASICS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'GeneralSans',
                    color: Color(0xFF757575),
                    letterSpacing: 0.5,
                  ),
                ),
                const Gap(12),

                _buildBudgetBasics(
                  data.totalEarnings,
                  totalBudget,
                  monthlySavings,
                ),
                const Gap(32),

                // Category Breakdown
                const Text(
                  'BREAKDOWN',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'GeneralSans',
                    color: Color(0xFF757575),
                    letterSpacing: 0.5,
                  ),
                ),
                const Gap(12),

                _buildCategoryBreakdown(data.budgets),
                const Gap(24),

                // Add Category Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      BudgetCategoryBottomSheet.show(context);
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.black),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Add category',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'GeneralSans',
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                const Gap(16),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Budget saved successfully!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.yellow,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Save',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'GeneralSans',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMonthSelector() {
    return Row(
      children: List.generate(3, (index) {
        final monthIndex = (_selectedMonthIndex - 1 + index) % 12;
        final isSelected = monthIndex == _selectedMonthIndex;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: index < 2 ? 8 : 0),
            child: InkWell(
              onTap: () {
                // setState(() {
                //   _selectedMonthIndex = monthIndex;
                // });
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.yellow : Colors.white,
                  border: Border.all(
                    color: isSelected ? AppColors.yellow : Colors.grey.shade300,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    _months[monthIndex],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'GeneralSans',
                      color: isSelected ? Colors.black : Colors.grey.shade700,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSpendingCard(num safeToSpend, num totalSpent, num totalBudget) {
    final progress = totalBudget > 0
        ? (totalSpent / totalBudget).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.calculate_outlined,
                    size: 20,
                    color: Colors.grey.shade700,
                  ),
                  const Gap(8),
                  const Text(
                    'Spending',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'GeneralSans',
                    ),
                  ),
                ],
              ),
              // Icon(Icons.chevron_right, color: Colors.grey.shade400),
            ],
          ),
          const Gap(12),

          Text(
            'Safe To Spend',
            style: TextStyle(
              fontSize: 12,
              fontFamily: 'GeneralSans',
              color: Colors.grey.shade600,
            ),
          ),
          const Gap(4),

          Text(
            safeToSpend.toDouble().formatCurrency(decimalDigits: 0),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              fontFamily: 'GeneralSans',
            ),
          ),
          const Gap(16),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                progress > 0.8 ? Colors.red : AppColors.success,
              ),
              minHeight: 8,
            ),
          ),
          const Gap(8),

          // Spent and Budgeted Labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${totalSpent.toDouble().formatCurrency(decimalDigits: 0)} spent',
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'GeneralSans',
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                '${totalBudget.toDouble().formatCurrency(decimalDigits: 0)} budgeted',
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'GeneralSans',
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetBasics(num income, num budget, num savings) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          _buildBasicItem(
            Icons.account_balance_wallet_outlined,
            'Monthly Income',
            income,
            onTap: () => context.pushNamed(SetIncomeScreen.path),
          ),
          const Divider(height: 32),
          _buildBasicItem(
            Icons.calculate_outlined,
            'Monthly Budget',
            budget,
            onTap: () => context.pushNamed(SetBudgetScreen.path),
          ),
          const Divider(height: 32),
          _buildBasicItem(
            Icons.savings_outlined,
            'Monthly Savings',
            savings,
            showInfo: true,
          ),
        ],
      ),
    );
  }

  Widget _buildBasicItem(
    IconData icon,
    String label,
    num amount, {
    VoidCallback? onTap,
    bool showInfo = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade700),
          const Gap(12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              fontFamily: 'GeneralSans',
            ),
          ),
          const Spacer(),
          Text(
            amount.toDouble().formatCurrency(decimalDigits: 2),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              fontFamily: 'GeneralSans',
            ),
          ),
          const Gap(8),
          Icon(
            showInfo ? Icons.info_outline : Icons.chevron_right,
            size: 20,
            color: Colors.grey.shade400,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdown(List<Budget> budgets) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: budgets.asMap().entries.map((entry) {
          final index = entry.key;
          final budget = entry.value;
          final isLast = index == budgets.length - 1;

          return Column(
            children: [
              _buildCategoryItem(budget),
              if (!isLast) const Divider(height: 32),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCategoryItem(Budget budget) {
    return InkWell(
      onTap: () {
        EditBudgetBottomSheet.show(context, budget: budget);
      },
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _getCategoryColor(budget.budgetName).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getCategoryIcon(budget.budgetName),
              color: _getCategoryColor(budget.budgetName),
              size: 20,
            ),
          ),
          const Gap(12),
          Text(
            budget.budgetName,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              fontFamily: 'GeneralSans',
            ),
          ),
          const Spacer(),
          Text(
            budget.targetAmountMonthly.toDouble().formatCurrency(
              decimalDigits: 0,
            ),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              fontFamily: 'GeneralSans',
            ),
          ),
          const Gap(8),
          Icon(Icons.chevron_right, size: 20, color: Colors.grey.shade400),
        ],
      ),
    );
  }
}
