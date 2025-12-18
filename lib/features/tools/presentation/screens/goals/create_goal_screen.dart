import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_input_field.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_snackbar.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/providers/goals_provider.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/widgets/insight_card.dart';

import '../../../../../core/utils/date_time_utils.dart';
import '../../../../../core/widgets/custom_dropdown_button.dart';

enum GoalType { save, increase }

class CreateGoalScreen extends ConsumerStatefulWidget {
  static String path = '/create-goal';

  const CreateGoalScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CreateGoalScreenState();
}

class _CreateGoalScreenState extends ConsumerState<CreateGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _initialDepositController = TextEditingController();
  final _dateController = TextEditingController();

  GoalType? _goalType;
  DateTime? _selectedDate;

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _initialDepositController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final date = await DateTimeUtils.pickDate(
      context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2050),
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
        _dateController.text = '${date.day}/${date.month}/${date.year}';
      });
    }
  }

  Future<void> _createGoal() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_goalType == null) {
      _showErrorSnackBar('Please select a goal type');
      return;
    }

    if (_selectedDate == null) {
      _showErrorSnackBar('Please select a target date');
      return;
    }

    // Only "Save" goals are supported by the API currently
    if (_goalType != GoalType.save) {
      _showErrorSnackBar('Only savings goals are currently supported');
      return;
    }

    final notifier = ref.read(savingsGoalNotifierProvider.notifier);

    await notifier.createGoal(
      name: _descriptionController.text.trim(),
      totalSavings: double.parse(_amountController.text),
      amountSaved: double.parse(_initialDepositController.text),
      endDate: _selectedDate!.toIso8601String().split(
        'T',
      )[0], // YYYY-MM-DD format
    );

    final state = ref.read(savingsGoalNotifierProvider);

    if (!mounted) return;

    if (state.error != null) {
      _showErrorSnackBar(state.error!);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Goal created successfully!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.pop();
    }
  }

  void _showErrorSnackBar(String message) {
    CustomSnackbar.show(context, message, type: SnackbarType.error);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(savingsGoalNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Create a goal')),
      body: Padding(
        padding: const EdgeInsets.all(16).copyWith(bottom: 32),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    CustomDropdownButton(
                      label: 'Goal type',
                      hint: 'Select goal type',
                      items: const ['Save', 'Increase'],
                      onChanged: (value) {
                        setState(() {
                          _goalType = value == 'Save'
                              ? GoalType.save
                              : value == 'Increase'
                              ? GoalType.increase
                              : null;
                        });
                      },
                    ),
                    const Gap(8),
                    if (_goalType != null) ...[
                      InsightCard(
                        insightType: InsightType.nextBestAction,
                        text: switch (_goalType) {
                          GoalType.save =>
                            'Save ₦500,000 by March 2026 to build your emergency fund.',
                          GoalType.increase =>
                            'Increase earnings by 10% through by the end of the first quarter',
                          null => '',
                        },
                      ),
                      const Gap(16),
                      CustomTextFormField(
                        isRounded: true,
                        controller: _descriptionController,
                        hint: 'Build emergency fund',
                        label: 'Description',
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a description';
                          }
                          return null;
                        },
                      ),
                      const Gap(16),
                      CustomTextFormField(
                        isRounded: true,
                        controller: _amountController,
                        hint: switch (_goalType) {
                          GoalType.save => 'e.g. 50,000',
                          GoalType.increase => 'e.g. 30%',
                          null => 'e.g. 50,000',
                        },
                        label: switch (_goalType) {
                          GoalType.save => 'Target amount',
                          GoalType.increase => 'Target percentage increase',
                          null => 'Target amount',
                        },
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          if (_goalType == GoalType.increase)
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^(100|[1-9]?[0-9])$'),
                            ),
                        ],
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter an amount';
                          }
                          final amount = double.tryParse(value);
                          if (amount == null) {
                            return 'Please enter a valid number';
                          }
                          if (amount <= 0) {
                            return 'Amount must be greater than 0';
                          }
                          if (_goalType == GoalType.increase && amount > 100) {
                            return 'Percentage cannot exceed 100';
                          }
                          return null;
                        },
                      ),
                      const Gap(16),
                      if (_goalType == GoalType.save) ...[
                        CustomTextFormField(
                          isRounded: true,
                          controller: _initialDepositController,
                          hint: '0',
                          label: 'Initial deposit',
                          // helperText: 'This amount will be deducted from your wallet',
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter an initial deposit amount';
                            }
                            final amount = double.tryParse(value);
                            if (amount == null) {
                              return 'Please enter a valid number';
                            }
                            if (amount < 0) {
                              return 'Amount cannot be negative';
                            }
                            return null;
                          },
                        ),
                        const Gap(16),
                      ],
                      CustomTextFormField(
                        isRounded: true,
                        controller: _dateController,
                        hint: 'DD/MM/YYYY',
                        label: 'Target date',
                        readOnly: true,
                        suffix: const Icon(Icons.calendar_month),
                        onTap: _selectDate,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please select a target date';
                          }
                          return null;
                        },
                      ),
                    ],
                    const Gap(16),
                  ],
                ),
              ),
              CustomElevatedButton(
                text: 'Create goal',
                onPressed: _createGoal,
                isLoading: state.isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
