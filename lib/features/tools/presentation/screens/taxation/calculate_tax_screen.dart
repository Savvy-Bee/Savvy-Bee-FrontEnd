import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:savvy_bee_mobile/core/utils/file_picker_util.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/assets/app_icons.dart';
import '../../../../../core/widgets/custom_button.dart';
import '../../../../../core/widgets/custom_card.dart';
import '../../../../../core/widgets/custom_error_widget.dart';
import '../../../../../core/widgets/custom_input_field.dart';
import '../../../../../core/widgets/custom_loading_widget.dart';
import '../../../../../core/widgets/intro_text.dart';
import '../../../domain/models/taxation.dart';
import '../../providers/taxation_provider.dart';

class CalculateTaxScreen extends ConsumerStatefulWidget {
  static const String path = '/calculate-tax';

  const CalculateTaxScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CalculateTaxScreenState();
}

class _CalculateTaxScreenState extends ConsumerState<CalculateTaxScreen> {
  late final TextEditingController monthlyIncomeController;
  late final TextEditingController annualRentController;

  @override
  void initState() {
    super.initState();
    monthlyIncomeController = TextEditingController();
    annualRentController = TextEditingController();
  }

  @override
  void dispose() {
    monthlyIncomeController.dispose();
    annualRentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final taxCalculatorState = ref.watch(taxCalculatorNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Calculate Tax')),
      body: taxCalculatorState.when(
        loading: () => const CustomLoadingWidget(text: 'Calculating tax...'),
        error: (error, stackTrace) => CustomErrorWidget.error(
          title: 'Calculation Failed',
          subtitle: error.toString(),
          onRetry: () => ref
              .read(taxCalculatorNotifierProvider.notifier)
              .resetCalculation(),
        ),
        data: (taxData) {
          if (taxData == null) {
            return _buildEmptyState();
          }
          return _buildTaxResults(taxData);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        IntroText(
          title: 'Calculate Tax',
          subtitle: 'Get your 2026 tax estimate instantly',
        ),
        const Gap(28),
        _buildUploadView(),
      ],
    );
  }

  Widget _buildTaxResults(TaxCalculatorResponse taxResponse) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        IntroText(
          title: 'Calculate Tax',
          subtitle: 'Get your 2026 tax estimate instantly',
        ),
        const Gap(28),
        _buildDashboardCard(taxResponse.data),
        const Gap(28),
        _buildBreakdownCard(taxResponse.data),
        const Gap(28),
        _buildMoreActionsCard(),
        const Gap(48),
        CustomElevatedButton(
          text: 'Calculate Again',
          onPressed: () => ref
              .read(taxCalculatorNotifierProvider.notifier)
              .resetCalculation(),
        ),
      ],
    );
  }

  Widget _buildMoreActionsCard() {
    return CustomCard(
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
              _buildMoreActionItem(AppIcons.chatIcon, 'Ask Nahl\nTo Explain'),
              _buildMoreActionItem(
                AppIcons.receiptColorIcon,
                'Explain More\nTax REliefs',
              ),
            ],
          ),
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

  Widget _buildBreakdownCard(TaxCalculatorData taxData) {
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
          _buildTaxBreakdownItem(
            'Gross Income',
            '₦${taxData.totalEarnings.toStringAsFixed(0)}',
          ),
          const Gap(8),
          _buildTaxBreakdownItem(
            'Base Exemption',
            '-₦${(taxData.totalEarnings - taxData.tax.yearly).toStringAsFixed(0)}',
          ),
          const Gap(8),
          _buildTaxBreakdownItem(
            'Taxable Income',
            '₦${taxData.tax.yearly.toStringAsFixed(0)}',
          ),
          const Gap(8),
          _buildTaxBreakdownItem(
            'Tax Before Relief',
            '₦${taxData.tax.yearly.toStringAsFixed(0)}',
          ),
          const Gap(18),
          const Divider(height: 0),
          const Gap(24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Final Tax', style: TextStyle(fontWeight: FontWeight.w600)),
              Text(
                '₦${taxData.tax.yearly.toStringAsFixed(0)}',
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

  Widget _buildDashboardCard(TaxCalculatorData taxData) {
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
            '₦${taxData.tax.yearly.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 32.0,
              fontWeight: FontWeight.w600,
              color: AppColors.white,
              height: 0.8,
            ),
          ),

          Text(
            '≈ ₦${taxData.tax.monthly.toStringAsFixed(0)}/month',
            style: TextStyle(color: AppColors.white),
          ),

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
                  '${taxData.tax.rate}%',
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
          controller: monthlyIncomeController,
          label: 'Monthly Income',
          hint: '₦800,000',
          subText:
              'Annual: ₦${(int.tryParse(monthlyIncomeController.text) ?? 0) * 12}',
          keyboardType: TextInputType.number,
        ),
        const Gap(28),
        CustomTextFormField(
          controller: annualRentController,
          label: 'Annual Rent (Optional)',
          hint: '₦800,000',
          keyboardType: TextInputType.number,
        ),
        const Gap(48),
        CustomElevatedButton(
          text: 'Calculate Tax',
          onPressed: () {
            final monthlyIncome =
                int.tryParse(monthlyIncomeController.text) ?? 0;
            final annualEarnings = monthlyIncome * 12;

            if (annualEarnings <= 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please enter a valid monthly income'),
                ),
              );
              return;
            }

            ref
                .read(taxCalculatorNotifierProvider.notifier)
                .calculateTax(
                  earnings: annualEarnings,
                  rent: int.tryParse(annualRentController.text),
                );
          },
        ),
      ],
    );
  }

  Widget _buildManualCalculateButton() {
    return Container(
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
    );
  }

  Widget _buildUploadCard() {
    return CustomCard(
      onTap: () {
        FileUtils.pickFile().then((value) {
          if (value == null) return;
        });
      },
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
