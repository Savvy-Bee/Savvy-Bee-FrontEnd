import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/screens/profile/spend_goal_detail_screen.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/spending_flow_theme.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/widgets/spending_flow/back_button_widget.dart';

class SpendGoalsScreen extends StatelessWidget {
  static const String path = '/spend/profile/goals';

  const SpendGoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
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

                      // Header
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Total Saved',
                                    style: AppTextStyles.labelMedium,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '₦56,550',
                                    style: AppTextStyles.amountLarge,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Across 3 active goals',
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

                      // Goals list
                      _GoalCard(
                        label: 'Rent',
                        saved: 25500,
                        target: 30000,
                        progressColor: AppColors.foodAmber,
                        badgeColor: AppColors.foodAmber,
                        badgeLabel: null,
                        onTap: () => context.push(SpendGoalDetailScreen.path),
                      ),
                      const SizedBox(height: 12),

                      _GoalCard(
                        label: 'Emergency Fund',
                        saved: 21000,
                        target: 50000,
                        progressColor: AppColors.transportBlue,
                        badgeColor: AppColors.transportBlue,
                        badgeLabel: '42%',
                        onTap: () => context.push(SpendGoalDetailScreen.path),
                      ),
                      const SizedBox(height: 12),

                      _GoalCard(
                        label: 'School Fees',
                        saved: 10050,
                        target: 15000,
                        progressColor: AppColors.billsPurple,
                        badgeColor: AppColors.billsPurple,
                        badgeLabel: '67%',
                        onTap: () => context.push(SpendGoalDetailScreen.path),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),

            // Create New Goal CTA
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
              child: _PrimaryButton(label: '+ Create New Goal', onTap: () {}),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final String label;
  final int saved;
  final int target;
  final Color progressColor;
  final Color badgeColor;
  final String? badgeLabel;
  final VoidCallback? onTap;

  const _GoalCard({
    required this.label,
    required this.saved,
    required this.target,
    required this.progressColor,
    required this.badgeColor,
    required this.badgeLabel,
    this.onTap,
  });

  String _formatAmount(int n) {
    if (n >= 1000) {
      return '₦${(n / 1000).toStringAsFixed(n % 1000 == 0 ? 0 : 1)}k';
    }
    return '₦$n';
  }

  @override
  Widget build(BuildContext context) {
    final double fraction = (saved / target).clamp(0.0, 1.0);
    final int percent = (fraction * 100).round();

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
                Text(
                  label,
                  style: AppTextStyles.amountSmall.copyWith(fontSize: 16),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: badgeLabel == null
                        ? badgeColor
                        : badgeColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    badgeLabel ?? '$percent%',
                    style: TextStyle(
                      color: badgeLabel == null ? Colors.white : badgeColor,
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
                Text(_formatAmount(saved), style: AppTextStyles.labelSmall),
                Text(_formatAmount(target), style: AppTextStyles.labelSmall),
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
