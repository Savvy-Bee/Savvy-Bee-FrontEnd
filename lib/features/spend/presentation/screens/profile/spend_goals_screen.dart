import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/utils/num_extensions.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_error_widget.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_loading_widget.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/screens/profile/spend_goal_detail_screen.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/spending_flow_theme.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/widgets/spending_flow/back_button_widget.dart';
import 'package:savvy_bee_mobile/features/tools/domain/models/savings.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/providers/goals_provider.dart';

const _goalColorPalette = [
  AppColors.foodAmber,
  AppColors.transportBlue,
  AppColors.billsPurple,
  AppColors.entertainmentGreen,
  AppColors.coral,
  AppColors.stressRed,
];

class SpendGoalsScreen extends ConsumerWidget {
  static const String path = '/spend/profile/goals';

  const SpendGoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(savingsGoalsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: goalsAsync.when(
          loading: () => const CustomLoadingWidget(),
          error: (e, _) => CustomErrorWidget.error(
            subtitle: e.toString(),
            onRetry: () => ref.invalidate(savingsGoalsProvider),
          ),
          data: (goals) {
            final totalSaved = goals.fold<double>(0, (s, g) => s + g.balance);
            final activeCount = goals.where((g) => !g.isCompleted).length;

            return Column(
              children: [
                Expanded(
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

                          Text('Goals', style: AppTextStyles.displayLarge),
                          const SizedBox(height: 2),
                          Text(
                            'Track your savings progress',
                            style: AppTextStyles.bodySmall,
                          ),
                          const SizedBox(height: 24),

                          // Total saved card
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.cardWhite,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.borderLight),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Total Saved',
                                        style: AppTextStyles.labelMedium,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        totalSaved.formatCurrency(
                                          decimalDigits: 0,
                                        ),
                                        style: AppTextStyles.amountLarge,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Across $activeCount active ${activeCount == 1 ? 'goal' : 'goals'}',
                                        style: AppTextStyles.labelSmall,
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: AppColors.entertainmentGreenLight,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Icon(
                                    Icons.trending_up_rounded,
                                    color: AppColors.entertainmentGreen,
                                    size: 24,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          if (goals.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 40),
                              child: Center(
                                child: Text(
                                  'No goals yet. Create one to get started!',
                                  style: AppTextStyles.bodySmall,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            )
                          else
                            ...goals.asMap().entries.map((entry) {
                              final i = entry.key;
                              final goal = entry.value;
                              final color =
                                  _goalColorPalette[i % _goalColorPalette.length];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _GoalCard(
                                  goal: goal,
                                  progressColor: color,
                                  onTap: () => context.push(
                                    SpendGoalDetailScreen.path,
                                    extra: goal,
                                  ),
                                ),
                              );
                            }),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                  child: _PrimaryButton(label: '+ Create New Goal', onTap: () {}),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final SavingsGoal goal;
  final Color progressColor;
  final VoidCallback? onTap;

  const _GoalCard({
    required this.goal,
    required this.progressColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fraction = (goal.targetAmount > 0
            ? goal.balance / goal.targetAmount
            : 0.0)
        .clamp(0.0, 1.0);
    final percent = (fraction * 100).round();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.cardWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    goal.goalName,
                    style: AppTextStyles.amountSmall.copyWith(fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: goal.isCompleted
                        ? progressColor
                        : progressColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    goal.isCompleted ? '✓ Done' : '$percent%',
                    style: TextStyle(
                      color: goal.isCompleted
                          ? Colors.white
                          : progressColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: fraction,
                backgroundColor: AppColors.progressBg,
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                minHeight: 7,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  goal.balance.formatCurrency(decimalDigits: 0),
                  style: AppTextStyles.labelSmall,
                ),
                Text(
                  goal.targetAmount.formatCurrency(decimalDigits: 0),
                  style: AppTextStyles.labelSmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _PrimaryButton({required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.foodAmber,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),
        ),
      ),
    );
  }
}
