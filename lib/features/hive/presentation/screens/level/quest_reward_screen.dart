import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/assets/assets.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';
import 'package:savvy_bee_mobile/features/hive/presentation/screens/level/quest_update_screen.dart';

class QuestRewardScreen extends ConsumerStatefulWidget {
  static String path = '/quest-reward';

  const QuestRewardScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _QuestCompleteScreenState();
}

class _QuestCompleteScreenState extends ConsumerState<QuestRewardScreen> {
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
                    Text(
                      '+50 honey drops',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        fontFamily: Constants.neulisNeueFontFamily,
                      ),
                    ),
                    Image.asset(Assets.honeyJar4),
                    Text(
                      "You earned 50 honey drops for completing today's quests",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: Constants.neulisNeueFontFamily,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
                CustomElevatedButton(
                  text: 'Continue',
                  isGamePlay: true,
                  onPressed: () => context.pushNamed(QuestUpdateScreen.path),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
