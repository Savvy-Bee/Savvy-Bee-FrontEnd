import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';
import 'package:savvy_bee_mobile/core/widgets/outlined_card.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/widgets/number_pad_widget.dart';

import '../../../../../core/theme/app_colors.dart';

class SendMoneyScreen extends ConsumerStatefulWidget {
  static String path = '/send-money';

  final String recipientName;

  const SendMoneyScreen({super.key, required this.recipientName});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SendMoneyScreenState();
}

class _SendMoneyScreenState extends ConsumerState<SendMoneyScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recipientName),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.person_add_alt_outlined),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(child: ListView(children: [])),
            CustomElevatedButton(
              text: 'Send money',
              onPressed: () => NumberPadWidget.show(context),
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
        children: [
          Container(
            width: 40,
            padding: EdgeInsets.all(2.5),
            decoration: BoxDecoration(
              color: AppColors.black,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const Gap(32),
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

  static Future<String> show(BuildContext context) async {
    return await showModalBottomSheet(
      context: context,
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
    return OutlinedCard(
      onTap: onPressed,
      borderRadius: 20,
      borderColor: AppColors.borderDark,
      padding: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          const Gap(8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontFamily: Constants.neulisNeueFontFamily,
            ),
          ),
        ],
      ),
    );
  }
}
