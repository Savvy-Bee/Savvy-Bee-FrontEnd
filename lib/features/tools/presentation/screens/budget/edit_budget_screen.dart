import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/assets/app_icons.dart';
import 'package:savvy_bee_mobile/core/utils/num_extensions.dart';
import 'package:savvy_bee_mobile/core/widgets/bottom_sheets/edit_budget_bottom_sheet.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_card.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_error_widget.dart';
import 'package:savvy_bee_mobile/core/widgets/section_title_widget.dart';
import 'package:savvy_bee_mobile/features/tools/domain/models/budget.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/providers/budget_provider.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/screens/budget/set_budget_screen.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/screens/budget/set_income_screen.dart';

import '../../../../../core/widgets/bottom_sheets/budget_category_bottom_sheet.dart';
import '../../widgets/insight_card.dart';

class EditBudgetScreen extends ConsumerStatefulWidget {
  static const String path = '/edit-budget';

  const EditBudgetScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EditBudgetScreenState();
}

class _EditBudgetScreenState extends ConsumerState<EditBudgetScreen> {
  @override
  Widget build(BuildContext context) {
    final availableCategories = ref.watch(availableBudgetCategoriesProvider);
    final budgetState = ref.watch(budgetHomeNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Budgets')),
      body: budgetState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => CustomErrorWidget.error(
          onRetry: () => ref
              .read(budgetHomeNotifierProvider.notifier)
              .fetchBudgetHomeData(),
        ),
        data: (data) {
          final totalBudget = data.budgets.fold<num>(
            0,
            (prev, budget) => prev + budget.targetAmountMonthly,
          );
          final remaining = data.totalEarnings - totalBudget;

          return ListView(
            padding: const EdgeInsets.all(16).copyWith(bottom: 32),
            children: [
              // Row(
              //   spacing: 8,
              //   children: List.generate(
              //     3,
              //     (index) => Expanded(
              //       child: CustomCard(
              //         borderColor: index == 2 ? AppColors.primary : null,
              //         bgColor: index == 2 ? AppColors.primaryFaint : null,
              //         borderRadius: 8,
              //         child: Center(child: Text('Aug')), // TODO: Make dynamic
              //       ),
              //     ),
              //   ),
              // ),
              // const Gap(24),
              const InsightCard(
                insightType: InsightType.nextBestAction,
                text:
                    "You've spent 15% more on transport this month. Try adjusting your allocation.",
              ),
              const Gap(28),
              _buildBudgetBasicsCard(data, totalBudget, remaining),
              const Gap(28),
              SectionTitleWidget(title: 'Category limits'),
              const Gap(8),

              // 6. Dynamically build category list
              ...data.budgets.map((budget) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: _buildCategoryItem(
                    budget.budgetName,
                    budget.balance, // 'amountSpent'
                    budget.targetAmountMonthly, // 'amount'
                    AppIcons.editIcon,
                    onEditPressed: () {
                      EditBudgetBottomSheet.show(context, budget: budget);
                    },
                  ),
                );
              }),
              const Gap(28),
              if (availableCategories.isNotEmpty) ...[
                CustomOutlinedButton(
                  text: 'Add category',
                  onPressed: () {
                    BudgetCategoryBottomSheet.show(context);
                  },
                ),
                const Gap(8),
              ],
              CustomElevatedButton(
                text: 'Save', // This button's action is unclear from spec
                onPressed: () => context.pop(), // Changed to pop
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCategoryItem(
    String title,
    num amountSpent, // Changed type
    num amount, // Changed type
    String iconPath, {
    VoidCallback? onEditPressed,
  }) {
    return CustomCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.circle), // TODO: Use dynamic category icon
              const Gap(16),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 16)),
                  Text(
                    // Using amountSpent here, was 'last month' before
                    '${amountSpent.toDouble().formatCurrency(decimalDigits: 0)} spent',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                amount.toDouble().formatCurrency(decimalDigits: 0),
                style: TextStyle(fontSize: 16),
              ),
              const Gap(16),
              InkWell(onTap: onEditPressed, child: AppIcon(AppIcons.editIcon)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetBasicsCard(
    BudgetHomeData data,
    num totalBudget,
    num remaining,
  ) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Budget Basics', style: TextStyle(fontWeight: FontWeight.w500)),
          const Gap(24),
          _buildBudgetBasicsItem(
            'Monthly income',
            data.totalEarnings,
            AppIcons.editIcon,
            // Navigate to the screen to set income
            onPressed: () => context.pushNamed(SetIncomeScreen.path),
          ),
          const Gap(16),
          _buildBudgetBasicsItem(
            'Monthly budget',
            totalBudget,
            AppIcons.editIcon,
            onPressed: () => context.pushNamed(SetBudgetScreen.path),
          ),
          const Divider(height: 48),
          // Renamed this from 'Monthly income' to 'Remaining'
          _buildBudgetBasicsItem(
            'Unbudgeted',
            remaining,
            AppIcons.infoIcon, // Changed icon
            onPressed: () {
              // Show info about unbudgeted funds
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetBasicsItem(
    String title,
    num amount, // Changed type
    String iconPath, {
    VoidCallback? onPressed,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 16)),
        Text(
          amount.toDouble().formatCurrency(decimalDigits: 0),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        InkWell(onTap: onPressed, child: AppIcon(iconPath)),
      ],
    );
  }
}
