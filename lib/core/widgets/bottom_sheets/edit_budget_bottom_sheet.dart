import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';
import 'package:savvy_bee_mobile/core/utils/num_extensions.dart';
import 'package:savvy_bee_mobile/core/utils/number_input_formatter.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_input_field.dart';
import 'package:savvy_bee_mobile/features/tools/domain/models/budget.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/providers/budget_provider.dart';

import 'package:savvy_bee_mobile/features/tools/presentation/widgets/insight_card.dart';

class EditBudgetBottomSheet extends ConsumerStatefulWidget {
  final Budget budget;

  const EditBudgetBottomSheet({super.key, required this.budget});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EditBudgetBottomSheetState();

  static void show(BuildContext context, {required Budget budget}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => EditBudgetBottomSheet(budget: budget),
    );
  }
}

class _EditBudgetBottomSheetState extends ConsumerState<EditBudgetBottomSheet> {
  late final TextEditingController _controller;
  final NumberFormat _formatter = NumberFormat('#,###');
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Format the initial value with commas
    final initialAmount = widget.budget.targetAmountMonthly.toInt();
    _controller = TextEditingController(text: _formatter.format(initialAmount));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Helper to get current month name
  String _getCurrentMonthName() {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final now = DateTime.now();
    return months[now.month - 1];
  }

  // Helper to get numeric value from formatted text
  num _getNumericValue(String formattedText) {
    if (formattedText.isEmpty) return 0;
    final numericString = formattedText.replaceAll(',', '');
    return num.tryParse(numericString) ?? 0;
  }

  void _onSave() async {
    setState(() => _isLoading = true);
    try {
      final newAmount = _getNumericValue(_controller.text);

      final message = await ref
          .read(budgetHomeNotifierProvider.notifier)
          .updateBudget(
            budgetName: widget.budget.budgetName,
            newTargetAmount: newAmount,
            amountSpent: widget.budget.balance,
          );

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final budgetState = ref.watch(budgetHomeNotifierProvider);
    final totalEarnings = budgetState.value?.totalEarnings ?? 0;

    // Calculate total budgeted from all OTHER budgets (excluding current)
    final otherBudgetsTotal =
        budgetState.value?.budgets
            .where((b) => b.budgetName != widget.budget.budgetName)
            .fold<num>(
              0,
              (prev, budget) => prev + budget.targetAmountMonthly,
            ) ??
        0;

    // Get the current input value (with commas removed)
    final currentBudgetValue = _getNumericValue(_controller.text);

    // Calculate unbudgeted = total earnings - (other budgets + current input)
    final unbudgeted = totalEarnings - (otherBudgetsTotal + currentBudgetValue);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: ListView(
        shrinkWrap: true,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Budget by category'),
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
          const Gap(24),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.circle),
                    const Gap(8),
                    Text(
                      widget.budget.budgetName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'GeneralSans',
                        letterSpacing: 20 * 0.02,
                      ),
                    ),
                  ],
                ),
                const Gap(24),
                CustomTextFormField(
                  controller: _controller,
                  label: 'Budget for ${_getCurrentMonthName()}',
                  hint: 'Enter amount',
                  isRounded: true,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    NumberInputFormatter(),
                  ],
                  onChanged: (value) {
                    // Trigger rebuild to update "available" text
                    setState(() {});
                  },
                ),
                const Gap(8),
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.textLight,
                      size: 16,
                    ),
                    const Gap(3),
                    Text(
                      '${unbudgeted.toDouble().formatCurrency(decimalDigits: 0)} available',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textLight,
                        fontFamily: 'GeneralSans',
                        letterSpacing: 12 * 0.02,
                      ),
                    ),
                  ],
                ),
                const Gap(24),
                CustomElevatedButton(
                  text: 'Save',
                  buttonColor: CustomButtonColor.black,
                  isLoading: _isLoading,
                  onPressed: _onSave,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:gap/gap.dart';
// import 'package:go_router/go_router.dart';
// import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
// import 'package:savvy_bee_mobile/core/utils/constants.dart';
// import 'package:savvy_bee_mobile/core/utils/num_extensions.dart';
// import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';
// import 'package:savvy_bee_mobile/core/widgets/custom_input_field.dart';
// import 'package:savvy_bee_mobile/features/tools/domain/models/budget.dart';
// import 'package:savvy_bee_mobile/features/tools/presentation/providers/budget_provider.dart';

// import 'package:savvy_bee_mobile/features/tools/presentation/widgets/insight_card.dart';

// class EditBudgetBottomSheet extends ConsumerStatefulWidget {
//   // 2. Add budget model to constructor
//   final Budget budget;

//   const EditBudgetBottomSheet({super.key, required this.budget});

//   @override
//   ConsumerState<ConsumerStatefulWidget> createState() =>
//       _EditBudgetBottomSheetState();

//   // 3. Update show method to accept the budget
//   static void show(BuildContext context, {required Budget budget}) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       useSafeArea: true,
//       builder: (context) => EditBudgetBottomSheet(budget: budget),
//     );
//   }
// }

// class _EditBudgetBottomSheetState extends ConsumerState<EditBudgetBottomSheet> {
//   // 4. Add controller and loading state
//   late final TextEditingController _controller;
//   bool _isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     // 5. Initialize controller with the budget's current amount
//     _controller = TextEditingController(
//       text: widget.budget.targetAmountMonthly.toStringAsFixed(0),
//     );
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   // 6. Implement save logic
//   void _onSave() async {
//     setState(() => _isLoading = true);
//     try {
//       final newAmount = num.tryParse(_controller.text) ?? 0;

//       // **Updated call to updateBudget with correct parameters**
//       final message = await ref
//           .read(budgetHomeNotifierProvider.notifier)
//           .updateBudget(
//             budgetName: widget.budget.budgetName, // Use BudgetName
//             newTargetAmount: newAmount, // Use new target amount as TotalBudget
//             amountSpent:
//                 widget.budget.balance, // Use current balance as amountSpent
//           );

//       if (mounted) {
//         // Show success message
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text(message)));
//         // Pop the bottom sheet
//         context.pop();
//       }
//     } catch (e) {
//       if (mounted) {
//         // Show error
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Error: ${e.toString()}'),
//             backgroundColor: AppColors.error,
//           ),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     // 7. Get remaining budget to show as a helper
//     final budgetState = ref.watch(budgetHomeNotifierProvider);
//     final totalEarnings = budgetState.value?.totalEarnings ?? 0;
//     final totalBudgeted =
//         budgetState.value?.budgets.fold<num>(
//           0,
//           (prev, budget) => prev + budget.targetAmountMonthly,
//         ) ??
//         0;
//     // Calculate unbudgeted funds, *excluding* the one being edited
//     final unbudgeted =
//         totalEarnings - (totalBudgeted - widget.budget.targetAmountMonthly);

//     return Padding(
//       // 8. Add padding for the keyboard
//       padding: EdgeInsets.only(
//         bottom: MediaQuery.of(context).viewInsets.bottom,
//       ),
//       child: ListView(
//         shrinkWrap: true,
//         // mainAxisSize: MainAxisSize.min,
//         // crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Padding(
//             padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text('Budget by category'),
//                 IconButton(
//                   onPressed: () => context.pop(),
//                   icon: const Icon(Icons.close),
//                   constraints: const BoxConstraints(),
//                   style: Constants.collapsedButtonStyle,
//                 ),
//               ],
//             ),
//           ),
//           const Divider(),
//           const Gap(24),
//           Padding(
//             padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
//             child: Column(
//               children: [
//                 Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     const Icon(Icons.circle), // TODO: Dynamic icon
//                     const Gap(8),
//                     Text(
//                       // 9. Use widget.budget data
//                       widget.budget.budgetName,
//                       style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const Gap(24),
//                 // const InsightCard(
//                 //   insightType: InsightType.nextBestAction,
//                 //   text:
//                 //       "You've spent 15% more on transport this month. Try adjusting your allocation.",
//                 // ),
//                 // const Gap(24),
//                 CustomTextFormField(
//                   // 10. Use the controller
//                   controller: _controller,
//                   label: 'Budget for November', // TODO: Dynamic month
//                   hint: '\$${widget.budget.targetAmountMonthly}',
//                   isRounded: true,
//                   keyboardType: TextInputType.number,
//                   inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//                 ),
//                 Row(
//                   children: [
//                     Icon(
//                       Icons.info_outline,
//                       color: AppColors.textLight,
//                       size: 16,
//                     ),
//                     const Gap(3),
//                     Text(
//                       // 11. Show available funds
//                       '${unbudgeted.toDouble().formatCurrency(decimalDigits: 0)} available',
//                       style: TextStyle(
//                         fontSize: 12,
//                         fontWeight: FontWeight.w500,
//                         color: AppColors.textLight,
//                       ),
//                     ),
//                   ],
//                 ),
//                 // const Gap(24),
//                 // CustomCard(
//                 //   padding: const EdgeInsets.symmetric(
//                 //     horizontal: 32,
//                 //     vertical: 24,
//                 //   ),
//                 //   child: Row(
//                 //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 //     children: [
//                 //       Column(
//                 //         mainAxisSize: MainAxisSize.min,
//                 //         children: [
//                 //           const Text(
//                 //             'Spent last month',
//                 //             style: TextStyle(
//                 //               fontWeight: FontWeight.w500,
//                 //               fontSize: 12,
//                 //               color: AppColors.textLight,
//                 //             ),
//                 //           ),
//                 //           const Gap(4),
//                 //           Text(
//                 //             // 12. Use widget.budget data (balance)
//                 //             widget.budget.balance.toDouble().formatCurrency(),
//                 //             style: const TextStyle(
//                 //               fontWeight: FontWeight.w500,
//                 //               fontSize: 12,
//                 //               color: AppColors.textSecondary,
//                 //             ),
//                 //           ),
//                 //         ],
//                 //       ),
//                 //       Column(
//                 //         mainAxisSize: MainAxisSize.min,
//                 //         children: [
//                 //           const Text(
//                 //             'Monthly average',
//                 //             style: TextStyle(
//                 //               fontWeight: FontWeight.w500,
//                 //               fontSize: 12,
//                 //               color: AppColors.textLight,
//                 //             ),
//                 //           ),
//                 //           const Gap(4),
//                 //           Text(
//                 //             // TODO: Need real data for this
//                 //             0.formatCurrency(),
//                 //             style: const TextStyle(
//                 //               fontWeight: FontWeight.w500,
//                 //               fontSize: 12,
//                 //               color: AppColors.textSecondary,
//                 //             ),
//                 //           ),
//                 //         ],
//                 //       ),
//                 //     ],
//                 //   ),
//                 // ),
//                 // const Gap(24),
//                 // const Text('Chart goes here'), // TODO: Implement chart
//                 const Gap(24),
//                 CustomElevatedButton(
//                   text: 'Save',
//                   buttonColor: CustomButtonColor.black,
//                   // 13. Use loading state and save handler
//                   isLoading: _isLoading,
//                   onPressed: _onSave,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
