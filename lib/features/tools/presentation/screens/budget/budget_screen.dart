import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/assets/app_icons.dart';
import 'package:savvy_bee_mobile/core/widgets/charts/custom_circular_progress_indicator.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/providers/budget_provider.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/screens/budget/edit_budget_screen.dart';

import '../../../../../core/widgets/category_progress_widget.dart';
import '../../../../../core/widgets/custom_error_widget.dart';
import '../../../../../core/widgets/custom_loading_widget.dart';
import '../../widgets/insight_card.dart';

class BudgetScreen extends ConsumerStatefulWidget {
  static String path = '/budget-screen';

  const BudgetScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends ConsumerState<BudgetScreen> {
  @override
  Widget build(BuildContext context) {
    // 2. Watch the provider
    final budgetState = ref.watch(budgetHomeNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Budgets')),
      // 3. Use .when to handle loading, error, and data states
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
          // 5. Calculate derived values from the data
          final totalSpent = data.budgets.fold<num>(
            0,
            (prev, budget) => prev + budget.balance,
          );
          final totalBudget = data.totalEarnings;
          final progress = (totalBudget > 0) ? (totalSpent / totalBudget) : 0.0;

          // A simple list of colors to cycle through for categories
          final categoryColors = [
            AppColors.primary,
            AppColors.success,
            AppColors.blue, // Assuming AppColors has other colors
            AppColors.primaryFaded,
            AppColors.error,
          ];

          // 6. Return the UI with live data
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(budgetHomeNotifierProvider);
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Gap(20),
                CustomCircularProgressIndicator(
                  // Use calculated progress
                  progress: progress.toDouble(),
                  // Format numbers as strings (assuming NGN currency from insight)
                  currentAmount: "₦${totalSpent.toStringAsFixed(0)}",
                  totalBudget: "₦${totalBudget.toStringAsFixed(0)} budget",
                  size: 280,
                ),
                const Gap(47),
                CustomElevatedButton(
                  text: 'Edit budget',
                  icon: AppIcon(AppIcons.editIcon),
                  onPressed: () => context.pushNamed(EditBudgetScreen.path),
                ),
                const Gap(37),
                // --- Static Insight Cards (as before) ---
                const InsightCard(
                  text: 'You saved 12% more than last month — amazing work!',
                  insightType: InsightType.nahlInsight,
                ),
                const Gap(8),
                const InsightCard(
                  insightType: InsightType.nextBestAction,
                  text:
                      'Your dining expenses are trending upward. Try setting a ₦10,000 cap next month.',
                ),
                const Gap(16),

                // 7. Dynamically build category list from data.budgets
                ...List.generate(data.budgets.length, (index) {
                  final budget = data.budgets[index];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: CategoryProgressWidget(
                      title: budget.budgetName,
                      totalAmount: budget.targetAmountMonthly.toDouble(),
                      totalSpent: budget.balance.toDouble(),
                      // Cycle through colors
                      color: categoryColors[index % categoryColors.length],
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}
