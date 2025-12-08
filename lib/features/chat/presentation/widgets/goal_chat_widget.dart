import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/num_extensions.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_card.dart';
import 'package:savvy_bee_mobile/features/chat/domain/models/chat_models.dart';

class GoalChatWidget extends ConsumerStatefulWidget {
  final GoalData? goalData;
  final VoidCallback? onCreateGoal;
  final VoidCallback? onViewAchievements;

  const GoalChatWidget({
    super.key,
    this.goalData,
    this.onCreateGoal,
    this.onViewAchievements,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _GoalChatWidgetState();
}

class _GoalChatWidgetState extends ConsumerState<GoalChatWidget> {
  @override
  Widget build(BuildContext context) {
    final hasGoalData = widget.goalData != null;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Motivational message
                Text(
                  '''I'm here for you 🥰
Every small step counts toward your financial goals 🌱''',
                  style: TextStyle(fontSize: 14, height: 1.4),
                ),
                const Gap(10),
                Text(
                  hasGoalData
                      ? '''Based on your profile, here's a personalized goal suggestion that fits your financial journey.'''
                      : '''To make you feel better, let's try setting a goal for this week and celebrating your progress so far.''',
                  style: TextStyle(fontSize: 14, height: 1.4),
                ),
                const Gap(16),

                // Goal suggestion card
                CustomCard(
                  borderRadius: 8,
                  borderColor: AppColors.primary.withValues(alpha: 0.3),
                  bgColor: AppColors.primaryFaint.withValues(alpha: 0.3),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            color: AppColors.primary,
                            size: 16,
                          ),
                          const Gap(6),
                          Text(
                            'Personalized Suggestion',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const Gap(8),
                      if (hasGoalData) ...[
                        Row(
                          children: [
                            Icon(
                              Icons.flag_rounded,
                              color: AppColors.primary,
                              size: 20,
                            ),
                            const Gap(8),
                            Expanded(
                              child: Text(
                                widget.goalData!.goalName,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Gap(8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.savings_outlined,
                                color: AppColors.success,
                                size: 16,
                              ),
                              const Gap(8),
                              Text(
                                'Target: ${widget.goalData!.goalAmount.formatCurrency(decimalDigits: 0)}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.success,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else
                        Text(
                          "Save ₦50,000 this week",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ),

                // Motivational tip
                if (hasGoalData) ...[
                  const Gap(12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: AppColors.primary,
                          size: 16,
                        ),
                        const Gap(8),
                        Expanded(
                          child: Text(
                            'Break it down into smaller monthly or weekly targets to make it more achievable!',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.primaryDark,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Action buttons
          const Divider(height: 0),
          TextButton.icon(
            onPressed: widget.onCreateGoal,
            label: Text(hasGoalData ? 'Create This Goal' : 'Create Goal'),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.all(20),
              foregroundColor: AppColors.primary,
            ),
          ),
          const Divider(height: 0),
          TextButton.icon(
            onPressed: widget.onViewAchievements,
            label: const Text('View Achievements'),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.all(20),
              foregroundColor: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
