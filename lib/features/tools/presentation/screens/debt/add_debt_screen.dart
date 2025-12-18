import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';
import 'package:savvy_bee_mobile/core/utils/date_time_utils.dart';
import 'package:savvy_bee_mobile/core/utils/string_extensions.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_dropdown_button.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_input_field.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_card.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_snackbar.dart';
import 'package:savvy_bee_mobile/features/tools/domain/models/debt.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/providers/debt_provider.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/screens/debt/debt_repayment_details_screen.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/widgets/insight_card.dart';

enum LoanRepaymentFrequency { weekly, monthly, quarterly, manually }

class AddDebtScreen extends ConsumerStatefulWidget {
  static const String path = '/add-debt';

  const AddDebtScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddDebtScreenState();
}

class _AddDebtScreenState extends ConsumerState<AddDebtScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountOwedController = TextEditingController();
  final TextEditingController _interestRateController = TextEditingController();
  final TextEditingController _minimumPaymentController =
      TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  LoanRepaymentFrequency _selectedPaymentFrequency =
      LoanRepaymentFrequency.monthly;

  // Variable to hold selected day (e.g. "1", "15", "Monday")
  String? _selectedRepaymentDay;
  DateTime? _selectedDate;

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _amountOwedController.dispose();
    _interestRateController.dispose();
    _minimumPaymentController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _submitDebtStep1() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      CustomSnackbar.show(context, 'Please select a target payoff date');
      return;
    }

    setState(() => _isLoading = true);

    // Clean data (remove commas if formatted, etc.)
    final amount = _amountOwedController.text.replaceAll(',', '');
    final minPayment = _minimumPaymentController.text.replaceAll(',', '');
    final interest = _interestRateController.text.replaceAll('%', '');

    final DebtRequestModel reqData = DebtRequestModel(
      name: _nameController.text.trim(),
      amountOwed: num.tryParse(amount)!,
      interestRate: num.tryParse(interest)!,
      paymentFrequency: _selectedPaymentFrequency.name.capitalizeFirstLetter(),
      minPayment: num.tryParse(minPayment)!,
      expectedPayoffDate: _selectedDate!,
      repaymentDay: _selectedRepaymentDay!,
    );

    try {
      // Call Provider
      final response = await ref
          .read(debtListNotifierProvider.notifier)
          .createDebt(reqData);

      if (mounted) {
        // Assuming response contains 'id' or 'data'['id']. Adjust based on actual API response.
        // Example: response is Map<String, dynamic>
        final String debtId = response.debtId;

        context.pushNamed(
          DebtRepaymentDetailsScreen.path,
          extra: debtId, // Pass the ID to the next screen
        );
      }
    } catch (e) {
      if (mounted) {
        CustomSnackbar.show(context, e.toString());
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Helper to generate days
  List<String> _getDropdownItems() {
    return List.generate(31, (index) => (index + 1).toString());
  }

  @override
  Widget build(BuildContext context) {
    // You can also watch the provider state for loading if you prefer
    // final providerState = ref.watch(debtListNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Add a debt')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    CustomTextFormField(
                      isRounded: true,
                      label: 'Debt name',
                      hint: 'Car loan',
                      controller: _nameController,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Required' : null,
                    ),
                    const Gap(16),
                    CustomTextFormField(
                      isRounded: true,
                      label: 'Amount owed',
                      hint: '100,000,000',
                      controller: _amountOwedController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Required' : null,
                    ),
                    const Gap(16),
                    CustomTextFormField(
                      isRounded: true,
                      label: 'Interest rate',
                      hint: '5%',
                      controller: _interestRateController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}'),
                        ),
                      ],
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Required' : null,
                    ),
                    const Gap(16),
                    Text(
                      'How would you prefer to pay off this debt?',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontFamily: Constants.neulisNeueFontFamily,
                      ),
                    ),
                    const Gap(8),
                    Row(
                      spacing: 8,
                      children: LoanRepaymentFrequency.values.map((frequency) {
                        return Expanded(
                          child: _buildPaymentFrequencyButton(
                            frequency.name[0].toUpperCase() +
                                frequency.name.substring(1),
                            isSelected: _selectedPaymentFrequency == frequency,
                            onTap: () => setState(() {
                              _selectedPaymentFrequency = frequency;
                              _selectedRepaymentDay =
                                  null; // Reset dropdown selection
                            }),
                          ),
                        );
                      }).toList(),
                    ),
                    const Gap(8),
                    const InsightCard(
                      insightType: InsightType.nextBestAction,
                      text:
                          'Pay ₦125,000/month to clear ₦1,000,000 loan in 8 months.',
                    ),
                    const Gap(16),
                    // Only show dropdown if relevant
                    if (_selectedPaymentFrequency !=
                        LoanRepaymentFrequency.manually)
                      CustomDropdownButton(
                        items: _getDropdownItems(),
                        label:
                            'Day of the ${_selectedPaymentFrequency.name.replaceFirst('ly', '')}',
                        onChanged: (val) {
                          setState(() => _selectedRepaymentDay = val);
                        },
                      ),
                    const Gap(16),
                    CustomTextFormField(
                      isRounded: true,
                      label: 'Minimum monthly payment',
                      hint: '100,000',
                      controller: _minimumPaymentController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}'),
                        ),
                      ],
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Required' : null,
                    ),
                    const Gap(8),
                    const InsightCard(
                      insightType: InsightType.nahlInsight,
                      text:
                          'At ₦100,000/month and 5% interest, your loan will be be paid off in 9 months.',
                    ),
                    const Gap(8),
                    const InsightCard(
                      insightType: InsightType.nextBestAction,
                      text:
                          'We will send you a reminder when each repayment is due',
                    ),
                    const Gap(16),
                    CustomTextFormField(
                      isRounded: true,
                      controller: _dateController,
                      hint: '01/03/26',
                      label: 'Target payoff date',
                      suffixIcon: const Icon(Icons.calendar_month),
                      readOnly: true, // Prevent manual typing to ensure format
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Required' : null,
                      onTap: () async {
                        final date = await DateTimeUtils.pickDate(
                          context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2050),
                        );
                        if (date != null) {
                          setState(() {
                            _selectedDate = date;
                            _dateController.text =
                                '${date.month}/${date.day}/${date.year}';
                          });
                        }
                      },
                    ),
                    const Gap(16),
                  ],
                ),
              ),
              CustomElevatedButton(
                text: 'Add repayment details',
                isLoading: _isLoading,
                onPressed: _submitDebtStep1,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentFrequencyButton(
    String text, {
    isSelected = false,
    VoidCallback? onTap,
  }) {
    return CustomCard(
      borderWidth: isSelected ? 2 : null,
      borderRadius: 8,
      onTap: onTap,
      borderColor: isSelected ? AppColors.primary : null,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Center(
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.fade,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
