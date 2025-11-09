import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/widgets/outlined_card.dart';

import '../../../../core/utils/assets/app_icons.dart';

class GoalChatWidget extends ConsumerStatefulWidget {
  const GoalChatWidget({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _GoalChatWidgetState();
}

class _GoalChatWidgetState extends ConsumerState<GoalChatWidget> {
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
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '''I'm here for you 🥰
Every small step counts toward your financial goals 🌱''',
                  style: TextStyle(fontSize: 16),
                ),
                const Gap(10),
                Text(
                  '''To make you feel better, let's try setting a goal for this week and celebrating your progress so far.''',
                  style: TextStyle(fontSize: 16),
                ),
                const Gap(10),
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
                          AppIcon(
                            AppIcons.sparklesIcon,
                            color: AppColors.primary,
                            size: 14,
                          ),
                          const Gap(4),
                          Text(
                            'Personalized Suggestion',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const Gap(4),
                      Text(
                        "Save ₦50,000 this week",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 0),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(padding: const EdgeInsets.all(20)),
            child: Text('Create Goal'),
          ),
          const Divider(height: 0),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(padding: const EdgeInsets.all(20)),
            child: Text('View Achievements'),
          ),
        ],
      ),
    );
  }
}
