import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/assets/app_icons.dart';
import '../../../../../core/utils/num_extensions.dart';
import '../../../../../core/widgets/custom_card.dart';
import '../../../../../core/widgets/custom_error_widget.dart';
import '../../../../../core/widgets/custom_loading_widget.dart';
import '../../../../../core/widgets/intro_text.dart';
import '../../../domain/models/taxation.dart';
import '../../providers/taxation_provider.dart';

class StrategyCenterScreen extends ConsumerStatefulWidget {
  static const String path = '/strategy-center';

  const StrategyCenterScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _StrategyCenterScreenState();
}

class _StrategyCenterScreenState extends ConsumerState<StrategyCenterScreen> {
  @override
  Widget build(BuildContext context) {
    final strategyAsync = ref.watch(taxationStrategyNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Strategy Center')),
      body: strategyAsync.when(
        loading: () => CustomLoadingWidget(),
        error: (error, stack) => CustomErrorWidget.error(
          title: 'Error',
          subtitle: error.toString(),
          onRetry: () =>
              ref.read(taxationStrategyNotifierProvider.notifier).refresh(),
        ),
        data: (strategyData) {
          final strategy = strategyData.data;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              IntroText(
                title: 'Strategy Center',
                subtitle: 'Optimize your portfolio tax efficiency',
              ),
              const Gap(28),
              Row(
                spacing: 10,
                children: [
                  _buildProfitLossCard(
                    isProfit: true,
                    amount: strategy.gains.toDouble(),
                  ),
                  _buildProfitLossCard(
                    isProfit: false,
                    amount: strategy.losses.toDouble(),
                  ),
                ],
              ),
              const Gap(28),
              _buildHarvestCard(strategy.recommendation.data),
              const Gap(28),
              _buildBreakdownCard(strategy),
              const Gap(28),
              _buildAssetCard(strategy),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAssetCard(TaxationStrategyData strategy) {
    return CustomCard(
      padding: const EdgeInsets.symmetric(
        vertical: 20,
        horizontal: 16,
      ).copyWith(bottom: 50),
      borderColor: AppColors.border,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            spacing: 50,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Your Assests',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              _buildTextIconButton('Add Asset', () {}),
            ],
          ),
          const Gap(16),
          if (strategy.statements.isEmpty)
            _buildNoAssetWidget()
          else
            ...strategy.statements.map((statement) {
              final cost = statement.cost ?? 0.0;
              final isProfit = statement.returnValue >= cost;
              final profitLoss = (statement.returnValue - cost).abs();
              final profitLossPercent = cost > 0
                  ? ((statement.returnValue - cost) / cost * 100).abs()
                  : 0.0;
              final potentialTaxSavings = isProfit
                  ? null
                  : (profitLoss * 0.24).round().formatCurrency();

              return Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: _buildAssetItemCard(
                  assetName: statement.name,
                  datePurchased: 'Unknown',
                  unitsPurchased: statement.quantity ?? 0,
                  costBasis: cost.formatCurrency(),
                  currentValue: statement.returnValue.formatCurrency(),
                  profitLoss: profitLoss.formatCurrency(),
                  profitLossPercent: '${profitLossPercent.toStringAsFixed(2)}%',
                  isProfit: isProfit,
                  potentialTaxSavings: potentialTaxSavings,
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildAssetItemCard({
    required String assetName,
    required String datePurchased,
    required double unitsPurchased,
    required String costBasis,
    required String currentValue,
    required String profitLoss,
    required String profitLossPercent,
    required bool isProfit,
    String? potentialTaxSavings,
  }) {
    Widget buildAssetStat(String label, String value) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12)),
          Text(value, style: TextStyle(fontWeight: FontWeight.w500)),
        ],
      );
    }

    return CustomCard(
      borderColor: AppColors.primaryFaded,
      bgColor: isProfit
          ? AppColors.success.withValues(alpha: 0.1)
          : AppColors.primaryFaint.withValues(alpha: 0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(assetName, style: TextStyle(fontWeight: FontWeight.w600)),
          const Gap(4),
          Text(
            '${unitsPurchased.toStringAsFixed(0)} units • Purchased $datePurchased',
            style: TextStyle(fontSize: 12),
          ),
          const Gap(12),
          Row(
            spacing: 24,
            children: [
              buildAssetStat('Cost Basis', costBasis),
              buildAssetStat('Current Value', currentValue),
            ],
          ),
          const Gap(10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: isProfit
                  ? AppColors.success.withValues(alpha: 0.2)
                  : AppColors.primaryFaint,
              border: isProfit ? Border.all(color: AppColors.success) : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  spacing: 8,
                  children: [
                    Icon(
                      isProfit ? Icons.trending_up : Icons.trending_down,
                      color: isProfit ? AppColors.success : AppColors.error,
                    ),
                    Text(
                      isProfit ? 'Gain' : 'Loss',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      profitLoss,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        color: isProfit ? AppColors.success : AppColors.error,
                      ),
                    ),
                    Text(
                      profitLossPercent,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isProfit ? AppColors.success : AppColors.error,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (!isProfit) const Gap(10),
          if (!isProfit)
            CustomCard(
              padding: const EdgeInsets.all(12),
              bgColor: AppColors.background,
              borderColor: AppColors.primaryFaded,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 10,
                children: [
                  AppIcon(AppIcons.sparklesIcon, color: AppColors.error),
                  Text(
                    'Potential tax savings: $potentialTaxSavings',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNoAssetWidget() {
    return Column(
      children: [
        Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
            color: AppColors.greyLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.trending_up, color: AppColors.greyDark),
        ),
        const Gap(16),
        Text('No Assests added yet'),
        const Gap(16),
        _buildTextIconButton('Add Your First Asset', () {}),
      ],
    );
  }

  Widget _buildTextIconButton(String label, VoidCallback onPressed) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(Icons.add_rounded),
      label: Text(label),
      style: TextButton.styleFrom(
        foregroundColor: AppColors.black,
        backgroundColor: AppColors.buttonPrimary,
        iconSize: 24,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(20),
        ),
      ),
    );
  }

  Widget _buildBreakdownCard(TaxationStrategyData strategy) {
    final netTaxableGains = strategy.gains - strategy.exemptions;
    final estimatedCGT = (netTaxableGains * strategy.rate / 100).round();

    return CustomCard(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      borderColor: AppColors.border,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Net Tax Position',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const Gap(16),
          _buildTaxBreakdownItem(
            'Realized Gains',
            '+${strategy.gains.formatCurrency()}',
          ),
          const Gap(8),
          _buildTaxBreakdownItem(
            'Base Exemption',
            '-${strategy.exemptions.formatCurrency()}',
          ),
          const Gap(18),
          const Divider(height: 0),
          const Gap(24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Net Taxable Gains',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                netTaxableGains.formatCurrency(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: AppColors.info,
                ),
              ),
            ],
          ),
          const Gap(18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Estimated CGT (${strategy.rate}%)',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                estimatedCGT.formatCurrency(),
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
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

  Widget _buildHarvestCard(List<StrategyRecommendationItem> data) {
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
          Text(
            'AI Harvest Recommendation',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.white,
            ),
          ),
          const Gap(12),
          Text(
            'Optimized tax-loss harvesting opportunities',
            style: TextStyle(color: AppColors.white),
          ),
          const Gap(16),
          ...data.map(
            (e) => Padding(
              padding: EdgeInsets.only(bottom: e == data.last ? 0 : 16),
              child: _buildHarvestItem(
                e.title,
                e.amount.formatCurrency(),
                e.recommendation,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHarvestItem(String title, String value, String infoText) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 6,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(title, style: TextStyle(color: AppColors.white)),
              ),
              Text(
                value,
                style: TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 6,
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 14,
                color: AppColors.white,
              ),
              Expanded(
                child: Text(
                  infoText,
                  style: TextStyle(color: AppColors.white, fontSize: 10),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfitLossCard({
    required bool isProfit,
    required double amount,
  }) {
    final profitColor = AppColors.success;
    final lossColor = AppColors.error;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        decoration: BoxDecoration(
          border: Border.all(
            width: 2,
            color: isProfit
                ? profitColor.withValues(alpha: 0.2)
                : lossColor.withValues(alpha: 0.2),
          ),
          borderRadius: BorderRadius.circular(12),
          color: isProfit
              ? profitColor.withValues(alpha: 0.05)
              : lossColor.withValues(alpha: 0.05),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              spacing: 6,
              children: [
                Icon(
                  isProfit ? Icons.trending_up : Icons.trending_down,
                  color: isProfit ? profitColor : lossColor,
                ),
                Text(
                  isProfit ? 'TOTAL GAINS' : 'TOTAL LOSSES',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            Text(
              amount.formatCurrency(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: isProfit ? profitColor : lossColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
