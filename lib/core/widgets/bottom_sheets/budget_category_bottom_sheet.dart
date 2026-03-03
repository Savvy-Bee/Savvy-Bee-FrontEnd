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
  /// Maps category name → asset path
  String _getCategoryIconPath(String categoryName) {
    final name = categoryName.trim().toLowerCase();

    // You can also keep original casing and use == if you prefer exact match
    switch (name) {
      case 'auto & transport':
        return 'assets/images/icons/budget categories/Auto & Transport.png';
      case 'childcare & education':
        return 'assets/images/icons/budget categories/Childcare & Education.png';
      case 'drinks & dining':
        return 'assets/images/icons/budget categories/Drinks & Dining.png';
      case 'entertainment':
        return 'assets/images/icons/budget categories/Entertainment.png';
      case 'financial':
        return 'assets/images/icons/budget categories/Financial.png';
      case 'groceries':
        return 'assets/images/icons/budget categories/Groceries.png';
      case 'healthcare':
        return 'assets/images/icons/budget categories/Healthcare.png';
      case 'household':
        return 'assets/images/icons/budget categories/Household.png';
      case 'other':
        return 'assets/images/icons/budget categories/Other.png';
      case 'personal care':
        return 'assets/images/icons/budget categories/Personal Care.png';
      case 'shopping':
        return 'assets/images/icons/budget categories/Shopping.png';
      default:
        // Fallback for unknown / future categories
        return 'assets/images/icons/budget_category.png';
    }
  }

  /// Creates a new budget category
  Future<void> _createBudgetCategory(String categoryName) async {
    try {
      await ref
          .read(budgetHomeNotifierProvider.notifier)
          .createBudgetCategory(categoryName);

      if (mounted) {
        context.pop(); // Close the bottom sheet on success

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$categoryName budget category added successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
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
    final availableCategories = ref.watch(availableBudgetCategoriesProvider);
    final existingBudgets = ref.watch(existingBudgetCategoriesProvider);

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
              Text(
                'Add budget category',
                style: TextStyle(
                  fontFamily: 'GeneralSans',
                  fontSize: 20.0,
                  letterSpacing: 20.0 * 0.02,
                ),
              ),
              IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.close),
                constraints: const BoxConstraints(),
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
            // ── Conditional category icon ────────────────────────────────
            CircleAvatar(
              backgroundColor: Colors.white,
              radius: 24, // optional: give consistent size
              child: Image.asset(
                _getCategoryIconPath(categoryName),
                width: 48, // adjust size to fit nicely
                height: 48,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback if image fails to load
                  return const Icon(
                    Icons.category_outlined,
                    color: Colors.white,
                    size: 24,
                  );
                },
              ),
            ),
            const Gap(16),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  categoryName,
                  style: const TextStyle(
                    fontFamily: 'GeneralSans',
                    fontSize: 16.0,
                    letterSpacing: 16.0 * 0.02,
                  ),
                ),
                if (existingBudget != null) ...[
                  Text(
                    '${existingBudget.targetAmountMonthly.formatCurrency(decimalDigits: 0)} monthly limit',
                    style: TextStyle(
                      fontFamily: 'GeneralSans',
                      fontSize: 12.0,
                      letterSpacing: 12.0 * 0.02,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ] else ...[
                  Text(
                    'Not set up yet',
                    style: TextStyle(
                      fontFamily: 'GeneralSans',
                      fontSize: 12.0,
                      letterSpacing: 12.0 * 0.02,
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
            if (!isAvailable && existingBudget != null)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    existingBudget.targetAmountMonthly.formatCurrency(
                      decimalDigits: 0,
                    ),
                    style: const TextStyle(
                      fontFamily: 'GeneralSans',
                      fontSize: 16.0,
                      letterSpacing: 16.0 * 0.02,
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
                    constraints: const BoxConstraints(),
                    style: Constants.collapsedButtonStyle,
                  ),
                ],
              ),
            if (isAvailable)
              IconButton(
                onPressed: () => _createBudgetCategory(categoryName),
                icon: const Icon(Icons.add),
                iconSize: 20,
                constraints: const BoxConstraints(),
                style: Constants.collapsedButtonStyle,
              ),
          ],
        ),
      ],
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:gap/gap.dart';
// import 'package:go_router/go_router.dart';
// import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
// import 'package:savvy_bee_mobile/core/utils/num_extensions.dart';
// import 'package:savvy_bee_mobile/core/widgets/custom_card.dart';
// import 'package:savvy_bee_mobile/features/tools/domain/models/budget.dart';
// import 'package:savvy_bee_mobile/features/tools/presentation/providers/budget_provider.dart';

// import '../../utils/constants.dart';
// import 'edit_budget_bottom_sheet.dart';

// class BudgetCategoryBottomSheet extends ConsumerStatefulWidget {
//   const BudgetCategoryBottomSheet({super.key});

//   @override
//   ConsumerState<ConsumerStatefulWidget> createState() =>
//       _BudgetCategoryBottomSheetState();

//   static void show(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       useSafeArea: true,
//       builder: (context) => const BudgetCategoryBottomSheet(),
//     );
//   }
// }

// class _BudgetCategoryBottomSheetState
//     extends ConsumerState<BudgetCategoryBottomSheet> {
//   /// Creates a new budget category
//   Future<void> _createBudgetCategory(String categoryName) async {
//     try {
//       await ref
//           .read(budgetHomeNotifierProvider.notifier)
//           .createBudgetCategory(categoryName);

//       if (mounted) {
//         context.pop(); // Close the bottom sheet on success

//         // Show success message
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('$categoryName budget category added successfully'),
//             backgroundColor: AppColors.success,
//           ),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         // Show error message
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Failed to add $categoryName budget category: $e'),
//             backgroundColor: AppColors.error,
//           ),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Watch the available budget categories provider
//     final availableCategories = ref.watch(availableBudgetCategoriesProvider);
//     final existingBudgets = ref.watch(existingBudgetCategoriesProvider);

//     // Create a map of existing budgets for quick lookup
//     final existingBudgetsMap = {
//       for (var budget in existingBudgets) budget.budgetName: budget,
//     };

//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'Add budget category',
//                 style: TextStyle(
//                   fontFamily: 'GeneralSans',
//                   fontSize: 20.0, // assuming a reasonable default for title
//                   letterSpacing: 20.0 * 0.02,
//                 ),
//               ),
//               IconButton(
//                 onPressed: () => context.pop(),
//                 icon: const Icon(Icons.close),
//                 constraints: BoxConstraints(),
//                 style: Constants.collapsedButtonStyle,
//               ),
//             ],
//           ),
//         ),
//         const Divider(),
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
//           child: CustomCard(
//             padding: const EdgeInsets.all(16.0),
//             borderColor: AppColors.grey.withValues(alpha: 0.3),
//             child: Column(
//               children: predefinedBudgetCategories.map((category) {
//                 final isAvailable = availableCategories.contains(category);
//                 final existingBudget = existingBudgetsMap[category];

//                 return Column(
//                   children: [
//                     _buildCategoryListTile(
//                       categoryName: category,
//                       isAvailable: isAvailable,
//                       existingBudget: existingBudget,
//                     ),
//                     const Gap(8),
//                   ],
//                 );
//               }).toList(),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildCategoryListTile({
//     required String categoryName,
//     required bool isAvailable,
//     Budget? existingBudget,
//   }) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // category image
//             CircleAvatar(
//               backgroundColor: Color(0xFF76D4FF),
//               child: Image.asset('assets/images/icons/budget_category.png'),
//             ),
//             const Gap(16),
//             Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   categoryName,
//                   style: TextStyle(
//                     fontFamily: 'GeneralSans',
//                     fontSize: 16.0,
//                     letterSpacing: 16.0 * 0.02,
//                   ),
//                 ),
//                 if (existingBudget != null) ...[
//                   Text(
//                     '${existingBudget.targetAmountMonthly.formatCurrency(decimalDigits: 0)} monthly limit',
//                     style: TextStyle(
//                       fontFamily: 'GeneralSans',
//                       fontSize: 12.0,
//                       letterSpacing: 12.0 * 0.02,
//                       fontWeight: FontWeight.w500,
//                       color: AppColors.textSecondary,
//                     ),
//                   ),
//                 ] else ...[
//                   Text(
//                     'Not set up yet',
//                     style: TextStyle(
//                       fontFamily: 'GeneralSans',
//                       fontSize: 12.0,
//                       letterSpacing: 12.0 * 0.02,
//                       fontWeight: FontWeight.w500,
//                       color: AppColors.textSecondary.withValues(alpha: 0.6),
//                     ),
//                   ),
//                 ],
//               ],
//             ),
//           ],
//         ),
//         Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             if (!isAvailable &&
//                 existingBudget != null) // Category already exists
//               Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(
//                     existingBudget.targetAmountMonthly.formatCurrency(
//                       decimalDigits: 0,
//                     ),
//                     style: TextStyle(
//                       fontFamily: 'GeneralSans',
//                       fontSize: 16.0,
//                       letterSpacing: 16.0 * 0.02,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                   const Gap(8),
//                   IconButton(
//                     onPressed: () {
//                       context.pop();
//                       EditBudgetBottomSheet.show(
//                         context,
//                         budget: existingBudget,
//                       );
//                     },
//                     icon: const Icon(Icons.edit_outlined),
//                     iconSize: 20,
//                     constraints: BoxConstraints(),
//                     style: Constants.collapsedButtonStyle,
//                   ),
//                 ],
//               ),
//             if (isAvailable) // Category doesn't exist yet - show add button
//               IconButton(
//                 onPressed: () => _createBudgetCategory(categoryName),
//                 icon: const Icon(Icons.add),
//                 iconSize: 20,
//                 constraints: BoxConstraints(),
//                 style: Constants.collapsedButtonStyle,
//               ),
//           ],
//         ),
//       ],
//     );
//   }
// }
