import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';
import 'package:savvy_bee_mobile/core/utils/num_extensions.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_card.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_snackbar.dart';
import 'package:savvy_bee_mobile/core/widgets/dial_pad_widget.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/screens/bills/bill_completion_screen.dart';

import '../../../../../core/utils/string_extensions.dart';
import '../../providers/bill_provider.dart';
import '../../widgets/bottom_sheets/bills_bottom_sheet.dart';

class BillConfirmationData {
  final BillType type;
  final String network;
  final String phoneNumber;
  final double amount;
  final String provider; // Provider code
  final String? transactionRef;
  final String? planCode; // For data/TV
  final String? planName; // For display
  final String? meterType; // For electricity
  final String? meterNumber; // For electricity

  BillConfirmationData({
    required this.type,
    required this.network,
    required this.phoneNumber,
    required this.amount,
    required this.provider,
    this.transactionRef,
    this.planCode,
    this.planName,
    this.meterType,
    this.meterNumber,
  });
}

class BillConfirmationScreen extends ConsumerStatefulWidget {
  static const String path = '/confirmation';

  final BillConfirmationData confirmationData;

  const BillConfirmationScreen({super.key, required this.confirmationData});

  @override
  ConsumerState<BillConfirmationScreen> createState() =>
      _BillConfirmationScreenState();
}

class _BillConfirmationScreenState
    extends ConsumerState<BillConfirmationScreen> {
  bool _isProcessing = false;

  @override
  void dispose() {
    super.dispose();

    // TODO: Cancel the request if the screen is disposed
  }

  Future<void> _verifyTransaction(String pin) async {
    setState(() => _isProcessing = true);

    final rawPhone = widget.confirmationData.phoneNumber;
    // Add country code if not present
    final phoneNumber = rawPhone.startsWith('0')
        ? '+234${rawPhone.substring(1)}'
        : '+234$rawPhone';

    bool success = false;

    try {
      switch (widget.confirmationData.type) {
        case BillType.airtime:
          success = await ref
              .read(billsProvider.notifier)
              .purchaseAirtime(
                pin: pin,
                phoneNo: phoneNumber,
                provider: widget.confirmationData.provider,
                amount: widget.confirmationData.amount.toString(),
              );
          break;
        case BillType.data:
          success = await ref
              .read(billsProvider.notifier)
              .purchaseData(
                pin: pin,
                phoneNo: phoneNumber,
                provider: widget.confirmationData.provider,
                code: widget.confirmationData.planCode ?? '',
              );
          break;
        case BillType.tv:
          // This would already have been initialized in the previous screen
          // thus there is no need to initialize here as well
          () {};
          break;
        case BillType.electricity:
          // This would already have been initialized in the previous screen
          // thus there is no need to initialize here as well
          () {};
          break;
      }

      if (mounted) {
        setState(() => _isProcessing = false);

        // Navigate to completion screen
        if (success) {
          context.pushReplacementNamed(
            BillCompletionScreen.path,
            extra: {
              'type': widget.confirmationData.type,
              'amount': widget.confirmationData.amount,
              'recipient': widget.confirmationData.phoneNumber,
              'network': widget.confirmationData.network,
            },
          );
        } else {
          CustomSnackbar.show(
            context,
            'Transaction failed. Please check your pin and try again.',
            type: SnackbarType.error,
            position: SnackbarPosition.bottom,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        CustomSnackbar.show(
          context,
          'Transaction failed: ${e.toString()}',
          type: SnackbarType.error,
          position: SnackbarPosition.bottom,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.confirmationData;

    return Scaffold(
      appBar: AppBar(title: const Text('Confirm')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('To', style: TextStyle(fontSize: 10)),
                    const Gap(4),
                    Text(
                      data.phoneNumber,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Gap(16),
                    Text('Amount', style: TextStyle(fontSize: 10)),
                    const Gap(4),
                    Text(
                      data.amount.formatCurrency(decimalDigits: 0),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,

                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const Gap(24),
                CustomCard(
                  borderRadius: 16,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildInfoRow('Type:', data.type.name),
                      const Gap(12),
                      _buildInfoRow(
                        widget.confirmationData.type == BillType.electricity
                            ? 'Provider'
                            : 'Network:',
                        data.network.truncate(30),
                      ),
                      if (data.planName != null) ...[
                        const Gap(12),
                        _buildInfoRow('Plan:', data.planName!),
                      ],
                      if (data.meterNumber != null) ...[
                        const Gap(12),
                        _buildInfoRow('Meter Number:', data.meterNumber!),
                      ],
                      if (data.meterType != null) ...[
                        const Gap(12),
                        _buildInfoRow(
                          'Meter Type:',
                          data.meterType!.toUpperCase(),
                        ),
                      ],
                      const Gap(12),
                      _buildInfoRow(
                        'Transaction Fee:',
                        0.formatCurrency(decimalDigits: 0),
                      ),
                      const Gap(12),
                      Divider(color: AppColors.borderDark),
                      const Gap(12),
                      _buildInfoRow(
                        'Total:',
                        data.amount.formatCurrency(decimalDigits: 0),
                        isTotal: true,
                      ),
                    ],
                  ),
                ),
                const Gap(16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const Gap(8),
                      Expanded(
                        child: Text(
                          'Please review the details carefully before confirming',
                          style: TextStyle(
                            fontSize: 10,

                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SafeArea(
              child: CustomElevatedButton(
                onPressed: _isProcessing
                    ? null
                    : () => EnterPinBottomSheet.show(context, (pin) {
                        context.pop();
                        _verifyTransaction(pin);
                      }),
                // onPressed: _isProcessing ? null : _showPinDialog,
                isLoading: _isProcessing,
                text: 'Enter PIN to confirm',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String title, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: isTotal ? 12 : 10,

            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 14 : 12,
            fontWeight: FontWeight.bold,

            color: isTotal ? AppColors.primary : null,
          ),
        ),
      ],
    );
  }
}
