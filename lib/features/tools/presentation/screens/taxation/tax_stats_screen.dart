import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:share_plus/share_plus.dart';
import 'package:savvy_bee_mobile/core/utils/csv_generator_util.dart';
import 'package:savvy_bee_mobile/core/utils/pdf_generator_util.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_error_widget.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_loading_widget.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/providers/taxation_provider.dart';
import 'package:savvy_bee_mobile/features/tools/domain/models/taxation.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/assets/app_icons.dart';
import '../../../../../core/utils/num_extensions.dart';
import '../../../../../core/widgets/custom_card.dart';

class TaxStatsScreen extends ConsumerStatefulWidget {
  static const String path = '/tax-stats';

  const TaxStatsScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TaxStatsScreenState();
}

class _TaxStatsScreenState extends ConsumerState<TaxStatsScreen> {
  bool _isGeneratingPdf = false;
  bool _isGeneratingCsv = false;

  Future<void> _exportPdf(TaxationHomeData taxData) async {
    setState(() => _isGeneratingPdf = true);

    try {
      final filePath = await PdfGeneratorUtil.generateTaxStatsPdf(taxData);

      if (filePath != null && mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF generated successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Automatically open share dialog
        await Future.delayed(const Duration(milliseconds: 500));

        if (mounted) {
          await Share.shareXFiles(
            [XFile(filePath)],
            subject: 'Tax Health Report',
            text: 'Here is my tax health report',
          );
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to generate PDF'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGeneratingPdf = false);
      }
    }
  }

  Future<void> _exportCsv(TaxationHomeData taxData) async {
    setState(() => _isGeneratingCsv = true);

    try {
      final filePath = await CsvGeneratorUtil.generateTaxHistoryCsv(taxData);

      if (filePath != null && mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('CSV generated successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Automatically open share dialog
        await Future.delayed(const Duration(milliseconds: 500));

        if (mounted) {
          await Share.shareXFiles(
            [XFile(filePath)],
            subject: 'Tax History CSV',
            text: 'Here is my tax transaction history',
          );
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to generate CSV'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGeneratingCsv = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final taxStatsState = ref.watch(taxationHomeNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Tax Stats')),
      body: taxStatsState.when(
        loading: () => const CustomLoadingWidget(text: 'Loading tax stats...'),
        error: (error, stackTrace) => CustomErrorWidget.error(
          onRetry: () =>
              ref.read(taxationHomeNotifierProvider.notifier).refresh(),
        ),
        data: (taxStats) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildReportCard(taxStats.data),
            const Gap(28),
            _buildBreakdownCard(taxStats.data),
            const Gap(28),
            _buildMoreActionsCard(taxStats.data),
          ],
        ),
      ),
    );
  }

  Widget _buildMoreActionsCard(TaxationHomeData taxData) {
    Widget buildMoreActionItem(
      String iconPath,
      String title,
      VoidCallback onTap,
      bool isLoading,
    ) {
      return InkWell(
        onTap: isLoading ? null : onTap,
        child: Opacity(
          opacity: isLoading ? 0.5 : 1.0,
          child: Column(
            spacing: 12,
            children: [
              if (isLoading)
                const SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                AppIcon(iconPath, useOriginal: true),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: isLoading ? AppColors.grey : AppColors.greyDark,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
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
              buildMoreActionItem(
                AppIcons.documentColorIcon,
                'Export PDF',
                () => _exportPdf(taxData),
                _isGeneratingPdf,
              ),
              buildMoreActionItem(
                AppIcons.walletColorIcon,
                'Export CSV',
                () => _exportCsv(taxData),
                _isGeneratingCsv,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownCard(TaxationHomeData taxData) {
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
          buildTaxBreakdownItem(
            'Gross Income',
            taxData.totalEarnings.formatCurrency(decimalDigits: 0),
          ),
          const Gap(8),
          buildTaxBreakdownItem(
            'Base Exemption',
            '-${(taxData.totalEarnings - taxData.tax.yearly).formatCurrency(decimalDigits: 0)}',
          ),
          const Gap(8),
          buildTaxBreakdownItem(
            'Taxable Income',
            taxData.tax.yearly.formatCurrency(decimalDigits: 0),
          ),
          const Gap(18),
          const Divider(height: 0),
          const Gap(24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Tax', style: TextStyle(fontWeight: FontWeight.w600)),
              Text(
                taxData.tax.yearly.formatCurrency(decimalDigits: 0),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: AppColors.info,
                ),
              ),
            ],
          ),
          const Gap(24),
          CustomElevatedButton(
            text: 'Recalculate Tax',
            onPressed: () {
              ref.read(taxationHomeNotifierProvider.notifier).refresh();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Recalculating tax...'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(TaxationHomeData taxData) {
    Widget buildInfoItem(String text) {
      return Row(
        spacing: 6,
        children: [
          Icon(Icons.info_outline_rounded, color: AppColors.white, size: 16),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: AppColors.white, fontSize: 12),
            ),
          ),
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
            text: _isGeneratingPdf
                ? 'Generating...'
                : 'Generate Certified Audit',
            isLoading: _isGeneratingPdf,
            onPressed: _isGeneratingPdf ? null : () => _exportPdf(taxData),
          ),
        ],
      ),
    );
  }
}
