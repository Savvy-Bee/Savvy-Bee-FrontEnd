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
import 'package:savvy_bee_mobile/features/spend/presentation/screens/bills/bill_completion_screen.dart';

import '../../providers/bill_provider.dart';

class BillConfirmationData {
  final String type; // 'Airtime', 'Data', 'TV', 'Electricity'
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
  static String path = '/confirmation';

  final BillConfirmationData confirmationData;

  const BillConfirmationScreen({super.key, required this.confirmationData});

  @override
  ConsumerState<BillConfirmationScreen> createState() =>
      _BillConfirmationScreenState();
}

class _BillConfirmationScreenState
    extends ConsumerState<BillConfirmationScreen> {
  bool _isProcessing = false;

  Future<void> _showPinDialog() async {
    final pinController = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Enter PIN'),
        content: TextField(
          controller: pinController,
          keyboardType: TextInputType.number,
          maxLength: 4,
          obscureText: true,
          decoration: const InputDecoration(
            hintText: 'Enter 4-digit PIN',
            counterText: '',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (pinController.text.length == 4) {
                Navigator.pop(context, pinController.text);
              } else {
                CustomSnackbar.show(
                  context,
                  'Please enter a 4-digit PIN',
                  type: SnackbarType.error,
                );
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (result != null) {
      await _verifyTransaction(result);
    }
  }

  Future<void> _verifyTransaction(String pin) async {
    setState(() => _isProcessing = true);

    try {
      switch (widget.confirmationData.type.toLowerCase()) {
        case 'airtime':
          await ref.read(airtimeProvider.notifier).verifyAirtime(pin: pin);
          break;
        case 'data':
          await ref.read(dataProvider.notifier).verifyData(pin: pin);
          break;
        case 'tv':
          await ref.read(tvProvider.notifier).verifyTv(pin: pin);
          break;
        case 'electricity':
          await ref
              .read(electricityProvider.notifier)
              .verifyElectricity(pin: pin);
          break;
      }

      if (mounted) {
        setState(() => _isProcessing = false);

        // Navigate to completion screen
        context.pushReplacementNamed(
          BillCompletionScreen.path,
          extra: {
            'type': widget.confirmationData.type,
            'amount': widget.confirmationData.amount,
            'recipient': widget.confirmationData.phoneNumber,
            'network': widget.confirmationData.network,
          },
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        CustomSnackbar.show(
          context,
          'Transaction failed: ${e.toString()}',
          type: SnackbarType.error,
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
                    Text(
                      'To',
                      style: TextStyle(
                        fontSize: 10,
                        fontFamily: Constants.neulisNeueFontFamily,
                      ),
                    ),
                    const Gap(4),
                    Text(
                      data.phoneNumber,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: Constants.neulisNeueFontFamily,
                      ),
                    ),
                    const Gap(16),
                    Text(
                      'Amount',
                      style: TextStyle(
                        fontSize: 10,
                        fontFamily: Constants.neulisNeueFontFamily,
                      ),
                    ),
                    const Gap(4),
                    Text(
                      data.amount.formatCurrency(decimalDigits: 0),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: Constants.neulisNeueFontFamily,
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
                      _buildInfoRow('Type:', data.type),
                      const Gap(12),
                      _buildInfoRow('Network:', data.network),
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
                    color: AppColors.primary.withOpacity(0.1),
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
                            fontFamily: Constants.neulisNeueFontFamily,
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
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: CustomElevatedButton(
                onPressed: _isProcessing ? null : _showPinDialog,
                text: _isProcessing ? 'Processing...' : 'Confirm Payment',
                isLoading: _isProcessing,
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
            fontFamily: Constants.neulisNeueFontFamily,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 14 : 12,
            fontWeight: FontWeight.bold,
            fontFamily: Constants.neulisNeueFontFamily,
            color: isTotal ? AppColors.primary : null,
          ),
        ),
      ],
    );
  }
}
