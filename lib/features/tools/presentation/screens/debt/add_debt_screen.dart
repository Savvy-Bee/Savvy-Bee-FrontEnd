import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_dropdown_button.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_input_field.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_card.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/screens/debt/debt_repayment_details_screen.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/widgets/insight_card.dart';

import '../../../../../core/utils/constants.dart';
import '../../../../../core/utils/date_time_utils.dart';

enum LoanRepaymentFrequency { weekly, monthly, quarterly, manually }

class AddDebtScreen extends ConsumerStatefulWidget {
  static const String path = '/add-debt';

  const AddDebtScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddDebtScreenState();
}

class _AddDebtScreenState extends ConsumerState<AddDebtScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountOwedController = TextEditingController();
  final TextEditingController _interestRateController = TextEditingController();
  final TextEditingController _minimumPaymentController =
      TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  LoanRepaymentFrequency _selectedPaymentFrequency =
      LoanRepaymentFrequency.monthly;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add a debt')),
      body: Padding(
        padding: const EdgeInsets.all(16),
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
                  ),
                  const Gap(16),
                  CustomTextFormField(
                    isRounded: true,
                    label: 'Amount owed',
                    hint: '\$100,000,000',
                    controller: _amountOwedController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  const Gap(16),
                  CustomTextFormField(
                    isRounded: true,
                    label: 'Interest rate',
                    hint: '5%',
                    controller: _interestRateController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
                          onTap: () => setState(
                            () => _selectedPaymentFrequency = frequency,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const Gap(8),
                  InsightCard(
                    insightType: InsightType.nextBestAction,
                    text:
                        'Pay ₦125,000/month to clear ₦1,000,000 loan in 8 months.',
                  ),
                  const Gap(16),
                  CustomDropdownButton(
                    items: const [],
                    label: 'Day of the ${_selectedPaymentFrequency.name}',
                  ),
                  const Gap(16),
                  CustomTextFormField(
                    isRounded: true,
                    label: 'Minimum monthly payment',
                    hint: '\$100,000',
                    controller: _minimumPaymentController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  const Gap(8),
                  InsightCard(
                    insightType: InsightType.nahlInsight,
                    text:
                        'At ₦100,000/month and 5% interest, your loan will be be paid off in 9 months.',
                  ),
                  const Gap(8),
                  InsightCard(
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
                    suffix: Icon(Icons.calendar_month),
                    onTap: () async {
                      final date = await DateTimeUtils.pickDate(
                      context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2050),
                      );
                      if (date != null) {
                        setState(() {
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
              onPressed: () =>
                  context.pushNamed(DebtRepaymentDetailsScreen.path),
            ),
          ],
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
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Center(
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.fade,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
