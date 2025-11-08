import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:savvy_bee_mobile/core/widgets/bottom_sheets/edit_budget_bottom_sheet.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/constants.dart';
import '../../../../../core/utils/number_formatter.dart';
import '../../widgets/insight_card.dart';

class SetBudgetScreen extends ConsumerStatefulWidget {
  static String path = '/set-budget';

  const SetBudgetScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SetBudgetScreenState();
}

class _SetBudgetScreenState extends ConsumerState<SetBudgetScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Set monthly budget')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: ListView(
                children: [
                  Text(
                    "Now let's define your monthly budget.",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w500,
                      fontFamily: Constants.neulisNeueFontFamily,
                    ),
                  ),
                  const Gap(16),
                  Text(
                    "We'll subtract your monthly budget from your income to determine your savings.",
                    style: TextStyle(fontSize: 16),
                  ),
                  const Gap(28),
                  InsightCard(
                    insightType: InsightType.nextBestAction,
                    text:
                        'Based on your past spending, Nahl recommends allocating 30% to needs, 20% to wants, and saving 50%.',
                  ),
                  const Gap(28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Monthly income',
                            style: TextStyle(fontSize: 12),
                          ),
                          const Gap(4),
                          Text(
                            NumberFormatter.formatCurrency(
                              800000,
                              decimalDigits: 0,
                            ),
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              fontFamily: Constants.neulisNeueFontFamily,
                            ),
                          ),
                          const Gap(42),
                          Text(
                            'Monthly Savings',
                            style: TextStyle(fontSize: 12),
                          ),
                          const Gap(4),
                          SizedBox(
                            width: MediaQuery.sizeOf(context).width / 2,
                            child: _buildTextField(context),
                          ),
                          const Gap(42),
                          Text(
                            'Monthly Savings',
                            style: TextStyle(fontSize: 12),
                          ),
                          const Gap(4),
                          Text(
                            NumberFormatter.formatCurrency(
                              400000,
                              decimalDigits: 0,
                            ),
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              fontFamily: Constants.neulisNeueFontFamily,
                            ),
                          ),
                          const Gap(32),
                        ],
                      ),
                    ],
                  ),
                  Text.rich(
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                    TextSpan(
                      text: "At this rate you'll save ",
                      children: [
                        TextSpan(
                          text: '₦4.8M ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: 'every year'),
                      ],
                    ),
                  ),
                  const Gap(8),
                ],
              ),
            ),
            CustomElevatedButton(
              text: 'Save',
              onPressed: () => EditBudgetBottomSheet.show(context),
            ),
          ],
        ),
      ),
    );
  }

  TextField _buildTextField(BuildContext context) {
    var underlineInputBorder = UnderlineInputBorder(
      borderSide: BorderSide(color: AppColors.borderDark),
    );
    var textFieldTextStyle = TextStyle(
      fontSize: 28,
      color: AppColors.textLight,
    );
    return TextField(
      textAlign: TextAlign.center,
      onTapOutside: (event) => FocusScope.of(context).unfocus(),
      style: textFieldTextStyle.copyWith(color: AppColors.black),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        hint: Text(
          '\$400,000',
          textAlign: TextAlign.center,
          style: textFieldTextStyle,
        ),
        alignLabelWithHint: true,
        contentPadding: EdgeInsets.zero,
        border: underlineInputBorder,
        focusedBorder: underlineInputBorder,
        enabledBorder: underlineInputBorder,
      ),
    );
  }
}
