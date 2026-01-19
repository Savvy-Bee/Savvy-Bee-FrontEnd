import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_card.dart';
import 'package:savvy_bee_mobile/features/tools/domain/models/taxation.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/providers/taxation_provider.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/screens/taxation/calculate_tax_screen.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/screens/taxation/strategy_center_screen.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/screens/taxation/tax_stats_screen.dart';

import '../../../../../core/utils/assets/app_icons.dart';

class TaxationDashboardScreen extends ConsumerStatefulWidget {
  static const String path = '/taxation-dashboard';

  const TaxationDashboardScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _TaxationDashboardScreenState();
}

class _TaxationDashboardScreenState
    extends ConsumerState<TaxationDashboardScreen> {
  String _formatCurrency(int amount) {
    return NumberFormat.currency(symbol: '₦', decimalDigits: 0).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tax')),
      body: ref
          .watch(taxationHomeNotifierProvider)
          .when(
            data: (data) {
              return RefreshIndicator(
                onRefresh: () =>
                    ref.read(taxationHomeNotifierProvider.notifier).refresh(),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    TaxDashboardCard(taxationData: data.data),
                    const Gap(18),
                    _buildUploadStatementTile(),
                    const Gap(18),
                    Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: AppColors.greyDark,
                      ),
                    ),
                    const Gap(12),
                    _buildQuickActionCard(),
                    const Gap(18),
                    _buildTaxLeakCard(taxHistory: data.data.history),
                    const Gap(18),
                    _buildUnclaimedReliefCard(),
                  ],
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error loading taxation data'),
                  const Gap(16),
                  ElevatedButton(
                    onPressed: () => ref
                        .read(taxationHomeNotifierProvider.notifier)
                        .refresh(),
                    child: Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildTaxLeakCard({required List<TaxHistoryItem> taxHistory}) {
    // Calculate total tax leaks from history items
    final totalTaxLeaks = taxHistory
        .where((item) => item.type == 'debit' && item.amount <= 5000)
        .fold(0, (sum, item) => sum + item.amount);

    return CustomCard(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 22),
      borderColor: AppColors.borderLight,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                spacing: 10,
                children: [
                  AppIcon(AppIcons.moneySackIcon, useOriginal: true),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tax Leaks',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Text(
                        "Hidden Taxes you've paid!",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: AppColors.greyDark,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                spacing: 5,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryFaded,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Text(
                      _formatCurrency(totalTaxLeaks),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: AppColors.grey,
                    size: 32,
                  ),
                ],
              ),
            ],
          ),
          const Gap(20),
          // Show up to 3 recent tax leak items
          ...taxHistory
              .where((item) => item.type == 'debit' && item.amount <= 5000)
              .take(3)
              .map(
                (item) =>
                    Column(children: [_buildTaxLeakItem(item), const Gap(10)]),
              ),
        ],
      ),
    );
  }

  Widget _buildTaxLeakItem(TaxHistoryItem item) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final formattedDate = dateFormat.format(item.date);

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.greyLight,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            spacing: 4,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _extractMerchantName(item.narration),
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              Text(
                "$formattedDate • ${_formatCurrency(item.amount)}",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: AppColors.greyDark,
                ),
              ),
            ],
          ),
          Column(
            spacing: 8,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 6,
                  horizontal: 15,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryFaded,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primary),
                ),
                child: Text(
                  'Stamp Duty',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.error,
                  ),
                ),
              ),
              Text(
                _formatCurrency(item.amount),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _extractMerchantName(String narration) {
    // Extract merchant name from narration like "stamp duty on electronic funds transfer - 2067609802 to Cbn//Providus Bank"
    final parts = narration.split('//');
    if (parts.length > 1) {
      return parts.last.trim();
    }
    // Fallback to a generic name if pattern doesn't match
    return 'Bank Transfer';
  }

  Widget _buildUnclaimedReliefCard() {
    return CustomCard(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      borderColor: AppColors.success.withValues(alpha: 0.3),
      bgColor: AppColors.success.withValues(alpha: 0.05),
      child: Row(
        spacing: 10,
        children: [
          AppIcon(AppIcons.sparkleBgShadowIcon, useOriginal: true),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '₦120,000 in Savings Found!',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              Text(
                "You have unclaimed reliefs.",
                style: TextStyle(fontSize: 12, color: AppColors.greyDark),
              ),
              const Gap(5),
              InkWell(
                onTap: () {
                  //
                },
                child: Row(
                  spacing: 8,
                  children: [
                    Text(
                      'View Details',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: AppColors.success,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_sharp,
                      size: 16,
                      color: AppColors.success,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard() {
    return CustomCard(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      borderColor: AppColors.borderLight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        spacing: 10,
        children: [
          _buildQuickActionItem(
            iconPath: AppIcons.calculatorIcon,
            label: 'Calculator',
            onTap: () {
              Navigator.pushNamed(context, CalculateTaxScreen.path);
            },
          ),
          _buildQuickActionItem(
            iconPath: AppIcons.barChartIcon,
            label: 'Tax Stats',
            onTap: () {
              Navigator.pushNamed(context, TaxStatsScreen.path);
            },
          ),
          _buildQuickActionItem(
            iconPath: AppIcons.chatIcon,
            label: 'Ask Nahl',
            onTap: () {
              // Navigate to AI assistant
            },
          ),
          _buildQuickActionItem(
            iconPath: AppIcons.strategyIcon,
            label: 'Strategy',
            onTap: () {
              Navigator.pushNamed(context, StrategyCenterScreen.path);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionItem({
    required String iconPath,
    required String label,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          spacing: 12,
          mainAxisSize: MainAxisSize.min,
          children: [
            AppIcon(iconPath, useOriginal: true),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.greyDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadStatementTile() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        spacing: 10,
        children: [
          AppIcon(AppIcons.uploadIconBackgroundSvg, useOriginal: true),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Upload Bank Statement',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.white,
                ),
              ),
              Text(
                'Get instant tax calculation in seconds',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class TaxDashboardCard extends StatelessWidget {
  final TaxationHomeData taxationData;

  const TaxDashboardCard({super.key, required this.taxationData});

  String _formatCurrency(int amount) {
    return NumberFormat.currency(symbol: '₦', decimalDigits: 0).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        spacing: 12,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            spacing: 8,
            children: [
              const Text(
                'Your 2026 Tax',
                style: TextStyle(color: AppColors.white),
              ),
              Icon(Icons.visibility, color: AppColors.white),
            ],
          ),
          Text(
            _formatCurrency(taxationData.tax.yearly),
            style: TextStyle(
              fontSize: 32.0,
              fontWeight: FontWeight.w600,
              color: AppColors.white,
              height: 0.8,
            ),
          ),
          Text(
            '≈ ${_formatCurrency(taxationData.tax.monthly.toInt())}/month',
            style: TextStyle(color: AppColors.white),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              spacing: 10,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Effective Rate',
                      style: TextStyle(color: AppColors.white),
                    ),
                    Text(
                      '${taxationData.tax.rate}%',
                      style: TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                LinearProgressIndicator(
                  value: taxationData.tax.rate / 100,
                  backgroundColor: AppColors.white.withValues(alpha: 0.3),
                  minHeight: 10,
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                Row(
                  spacing: 6,
                  children: [
                    Text('●', style: TextStyle(color: AppColors.primary)),
                    Text(
                      'Below average for your income bracket',
                      style: TextStyle(color: AppColors.white, fontSize: 10),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
