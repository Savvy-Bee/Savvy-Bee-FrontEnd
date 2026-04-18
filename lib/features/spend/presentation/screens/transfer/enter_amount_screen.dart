import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/currency_input_formatter.dart';
import 'package:savvy_bee_mobile/core/utils/num_extensions.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_card.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_input_field.dart';
import 'package:savvy_bee_mobile/core/widgets/dial_pad_widget.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/providers/wallet_provider.dart';

import 'review_screen.dart';
import 'send_money_screen.dart';

class EnterAmountScreen extends ConsumerStatefulWidget {
  static const String path = '/enter-amount';

  final RecipientAccountInfo recipientAccountInfo;

  const EnterAmountScreen({super.key, required this.recipientAccountInfo});

  @override
  ConsumerState<EnterAmountScreen> createState() => _EnterAmountScreenState();
}

class _EnterAmountScreenState extends ConsumerState<EnterAmountScreen> {
  final _amountController = TextEditingController();
  final _narrationController = TextEditingController();
  final _formatter = CurrencyInputFormatter();

  @override
  void dispose() {
    _amountController.dispose();
    _narrationController.dispose();
    super.dispose();
  }

  bool get _canContinue =>
      _amountController.text.trim().isNotEmpty &&
      _narrationController.text.trim().isNotEmpty;

  void _updateAmount(String newText) {
    final oldValue = _amountController.value;
    final newValue = oldValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
    setState(() {
      _amountController.value = _formatter.formatEditUpdate(oldValue, newValue);
    });
  }

  void _onNumberPressed(String number) =>
      _updateAmount(_amountController.text + number);

  void _onDecimalPressed() =>
      _updateAmount('${_amountController.text}.');

  void _onDeletePressed() {
    final text = _amountController.text;
    if (text.isNotEmpty) _updateAmount(text.substring(0, text.length - 1));
  }

  void _onContinue() {
    context.pushNamed(
      ReviewScreen.path,
      extra: TransferAmountArgs(
        recipientAccountInfo: widget.recipientAccountInfo,
        amount: _amountController.text,
        narration: _narrationController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dashboardAsync = ref.watch(spendDashboardDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Send to ${widget.recipientAccountInfo.accountName}'),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Gap(8),
              dashboardAsync.when(
                data: (data) => CustomCard(
                  borderColor: AppColors.primary,
                  bgColor: AppColors.primaryFaint,
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                  child: Text(
                    'Savvy Wallet Balance: ${data.data?.accounts.balance.formatCurrency(decimalDigits: 0)}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const Gap(24),
              CustomTextFormField(
                controller: _amountController,
                showOutline: false,
                hint: (0).formatCurrency(decimalDigits: 0),
                readOnly: true,
                keyboardType: TextInputType.none,
                onChanged: (_) => setState(() {}),
                inputFormatters: [CurrencyInputFormatter()],
              ),
              const Gap(12),
              Row(
                children: [
                  Expanded(
                    child: CustomTextFormField(
                      controller: _narrationController,
                      showOutline: false,
                      hint: 'Narration',
                      prefixIcon: IconButton(
                        onPressed: () async {
                          final value = await BudgetCategoryBottomSheet.show(context);
                          if (value != null) {
                            _narrationController.text = value;
                            setState(() {});
                          }
                        },
                        icon: const Icon(Icons.pie_chart, color: AppColors.primary),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ],
              ),
              const Gap(24),
              DialPad(
                onNumberPressed: _onNumberPressed,
                onDecimalPressed: _onDecimalPressed,
                onDeletePressed: _onDeletePressed,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _canContinue ? _onContinue : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.black,
                    disabledBackgroundColor: Colors.grey.shade200,
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Continue',
                    style: TextStyle(
                      color: _canContinue ? Colors.white : Colors.grey.shade400,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const Gap(8),
            ],
          ),
        ),
      ),
    );
  }
}
