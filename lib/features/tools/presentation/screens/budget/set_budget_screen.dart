import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/num_extensions.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/providers/budget_provider.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/screens/budget/budget_completion_screen.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/widgets/insight_card.dart';

/// Set Monthly Budget Screen - Step 2 of budget onboarding
/// Shows income at top, adjustable budget with +/- controls, and calculated savings
class SetBudgetScreen extends ConsumerStatefulWidget {
  static const String path = '/set-budget';

  const SetBudgetScreen({super.key});

  @override
  ConsumerState<SetBudgetScreen> createState() => _SetBudgetScreenState();
}

class _SetBudgetScreenState extends ConsumerState<SetBudgetScreen> {
  num _monthlyBudget = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Calculate recommended budget (70% of income)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final budgetState = ref.read(budgetHomeNotifierProvider);
      budgetState.whenData((data) {
        if (data.budgets.isNotEmpty) {
          final totalTargetAmount = data.budgets.fold<double>(
            0.0,
            (sum, item) => sum + (item.targetAmountMonthly ?? 0),
          );

          setState(() {
            _monthlyBudget = totalTargetAmount;
          });
        }
        // if (data.totalEarnings > 0) {
        //   setState(() {
        //     // _monthlyBudget = (data.totalEarnings * 0.7).roundToDouble();
        //     _monthlyBudget = 100000;
        //   });
        // }
      });
    });
  }

  void _incrementBudget() {
    setState(() {
      _monthlyBudget += 10000; // Increment by ₦10,000
    });
  }

  void _decrementBudget() {
    final budgetState = ref.read(budgetHomeNotifierProvider);
    budgetState.whenData((data) {
      if (_monthlyBudget >= 10000 && _monthlyBudget <= data.totalEarnings) {
        setState(() {
          _monthlyBudget -= 10000; // Decrement by ₦10,000
        });
      }
    });
  }

  Future<void> _handleSave() async {
    final budgetState = ref.read(budgetHomeNotifierProvider);

    await budgetState.whenData((data) async {
      if (_monthlyBudget > data.totalEarnings) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Budget cannot exceed your monthly income'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() => _isLoading = true);

      try {
        // Here you might want to save the total budget or proceed to category setup
        // For now, we'll just navigate to the completion screen
        if (mounted) {
          context.pushReplacementNamed(BudgetCompletionScreen.path);
        }
      } catch (e) {
        setState(() => _isLoading = false);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceAll('Exception: ', '')),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    });
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
          'Set monthly budget',
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
        data: (data) {
          final monthlyIncome = data.totalEarnings;
          final monthlySavings = monthlyIncome - _monthlyBudget;
          final yearlySavings = monthlySavings * 12;
          final hasValidBudget =
              _monthlyBudget > 0 && _monthlyBudget <= monthlyIncome;
          final allInfo = data;
          print(allInfo);

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    // Title
                    const Text(
                      "Now let's define your monthly budget.",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'GeneralSans',
                        height: 1.2,
                        color: Colors.black,
                      ),
                    ),
                    const Gap(14),

                    // Subtitle
                    const Text(
                      "We'll subtract your monthly budget from your income to determine your savings.",
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'GeneralSans',
                        height: 1.4,
                        color: Colors.black87,
                      ),
                    ),
                    const Gap(28),

                    // Nahl's Recommendation
                    const InsightCard(
                      insightType: InsightType.nahlInsight,
                      text:
                          'Based on your past spending, Nahl recommends allocating 40% to needs, 30% to wants, and saving 30%.',
                    ),
                    const Gap(40),

                    // Monthly Income
                    Column(
                      children: [
                        Text(
                          'Monthly income',
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: 'GeneralSans',
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const Gap(4),
                        Text(
                          monthlyIncome.toDouble().formatCurrency(
                            decimalDigits: 0,
                          ),
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'GeneralSans',
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const Gap(42),

                    // Monthly Budget with +/- Controls
                    Column(
                      children: [
                        Text(
                          'Monthly budget',
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: 'GeneralSans',
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const Gap(12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: _isLoading ? null : _decrementBudget,
                              icon: const Icon(Icons.remove, size: 20),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.grey.shade200,
                                shape: const CircleBorder(),
                                padding: const EdgeInsets.all(12),
                              ),
                            ),
                            const Gap(32),
                            Text(
                              _monthlyBudget.toDouble().formatCurrency(
                                decimalDigits: 0,
                              ),
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'GeneralSans',
                                color: hasValidBudget
                                    ? Colors.black
                                    : Colors.red,
                              ),
                            ),
                            const Gap(32),
                            IconButton(
                              onPressed: _isLoading ? null : _incrementBudget,
                              icon: const Icon(Icons.add, size: 20),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.grey.shade200,
                                shape: const CircleBorder(),
                                padding: const EdgeInsets.all(12),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Gap(42),

                    // Monthly Savings
                    Column(
                      children: [
                        Text(
                          'Monthly savings',
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: 'GeneralSans',
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const Gap(4),
                        Text(
                          monthlySavings.toDouble().formatCurrency(
                            decimalDigits: 0,
                          ),
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'GeneralSans',
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const Gap(32),

                    // Yearly Projection
                    if (monthlySavings > 0)
                      Text.rich(
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          fontFamily: 'GeneralSans',
                        ),
                        TextSpan(
                          text: "At this rate you'll save ",
                          children: [
                            TextSpan(
                              text: yearlySavings.toDouble().formatCurrency(
                                decimalDigits: 1,
                              ),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const TextSpan(text: ' every year'),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              // Save Button
              Padding(
                padding: const EdgeInsets.all(24),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: hasValidBudget && !_isLoading
                        ? _handleSave
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: hasValidBudget
                          ? Colors.black
                          : Colors.grey.shade300,
                      disabledBackgroundColor: Colors.grey.shade300,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Text(
                            'Save',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'GeneralSans',
                              color: hasValidBudget
                                  ? Colors.white
                                  : Colors.grey.shade500,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:gap/gap.dart';
// import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';

// import '../../../../../core/theme/app_colors.dart';
// import '../../../../../core/utils/constants.dart';
// import '../../../../../core/utils/num_extensions.dart';
// import '../../widgets/insight_card.dart';

// class SetBudgetScreen extends ConsumerStatefulWidget {
//   static const String path = '/set-budget';

//   const SetBudgetScreen({super.key});

//   @override
//   ConsumerState<ConsumerStatefulWidget> createState() =>
//       _SetBudgetScreenState();
// }

// class _SetBudgetScreenState extends ConsumerState<SetBudgetScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Set monthly budget')),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Expanded(
//               child: ListView(
//                 children: [
//                   Text(
//                     "Now let's define your monthly budget.",
//                     style: TextStyle(
//                       fontSize: 28,
//                       fontWeight: FontWeight.w500,

//                       height: 1,
//                     ),
//                   ),
//                   const Gap(14),
//                   Text(
//                     "We'll subtract your monthly budget from your income to determine your savings.",
//                     style: TextStyle(fontSize: 16, height: 1),
//                   ),
//                   const Gap(28),
//                   InsightCard(
//                     insightType: InsightType.nahlInsight,
//                     text:
//                         'Based on your past spending, Nahl recommends allocating 30% to needs, 20% to wants, and saving 50%.',
//                   ),
//                   const Gap(28),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Column(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Text(
//                             'Monthly income',
//                             style: TextStyle(fontSize: 12),
//                           ),
//                           const Gap(4),
//                           Text(
//                             800000.formatCurrency(decimalDigits: 0),
//                             style: TextStyle(
//                               fontSize: 28,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           const Gap(42),
//                           Text(
//                             'Monthly Savings',
//                             style: TextStyle(fontSize: 12),
//                           ),
//                           const Gap(4),
//                           SizedBox(
//                             width: MediaQuery.sizeOf(context).width / 2,
//                             child: _buildTextField(context),
//                           ),
//                           const Gap(42),
//                           Text(
//                             'Monthly Savings',
//                             style: TextStyle(fontSize: 12),
//                           ),
//                           const Gap(4),
//                           Text(
//                             400000.formatCurrency(decimalDigits: 0),
//                             style: TextStyle(
//                               fontSize: 28,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           const Gap(32),
//                         ],
//                       ),
//                     ],
//                   ),
//                   Text.rich(
//                     textAlign: TextAlign.center,
//                     style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
//                     TextSpan(
//                       text: "At this rate you'll save ",
//                       children: [
//                         TextSpan(
//                           text: '₦4.8M ',
//                           style: TextStyle(fontWeight: FontWeight.bold),
//                         ),
//                         TextSpan(text: 'every year'),
//                       ],
//                     ),
//                   ),
//                   const Gap(8),
//                 ],
//               ),
//             ),
//             CustomElevatedButton(
//               text: 'Save',

//               // onPressed: () => EditBudgetBottomSheet.show(context),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   TextField _buildTextField(BuildContext context) {
//     var underlineInputBorder = UnderlineInputBorder(
//       borderSide: BorderSide(color: AppColors.borderDark),
//     );
//     var textFieldTextStyle = TextStyle(
//       fontSize: 28,
//       color: AppColors.textLight,
//     );
//     return TextField(
//       textAlign: TextAlign.center,
//       onTapOutside: (event) => FocusScope.of(context).unfocus(),
//       style: textFieldTextStyle.copyWith(color: AppColors.black),
//       keyboardType: TextInputType.number,
//       inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//       decoration: InputDecoration(
//         hint: Text(
//           '\$400,000',
//           textAlign: TextAlign.center,
//           style: textFieldTextStyle,
//         ),
//         alignLabelWithHint: true,
//         contentPadding: EdgeInsets.zero,
//         border: underlineInputBorder,
//         focusedBorder: underlineInputBorder,
//         enabledBorder: underlineInputBorder,
//       ),
//     );
//   }
// }
