import 'package:flutter/material.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/spending_flow_theme.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/widgets/spending_flow/back_button_widget.dart';

class EmotionalPatternsScreen extends StatelessWidget {
  static const String path = '/spending-flow/emotional-patterns';

  const EmotionalPatternsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                const BackButtonWidget(),
                const SizedBox(height: 20),

                // Title
                Text(
                  'Emotional\nPatterns',
                  style: AppTextStyles.displayLarge.copyWith(height: 1.15),
                ),
                const SizedBox(height: 4),
                Text(
                  'Understanding your triggers.',
                  style: AppTextStyles.bodySmall,
                ),

                const SizedBox(height: 24),

                // Key Insight Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.coralLight,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.coralSoft),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.coral.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text('💡', style: TextStyle(fontSize: 20)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Key Insight',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.coral,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'You spend 35% more when stressed, mostly on weekday evenings after work.',
                              style: AppTextStyles.bodyMedium.copyWith(
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Stress Spending Card
                _EmotionCard(
                  emoji: '😤',
                  label: 'Stress Spending',
                  trigger: 'Peak: Weekday evenings',
                  triggerColor: AppColors.stressRed,
                  bgColor: AppColors.stressRedLight,
                  borderColor: AppColors.stressRed.withOpacity(0.15),
                  amount: '₦15,000',
                  transactions: 8,
                  buttonLabel: 'Set Spending Limit',
                  buttonColor: AppColors.stressRed,
                ),

                const SizedBox(height: 12),

                // Impulse Buys Card
                _EmotionCard(
                  emoji: '⚡',
                  label: 'Impulse Buys',
                  trigger: 'Peak: Weekend mornings',
                  triggerColor: AppColors.impulseBlue,
                  bgColor: AppColors.impulseBlueLight,
                  borderColor: AppColors.impulseBlue.withOpacity(0.15),
                  amount: '₦8,000',
                  transactions: 5,
                  buttonLabel: 'Set Spending Limit',
                  buttonColor: AppColors.impulseBlue,
                ),

                const SizedBox(height: 24),

                // Recent Activity
                Text('Recent Activity', style: AppTextStyles.headingMedium),
                const SizedBox(height: 14),

                Container(
                  decoration: BoxDecoration(
                    color: AppColors.cardWhite,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Column(
                    children: [
                      _ActivityRow(
                        date: 'Apr 10, Thu',
                        description: 'Late evening shopping',
                        tag: 'Stress',
                        tagColor: AppColors.stressRed,
                        amount: '-₦4,200',
                        showDivider: true,
                      ),
                      _ActivityRow(
                        date: 'Apr 9, Wed',
                        description: 'Food delivery after work',
                        tag: 'Stress',
                        tagColor: AppColors.stressRed,
                        amount: '-₦4,500',
                        showDivider: true,
                      ),
                      _ActivityRow(
                        date: 'Apr 6, Sat',
                        description: 'Morning coffee & snacks',
                        tag: 'Impulse',
                        tagColor: AppColors.impulseBlue,
                        amount: '-₦2,800',
                        showDivider: true,
                      ),
                      _ActivityRow(
                        date: 'Apr 5, Sat',
                        description: 'Unplanned shopping',
                        tag: 'Impulse',
                        tagColor: AppColors.impulseBlue,
                        amount: '-₦6,200',
                        showDivider: false,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmotionCard extends StatelessWidget {
  final String emoji;
  final String label;
  final String trigger;
  final Color triggerColor;
  final Color bgColor;
  final Color borderColor;
  final String amount;
  final int transactions;
  final String buttonLabel;
  final Color buttonColor;

  const _EmotionCard({
    required this.emoji,
    required this.label,
    required this.trigger,
    required this.triggerColor,
    required this.bgColor,
    required this.borderColor,
    required this.amount,
    required this.transactions,
    required this.buttonLabel,
    required this.buttonColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: AppTextStyles.headingMedium),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.bar_chart_rounded,
                          size: 12,
                          color: triggerColor,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          trigger,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: triggerColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          Divider(height: 1, color: borderColor),
          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Amount', style: AppTextStyles.labelSmall),
                    const SizedBox(height: 4),
                    Text(amount, style: AppTextStyles.amountMedium),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Transactions', style: AppTextStyles.labelSmall),
                    const SizedBox(height: 4),
                    Text('$transactions', style: AppTextStyles.amountMedium),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          GestureDetector(
            onTap: () {},
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(
                color: AppColors.cardWhite,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: buttonColor.withOpacity(0.25)),
              ),
              child: Center(
                child: Text(
                  buttonLabel,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: buttonColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  final String date;
  final String description;
  final String tag;
  final Color tagColor;
  final String amount;
  final bool showDivider;

  const _ActivityRow({
    required this.date,
    required this.description,
    required this.tag,
    required this.tagColor,
    required this.amount,
    required this.showDivider,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(date, style: AppTextStyles.labelSmall),
                    const SizedBox(height: 3),
                    Text(description, style: AppTextStyles.amountSmall),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: tagColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        tag,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: tagColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                amount,
                style: AppTextStyles.amountSmall.copyWith(
                  color: AppColors.stressRed,
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: 18,
            endIndent: 18,
            color: AppColors.borderLight,
          ),
      ],
    );
  }
}
