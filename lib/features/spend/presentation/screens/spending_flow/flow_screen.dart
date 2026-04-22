import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/utils/num_extensions.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/providers/wallet_provider.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/screens/spending_flow/category_detail_screen.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/screens/spending_flow/emotional_patterns_screen.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/spending_flow_theme.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/widgets/spending_flow/category_row.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/widgets/spending_flow/emotional_insight_banner.dart';
import 'package:savvy_bee_mobile/features/tools/domain/models/budget.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/providers/budget_provider.dart';

// Maps a budget name to its icon and color pair.
({String icon, Color iconBgColor, Color progressColor}) _categoryStyle(
  String name,
) {
  switch (name.toLowerCase()) {
    case 'auto & transport':
      return (
        icon: '🚗',
        iconBgColor: AppColors.transportBlueLight,
        progressColor: AppColors.transportBlue,
      );
    case 'drinks & dining':
    case 'groceries':
      return (
        icon: name.toLowerCase() == 'groceries' ? '🛒' : '🍔',
        iconBgColor: AppColors.foodAmberLight,
        progressColor: AppColors.foodAmber,
      );
    case 'entertainment':
      return (
        icon: '🎉',
        iconBgColor: AppColors.entertainmentGreenLight,
        progressColor: AppColors.entertainmentGreen,
      );
    case 'financial':
      return (
        icon: '💰',
        iconBgColor: AppColors.billsPurpleLight,
        progressColor: AppColors.billsPurple,
      );
    case 'healthcare':
      return (
        icon: '🏥',
        iconBgColor: AppColors.stressRedLight,
        progressColor: AppColors.stressRed,
      );
    case 'household':
      return (
        icon: '🏠',
        iconBgColor: AppColors.billsPurpleLight,
        progressColor: AppColors.billsPurple,
      );
    case 'personal care':
      return (
        icon: '💆',
        iconBgColor: AppColors.coralLight,
        progressColor: AppColors.coral,
      );
    case 'shopping':
      return (
        icon: '🛍️',
        iconBgColor: AppColors.transportBlueLight,
        progressColor: AppColors.transportBlue,
      );
    case 'childcare & education':
      return (
        icon: '📚',
        iconBgColor: AppColors.foodAmberLight,
        progressColor: AppColors.foodAmber,
      );
    default:
      return (
        icon: '📦',
        iconBgColor: AppColors.coralLight,
        progressColor: AppColors.coral,
      );
  }
}

class FlowScreen extends ConsumerWidget {
  static const String path = '/spending-flow';

  const FlowScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(spendDashboardDataProvider);
    final txAsync = ref.watch(transactionListProvider);
    final budgets = ref.watch(existingBudgetCategoriesProvider);
    final budgetsAsync = ref.watch(budgetHomeNotifierProvider);

    final balance = dashboardAsync.valueOrNull?.data?.accounts.balance ?? 0.0;

    final now = DateTime.now();
    final transactions = txAsync.valueOrNull?.data?.transactions ?? [];
    final thisMonthTx = transactions.where((t) {
      return t.createdAt.year == now.year && t.createdAt.month == now.month;
    }).toList();

    final totalIncome = thisMonthTx
        .where((t) => t.isCredit)
        .fold(0.0, (sum, t) => sum + t.amount);
    final totalSpent = thisMonthTx
        .where((t) => t.isDebit)
        .fold(0.0, (sum, t) => sum + t.amount);

    final isLoading = dashboardAsync.isLoading || txAsync.isLoading;
    final isBudgetsLoading = budgetsAsync.isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(spendDashboardDataProvider);
            ref.invalidate(transactionListProvider);
            ref.invalidate(budgetHomeNotifierProvider);
            ref.invalidate(budgetSummaryProvider);
          },
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Flow', style: AppTextStyles.displayLarge),
                        const SizedBox(height: 2),
                        Text(
                          'Your spending patterns.',
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppColors.cardWhite,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // This Month card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.cardWhite,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.borderLight, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('This Month', style: AppTextStyles.labelMedium),
                      const SizedBox(height: 12),
                      isLoading
                          ? _shimmerAmount()
                          : Text(
                              balance.compactCurrency(),
                              style: AppTextStyles.amountLarge.copyWith(
                                fontSize: 38,
                              ),
                            ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _StatChip(
                            label: 'Income',
                            value: isLoading
                                ? '...'
                                : totalIncome.compactCurrency(),
                            color: AppColors.entertainmentGreen,
                          ),
                          const SizedBox(width: 12),
                          _StatChip(
                            label: 'Spent',
                            value: isLoading
                                ? '...'
                                : totalSpent.compactCurrency(),
                            color: AppColors.coral,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // By Category header
                Text('By Category', style: AppTextStyles.headingMedium),
                const SizedBox(height: 14),

                if (isBudgetsLoading)
                  ..._buildSkeletonRows()
                else if (budgets.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: Text(
                        'No budgets set up yet.\nCreate budgets in Tools to see categories here.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodySmall,
                      ),
                    ),
                  )
                else
                  ...budgets.asMap().entries.map((entry) {
                    final isLast = entry.key == budgets.length - 1;
                    return _BudgetCategoryRow(
                      budget: entry.value,
                      showDivider: !isLast,
                    );
                  }),

                const SizedBox(height: 20),

                // Emotional Insight Banner
                EmotionalInsightBanner(
                  onTap: () => context.push(EmotionalPatternsScreen.path),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    ),
    );
  }

  Widget _shimmerAmount() {
    return Container(
      width: 120,
      height: 38,
      decoration: BoxDecoration(
        color: AppColors.progressBg,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  List<Widget> _buildSkeletonRows() {
    return List.generate(3, (i) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.progressBg,
                borderRadius: BorderRadius.circular(13),
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 12,
                    width: 100,
                    decoration: BoxDecoration(
                      color: AppColors.progressBg,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppColors.progressBg,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _BudgetCategoryRow extends ConsumerWidget {
  final Budget budget;
  final bool showDivider;

  const _BudgetCategoryRow({
    required this.budget,
    required this.showDivider,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(budgetSummaryProvider(budget.budgetName));
    final style = _categoryStyle(budget.budgetName);

    // targetAmountMonthly is where the user's budget goal is stored (via TotalBudget param)
    final fallbackBudget = budget.targetAmountMonthly.toDouble();

    return summaryAsync.when(
      loading: () => _buildRow(
        context,
        style: style,
        spent: 0,
        budgetBalance: fallbackBudget,
        showDivider: showDivider,
      ),
      error: (_, __) => _buildRow(
        context,
        style: style,
        spent: 0,
        budgetBalance: fallbackBudget,
        showDivider: showDivider,
      ),
      data: (data) {
        final spent =
            data?.summary.totalAmountSpentThisMonth.toDouble() ?? 0.0;
        final rawBalance =
            data?.budgetInfo.currentBudgetBalance.toDouble() ?? 0.0;
        final budgetBalance = rawBalance > 0 ? rawBalance : fallbackBudget;
        return _buildRow(
          context,
          style: style,
          spent: spent,
          budgetBalance: budgetBalance,
          showDivider: showDivider,
          data: data,
        );
      },
    );
  }

  Widget _buildRow(
    BuildContext context, {
    required ({String icon, Color iconBgColor, Color progressColor}) style,
    required double spent,
    required double budgetBalance,
    required bool showDivider,
    dynamic data,
  }) {
    final progress = budgetBalance > 0
        ? (spent / budgetBalance).clamp(0.0, 1.0)
        : 0.0;
    final pct = (progress * 100).round();

    final spentLabel = spent > 0
        ? '${spent.formatCurrency(decimalDigits: 0)} spent · $pct%'
        : '₦0 spent';

    return CategoryRow(
      icon: style.icon,
      iconBgColor: style.iconBgColor,
      label: budget.budgetName,
      amount: budgetBalance.formatCurrency(decimalDigits: 0),
      percentage: spentLabel,
      progressColor: style.progressColor,
      progressValue: progress,
      showDivider: showDivider,
      onTap: () => context.push(
        CategoryDetailScreen.path,
        extra: CategoryInfo(
          icon: style.icon,
          iconBgColor: style.iconBgColor,
          progressColor: style.progressColor,
          label: budget.budgetName,
          amount: budgetBalance.formatCurrency(decimalDigits: 0),
          percentage: spentLabel,
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.labelSmall),
            const SizedBox(height: 4),
            Text(
              value,
              style: AppTextStyles.amountSmall.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}
