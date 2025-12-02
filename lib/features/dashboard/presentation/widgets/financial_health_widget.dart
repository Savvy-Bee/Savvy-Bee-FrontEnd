import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';
import 'package:savvy_bee_mobile/core/widgets/charts/arc_progress_indicator.dart';
import 'package:savvy_bee_mobile/features/dashboard/domain/models/dashboard_data.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/widgets/insight_card.dart';

import '../../../../core/widgets/custom_card.dart';
class FinancialHealthWidget extends StatelessWidget {
  final FinancialHealth healthData;

  const FinancialHealthWidget({
    super.key,
    required this.healthData,
  });

  @override
  Widget build(BuildContext context) {
    final progress = healthData.rate / 100.0;
    final healthStatus = _getHealthStatus(healthData.rate);

    return SizedBox(
      width: MediaQuery.of(context).size.width / 1.25,
      child: CustomCard(
        hasShadow: true,
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
              child: const Text(
                'FINANCIAL HEALTH STATUS',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const Divider(height: 0),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  ArcProgressIndicator(
                    progress: progress,
                    color: _getHealthColor(healthData.rate),
                  ),
                  Text(
                    'Your financial health is ${healthStatus}!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: Constants.neulisNeueFontFamily,
                    ),
                  ),
                  const Gap(16.0),
                  Text(
                    healthData.insight,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: Constants.neulisNeueFontFamily,
                    ),
                  ),
                  const Gap(24.0),
                  InsightCard(
                    text: healthData.insight,
                    insightType: InsightType.nahlInsight,
                    isExpandable: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getHealthStatus(int rate) {
    if (rate >= 80) return 'Thriving';
    if (rate >= 60) return 'Good';
    if (rate >= 40) return 'Fair';
    return 'Needs Attention';
  }

  Color _getHealthColor(int rate) {
    if (rate >= 80) return AppColors.primary;
    if (rate >= 60) return AppColors.success;
    if (rate >= 40) return Colors.orange;
    return Colors.red;
  }
}