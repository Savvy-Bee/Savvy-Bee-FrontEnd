import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_input_field.dart';
import 'package:savvy_bee_mobile/features/tools/domain/models/budget.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/providers/budget_provider.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/screens/budget/set_budget_screen.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/widgets/insight_card.dart';

class SetIncomeScreen extends ConsumerStatefulWidget {
  static const String path = '/set-income';

  const SetIncomeScreen({super.key});

  @override
  ConsumerState<SetIncomeScreen> createState() => _SetIncomeScreenState();
}

class _SetIncomeScreenState extends ConsumerState<SetIncomeScreen> {
  final _incomeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final budgetState = ref.read(budgetHomeNotifierProvider);
      budgetState.whenData((data) {
        if (_incomeController.text.isEmpty && data.totalEarnings > 0) {
          _incomeController.text = data.totalEarnings.toStringAsFixed(0);
        }
      });
    });
  }

  @override
  void dispose() {
    _incomeController.dispose();
    super.dispose();
  }

  List<DateTime> _getLast6Months() {
    final now = DateTime.now();
    return List.generate(6, (i) {
      return DateTime(now.year, now.month - (5 - i));
    });
  }

  String _monthLabel(DateTime date) {
    const months = [
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
    return months[date.month - 1];
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final cleanedIncome = _incomeController.text.replaceAll(
      RegExp(r'[^\d]'),
      '',
    );
    final monthlyEarning = num.tryParse(cleanedIncome);

    if (monthlyEarning == null || monthlyEarning <= 0) return;

    setState(() => _isLoading = true);

    try {
      final notifier = ref.read(budgetHomeNotifierProvider.notifier);
      await notifier.updateMonthlyEarnings(monthlyEarning);

      if (mounted) {
        // Use push instead of pushReplacementNamed
        context.pushNamed(SetBudgetScreen.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String? _validateIncome(String? value) {
    if (value == null || value.isEmpty) return 'Enter income';
    final cleaned = value.replaceAll(RegExp(r'[^\d]'), '');
    final numValue = num.tryParse(cleaned);
    if (numValue == null || numValue <= 0) return 'Invalid income';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final budgetState = ref.watch(budgetHomeNotifierProvider);
    final hasInput = _incomeController.text.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Set monthly income'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  const Text(
                    "First, let's set your monthly income.",
                    style: TextStyle(fontSize: 26),
                  ),
                  const Gap(16),

                  budgetState.when(
                    data: (data) => Text(
                      data.totalEarnings > 0
                          ? "Nahl estimated ₦${data.totalEarnings.toStringAsFixed(0)}"
                          : "Enter your income",
                    ),
                    loading: () => const Text("Loading..."),
                    error: (_, __) => const Text("Enter your income"),
                  ),

                  const Gap(20),

                  CustomTextFormField(
                    hint: '₦800,000',
                    controller: _incomeController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: _validateIncome,
                    onChanged: (_) => setState(() {}),
                  ),

                  const Gap(32),

                  _buildIncomeChart(budgetState),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: hasInput && !_isLoading ? _handleSave : null,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Save'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncomeChart(AsyncValue<BudgetHomeData> budgetState) {
    return budgetState.when(
      data: (data) {
        final months = _getLast6Months();

        // final Map<int, num> monthlyIncome = data.monthlyIncome ?? {};
        final Map<int, num> monthlyIncome = {};

        final maxValue = monthlyIncome.values.isEmpty
            ? 1
            : monthlyIncome.values.reduce((a, b) => a > b ? a : b);

        return SizedBox(
          height: 160,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: months.map((date) {
              final isCurrent =
                  date.month == DateTime.now().month &&
                  date.year == DateTime.now().year;
              //  final value = monthlyIncome[date.month] ?? 0
              final value = isCurrent ? 1 : 0;
              final factor = value == 0 ? 0.05 : value / maxValue;

              return _buildBar(
                _monthLabel(date),
                factor,
                value,
                isHighlighted: isCurrent,
              );
            }).toList(),
          ),
        );
      },
      loading: () => const SizedBox(height: 160),
      error: (_, __) => const SizedBox(height: 160),
    );
  }

  Widget _buildBar(
    String month,
    double heightFactor,
    num amount, {
    bool isHighlighted = false,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 32,
          height: 120 * heightFactor,
          decoration: BoxDecoration(
            color: isHighlighted
                ? AppColors.yellow
                : AppColors.yellow.withOpacity(0.3),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ),
        const Gap(6),
        Text(
          month,
          style: TextStyle(
            fontSize: 10,
            color: isHighlighted ? Colors.black : Colors.grey,
          ),
        ),
      ],
    );
  }
}



// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:gap/gap.dart';
// import 'package:go_router/go_router.dart';
// import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
// import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';
// import 'package:savvy_bee_mobile/core/widgets/custom_input_field.dart';
// import 'package:savvy_bee_mobile/features/tools/domain/models/budget.dart';
// import 'package:savvy_bee_mobile/features/tools/presentation/providers/budget_provider.dart';
// import 'package:savvy_bee_mobile/features/tools/presentation/screens/budget/set_budget_screen.dart';
// import 'package:savvy_bee_mobile/features/tools/presentation/widgets/insight_card.dart';

// /// Set Monthly Income Screen - Step 1 of budget onboarding
// /// Shows estimated income from bank accounts with bar chart
// class SetIncomeScreen extends ConsumerStatefulWidget {
//   static const String path = '/set-income';

//   const SetIncomeScreen({super.key});

//   @override
//   ConsumerState<SetIncomeScreen> createState() => _SetIncomeScreenState();
// }

// class _SetIncomeScreenState extends ConsumerState<SetIncomeScreen> {
//   final _incomeController = TextEditingController();
//   final _formKey = GlobalKey<FormState>();
//   bool _isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     // Pre-fill with estimated income when available
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final budgetState = ref.read(budgetHomeNotifierProvider);
//       budgetState.whenData((data) {
//         if (_incomeController.text.isEmpty && data.totalEarnings > 0) {
//           _incomeController.text = data.totalEarnings.toStringAsFixed(0);
//         }
//       });
//     });
//   }

//   @override
//   void dispose() {
//     _incomeController.dispose();
//     super.dispose();
//   }

//   Future<void> _handleSave() async {
//     if (!_formKey.currentState!.validate()) {
//       return;
//     }

//     final incomeText = _incomeController.text.trim();
//     final cleanedIncome = incomeText.replaceAll(RegExp(r'[^\d.]'), '');
//     final monthlyEarning = num.tryParse(cleanedIncome);

//     if (monthlyEarning == null || monthlyEarning <= 0) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please enter a valid income amount'),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }

//     setState(() => _isLoading = true);

//     try {
//       final notifier = ref.read(budgetHomeNotifierProvider.notifier);
//       final message = await notifier.updateMonthlyEarnings(monthlyEarning);

//       if (mounted) {
//         // Navigate to next screen (Set Budget)
//         context.pushReplacementNamed(SetBudgetScreen.path);
//       }
//     } catch (e) {
//       setState(() => _isLoading = false);

//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(e.toString().replaceAll('Exception: ', '')),
//             backgroundColor: Colors.red,
//             duration: const Duration(seconds: 3),
//           ),
//         );
//       }
//     }
//   }

//   String? _validateIncome(String? value) {
//     if (value == null || value.trim().isEmpty) {
//       return 'Please enter your monthly income';
//     }

//     final cleanedValue = value.replaceAll(RegExp(r'[^\d.]'), '');
//     final income = num.tryParse(cleanedValue);

//     if (income == null) {
//       return 'Please enter a valid number';
//     }

//     if (income <= 0) {
//       return 'Income must be greater than zero';
//     }

//     return null;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final budgetState = ref.watch(budgetHomeNotifierProvider);
//     final hasInput = _incomeController.text.trim().isNotEmpty;

//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         title: const Text(
//           'Set monthly income',
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.w500,
//             fontFamily: 'GeneralSans',
//             color: Colors.black,
//           ),
//         ),
//         centerTitle: true,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () => context.pop(),
//         ),
//       ),
//       body: Form(
//         key: _formKey,
//         child: Column(
//           children: [
//             Expanded(
//               child: ListView(
//                 padding: const EdgeInsets.all(24),
//                 children: [
//                   // Title
//                   const Text(
//                     "First, let's set your monthly income.",
//                     style: TextStyle(
//                       fontSize: 28,
//                       fontWeight: FontWeight.w500,
//                       fontFamily: 'GeneralSans',
//                       height: 1.2,
//                       color: Colors.black,
//                     ),
//                   ),
//                   const Gap(14),

//                   // Subtitle with estimated income
//                   budgetState.when(
//                     data: (data) {
//                       final estimatedIncome = data.totalEarnings;
//                       if (estimatedIncome > 0) {
//                         return Text(
//                           "Based on your accounts, Nahl estimated your take-home pay at ₦${estimatedIncome.toStringAsFixed(0)}.",
//                           style: const TextStyle(
//                             fontSize: 16,
//                             fontFamily: 'GeneralSans',
//                             height: 1.4,
//                             color: Colors.black87,
//                           ),
//                         );
//                       }
//                       return const Text(
//                         "Enter your monthly take-home pay to help us create personalized budgets and insights.",
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontFamily: 'GeneralSans',
//                           height: 1.4,
//                           color: Colors.black87,
//                         ),
//                       );
//                     },
//                     loading: () => const Text(
//                       "Loading your income estimate...",
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontFamily: 'GeneralSans',
//                         height: 1.4,
//                         color: Colors.black87,
//                       ),
//                     ),
//                     error: (_, __) => const Text(
//                       "Enter your monthly take-home pay to help us create personalized budgets and insights.",
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontFamily: 'GeneralSans',
//                         height: 1.4,
//                         color: Colors.black87,
//                       ),
//                     ),
//                   ),
//                   const Gap(28),

//                   // Insight Card (only if we have an estimate)
//                   budgetState.when(
//                     data: (data) {
//                       final estimatedIncome = data.totalEarnings;
//                       if (estimatedIncome > 0) {
//                         return Column(
//                           children: [
//                             InsightCard(
//                               insightType: InsightType.nahlInsight,
//                               text: 'Based on your accounts, Nahl estimated your take-home pay at ₦${estimatedIncome.toStringAsFixed(0)}.',
//                             ),
//                             const Gap(28),
//                           ],
//                         );
//                       }
//                       return const SizedBox.shrink();
//                     },
//                     loading: () => const SizedBox.shrink(),
//                     error: (_, __) => const SizedBox.shrink(),
//                   ),

//                   // Monthly Income Label
//                   const Text(
//                     'Monthly Income',
//                     style: TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.w600,
//                       fontFamily: 'GeneralSans',
//                       color: Colors.black,
//                     ),
//                   ),
//                   const Gap(8),

//                   // Income Input Field
//                   CustomTextFormField(
//                     hint: '₦800,000',
//                     isRounded: true,
//                     controller: _incomeController,
//                     keyboardType: const TextInputType.numberWithOptions(
//                       decimal: false,
//                     ),
//                     inputFormatters: [
//                       FilteringTextInputFormatter.digitsOnly,
//                     ],
//                     validator: _validateIncome,
//                     enabled: !_isLoading,
//                     onChanged: (_) => setState(() {}),
//                   ),
//                   const Gap(32),

//                   // Income Bar Chart
//                   _buildIncomeChart(budgetState),
//                 ],
//               ),
//             ),

//             // Save Button
//             Padding(
//               padding: const EdgeInsets.all(24),
//               child: SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: hasInput && !_isLoading ? _handleSave : null,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: hasInput ? Colors.black : Colors.grey.shade300,
//                     disabledBackgroundColor: Colors.grey.shade300,
//                     foregroundColor: Colors.white,
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     elevation: 0,
//                   ),
//                   child: _isLoading
//                       ? const SizedBox(
//                           height: 20,
//                           width: 20,
//                           child: CircularProgressIndicator(
//                             strokeWidth: 2,
//                             valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                           ),
//                         )
//                       : Text(
//                           'Save',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w600,
//                             fontFamily: 'GeneralSans',
//                             color: hasInput ? Colors.white : Colors.grey.shade500,
//                           ),
//                         ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildIncomeChart(AsyncValue<BudgetHomeData> budgetState) {
//     return budgetState.when(
//       data: (data) {
//         final estimatedIncome = data.totalEarnings > 0 ? data.totalEarnings : 800000;

//         return Column(
//           children: [
//             // Chart showing income over months
//             SizedBox(
//               height: 150,
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.end,
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   _buildBar('Jun', 0.3, estimatedIncome),
//                   _buildBar('Jul', 0.35, estimatedIncome),
//                   _buildBar('Aug', 0.4, estimatedIncome),
//                   _buildBar('Sep', 0.45, estimatedIncome),
//                   _buildBar('Oct', 0.85, estimatedIncome, isHighlighted: true),
//                   _buildBar('Nov', 0.6, estimatedIncome),
//                 ],
//               ),
//             ),
//             const Gap(8),

//             // Amount label on the right
//             Align(
//               alignment: Alignment.centerRight,
//               child: Text(
//                 '₦${estimatedIncome.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
//                 style: const TextStyle(
//                   fontSize: 12,
//                   fontWeight: FontWeight.w500,
//                   fontFamily: 'GeneralSans',
//                   color: Colors.black87,
//                 ),
//               ),
//             ),
//           ],
//         );
//       },
//       loading: () => const SizedBox(height: 150),
//       error: (_, __) => const SizedBox(height: 150),
//     );
//   }

//   Widget _buildBar(String month, double heightFactor, num amount, {bool isHighlighted = false}) {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.end,
//       children: [
//         Container(
//           width: 32,
//           height: 120 * heightFactor,
//           decoration: BoxDecoration(
//             color: isHighlighted ? AppColors.yellow : AppColors.yellow.withOpacity(0.3),
//             borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
//           ),
//         ),
//         const Gap(8),
//         Text(
//           month,
//           style: TextStyle(
//             fontSize: 10,
//             fontFamily: 'GeneralSans',
//             color: Colors.grey.shade600,
//           ),
//         ),
//       ],
//     );
//   }
// }




// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:gap/gap.dart';
// import 'package:go_router/go_router.dart';
// import 'package:savvy_bee_mobile/core/utils/constants.dart';
// import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';
// import 'package:savvy_bee_mobile/core/widgets/custom_input_field.dart';
// import 'package:savvy_bee_mobile/features/tools/presentation/widgets/insight_card.dart';

// import '../../providers/budget_provider.dart';

// class SetIncomeScreen extends ConsumerStatefulWidget {
//   static const String path = '/set-income';

//   const SetIncomeScreen({super.key});

//   @override
//   ConsumerState<ConsumerStatefulWidget> createState() =>
//       _SetIncomeScreenState();
// }

// class _SetIncomeScreenState extends ConsumerState<SetIncomeScreen> {
//   final _incomeController = TextEditingController();
//   final _formKey = GlobalKey<FormState>();
//   bool _isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     // Pre-fill with estimated income when available
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final budgetState = ref.read(budgetHomeNotifierProvider);
//       budgetState.whenData((data) {
//         if (_incomeController.text.isEmpty) {
//           _incomeController.text = data.totalEarnings.toString();
//         }
//       });
//     });
//   }

//   @override
//   void dispose() {
//     _incomeController.dispose();
//     super.dispose();
//   }

//   Future<void> _handleSave() async {
//     if (!_formKey.currentState!.validate()) {
//       return;
//     }

//     final incomeText = _incomeController.text.trim();
//     // Remove any currency symbols, commas, or spaces
//     final cleanedIncome = incomeText.replaceAll(RegExp(r'[^\d.]'), '');
//     final monthlyEarning = num.tryParse(cleanedIncome);

//     if (monthlyEarning == null || monthlyEarning <= 0) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Please enter a valid income amount'),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }

//     setState(() => _isLoading = true);

//     try {
//       final notifier = ref.read(budgetHomeNotifierProvider.notifier);
//       final message = await notifier.updateMonthlyEarnings(monthlyEarning);

//       // Invalidate the provider to refresh data
//       ref.invalidate(budgetHomeNotifierProvider);
//       ref.invalidate(budgetHomeDataProvider);

//       if (mounted) {
//         // Pop and show success message
//         context.pop();

//         // Show success snackbar after a short delay to ensure we're back on previous screen
//         Future.delayed(Duration(milliseconds: 100), () {
//           if (mounted) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Text(
//                   message.isNotEmpty
//                       ? message
//                       : 'Monthly income updated successfully!',
//                 ),
//                 backgroundColor: Colors.green,
//                 duration: Duration(seconds: 3),
//               ),
//             );
//           }
//         });
//       }
//     } catch (e) {
//       setState(() => _isLoading = false);

//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(e.toString().replaceAll('Exception: ', '')),
//             backgroundColor: Colors.red,
//             duration: Duration(seconds: 4),
//           ),
//         );
//       }
//     }
//   }

//   String? _validateIncome(String? value) {
//     if (value == null || value.trim().isEmpty) {
//       return 'Please enter your monthly income';
//     }

//     final cleanedValue = value.replaceAll(RegExp(r'[^\d.]'), '');
//     final income = num.tryParse(cleanedValue);

//     if (income == null) {
//       return 'Please enter a valid number';
//     }

//     if (income <= 0) {
//       return 'Income must be greater than zero';
//     }

//     return null;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final budgetState = ref.watch(budgetHomeNotifierProvider);

//     return Scaffold(
//       appBar: AppBar(title: Text('Set monthly income')),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               Expanded(
//                 child: ListView(
//                   children: [
//                     Text(
//                       "Let's set your monthly income.",
//                       style: TextStyle(
//                         fontSize: 28,
//                         fontWeight: FontWeight.w500,

//                         height: 1,
//                       ),
//                     ),
//                     const Gap(14),
//                     budgetState.when(
//                       data: (data) {
//                         final estimatedIncome = data.totalEarnings;
//                         if (estimatedIncome > 0) {
//                           return Text(
//                             "Based on your accounts, Nahl estimated your take-home pay at ₦${estimatedIncome.toStringAsFixed(0)}.",
//                             style: TextStyle(fontSize: 16, height: 1),
//                           );
//                         }
//                         return Text(
//                           "Enter your monthly take-home pay to help us create personalized budgets and insights.",
//                           style: TextStyle(fontSize: 16, height: 1),
//                         );
//                       },
//                       loading: () => Text(
//                         "Loading your income estimate...",
//                         style: TextStyle(fontSize: 16, height: 1),
//                       ),
//                       error: (_, __) => Text(
//                         "Enter your monthly take-home pay to help us create personalized budgets and insights.",
//                         style: TextStyle(fontSize: 16, height: 1),
//                       ),
//                     ),
//                     const Gap(28),
//                     budgetState.whenOrNull(
//                           data: (data) {
//                             final estimatedIncome = data.totalEarnings;
//                             if (estimatedIncome > 0) {
//                               return InsightCard(
//                                 insightType: InsightType.nextBestAction,
//                                 text:
//                                     'Based on your accounts, Nahl estimated your take-home pay at ₦${estimatedIncome.toStringAsFixed(0)}.',
//                               );
//                             }
//                             return null;
//                           },
//                         ) ??
//                         SizedBox.shrink(),
//                     if (budgetState.hasValue &&
//                         budgetState.value?.totalEarnings != null &&
//                         budgetState.value!.totalEarnings > 0)
//                       const Gap(28),
//                     Text(
//                       'Monthly income',
//                       style: TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const Gap(8),
//                     CustomTextFormField(
//                       hint: '₦800,000',
//                       isRounded: true,
//                       controller: _incomeController,
//                       keyboardType: TextInputType.numberWithOptions(
//                         decimal: true,
//                       ),
//                       inputFormatters: [
//                         FilteringTextInputFormatter.allow(RegExp(r'[\d,.]')),
//                       ],
//                       validator: _validateIncome,
//                       enabled: !_isLoading,
//                     ),
//                   ],
//                 ),
//               ),
//               CustomElevatedButton(
//                 text: 'Save',
//                 onPressed: _handleSave,
//                 isLoading: _isLoading,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
