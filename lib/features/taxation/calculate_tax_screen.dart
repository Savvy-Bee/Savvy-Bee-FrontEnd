import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/assets/app_icons.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_card.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_input_field.dart';
import 'package:savvy_bee_mobile/core/widgets/intro_text.dart';

class CalculateTaxScreen extends ConsumerStatefulWidget {
  static const String path = '/calculate-tax';

  const CalculateTaxScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CalculateTaxScreenState();
}

class _CalculateTaxScreenState extends ConsumerState<CalculateTaxScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calculate Tax')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          IntroText(
            title: 'Calculate Tax',
            subtitle: 'Get your 2026 tax estimate instantly',
          ),
          const Gap(28),
          _buildDashboardCard(),
          const Gap(28),
          _buildBreakdownCard(),
          const Gap(28),
          CustomCard(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            borderColor: AppColors.border,
            child: Column(
              spacing: 32,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMoreActionItem(
                      AppIcons.documentColorIcon,
                      'Export Tax\nSummary',
                    ),
                    _buildMoreActionItem(
                      AppIcons.walletColorIcon,
                      'Connect Bank\nfor Auto-Tracking',
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMoreActionItem(
                      AppIcons.chatIcon,
                      'Ask Nahl\nTo Explain',
                    ),
                    _buildMoreActionItem(
                      AppIcons.receiptColorIcon,
                      'Explain More\nTax REliefs',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Gap(48),
          CustomElevatedButton(text: 'Calculate Again', onPressed: () {}),
          // _buildUploadView(),
        ],
      ),
    );
  }

  Widget _buildMoreActionItem(String iconPath, String title) {
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

  Widget _buildBreakdownCard() {
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
          _buildTaxBreakdownItem('Gross Income', '₦1,800,000'),
          const Gap(8),
          _buildTaxBreakdownItem('Base Exemption', '-₦800,000'),
          const Gap(8),
          _buildTaxBreakdownItem('Taxable Income', '₦1,000,000'),
          const Gap(8),
          _buildTaxBreakdownItem('Tax Before Relief', '₦114,000'),
          const Gap(18),
          const Divider(height: 0),
          const Gap(24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Final Tax', style: TextStyle(fontWeight: FontWeight.w600)),
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
        ],
      ),
    );
  }

  Widget _buildTaxBreakdownItem(String title, String value) {
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

  Widget _buildDashboardCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        spacing: 10,
        children: [
          const Text(
            'Your Estimated Tax',
            style: TextStyle(color: AppColors.white),
          ),

          Text(
            '₦114,000',
            style: TextStyle(
              fontSize: 32.0,
              fontWeight: FontWeight.w600,
              color: AppColors.white,
              height: 0.8,
            ),
          ),

          Text('≈ ₦9,500/month', style: TextStyle(color: AppColors.white)),

          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Effective Rate',
                  style: TextStyle(color: AppColors.white),
                ),
                Text(
                  '18.5%',
                  style: TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadView() {
    return Column(
      children: [
        _buildUploadCard(),
        const Gap(28),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [_buildManualCalculateButton()],
        ),
        const Gap(28),
        CustomTextFormField(
          label: 'Monthly Income',
          hint: '₦800,000',
          subText: 'Annual: ₦0',
        ),
        const Gap(28),
        CustomTextFormField(label: 'Annual Rent (Optional)', hint: '₦800,000'),
        const Gap(48),
        CustomElevatedButton(text: 'Calculate Tax', onPressed: () {}),
      ],
    );
  }

  Widget _buildManualCalculateButton() {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(32),
      child: Ink(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        decoration: BoxDecoration(
          color: AppColors.greyLight,
          borderRadius: BorderRadius.circular(32),
        ),
        child: Center(
          child: Text(
            'Calculate manually',
            style: TextStyle(
              color: AppColors.greyDark,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUploadCard() {
    return CustomCard(
      padding: const EdgeInsets.symmetric(vertical: 100),
      borderRadius: 32,
      child: Center(
        child: Column(
          spacing: 30,
          mainAxisSize: MainAxisSize.min,
          children: [
            AppIcon(AppIcons.cloudUploadIcon, useOriginal: true),
            Text(
              'Upload Bank Statement',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                color: AppColors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
