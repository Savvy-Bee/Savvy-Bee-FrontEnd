import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/number_formatter.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_input_field.dart';
import 'package:savvy_bee_mobile/core/widgets/outlined_card.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/screens/transfer/send_money_screen.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/widgets/mini_button.dart';

import '../../../../core/utils/currency_input_formatter.dart';
import '../../../../core/widgets/dial_pad_widget.dart';

class NumberPadWidget extends ConsumerStatefulWidget {
  const NumberPadWidget({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _NumberPadWidgetState();

  static void show(BuildContext context) {
    showModalBottomSheet(
      isScrollControlled: true,
      useSafeArea: true,
      context: context,
      builder: (context) => NumberPadWidget(),
    );
  }
}

class _NumberPadWidgetState extends ConsumerState<NumberPadWidget> {
  final _narrationController = TextEditingController();
  final _amountController = TextEditingController();

  // Create an instance of the formatter to use manually
  final _formatter = CurrencyInputFormatter();

  // Helper to update and format text
  void _updateAmount(String newText) {
    final oldValue = _amountController.value;

    // Create a new TextEditingValue
    final newValue = oldValue.copyWith(
      text: newText,
      // We can't know the exact cursor position, so let's default to the end.
      // This is acceptable for a number pad.
      selection: TextSelection.collapsed(offset: newText.length),
    );

    // Manually run the formatter
    final formattedValue = _formatter.formatEditUpdate(oldValue, newValue);

    // Set the controller's value to the formatted value
    // This will display the formatted text and move the cursor to the end.
    _amountController.value = formattedValue;
  }

  void _onNumberPressed(String number) {
    // Get the raw text, add the new number, and let _updateAmount format it
    final currentText = _amountController.text;
    _updateAmount(currentText + number);
  }

  void _onDecimalPressed() {
    final currentText = _amountController.text;
    // The formatter will handle preventing multiple decimals
    _updateAmount('$currentText.');
  }

  void _onDeletePressed() {
    final currentText = _amountController.text;
    if (currentText.isNotEmpty) {
      final newText = currentText.substring(0, currentText.length - 1);
      _updateAmount(newText);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Gap(24),
          OutlinedCard(
            borderColor: AppColors.primary,
            bgColor: AppColors.primaryFaint,
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 16),
            child: Text(
              'Savvy Wallet Balance: ₦64,606.16',
              style: TextStyle(fontSize: 12),
            ),
          ),
          const Gap(32),
          CustomTextFormField(
            controller: _amountController,
            showOutline: false,
            hint: NumberFormatter.formatCurrency(0),
            readOnly: true,
            keyboardType: TextInputType.none,
            // prefix: Text(
            //   '€',
            //   style: TextStyle(
            //     fontSize: 24.0,
            //     fontWeight: FontWeight.bold,
            //     color: AppColors.black,
            //     height: 2,
            //   ),
            // ),
            inputFormatters: [CurrencyInputFormatter()],
          ),
          const Gap(16),
          Row(
            children: [
              Expanded(
                child: CustomTextFormField(
                  controller: _narrationController,
                  showOutline: false,
                  hint: 'Narration',
                  prefix: IconButton(
                    onPressed: () async {
                      _narrationController.text =
                          await BudgetCategoryBottomSheet.show(context);
                    },
                    icon: Icon(Icons.pie_chart, color: AppColors.primary),
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                ),
              ),
              MiniButton(
                child: Icon(Icons.send_outlined, size: 16),
                onTap: () {},
              ),
            ],
          ),
          const Gap(32),
          DialPad(
            onNumberPressed: (number) => _onNumberPressed(number),
            onDecimalPressed: _onDecimalPressed,
            onDeletePressed: _onDeletePressed,
          ),
        ],
      ),
    );
  }
}
