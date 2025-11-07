import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/assets/assets.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';
import 'package:savvy_bee_mobile/core/utils/number_formatter.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_input_field.dart';
import 'package:savvy_bee_mobile/core/widgets/outlined_card.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/screens/transfer/send_money_screen.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/widgets/mini_button.dart';

import '../../../../core/utils/currency_input_formatter.dart';
import '../../../../core/widgets/dial_pad_widget.dart';
import '../../../../core/widgets/dot.dart';

class EnterAmountBottomSheet extends ConsumerStatefulWidget {
  final String recipientName;
  const EnterAmountBottomSheet({super.key, required this.recipientName});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EnterAmountBottomSheetState();

  static void show(BuildContext context, {required String recipientName}) {
    showModalBottomSheet(
      isScrollControlled: true,
      useSafeArea: true,
      context: context,
      builder: (context) =>
          EnterAmountBottomSheet(recipientName: recipientName),
    );
  }
}

class _EnterAmountBottomSheetState
    extends ConsumerState<EnterAmountBottomSheet> {
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

    setState(() {
      _amountController.value = formattedValue;
    });
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
    return Padding(
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
            onChanged: (_) {
              setState(() {});
            },
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
                      setState(() {});
                    },
                    icon: Icon(Icons.pie_chart, color: AppColors.primary),
                  ),
                  onChanged: (_) {
                    setState(() {});
                  },
                ),
              ),
              MiniButton(
                onTap:
                    _amountController.text.trim().isEmpty ||
                        _narrationController.text.trim().isEmpty
                    ? null
                    : () {
                        EnterPinBottomSheet.show(
                          context,
                          amount: _amountController.text,
                          category: _narrationController.text,
                          recipientName: widget.recipientName,
                        );
                      },
                child: Icon(
                  Icons.send_outlined,
                  size: 16,
                  color:
                      _amountController.text.trim().isEmpty ||
                          _narrationController.text.trim().isEmpty
                      ? AppColors.buttonDisabled
                      : null,
                ),
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

class EnterPinBottomSheet extends ConsumerStatefulWidget {
  final String amount;
  final String category;
  final String recipientName;
  const EnterPinBottomSheet({
    super.key,
    required this.amount,
    required this.category,
    required this.recipientName,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EnterPinBottomSheetState();

  static void show(
    BuildContext context, {
    required String amount,
    required String category,
    required String recipientName,
  }) {
    showModalBottomSheet(
      isScrollControlled: true,
      useSafeArea: true,
      isDismissible: false,
      enableDrag: false,
      context: context,
      builder: (context) => EnterPinBottomSheet(
        amount: amount,
        category: category,
        recipientName: recipientName,
      ),
    );
  }
}

class _EnterPinBottomSheetState extends ConsumerState<EnterPinBottomSheet> {
  String pin = '';

  void _updatePin(String newText) {
    if (newText.length <= 4) {
      setState(() => pin = newText);
    }
    if (pin.length == 4) {
      context.pop();
      context.pop();

      TransactionCompletionBottomSheet.show(context);
    }
  }

  void _onNumberPressed(String number) {
    if (pin.length < 4) _updatePin(pin + number);
  }

  void _onDeletePressed() {
    if (pin.isNotEmpty) _updatePin(pin.substring(0, pin.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Gap(6),
        Container(
          width: 40,
          padding: EdgeInsets.all(2.5),
          decoration: BoxDecoration(
            color: AppColors.black,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        const Gap(16),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    style: Constants.collapsedButtonStyle,
                    icon: Icon(Icons.close),
                  ),
                ],
              ),
              const Gap(16),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primaryFaint,
                      shape: BoxShape.circle,
                    ),
                    child: Text('Logo'),
                  ),
                  const Gap(8),
                  Text(
                    widget.recipientName,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontFamily: Constants.neulisNeueFontFamily,
                    ),
                  ),
                ],
              ),
              const Gap(16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    NumberFormatter.formatCurrency(
                      double.parse(widget.amount.split(',').join()),
                      decimalDigits: 0,
                    ),
                    style: TextStyle(fontSize: 16),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(widget.category, style: TextStyle(fontSize: 16)),
                      const Gap(8),
                      Icon(Icons.pie_chart, color: AppColors.primary),
                    ],
                  ),
                ],
              ),
              const Gap(24),
              OutlinedCard(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 24,
                ),
                borderRadius: 50,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('From:', style: TextStyle(fontSize: 10)),
                        Text(
                          '1234567890',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            fontFamily: Constants.neulisNeueFontFamily,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Transaction Fee:',
                          style: TextStyle(fontSize: 10),
                        ),
                        Text(
                          NumberFormatter.formatCurrency(10),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            fontFamily: Constants.neulisNeueFontFamily,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Gap(24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_outline, size: 20, color: AppColors.primary),
                  const Gap(8),
                  Text('Transaction PIN', style: TextStyle(fontSize: 12)),
                ],
              ),
              const Gap(16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Dot(
                      size: 16,
                      color: index < pin.length
                          ? AppColors.primary
                          : AppColors.grey,
                    ),
                  );
                }),
              ),
              const Gap(24),
              DialPad(
                onNumberPressed: (number) => _onNumberPressed(number),
                onDecimalPressed: () {},
                onDeletePressed: _onDeletePressed,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class TransactionCompletionBottomSheet extends StatelessWidget {
  const TransactionCompletionBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => TransactionCompletionBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Gap(6),
        Container(
          width: 40,
          padding: EdgeInsets.all(2.5),
          decoration: BoxDecoration(
            color: AppColors.black,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        const Gap(16),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(Assets.successSvg),
              const Gap(16),
              Text(
                'Sent',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: Constants.neulisNeueFontFamily,
                ),
              ),
              const Gap(4),
              Text.rich(
                textAlign: TextAlign.center,
                TextSpan(
                  text: '₦60,000',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  children: [
                    TextSpan(
                      text: ' is on its way to\n',
                      style: TextStyle(fontWeight: FontWeight.w400),
                    ),
                    TextSpan(text: 'Aegon Targaryen'),
                  ],
                ),
              ),
              const Gap(24),
              CustomElevatedButton(
                text: 'Share receipt',
                onPressed: () {},
                buttonColor: CustomButtonColor.black,
                icon: Icon(Icons.file_upload_outlined),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
