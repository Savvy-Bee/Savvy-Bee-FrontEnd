import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/utils/num_extensions.dart';
import 'package:savvy_bee_mobile/features/spend/domain/models/wallet.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/screens/spend_screen.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/screens/transactions/transaction_details_screen.dart';

import '../../../../../core/utils/assets/assets.dart';

class SendSuccessScreen extends StatelessWidget {
  static const String path = '/send-success';

  final WalletTransaction? transaction;

  const SendSuccessScreen({super.key, this.transaction});

  bool get _isSuccess =>
      transaction == null ||
      transaction!.isSuccess ||
      transaction!.isPending;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                _isSuccess ? Assets.successSvg : Assets.errorSvg,
                width: 80,
                height: 80,
              ),
              const Gap(32),
              Text(
                _isSuccess ? 'Sent Successfully' : 'Transfer Failed',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Gap(8),
              Text(
                _isSuccess
                    ? 'Your money is on its way'
                    : 'Something went wrong. Please try again.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, color: Colors.grey),
              ),
              if (transaction != null) ...[
                const Gap(24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      _ReceiptRow(
                        label: 'Amount',
                        value: transaction!.amount.formatCurrency(
                          decimalDigits: 0,
                        ),
                      ),
                      const Gap(8),
                      _ReceiptRow(
                        label: 'Fee',
                        value: transaction!.charges.formatCurrency(
                          decimalDigits: 0,
                        ),
                      ),
                      const Gap(8),
                      _ReceiptRow(
                        label: 'Reference',
                        value: transaction!.koraReferenceId.length > 6
                            ? '...${transaction!.koraReferenceId.substring(transaction!.koraReferenceId.length - 6)}'
                            : transaction!.koraReferenceId,
                      ),
                    ],
                  ),
                ),
              ],
              const Gap(48),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => context.go(SpendScreen.path),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.black,
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Go Home',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const Gap(16),
              if (_isSuccess && transaction != null)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => context.pushNamed(
                      TransactionDetailScreen.path,
                      extra: transaction,
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      side: const BorderSide(color: Colors.grey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'View Receipt',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              const Gap(24),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  final String label;
  final String value;

  const _ReceiptRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
      ],
    );
  }
}
