import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
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

// enum LoanRepaymentFrequency { weekly, monthly, quarterly, manually }
enum LoanRepaymentFrequency { weekly, monthly, quarterly }

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

  String? _selectedRepaymentDay;
  DateTime? _selectedDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Add listeners to recalculate when values change
    _amountOwedController.addListener(_updateInsight);
    _interestRateController.addListener(_updateInsight);
    _minimumPaymentController.addListener(_updateInsight);
  }

  void _updateInsight() {
    setState(() {}); // Trigger rebuild when values change
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountOwedController.dispose();
    _interestRateController.dispose();
    _minimumPaymentController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  // Calculate months to payoff
  String _calculatePayoffInsight() {
    final amountText = _amountOwedController.text.replaceAll(',', '');
    final interestText = _interestRateController.text.replaceAll('%', '');
    final minPaymentText = _minimumPaymentController.text.replaceAll(',', '');

    final amount = num.tryParse(amountText);
    final interestRate = num.tryParse(interestText);
    final minPayment = num.tryParse(minPaymentText);

    if (amount == null || interestRate == null || minPayment == null) {
      return 'Enter all fields to see payoff calculation';
    }

    if (amount <= 0 || minPayment <= 0) {
      return 'Enter valid amounts to see payoff calculation';
    }

    // Calculate months to pay off with interest
    final monthlyInterestRate = (interestRate / 100) / 12;

    if (minPayment <= (amount * monthlyInterestRate)) {
      return 'Minimum payment is too low to cover interest. Increase payment amount.';
    }

    int months = 0;
    double remainingBalance = amount.toDouble();

    // Simple amortization calculation
    while (remainingBalance > 0 && months < 1200) {
      // Cap at 100 years to prevent infinite loop
      final interestCharge = remainingBalance * monthlyInterestRate;
      final principalPayment = minPayment - interestCharge;
      remainingBalance -= principalPayment;
      months++;

      if (remainingBalance <= 0) break;
    }

    final formattedPayment = minPayment
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );

    return 'At ₦$formattedPayment/month and ${interestRate.toStringAsFixed(1)}% interest, your loan will be paid off in $months months.';
  }

  Future<void> _submitDebtStep1() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDate == null) {
      CustomSnackbar.show(context, 'Please select a target payoff date');
      return;
    }

    // Add validation for repayment day (except for manual payments)
    // if (_selectedPaymentFrequency != LoanRepaymentFrequency.manually &&
    //     _selectedRepaymentDay == null) {
    //   CustomSnackbar.show(
    //     context,
    //     'Please select a repayment day for ${_selectedPaymentFrequency.name} payments',
    //   );
    //   return;
    // }
    if (_selectedRepaymentDay == null) {
      CustomSnackbar.show(
        context,
        'Please select a repayment day for ${_selectedPaymentFrequency.name} payments',
      );
      return;
    }

    // Clean data (remove commas if formatted, etc.)
    final amount = _amountOwedController.text.replaceAll(',', '');
    final minPayment = _minimumPaymentController.text.replaceAll(',', '');
    final interest = _interestRateController.text.replaceAll('%', '');

    // Validate that parsing will succeed
    if (num.tryParse(amount) == null) {
      CustomSnackbar.show(context, 'Invalid amount owed');
      return;
    }
    if (num.tryParse(interest) == null) {
      CustomSnackbar.show(context, 'Invalid interest rate');
      return;
    }
    if (num.tryParse(minPayment) == null) {
      CustomSnackbar.show(context, 'Invalid minimum payment');
      return;
    }

    setState(() => _isLoading = true);

    final DebtRequestModel reqData = DebtRequestModel(
      name: _nameController.text.trim(),
      amountOwed: num.parse(
        amount,
      ), // Now safe to use parse instead of tryParse
      interestRate: num.parse(interest),
      paymentFrequency: _selectedPaymentFrequency.name.capitalizeFirstLetter(),
      minPayment: num.parse(minPayment),
      expectedPayoffDate: _selectedDate!,
      repaymentDay:
          _selectedRepaymentDay ?? '1', // Provide default for manual payments
    );

    try {
      // Call Provider
      final response = await ref
          .read(debtListNotifierProvider.notifier)
          .createDebt(reqData);

      if (mounted) {
        final String debtId = response.debtId;

        context.pushNamed(DebtRepaymentDetailsScreen.path, extra: debtId);
      }
    } catch (e) {
      if (mounted) {
        CustomSnackbar.show(context, e.toString());
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<String> _getDropdownItems() {
    switch (_selectedPaymentFrequency) {
      case LoanRepaymentFrequency.weekly:
        return List.generate(7, (index) => (index + 1).toString());

      case LoanRepaymentFrequency.monthly:
      case LoanRepaymentFrequency.quarterly:
        // Use 1–28 so it works for all months safely
        return List.generate(28, (index) => (index + 1).toString());

      // case LoanRepaymentFrequency.manually:
      //   return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add a debt')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            CustomTextFormField(
              isRounded: true,
              label: 'Debt name',
              hint: 'Car loan',
              controller: _nameController,
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const Gap(16),
            CustomTextFormField(
              isRounded: true,
              label: 'Amount owed',
              hint: '100,000,000',
              controller: _amountOwedController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
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
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const Gap(16),
            Text(
              'How would you prefer to pay off this debt?',
              style: TextStyle(fontWeight: FontWeight.w500),
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
                      _selectedRepaymentDay = null;
                    }),
                  ),
                );
              }).toList(),
            ),
            // const Gap(8),
            // const InsightCard(
            //   insightType: InsightType.nextBestAction,
            //   text: 'Pay ₦125,000/month to clear ₦1,000,000 loan in 8 months.',
            // ),
            const Gap(16),
            // if (_selectedPaymentFrequency != LoanRepaymentFrequency.manually)
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
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const Gap(8),
            // Dynamic calculated insight
            InsightCard(
              insightType: InsightType.nahlInsight,
              text: _calculatePayoffInsight(),
            ),
            const Gap(8),
            const InsightCard(
              insightType: InsightType.nextBestAction,
              text: 'We will send you a reminder when each repayment is due',
            ),
            const Gap(16),
            CustomTextFormField(
              isRounded: true,
              controller: _dateController,
              hint: '01/03/26',
              label: 'Target payoff date',
              suffixIcon: const Icon(Icons.calendar_month),
              readOnly: true,
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
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
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16).copyWith(bottom: 32),
        child: CustomElevatedButton(
          text: 'Add repayment details',
          isLoading: _isLoading,
          onPressed: _submitDebtStep1,
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
