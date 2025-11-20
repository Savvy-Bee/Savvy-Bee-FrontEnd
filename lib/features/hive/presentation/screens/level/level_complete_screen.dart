import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/assets/assets.dart';
import 'package:savvy_bee_mobile/core/utils/assets/illustrations.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_card.dart';
import 'package:savvy_bee_mobile/features/hive/presentation/screens/level/quest_reward_screen.dart';

import '../../../../../core/utils/assets/app_icons.dart';

class LevelCompleteArgs {
  final double score;
  final int newFlowers;

  const LevelCompleteArgs({required this.score, required this.newFlowers});
}

class LevelCompleteScreen extends ConsumerStatefulWidget {
  static String path = '/level-complete';

  final LevelCompleteArgs args;

  const LevelCompleteScreen({super.key, required this.args});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _LevelCompleteScreenState();
}

class _LevelCompleteScreenState extends ConsumerState<LevelCompleteScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(Assets.hivePatternYellow),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 24,
                  children: [
                    Image.asset(Illustrations.sleepingBee, scale: 1.3),
                    Text(
                      'Level complete!',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        fontFamily: Constants.neulisNeueFontFamily,
                      ),
                    ),
                    Row(
                      spacing: 24,
                      children: [
                        Expanded(
                          child: _buildScoreCard(
                            title: 'Total Flowers',
                            score: '${widget.args.newFlowers}',
                            icon: Image.asset(
                              Illustrations.hiveFlower,
                              scale: 0.9,
                            ),
                            color: AppColors.primary,
                          ),
                        ),
                        Expanded(
                          child: _buildScoreCard(
                            title: 'Score',
                            score: '${widget.args.score.toInt()}%',
                            icon: AppIcon(
                              AppIcons.scoreIcon,
                              color: AppColors.success,
                              size: 22,
                            ),
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                CustomElevatedButton(
                  text: 'Claim your flowers',
                  isGamePlay: true,
                  onPressed: () => context.pushNamed(QuestRewardScreen.path),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScoreCard({
    required String title,
    required String score,
    required Widget icon,
    required Color color,
    bool hasBorder = false,
  }) {
    return CustomCard(
      padding: const EdgeInsets.all(4).copyWith(top: 8),
      bgColor: color,
      borderColor: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.white,
              fontWeight: FontWeight.bold,
              fontFamily: Constants.neulisNeueFontFamily,
            ),
          ),
          CustomCard(
            padding: const EdgeInsets.all(8),
            bgColor: AppColors.background,
            borderColor: hasBorder
                ? AppColors.primaryFaded
                : Colors.transparent,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 6,
              children: [
                icon,
                Text(
                  score,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: Constants.neulisNeueFontFamily,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
