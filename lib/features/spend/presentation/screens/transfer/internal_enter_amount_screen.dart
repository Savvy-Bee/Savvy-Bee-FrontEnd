import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/utils/currency_input_formatter.dart';
import 'package:savvy_bee_mobile/core/utils/num_extensions.dart';
import 'package:savvy_bee_mobile/core/widgets/dial_pad_widget.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/providers/wallet_provider.dart';

import 'internal_review_screen.dart';

class InternalTransferArgs {
  final String username;
  final String amount;
  final String narration;

  const InternalTransferArgs({
    required this.username,
    required this.amount,
    required this.narration,
  });
}

class InternalEnterAmountScreen extends ConsumerStatefulWidget {
  static const String path = '/internal-enter-amount';

  final String username;

  const InternalEnterAmountScreen({super.key, required this.username});

  @override
  ConsumerState<InternalEnterAmountScreen> createState() =>
      _InternalEnterAmountScreenState();
}

class _InternalEnterAmountScreenState
    extends ConsumerState<InternalEnterAmountScreen> {
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

  void _onDecimalPressed() => _updateAmount('${_amountController.text}.');

  void _onDeletePressed() {
    final text = _amountController.text;
    if (text.isNotEmpty) _updateAmount(text.substring(0, text.length - 1));
  }

  void _onContinue() {
    context.pushNamed(
      InternalReviewScreen.path,
      extra: InternalTransferArgs(
        username: widget.username,
        amount: _amountController.text,
        narration: _narrationController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dashboardAsync = ref.watch(spendDashboardDataProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Amount',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Gap(20),
              Text(
                'How much to @${widget.username}?',
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const Spacer(),

              // Amount display
              Center(
                child: Column(
                  children: [
                    const Text(
                      '₦',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w300,
                        color: Colors.black,
                      ),
                    ),
                    const Gap(8),
                    Text(
                      _amountController.text.isEmpty
                          ? '0'
                          : _amountController.text,
                      style: const TextStyle(
                        fontSize: 72,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                        letterSpacing: -2,
                      ),
                    ),
                  ],
                ),
              ),

              const Gap(12),
              Center(
                child: dashboardAsync.when(
                  data: (data) => Text(
                    'Available: ${data.data?.accounts.balance.formatCurrency(decimalDigits: 0) ?? ''}',
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF757575),
                    ),
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ),

              const Gap(16),

              Center(
                child: TextField(
                  controller: _narrationController,
                  maxLength: 21,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    hintText: 'Enter description',
                    border: InputBorder.none,
                    counterText: '',
                  ),
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                  onChanged: (_) => setState(() {}),
                ),
              ),

              const Spacer(),

              DialPad(
                onNumberPressed: _onNumberPressed,
                onDecimalPressed: _onDecimalPressed,
                onDeletePressed: _onDeletePressed,
              ),

              const Gap(16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _canContinue ? _onContinue : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFC107),
                    disabledBackgroundColor: Colors.grey.shade200,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _canContinue ? Colors.black : Colors.grey.shade400,
                    ),
                  ),
                ),
              ),
              const Gap(30),
            ],
          ),
        ),
      ),
    );
  }
}
