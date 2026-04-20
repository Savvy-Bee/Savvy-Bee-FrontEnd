import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/utils/currency_input_formatter.dart';
import 'package:savvy_bee_mobile/core/utils/num_extensions.dart';
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
  final _amountFocus = FocusNode();
  final _narrationFocus = FocusNode();

  @override
  void dispose() {
    _amountController.dispose();
    _narrationController.dispose();
    _amountFocus.dispose();
    _narrationFocus.dispose();
    super.dispose();
  }

  bool get _canContinue =>
      _amountController.text.trim().isNotEmpty &&
      _narrationController.text.trim().isNotEmpty;

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

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
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
                  'How much to ${widget.recipientAccountInfo.accountName}?',
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
                const Spacer(),

                // Amount input
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
                      const Gap(4),
                      IntrinsicWidth(
                        child: TextField(
                          controller: _amountController,
                          focusNode: _amountFocus,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[\d,.]'),
                            ),
                            CurrencyInputFormatter(),
                          ],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                            letterSpacing: -2,
                          ),
                          decoration: InputDecoration(
                            hintText: '0',
                            hintStyle: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey.shade300,
                              letterSpacing: -2,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          onChanged: (_) => setState(() {}),
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
                    focusNode: _narrationFocus,
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
      ),
    );
  }
}
