import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/number_formatter.dart';
import 'package:savvy_bee_mobile/core/widgets/outlined_card.dart';

class BudgetChatWidget extends ConsumerStatefulWidget {
  const BudgetChatWidget({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _BudgetChatWidgetState();
}

class _BudgetChatWidgetState extends ConsumerState<BudgetChatWidget> {
  bool showMore = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                OutlinedCard(
                  borderRadius: 8,
                  borderColor: AppColors.border,
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.attach_file,
                            color: AppColors.primary,
                            size: 14,
                          ),
                          const Gap(4),
                          Text(
                            'Heres your spending analysis',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const Gap(4),
                      Text(
                        "You've spent ₦200,000 this month",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Budget',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                    Text('₦200,000/₦600,000', style: TextStyle(fontSize: 8)),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: 0.3,
                        backgroundColor: AppColors.success.withValues(
                          alpha: 0.34,
                        ),
                        minHeight: 10,
                        borderRadius: BorderRadius.circular(10),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.success,
                        ),
                      ),
                    ),
                    const Gap(4),
                    Text('33%', style: TextStyle(fontWeight: FontWeight.w500)),
                  ],
                ),
                const Gap(24),
                ...List.generate(
                  2,
                  (index) => _buildCategoryInfo(
                    'Drinks & dining',
                    totalAmount: 35000,
                    amountSpent: 45000,
                    gainLoss: 30,
                    color: index.isEven ? AppColors.bgBlue : AppColors.primary,
                  ),
                ),
                const Gap(16),
                InkWell(
                  onTap: () {
                    setState(() {
                      showMore = !showMore;
                    });
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Show more categories',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary,
                        ),
                      ),
                      Icon(
                        showMore
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        size: 16,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
                if (showMore) const Gap(16),
                if (showMore) Text('More'),
                const Gap(16),
                OutlinedCard(
                  padding: const EdgeInsets.all(8),
                  borderRadius: 8,
                  borderColor: AppColors.border,
                  bgColor: AppColors.primaryFaint.withValues(alpha: 0.5),
                  child: Text(
                    "⚠️ You're over budget in 2 categories",
                    style: TextStyle(fontSize: 8, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 0),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(padding: const EdgeInsets.all(20)),
            child: Text('Adjust Budget'),
          ),
          const Divider(height: 0),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(padding: const EdgeInsets.all(20)),
            child: Text('Adjust Budget'),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryInfo(
    String title, {
    required double totalAmount,
    required double amountSpent,
    required double gainLoss,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(5.0),
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: Icon(
            Icons.dinner_dining_outlined,
            size: 20,
            color: AppColors.white,
          ),
        ),
        const Gap(8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    '${NumberFormatter.formatCurrency(amountSpent, decimalDigits: 0)} of ${NumberFormatter.formatCurrency(totalAmount, decimalDigits: 0)}',
                    style: TextStyle(fontSize: 8),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: (amountSpent / totalAmount).clamp(0.0, 1.0),
                      backgroundColor: color.withValues(alpha: 0.2),
                      minHeight: 3,
                      borderRadius: BorderRadius.circular(10),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                  const Gap(4),
                  Text(
                    NumberFormatter.formatSignedPercentage(
                      gainLoss,
                      decimalPlaces: 0,
                    ),
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
