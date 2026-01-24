import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_card.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/widgets/send_money_bottom_sheets.dart';

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
            onPressed: () {},
            icon: Icon(Icons.person_add_alt_outlined),
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
              onPressed: () => EnterAmountBottomSheet.show(
                context,
                recipientAccountInfo: widget.recipientAccountInfo,
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
