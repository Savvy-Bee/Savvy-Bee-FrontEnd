import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/utils/num_extensions.dart';
import 'package:savvy_bee_mobile/features/spend/domain/models/transaction.dart';

import '../../../../../core/utils/assets/assets.dart';

class SendSuccessScreen extends StatelessWidget {
  static const String path = '/send-success';

  final TransactionData? transaction;

  const SendSuccessScreen({super.key, this.transaction});

  bool get _isSuccess =>
      transaction == null ||
      transaction!.status.toLowerCase() == 'success';

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
                    : (transaction?.message.isNotEmpty == true
                        ? transaction!.message
                        : 'Something went wrong. Please try again.'),
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
                        value: double.tryParse(transaction!.amount)
                                ?.formatCurrency(decimalDigits: 0) ??
                            transaction!.amount,
                      ),
                      const Gap(8),
                      _ReceiptRow(
                        label: 'Fee',
                        value: double.tryParse(transaction!.fee)
                                ?.formatCurrency(decimalDigits: 0) ??
                            transaction!.fee,
                      ),
                      const Gap(8),
                      _ReceiptRow(
                        label: 'Reference',
                        value: transaction!.reference,
                      ),
                    ],
                  ),
                ),
              ],
              const Gap(48),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => context.go('/home'),
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
              if (_isSuccess)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {},
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
