import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:savvy_bee_mobile/core/utils/num_extensions.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/spending_flow_theme.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/widgets/spending_flow/back_button_widget.dart';
import 'package:savvy_bee_mobile/features/tools/domain/models/savings.dart';

class SpendGoalDetailScreen extends StatelessWidget {
  static const String path = '/spend/profile/goals/detail';

  final SavingsGoal goal;

  const SpendGoalDetailScreen({super.key, required this.goal});

  String _formatEndDate(String endDate) {
    try {
      final date = DateTime.parse(endDate);
      return DateFormat('MMMM d, yyyy').format(date);
    } catch (_) {
      return endDate;
    }
  }

  String _daysRemaining(String endDate) {
    try {
      final date = DateTime.parse(endDate);
      final now = DateTime.now();
      final diff = date.difference(now).inDays;
      if (diff < 0) return 'Past due';
      if (diff == 0) return 'Due today';
      return '$diff ${diff == 1 ? 'day' : 'days'} remaining';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final fraction = (goal.targetAmount > 0
            ? goal.balance / goal.targetAmount
            : 0.0)
        .clamp(0.0, 1.0);
    final percent = (fraction * 100).round();

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

                      Text(goal.goalName, style: AppTextStyles.displayLarge),
                      const SizedBox(height: 2),
                      Text(
                        goal.goalType,
                        style: AppTextStyles.bodySmall,
                      ),
                      const SizedBox(height: 24),

                      // Progress card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
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
                                  'Progress',
                                  style: AppTextStyles.labelMedium,
                                ),
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: AppColors.foodAmberLight,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.trending_up_rounded,
                                    color: AppColors.foodAmber,
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '$percent%',
                              style: AppTextStyles.displayLarge.copyWith(
                                fontSize: 42,
                              ),
                            ),
                            const SizedBox(height: 14),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: LinearProgressIndicator(
                                value: fraction,
                                backgroundColor: AppColors.progressBg,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  AppColors.foodAmber,
                                ),
                                minHeight: 8,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Saved',
                                        style: AppTextStyles.labelSmall,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        goal.balance.formatCurrency(
                                          decimalDigits: 0,
                                        ),
                                        style: AppTextStyles.amountMedium,
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Target',
                                        style: AppTextStyles.labelSmall,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        goal.targetAmount.formatCurrency(
                                          decimalDigits: 0,
                                        ),
                                        style: AppTextStyles.amountMedium,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Target date card
                      if (goal.endDate.isNotEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: AppColors.foodAmberLight,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.foodAmber.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today_rounded,
                                    size: 14,
                                    color: AppColors.foodAmber,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Target Date',
                                    style: AppTextStyles.labelSmall.copyWith(
                                      color: AppColors.foodAmber,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _formatEndDate(goal.endDate),
                                style: AppTextStyles.headingMedium.copyWith(
                                  fontSize: 20,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _daysRemaining(goal.endDate),
                                style: AppTextStyles.labelSmall,
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

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.foodAmber,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text(
                      '+ Add Money',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
