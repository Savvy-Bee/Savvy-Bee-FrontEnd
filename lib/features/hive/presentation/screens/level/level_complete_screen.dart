import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/assets/assets.dart';
import 'package:savvy_bee_mobile/core/utils/assets/illustrations.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_card.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_snackbar.dart';
import 'package:savvy_bee_mobile/features/hive/presentation/screens/hive_screen.dart';
import 'package:savvy_bee_mobile/features/hive/presentation/screens/streak/new_streak_screen.dart';

import '../../../../../core/utils/assets/app_icons.dart';
import '../../providers/hive_provider.dart';

class LevelCompleteArgs {
  final double score;
  final int newFlowers;

  const LevelCompleteArgs({required this.score, required this.newFlowers});
}

class LevelCompleteScreen extends ConsumerStatefulWidget {
  static const String path = '/level-complete';

  final LevelCompleteArgs args;

  const LevelCompleteScreen({super.key, required this.args});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _LevelCompleteScreenState();
}

class _LevelCompleteScreenState extends ConsumerState<LevelCompleteScreen> {
  bool _isProcessing = false;
  bool _isClaimed = false;

  Future<void> _claimRewards() async {
    if (_isProcessing || _isClaimed) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final notifier = ref.read(hiveNotifierProvider.notifier);

      // First, fetch current streak details to check if today's streak exists
      await notifier.fetchStreakDetails();

      // Top up streak (will automatically check if already done today)
      final streakResult = await notifier.topUpStreakWithCheck();
      final streakUpdated = streakResult['updated'] ?? false;
      final streakSuccess = streakResult['success'] ?? false;

      // Top up flowers with the earned amount
      final flowersSuccess = await notifier.topUpFlowers(
        widget.args.newFlowers,
      );

      if (streakSuccess && flowersSuccess) {
        setState(() {
          _isClaimed = true;
          _isProcessing = false;
        });

        // Show success message
        if (mounted) {
          final message = streakUpdated
              ? '🎉 Claimed ${widget.args.newFlowers} flowers and updated streak!'
              : '🎉 Claimed ${widget.args.newFlowers} flowers!';

          CustomSnackbar.show(context, message, type: SnackbarType.success);
        }

        // Navigate to streak screen only if streak was updated
        if (streakUpdated) {
          await Future.delayed(const Duration(milliseconds: 500));
          if (mounted) {
            context.pushNamed(NewStreakScreen.path);
          }
        } else {
          // Just pop back after a delay if no streak update
          await Future.delayed(const Duration(milliseconds: 1500));
          if (mounted) {
            context.goNamed(HiveScreen.path);
          }
        }
      } else {
        // Handle failure
        setState(() {
          _isProcessing = false;
        });

        if (mounted) {
          CustomSnackbar.show(
            context,
            'Failed to claim rewards. Please try again.',
            type: SnackbarType.error,
          );
        }
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });

      if (mounted) {
        CustomSnackbar.show(
          context,
          'Error: ${e.toString()}',
          type: SnackbarType.error,
        );
      }
    }
  }

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
                  text: _isClaimed
                      ? 'Claimed! ✓'
                      : _isProcessing
                      ? 'Claiming...'
                      : 'Claim your flowers',
                  isGamePlay: true,
                  onPressed: _isClaimed ? null : _claimRewards,
                  isLoading: _isProcessing,
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
                  style: TextStyle(fontWeight: FontWeight.bold, color: color),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
