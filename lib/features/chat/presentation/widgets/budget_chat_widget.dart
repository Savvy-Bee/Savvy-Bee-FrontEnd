import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/number_formatter.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_card.dart';
import 'package:savvy_bee_mobile/features/chat/domain/models/chat_models.dart';

class BudgetChatWidget extends ConsumerStatefulWidget {
  final List<BudgetData>? budgetData;
  final VoidCallback? onAdjustBudget;
  final VoidCallback? onViewDetails;

  const BudgetChatWidget({
    super.key,
    this.budgetData,
    this.onAdjustBudget,
    this.onViewDetails,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _BudgetChatWidgetState();
}

class _BudgetChatWidgetState extends ConsumerState<BudgetChatWidget> {
  bool showMore = false;

  @override
  Widget build(BuildContext context) {
    final budgets = widget.budgetData ?? [];
    final hasData = budgets.isNotEmpty;

    // Calculate totals
    double totalBudget = 0;
    double totalSpent = 0;
    int overBudgetCount = 0;

    if (hasData) {
      for (final budget in budgets) {
        totalBudget += budget.targetAmountMonthly;
        totalSpent += budget.balance;
        if (budget.balance > budget.targetAmountMonthly) {
          overBudgetCount++;
        }
      }
    }

    final overallProgress = totalBudget > 0 ? (totalSpent / totalBudget) : 0.0;
    final isOverBudget = totalSpent > totalBudget;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header info card
                CustomCard(
                  borderRadius: 8,
                  borderColor: AppColors.border,
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.analytics_outlined,
                            color: AppColors.primary,
                            size: 14,
                          ),
                          const Gap(4),
                          Text(
                            'Budget Analysis',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const Gap(4),
                      Text(
                        hasData
                            ? "You've spent ${NumberFormatter.formatCurrency(totalSpent, decimalDigits: 0)} this month"
                            : "No budget data available",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                if (hasData) ...[
                  const Gap(16),
                  // Overall budget progress
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Budget',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${NumberFormatter.formatCurrency(totalSpent, decimalDigits: 0)}/${NumberFormatter.formatCurrency(totalBudget, decimalDigits: 0)}',
                        style: TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                  const Gap(4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: overallProgress.clamp(0.0, 1.0),
                          backgroundColor:
                              (isOverBudget
                                      ? AppColors.error
                                      : AppColors.success)
                                  .withValues(alpha: 0.2),
                          minHeight: 10,
                          borderRadius: BorderRadius.circular(10),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isOverBudget ? AppColors.error : AppColors.success,
                          ),
                        ),
                      ),
                      const Gap(4),
                      Text(
                        '${(overallProgress * 100).toStringAsFixed(0)}%',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const Gap(24),

                  // Show first 2 budgets
                  ...budgets
                      .take(2)
                      .map(
                        (budget) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildCategoryInfo(
                            budget.budgetName,
                            totalAmount: budget.targetAmountMonthly,
                            amountSpent: budget.balance,
                            color: budget.balance > budget.targetAmountMonthly
                                ? AppColors.error
                                : AppColors.primary,
                          ),
                        ),
                      ),

                  // Show more button if there are more than 2 budgets
                  if (budgets.length > 2) ...[
                    const Gap(4),
                    InkWell(
                      onTap: () {
                        setState(() {
                          showMore = !showMore;
                        });
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            showMore
                                ? 'Show less categories'
                                : 'Show ${budgets.length - 2} more categories',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primary,
                            ),
                          ),
                          Icon(
                            showMore
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            size: 16,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Show remaining budgets when expanded
                  if (showMore && budgets.length > 2) ...[
                    const Gap(16),
                    ...budgets
                        .skip(2)
                        .map(
                          (budget) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildCategoryInfo(
                              budget.budgetName,
                              totalAmount: budget.targetAmountMonthly,
                              amountSpent: budget.balance,
                              color: budget.balance > budget.targetAmountMonthly
                                  ? AppColors.error
                                  : AppColors.blue,
                            ),
                          ),
                        ),
                  ],

                  const Gap(16),

                  // Warning card if over budget
                  if (overBudgetCount > 0)
                    CustomCard(
                      padding: const EdgeInsets.all(8),
                      borderRadius: 8,
                      borderColor: AppColors.warning,
                      bgColor: AppColors.warning.withValues(alpha: 0.1),
                      child: Text(
                        "⚠️ You're over budget in $overBudgetCount ${overBudgetCount == 1 ? 'category' : 'categories'}",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: AppColors.warning.withValues(alpha: 0.9),
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),

          // Action buttons
          const Divider(height: 0),
          TextButton(
            onPressed: widget.onAdjustBudget,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.all(20),
              foregroundColor: AppColors.primary,
            ),
            child: const Text('Adjust Budget'),
          ),
          const Divider(height: 0),
          TextButton(
            onPressed: widget.onViewDetails,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.all(20),
              foregroundColor: AppColors.primary,
            ),
            child: const Text('View Details'),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryInfo(
    String title, {
    required double totalAmount,
    required double amountSpent,
    required Color color,
  }) {
    final percentage = totalAmount > 0
        ? (amountSpent / totalAmount * 100)
        : 0.0;
    final isOverBudget = amountSpent > totalAmount;
    final difference = amountSpent - totalAmount;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(5.0),
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: Icon(
            Icons.account_balance_wallet_outlined,
            size: 20,
            color: AppColors.white,
          ),
        ),
        const Gap(8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Gap(8),
                  Text(
                    '${NumberFormatter.formatCurrency(amountSpent, decimalDigits: 0)} of ${NumberFormatter.formatCurrency(totalAmount, decimalDigits: 0)}',
                    style: TextStyle(fontSize: 9),
                  ),
                ],
              ),
              const Gap(4),
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: (amountSpent / totalAmount).clamp(0.0, 1.0),
                      backgroundColor: color.withValues(alpha: 0.2),
                      minHeight: 3,
                      borderRadius: BorderRadius.circular(10),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                  const Gap(4),
                  Text(
                    isOverBudget
                        ? '+${NumberFormatter.formatCurrency(difference, decimalDigits: 0)}'
                        : '${percentage.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: isOverBudget ? AppColors.error : color,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
