import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/utils/num_extensions.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/providers/wallet_provider.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/screens/spending_flow/category_detail_screen.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/screens/spending_flow/emotional_patterns_screen.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/spending_flow_theme.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/widgets/spending_flow/category_row.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/widgets/spending_flow/emotional_insight_banner.dart';

class FlowScreen extends ConsumerWidget {
  static const String path = '/spending-flow';

  const FlowScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(spendDashboardDataProvider);
    final txAsync = ref.watch(transactionListProvider);

    final balance = dashboardAsync.valueOrNull?.data?.accounts.balance ?? 0.0;

    final now = DateTime.now();
    final transactions = txAsync.valueOrNull?.data?.transactions ?? [];
    final thisMonthTx = transactions.where((t) {
      return t.createdAt.year == now.year && t.createdAt.month == now.month;
    }).toList();

    final totalIncome = thisMonthTx
        .where((t) => t.isCredit)
        .fold(0.0, (sum, t) => sum + t.amount);
    final totalSpent = thisMonthTx
        .where((t) => t.isDebit)
        .fold(0.0, (sum, t) => sum + t.amount);

    final isLoading = dashboardAsync.isLoading || txAsync.isLoading;

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

                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Flow', style: AppTextStyles.displayLarge),
                        const SizedBox(height: 2),
                        Text(
                          'Your spending patterns.',
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppColors.cardWhite,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // This Month card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.cardWhite,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.borderLight, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('This Month', style: AppTextStyles.labelMedium),
                      const SizedBox(height: 12),
                      isLoading
                          ? _shimmerAmount()
                          : Text(
                              balance.compactCurrency(),
                              style: AppTextStyles.amountLarge.copyWith(
                                fontSize: 38,
                              ),
                            ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _StatChip(
                            label: 'Income',
                            value: isLoading
                                ? '...'
                                : totalIncome.compactCurrency(),
                            color: AppColors.entertainmentGreen,
                          ),
                          const SizedBox(width: 12),
                          _StatChip(
                            label: 'Spent',
                            value: isLoading
                                ? '...'
                                : totalSpent.compactCurrency(),
                            color: AppColors.coral,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // By Category header
                Text('By Category', style: AppTextStyles.headingMedium),
                const SizedBox(height: 14),

                // Category rows
                CategoryRow(
                  icon: '🍔',
                  iconBgColor: AppColors.foodAmberLight,
                  label: 'Food',
                  percentage: '30% of spending',
                  amount: '₦18,000',
                  progressColor: AppColors.foodAmber,
                  progressValue: 0.30,
                  onTap: () => context.push(
                    CategoryDetailScreen.path,
                    extra: const CategoryInfo(
                      icon: '🍔',
                      iconBgColor: AppColors.foodAmberLight,
                      progressColor: AppColors.foodAmber,
                      label: 'Food',
                      amount: '₦18,000',
                      percentage: '30% of spending',
                    ),
                  ),
                ),
                CategoryRow(
                  icon: '🚗',
                  iconBgColor: AppColors.transportBlueLight,
                  label: 'Transport',
                  percentage: '25% of spending',
                  amount: '₦12,000',
                  progressColor: AppColors.transportBlue,
                  progressValue: 0.25,
                  onTap: () => context.push(
                    CategoryDetailScreen.path,
                    extra: const CategoryInfo(
                      icon: '🚗',
                      iconBgColor: AppColors.transportBlueLight,
                      progressColor: AppColors.transportBlue,
                      label: 'Transport',
                      amount: '₦12,000',
                      percentage: '25% of spending',
                    ),
                  ),
                ),
                CategoryRow(
                  icon: '💡',
                  iconBgColor: AppColors.billsPurpleLight,
                  label: 'Bills',
                  percentage: '21% of spending',
                  amount: '₦10,000',
                  progressColor: AppColors.billsPurple,
                  progressValue: 0.21,
                  onTap: () => context.push(
                    CategoryDetailScreen.path,
                    extra: const CategoryInfo(
                      icon: '💡',
                      iconBgColor: AppColors.billsPurpleLight,
                      progressColor: AppColors.billsPurple,
                      label: 'Bills',
                      amount: '₦10,000',
                      percentage: '21% of spending',
                    ),
                  ),
                ),
                CategoryRow(
                  icon: '🎉',
                  iconBgColor: AppColors.entertainmentGreenLight,
                  label: 'Entertainment',
                  percentage: '17% of spending',
                  amount: '₦8,000',
                  progressColor: AppColors.entertainmentGreen,
                  progressValue: 0.17,
                  showDivider: false,
                  onTap: () => context.push(
                    CategoryDetailScreen.path,
                    extra: const CategoryInfo(
                      icon: '🎉',
                      iconBgColor: AppColors.entertainmentGreenLight,
                      progressColor: AppColors.entertainmentGreen,
                      label: 'Entertainment',
                      amount: '₦8,000',
                      percentage: '17% of spending',
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Emotional Insight Banner
                EmotionalInsightBanner(
                  onTap: () => context.push(EmotionalPatternsScreen.path),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _shimmerAmount() {
    return Container(
      width: 120,
      height: 38,
      decoration: BoxDecoration(
        color: AppColors.progressBg,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.labelSmall),
            const SizedBox(height: 4),
            Text(
              value,
              style: AppTextStyles.amountSmall.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}
