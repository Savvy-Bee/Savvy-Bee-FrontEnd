import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/utils/num_extensions.dart';
import 'package:savvy_bee_mobile/features/spend/domain/models/wallet.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/providers/transfer_provider.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/providers/wallet_provider.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/widgets/send_money_bottom_sheets.dart';

import 'send_money_screen.dart';
import 'success_screen.dart';

class ReviewScreen extends ConsumerStatefulWidget {
  static const String path = '/review';

  final TransferAmountArgs args;

  const ReviewScreen({super.key, required this.args});

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialize();
    });
  }

  Future<void> _initialize() async {
    final amountDouble =
        double.tryParse(widget.args.amount.replaceAll(',', '')) ?? 0;
    ref.read(transferNotifierProvider.notifier).reset();
    try {
      await ref
          .read(transferNotifierProvider.notifier)
          .initializeExternalTransfer(
            accountNumber: widget.args.recipientAccountInfo.accountNumber,
            bankCode: widget.args.recipientAccountInfo.bankCode,
            amount: amountDouble,
            accountName: widget.args.recipientAccountInfo.accountName,
          );
    } catch (_) {
      // Error is shown via transferState.error in build
    }
  }

  @override
  Widget build(BuildContext context) {
    final transferState = ref.watch(transferNotifierProvider);
    final amountDouble =
        double.tryParse(widget.args.amount.replaceAll(',', '')) ?? 0;
    final dashboardAsync = ref.watch(spendDashboardDataProvider);

    final bool isInitializing =
        transferState.isLoading && !transferState.isInitialized;

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
                        '${widget.args.recipientAccountInfo.accountName} (${widget.args.recipientAccountInfo.bankName})',
                  ),
                  const Gap(12),
                  _DetailRow(
                    label: 'Account',
                    value: widget.args.recipientAccountInfo.accountNumber,
                  ),
                  const Gap(12),
                  _DetailRow(label: 'For', value: widget.args.transferFor),
                  const Gap(12),
                  _DetailRow(label: 'Narration', value: widget.args.narration),
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
                      if (isInitializing)
                        const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      else
                        Text(
                          double.tryParse(
                                (transferState.initializeResult?['fee'] ?? '0')
                                    .toString(),
                              )?.formatCurrency(decimalDigits: 0) ??
                              '₦10',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                  if (transferState.error != null) ...[
                    const Gap(12),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            transferState.error!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: isInitializing ? null : _initialize,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed:
                    transferState.isInitialized && !transferState.isLoading
                        ? () => EnterPinBottomSheet.show(
                            context,
                            amount: widget.args.amount,
                            category: widget.args.transferFor,
                            narration: widget.args.narration,
                            recipientAccountInfo:
                                widget.args.recipientAccountInfo,
                            onSuccess: (WalletTransaction transaction) =>
                              context.pushNamed(
                                SendSuccessScreen.path,
                                extra: transaction,
                              ),
                          )
                        : null,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.black,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isInitializing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
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
