import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/assets/app_icons.dart';
import 'package:savvy_bee_mobile/core/utils/assets/assets.dart';
import 'package:savvy_bee_mobile/core/utils/assets/illustrations.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';
import 'package:savvy_bee_mobile/features/hive/presentation/screens/level/level_complete_screen.dart';

class LessonUnlockedScreen extends ConsumerStatefulWidget {
  static const String path = '/lesson-unlocked';

  const LessonUnlockedScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _LessonUnlockedScreenState();
}

class _LessonUnlockedScreenState extends ConsumerState<LessonUnlockedScreen> {
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
                    Image.asset(Illustrations.susu, scale: 1.3),
                    _buildLevelIndicator(),
                    Text(
                      "You've unlocked a new lesson!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,

                        height: 1.1,
                      ),
                    ),
                  ],
                ),
                Row(
                  spacing: 8,
                  children: [
                    ShareButton(onPressed: () {}),
                    Expanded(
                      flex: 2,
                      child: CustomElevatedButton(
                        text: 'Continue',
                        isGamePlay: true,
                        onPressed: () =>
                            context.pushNamed(LevelCompleteScreen.path),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Container _buildLevelIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        '1/5',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,

          color: AppColors.white,
        ),
      ),
    );
  }
}
