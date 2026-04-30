import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_card.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_snackbar.dart';
import 'package:savvy_bee_mobile/features/spend/domain/models/beneficiary.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/providers/beneficiary_provider.dart';
import 'enter_amount_screen.dart';

import '../../../../../core/theme/app_colors.dart';

class RecipientAccountInfo {
  final String accountName;
  final String accountNumber;
  final String bankName;
  final String bankCode;

  const RecipientAccountInfo({
    required this.accountName,
    required this.accountNumber,
    required this.bankName,
    required this.bankCode,
  });
}

class TransferAmountArgs {
  final RecipientAccountInfo recipientAccountInfo;
  final String amount;
  final String transferFor;
  final String narration;

  const TransferAmountArgs({
    required this.recipientAccountInfo,
    required this.amount,
    required this.transferFor,
    required this.narration,
  });
}

class SendMoneyScreen extends ConsumerStatefulWidget {
  static const String path = '/send-money';

  final RecipientAccountInfo recipientAccountInfo;

  const SendMoneyScreen({super.key, required this.recipientAccountInfo});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SendMoneyScreenState();
}

class _SendMoneyScreenState extends ConsumerState<SendMoneyScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recipientAccountInfo.accountName),
        actions: [
          IconButton(
            tooltip: 'Save beneficiary',
            onPressed: () => _SaveBeneficiaryBottomSheet.show(
              context,
              recipientAccountInfo: widget.recipientAccountInfo,
              onSave: (beneficiary) {
                ref.read(beneficiaryProvider.notifier).add(beneficiary);
                CustomSnackbar.show(
                  context,
                  'Beneficiary saved',
                  type: SnackbarType.success,
                );
              },
            ),
            icon: const Icon(Icons.person_add_alt_outlined),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16).copyWith(bottom: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(child: ListView(children: [])),
            CustomElevatedButton(
              text: 'Send money',
              onPressed: () => context.pushNamed(
                EnterAmountScreen.path,
                extra: widget.recipientAccountInfo,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BudgetCategoryBottomSheet extends StatelessWidget {
  BudgetCategoryBottomSheet({super.key});

  final List<String> categories = [
    'Auto & transport',
    'Business',
    'Entertainment',
    'Food & drink',
    'Health & fitness',
    'Home',
    'Other',
    'Personal care',
    'Shopping',
    'Travel',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: categories
                .map(
                  (category) => CutomChip(
                    icon: Icon(Icons.pie_chart, color: AppColors.primary),
                    label: category,
                    onPressed: () => context.pop(category),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  static Future<String?> show(BuildContext context) async {
    return await showModalBottomSheet(
      context: context,
      showDragHandle: true,
      useRootNavigator: true,
      builder: (context) => BudgetCategoryBottomSheet(),
    );
  }
}

class CutomChip extends StatelessWidget {
  final Widget icon;
  final String label;
  final VoidCallback onPressed;

  const CutomChip({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      onTap: onPressed,
      borderRadius: 20,
      borderColor: AppColors.borderDark,
      padding: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          const Gap(8),
          Text(label, style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

class _SaveBeneficiaryBottomSheet extends StatelessWidget {
  final RecipientAccountInfo recipientAccountInfo;
  final void Function(Beneficiary) onSave;

  const _SaveBeneficiaryBottomSheet({
    required this.recipientAccountInfo,
    required this.onSave,
  });

  static void show(
    BuildContext context, {
    required RecipientAccountInfo recipientAccountInfo,
    required void Function(Beneficiary) onSave,
  }) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _SaveBeneficiaryBottomSheet(
        recipientAccountInfo: recipientAccountInfo,
        onSave: onSave,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Save beneficiary',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const Gap(8),
          const Text(
            'Save this recipient for quick future transfers.',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const Gap(24),
          CustomCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _InfoRow(
                  label: 'Account name',
                  value: recipientAccountInfo.accountName,
                ),
                const Gap(8),
                _InfoRow(
                  label: 'Account number',
                  value: recipientAccountInfo.accountNumber,
                ),
                const Gap(8),
                _InfoRow(label: 'Bank', value: recipientAccountInfo.bankName),
              ],
            ),
          ),
          const Gap(24),
          Row(
            children: [
              Expanded(
                child: CustomOutlinedButton(
                  text: 'Cancel',
                  onPressed: () => context.pop(),
                ),
              ),
              const Gap(8),
              Expanded(
                child: CustomElevatedButton(
                  text: 'Save',
                  buttonColor: CustomButtonColor.black,
                  onPressed: () {
                    onSave(
                      Beneficiary(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        name: recipientAccountInfo.accountName,
                        accountNumber: recipientAccountInfo.accountNumber,
                        bankName: recipientAccountInfo.bankName,
                        bankCode: recipientAccountInfo.bankCode,
                      ),
                    );
                    context.pop();
                  },
                ),
              ),
            ],
          ),
          const Gap(8),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
