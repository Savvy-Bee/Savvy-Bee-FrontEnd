import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/num_extensions.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_card.dart';
import 'package:savvy_bee_mobile/features/tools/domain/models/budget.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/providers/budget_provider.dart';

import '../../utils/constants.dart';
import 'edit_budget_bottom_sheet.dart';

class BudgetCategoryBottomSheet extends ConsumerStatefulWidget {
  const BudgetCategoryBottomSheet({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _BudgetCategoryBottomSheetState();

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => const BudgetCategoryBottomSheet(),
    );
  }
}

class _BudgetCategoryBottomSheetState
    extends ConsumerState<BudgetCategoryBottomSheet> {
  /// Creates a new budget category
  Future<void> _createBudgetCategory(String categoryName) async {
    try {
      await ref
          .read(budgetHomeNotifierProvider.notifier)
          .createBudgetCategory(categoryName);

      if (mounted) {
        context.pop(); // Close the bottom sheet on success

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$categoryName budget category added successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add $categoryName budget category: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch the available budget categories provider
    final availableCategories = ref.watch(availableBudgetCategoriesProvider);
    final existingBudgets = ref.watch(existingBudgetCategoriesProvider);

    // Create a map of existing budgets for quick lookup
    final existingBudgetsMap = {
      for (var budget in existingBudgets) budget.budgetName: budget,
    };

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Add budget category'),
              IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.close),
                constraints: BoxConstraints(),
                style: Constants.collapsedButtonStyle,
              ),
            ],
          ),
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: CustomCard(
            padding: const EdgeInsets.all(16.0),
            borderColor: AppColors.grey.withValues(alpha: 0.3),
            child: Column(
              children: predefinedBudgetCategories.map((category) {
                final isAvailable = availableCategories.contains(category);
                final existingBudget = existingBudgetsMap[category];

                return Column(
                  children: [
                    _buildCategoryListTile(
                      categoryName: category,
                      isAvailable: isAvailable,
                      existingBudget: existingBudget,
                    ),
                    const Gap(8),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryListTile({
    required String categoryName,
    required bool isAvailable,
    Budget? existingBudget,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              backgroundColor: AppColors.primary.withValues(alpha: 0.2),
              child: const Icon(
                Icons.category,
                size: 16,
                color: AppColors.primary,
              ),
            ),
            const Gap(16),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(categoryName, style: TextStyle(fontSize: 16.0)),
                if (existingBudget != null) ...[
                  Text(
                    '${existingBudget.targetAmountMonthly.formatCurrency(decimalDigits: 0)} monthly limit',
                    style: TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ] else ...[
                  Text(
                    'Not set up yet',
                    style: TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isAvailable &&
                existingBudget != null) // Category already exists
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    existingBudget.targetAmountMonthly.formatCurrency(
                      decimalDigits: 0,
                    ),
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Gap(8),
                  IconButton(
                    onPressed: () {
                      context.pop();
                      EditBudgetBottomSheet.show(
                        context,
                        budget: existingBudget,
                      );
                    },
                    icon: const Icon(Icons.edit_outlined),
                    iconSize: 20,
                    constraints: BoxConstraints(),
                    style: Constants.collapsedButtonStyle,
                  ),
                ],
              ),
            if (isAvailable) // Category doesn't exist yet - show add button
              IconButton(
                onPressed: () => _createBudgetCategory(categoryName),
                icon: const Icon(Icons.add),
                iconSize: 20,
                constraints: BoxConstraints(),
                style: Constants.collapsedButtonStyle,
              ),
          ],
        ),
      ],
    );
  }
}
