import 'package:flutter/material.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/spending_flow_theme.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/widgets/spending_flow/back_button_widget.dart';

class SpendGoalDetailScreen extends StatelessWidget {
  static const String path = '/spend/profile/goals/detail';

  const SpendGoalDetailScreen({super.key});

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
                      Text('Rent', style: AppTextStyles.displayLarge),
                      const SizedBox(height: 2),
                      Text(
                        'Monthly rent savings goal',
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
                              '85%',
                              style: AppTextStyles.displayLarge.copyWith(
                                fontSize: 42,
                              ),
                            ),
                            const SizedBox(height: 14),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: const LinearProgressIndicator(
                                value: 0.85,
                                backgroundColor: AppColors.progressBg,
                                valueColor: AlwaysStoppedAnimation<Color>(
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
                                        '₦25,500',
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
                                        '₦30,000',
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

                      // Target Date card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: AppColors.foodAmberLight,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.foodAmber.withOpacity(0.2),
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
                              'April 30, 2026',
                              style: AppTextStyles.headingMedium.copyWith(
                                fontSize: 20,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '20 days remaining',
                              style: AppTextStyles.labelSmall,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Contributions
                      Text('Contributions', style: AppTextStyles.headingMedium),
                      const SizedBox(height: 14),

                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.cardWhite,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: Column(
                          children: [
                            _ContributionRow(
                              date: 'Apr 8, 2026',
                              amount: '+₦5,000',
                              showDivider: true,
                            ),
                            _ContributionRow(
                              date: 'Apr 1, 2026',
                              amount: '+₦10,000',
                              showDivider: true,
                            ),
                            _ContributionRow(
                              date: 'Mar 15, 2026',
                              amount: '+₦7,500',
                              showDivider: true,
                            ),
                            _ContributionRow(
                              date: 'Mar 1, 2026',
                              amount: '+₦3,000',
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

            // Add Money CTA
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

class _ContributionRow extends StatelessWidget {
  final String date;
  final String amount;
  final bool showDivider;

  const _ContributionRow({
    required this.date,
    required this.amount,
    required this.showDivider,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(date, style: AppTextStyles.bodyMedium),
              Text(
                amount,
                style: AppTextStyles.amountSmall.copyWith(
                  color: AppColors.entertainmentGreen,
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
