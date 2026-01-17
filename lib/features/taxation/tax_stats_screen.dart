import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/assets/app_icons.dart';
import '../../core/widgets/custom_card.dart';

class TaxStatsScreen extends ConsumerStatefulWidget {
  static const String path = '/tax-stats';

  const TaxStatsScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TaxStatsScreenState();
}

class _TaxStatsScreenState extends ConsumerState<TaxStatsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tax Stats')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildReportCard(),
          const Gap(28),
          _buildBreakdownCard(),
          const Gap(28),
          _buildMoreActionsCard(),
        ],
      ),
    );
  }

  Widget _buildMoreActionsCard() {
    Widget buildMoreActionItem(String iconPath, String title) {
      return Column(
        spacing: 12,
        children: [
          AppIcon(iconPath, useOriginal: true),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: AppColors.greyDark,
              height: 1.1,
            ),
          ),
        ],
      );
    }

    return CustomCard(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      borderColor: AppColors.border,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Export Tax Report',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const Gap(8),
          Text(
            'Download your complete tax summary for filing or record-keeping',
          ),
          const Gap(16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              buildMoreActionItem(AppIcons.documentColorIcon, 'Export PDF'),
              buildMoreActionItem(AppIcons.walletColorIcon, 'Export CSV'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownCard() {
    Widget buildTaxBreakdownItem(String title, String value) {
      return Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.greyLight.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title),
            Text(value, style: TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
      );
    }

    return CustomCard(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      borderColor: AppColors.border,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tax Breakdown',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const Gap(16),
          buildTaxBreakdownItem('Gross Income', '₦1,800,000'),
          const Gap(8),
          buildTaxBreakdownItem('Base Exemption', '-₦800,000'),
          const Gap(8),
          buildTaxBreakdownItem('Taxable Income', '₦1,000,000'),
          const Gap(18),
          const Divider(height: 0),
          const Gap(24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Tax', style: TextStyle(fontWeight: FontWeight.w600)),
              Text(
                '₦114,000',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: AppColors.info,
                ),
              ),
            ],
          ),
          const Gap(24),
          CustomElevatedButton(text: 'Recalculate Tax', onPressed: () {}),
        ],
      ),
    );
  }

  Widget _buildReportCard() {
    Widget buildInfoItem(String text) {
      return Row(
        spacing: 6,
        children: [
          Icon(Icons.info_outline_rounded, color: AppColors.white, size: 16),
          Text(text, style: TextStyle(color: AppColors.white, fontSize: 12)),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  spacing: 8,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tax Health Report',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.white,
                      ),
                    ),
                    Text(
                      'Generate an institutional-grade certified audit report for HR, LIRS, or FIRS compliance',
                      style: TextStyle(color: AppColors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Gap(16),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              spacing: 10,
              mainAxisSize: MainAxisSize.min,
              children: [
                buildInfoItem('All income sources tracked'),
                buildInfoItem('Tax shields & reliefs consolidated'),
                buildInfoItem('Stamp duties & WHT documented'),
                buildInfoItem('Investment losses harvested'),
              ],
            ),
          ),
          const Gap(16),
          CustomElevatedButton(
            text: 'Generate Certified Audit',
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
