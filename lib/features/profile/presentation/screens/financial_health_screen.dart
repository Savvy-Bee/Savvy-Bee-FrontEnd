import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_error_widget.dart';
import 'package:savvy_bee_mobile/features/home/presentation/widgets/health_card.dart';

import '../../../home/presentation/providers/home_data_provider.dart';

class FinancialHealthScreen extends ConsumerStatefulWidget {
  static const String path = '/financia;-health';

  const FinancialHealthScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _FinancialHealthScreenState();
}

class _FinancialHealthScreenState extends ConsumerState<FinancialHealthScreen> {
  @override
  Widget build(BuildContext context) {
    final homeData = ref.watch(homeDataProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.financialHealthBg,
        foregroundColor: AppColors.white,
        actions: [
          IconButton(
            onPressed: () => ref.invalidate(homeDataProvider),
            icon: Icon(Icons.refresh),
          ),
        ],
      ),
      backgroundColor: AppColors.financialHealthBg,
      body: homeData.when(
        skipLoadingOnRefresh: false,
        data: (data) {
          final healthData = data.data.aiData;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(),
                HealthCardWidget(
                  statusText: healthData.status,
                  descriptionText: healthData.message,
                  rating: healthData.ratings.toDouble(),
                ),
                Row(
                  spacing: 8,
                  children: [
                    ShareButton(onPressed: () {}),
                    Expanded(
                      flex: 2,
                      child: CustomElevatedButton(
                        text: 'Fix your financial health',
                        isGamePlay: true,
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
        error: (error, stackTrace) => CustomErrorWidget.error(
          onRetry: () => ref.invalidate(homeDataProvider),
        ),
        loading: () => Center(
          child: Text(
            'Loading...',
            style: TextStyle(
              fontSize: 40,
              color: AppColors.primaryFaint,
              fontFamily: Constants.fredokaFontFamily,
            ),
          ),
        ),
      ),
    );
  }
}
