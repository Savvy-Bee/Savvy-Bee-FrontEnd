import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/utils/num_extensions.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/providers/transfer_provider.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/providers/wallet_provider.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/widgets/send_money_bottom_sheets.dart';

import 'send_money_screen.dart';
import 'success_screen.dart';

class ReviewScreen extends ConsumerWidget {
  static const String path = '/review';

  final TransferAmountArgs args;

  const ReviewScreen({super.key, required this.args});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final amountDouble = double.tryParse(args.amount.replaceAll(',', '')) ?? 0;

    final initAsync = ref.watch(
      initializeTransferProvider((
        accountNumber: args.recipientAccountInfo.accountNumber,
        bankCode: args.recipientAccountInfo.bankCode,
        amount: amountDouble,
        accountName: args.recipientAccountInfo.accountName,
      )),
    );

    final dashboardAsync = ref.watch(spendDashboardDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Review'),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Confirm the details',
              style: TextStyle(fontSize: 15, color: Colors.grey),
            ),
            const Gap(20),

            // Transfer summary card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "You're sending",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const Gap(8),
                  Text(
                    amountDouble.formatCurrency(decimalDigits: 0),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -1,
                    ),
                  ),
                  const Gap(24),
                  _DetailRow(
                    label: 'To',
                    value:
                        '${args.recipientAccountInfo.accountName} (${args.recipientAccountInfo.bankName})',
                  ),
                  const Gap(12),
                  _DetailRow(
                    label: 'Account',
                    value: args.recipientAccountInfo.accountNumber,
                  ),
                  const Gap(12),
                  _DetailRow(label: 'Narration', value: args.narration),
                  const Gap(12),
                  _DetailRow(
                    label: 'From',
                    value: dashboardAsync.when(
                      data: (d) =>
                          d.data?.accounts.ngnAccount?.accountNumber ??
                          'Savvy Wallet',
                      loading: () => 'Savvy Wallet',
                      error: (_, __) => 'Savvy Wallet',
                    ),
                  ),
                  const Gap(12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Fee',
                        style: TextStyle(fontSize: 15, color: Colors.grey),
                      ),
                      initAsync.when(
                        data: (data) => Text(
                          double.tryParse(
                                    (data['fee'] ?? '10').toString(),
                                  )?.formatCurrency(decimalDigits: 0) ??
                              '₦10',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        loading: () => const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        error: (_, __) => const Text(
                          '₦10',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => EnterPinBottomSheet.show(
                  context,
                  amount: args.amount,
                  category: args.narration,
                  recipientAccountInfo: args.recipientAccountInfo,
                  onSuccess: (transaction) => context.pushNamed(
                    SendSuccessScreen.path,
                    extra: transaction,
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.black,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Confirm & send',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const Gap(16),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 15, color: Colors.grey)),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
