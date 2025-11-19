import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';
import 'package:savvy_bee_mobile/features/home/presentation/widgets/health_card.dart';

class FinancialHealthScreen extends ConsumerStatefulWidget {
  static String path = '/financia;-health';

  const FinancialHealthScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _FinancialHealthScreenState();
}

class _FinancialHealthScreenState extends ConsumerState<FinancialHealthScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.financialHealthBg,
        foregroundColor: AppColors.white,
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.refresh))],
      ),
      backgroundColor: AppColors.financialHealthBg,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(),
            HealthCardWidget(
              statusText: 'statusText',
              descriptionText: 'descriptionText',
              rating: 100,
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
      ),
    );
  }
}
