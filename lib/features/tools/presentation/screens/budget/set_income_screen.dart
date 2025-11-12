import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_input_field.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/widgets/insight_card.dart';

import '../../providers/budget_provider.dart';

class SetIncomeScreen extends ConsumerStatefulWidget {
  static String path = '/set-income';

  const SetIncomeScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SetIncomeScreenState();
}

class _SetIncomeScreenState extends ConsumerState<SetIncomeScreen> {
  final _incomeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill with estimated income when available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final budgetState = ref.read(budgetHomeNotifierProvider);
      budgetState.whenData((data) {
        if (_incomeController.text.isEmpty) {
          _incomeController.text = data.totalEarnings.toString();
        }
      });
    });
  }

  @override
  void dispose() {
    _incomeController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final incomeText = _incomeController.text.trim();
    // Remove any currency symbols, commas, or spaces
    final cleanedIncome = incomeText.replaceAll(RegExp(r'[^\d.]'), '');
    final monthlyEarning = num.tryParse(cleanedIncome);

    if (monthlyEarning == null || monthlyEarning <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a valid income amount'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final notifier = ref.read(budgetHomeNotifierProvider.notifier);
      final message = await notifier.updateMonthlyEarnings(monthlyEarning);

      // Invalidate the provider to refresh data
      ref.invalidate(budgetHomeNotifierProvider);
      ref.invalidate(budgetHomeDataProvider);

      if (mounted) {
        // Pop and show success message
        context.pop();

        // Show success snackbar after a short delay to ensure we're back on previous screen
        Future.delayed(Duration(milliseconds: 100), () {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  message.isNotEmpty
                      ? message
                      : 'Monthly income updated successfully!',
                ),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 3),
              ),
            );
          }
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );
      }
    }
  }

  String? _validateIncome(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your monthly income';
    }

    final cleanedValue = value.replaceAll(RegExp(r'[^\d.]'), '');
    final income = num.tryParse(cleanedValue);

    if (income == null) {
      return 'Please enter a valid number';
    }

    if (income <= 0) {
      return 'Income must be greater than zero';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final budgetState = ref.watch(budgetHomeNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Set monthly income')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    Text(
                      "Let's set your monthly income.",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w500,
                        fontFamily: Constants.neulisNeueFontFamily,
                        height: 1,
                      ),
                    ),
                    const Gap(14),
                    budgetState.when(
                      data: (data) {
                        final estimatedIncome = data.totalEarnings;
                        if (estimatedIncome > 0) {
                          return Text(
                            "Based on your accounts, Nahl estimated your take-home pay at ₦${estimatedIncome.toStringAsFixed(0)}.",
                            style: TextStyle(fontSize: 16, height: 1),
                          );
                        }
                        return Text(
                          "Enter your monthly take-home pay to help us create personalized budgets and insights.",
                          style: TextStyle(fontSize: 16, height: 1),
                        );
                      },
                      loading: () => Text(
                        "Loading your income estimate...",
                        style: TextStyle(fontSize: 16, height: 1),
                      ),
                      error: (_, __) => Text(
                        "Enter your monthly take-home pay to help us create personalized budgets and insights.",
                        style: TextStyle(fontSize: 16, height: 1),
                      ),
                    ),
                    const Gap(28),
                    budgetState.whenOrNull(
                          data: (data) {
                            final estimatedIncome = data.totalEarnings;
                            if (estimatedIncome > 0) {
                              return InsightCard(
                                insightType: InsightType.nextBestAction,
                                text:
                                    'Based on your accounts, Nahl estimated your take-home pay at ₦${estimatedIncome.toStringAsFixed(0)}.',
                              );
                            }
                            return null;
                          },
                        ) ??
                        SizedBox.shrink(),
                    if (budgetState.hasValue &&
                        budgetState.value?.totalEarnings != null &&
                        budgetState.value!.totalEarnings > 0)
                      const Gap(28),
                    Text(
                      'Monthly income',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Gap(8),
                    CustomTextFormField(
                      hint: '₦800,000',
                      isRounded: true,
                      controller: _incomeController,
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[\d,.]')),
                      ],
                      validator: _validateIncome,
                      enabled: !_isLoading,
                    ),
                  ],
                ),
              ),
              CustomElevatedButton(
                text: 'Save',
                onPressed: _handleSave,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
