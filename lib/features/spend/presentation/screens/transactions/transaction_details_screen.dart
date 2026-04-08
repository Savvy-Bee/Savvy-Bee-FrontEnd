import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/utils/date_time_extension.dart';
import 'package:savvy_bee_mobile/core/utils/num_extensions.dart';
import 'package:savvy_bee_mobile/features/spend/domain/models/wallet.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/screens/transfer/transfer_screen_one.dart';
import 'package:share_plus/share_plus.dart';

class TransactionDetailScreen extends StatelessWidget {
  static const String path = '/transaction-detail';

  final WalletTransaction transaction;

  const TransactionDetailScreen({super.key, required this.transaction});

  void _shareTransaction() {
    final direction = transaction.isCredit ? 'Received from' : 'Sent to';
    final text = '''
Savvy Bee Transaction Receipt
━━━━━━━━━━━━━━━━━━━━━━━
$direction: ${transaction.transactionFor}
Amount: ${transaction.amount.formatCurrency()}
${transaction.charges > 0 ? 'Fee: ${transaction.charges.formatCurrency()}\n' : ''}Status: ${transaction.status.value}
Date: ${transaction.createdAt.formatDateTime()}
${transaction.koraReferenceId.isNotEmpty ? 'Reference: ${transaction.koraReferenceId}' : ''}
${transaction.narration.isNotEmpty ? 'Note: ${transaction.narration}' : ''}
━━━━━━━━━━━━━━━━━━━━━━━'''.trim();
    Share.share(text);
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length.clamp(0, 2)).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final isCredit = transaction.isCredit;
    final directionLabel = isCredit ? 'From' : 'To';
    final dateLabel =
        '${transaction.createdAt.formatDayOrToday()},  ${transaction.createdAt.formatTime()}';
    final formattedAmount = transaction.amount.formatCurrency();
    final formattedCharges = transaction.charges.formatCurrency();
    final initials = transaction.transactionFor.isNotEmpty
        ? _initials(transaction.transactionFor)
        : '--';

    Color statusColor;
    if (transaction.isSuccess) {
      statusColor = const Color(0xFF22C55E);
    } else if (transaction.isPending) {
      statusColor = Colors.orange;
    } else {
      statusColor = Colors.red;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button
              Padding(
                padding: const EdgeInsets.only(left: 16.0, top: 12.0),
                child: GestureDetector(
                  onTap: () => Navigator.maybePop(context),
                  child: const Icon(
                    Icons.chevron_left,
                    size: 28,
                    color: Colors.black,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Amount + Avatar row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            formattedAmount,
                            style: TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                              decoration: transaction.isFailed
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                              decorationColor: Colors.black,
                              decorationThickness: 2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.black87,
                              ),
                              children: [
                                TextSpan(text: '$directionLabel '),
                                TextSpan(
                                  text: transaction.transactionFor,
                                  style: const TextStyle(
                                    decoration: TextDecoration.underline,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            dateLabel,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Avatar + type chip
                    Column(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black, width: 1.5),
                          ),
                          child: Center(
                            child: Text(
                              initials,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isCredit
                                ? const Color(0xFFE8F5E9)
                                : const Color(0xFFF3F0FF),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: isCredit
                                      ? const Color(0xFF4CAF50)
                                      : const Color(0xFF7C5CBF),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isCredit
                                      ? Icons.arrow_downward
                                      : Icons.arrow_upward,
                                  size: 10,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                transaction.type.value,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isCredit
                                      ? const Color(0xFF4CAF50)
                                      : const Color(0xFF7C5CBF),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Action buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => context.pushNamed(TransferScreenOne.path),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Send again',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward, size: 18),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _shareTransaction,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: Colors.black26),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Share',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(
                              Icons.upload_outlined,
                              color: Colors.black,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Narration / note
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F7F7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    transaction.narration.isNotEmpty
                        ? transaction.narration
                        : 'No note',
                    style: TextStyle(
                      fontSize: 14,
                      color: transaction.narration.isNotEmpty
                          ? Colors.black87
                          : Colors.black38,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Transaction info card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: _InfoCard(
                  rows: [
                    _DetailRow(
                      label: 'Status',
                      valueWidget: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            transaction.status.value,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _DetailRow(label: directionLabel, value: transaction.transactionFor),
                    if (transaction.koraReferenceId.isNotEmpty)
                      _DetailRow(
                        label: 'Transaction Reference',
                        valueWidget: _CopyableValue(
                          text: transaction.koraReferenceId,
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Payment details card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: _InfoCard(
                  rows: [
                    const _DetailRow(
                      label: 'Payment Method',
                      value: 'Bank Transfer',
                    ),
                    _DetailRow(
                      label: isCredit ? 'Amount received' : 'Amount sent',
                      value: formattedAmount,
                    ),
                    if (transaction.charges > 0)
                      _DetailRow(
                        label: 'Transfer Fee',
                        value: formattedCharges,
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<_DetailRow> rows;

  const _InfoCard({required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          for (int i = 0; i < rows.length; i++) ...[
            if (i != 0)
              const Divider(
                height: 1,
                thickness: 1,
                color: Color(0xFFEAEAEA),
                indent: 16,
                endIndent: 16,
              ),
            rows[i],
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String? value;
  final Widget? valueWidget;

  const _DetailRow({required this.label, this.value, this.valueWidget});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
          valueWidget ??
              Text(
                value ?? '',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
        ],
      ),
    );
  }
}

class _CopyableValue extends StatelessWidget {
  final String text;
  final String? copyText;

  const _CopyableValue({required this.text, this.copyText});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => Clipboard.setData(ClipboardData(text: copyText ?? text)),
          child: const Icon(Icons.copy_outlined, size: 16, color: Colors.black45),
        ),
      ],
    );
  }
}
