import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/assets/illustrations.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';

class WeeklyPositionScreen extends ConsumerStatefulWidget {
  static const String path = '/weekly-position';

  const WeeklyPositionScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _WeeklyPositionScreenState();
}

class _WeeklyPositionScreenState extends ConsumerState<WeeklyPositionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Leaderboard')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(),
            Column(
              spacing: 48,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'You finished #1 last week',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    fontFamily: Constants.neulisNeueFontFamily,
                    height: 1.0,
                  ),
                ),
                _buildPositionIndicator(),
              ],
            ),
            CustomElevatedButton(
              text: 'Continue',
              isGamePlay: true,
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPositionIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryFaint,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            spacing: 8,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.onetwothree_sharp),
              CircleAvatar(),
              Text(
                'Joshua',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: Constants.neulisNeueFontFamily,
                ),
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('1000', style: TextStyle(fontSize: 16)),
              Image.asset(Illustrations.hiveFlower),
            ],
          ),
        ],
      ),
    );
  }
}
