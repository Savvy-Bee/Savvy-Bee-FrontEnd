import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/assets/assets.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_card.dart';

class QuestUpdateScreen extends ConsumerStatefulWidget {
  static String path = '/quest-update';

  const QuestUpdateScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _QuestUpdateScreenState();
}

class _QuestUpdateScreenState extends ConsumerState<QuestUpdateScreen> {
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
                      'Daily Quest update!',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        fontFamily: Constants.neulisNeueFontFamily,
                      ),
                    ),
                    _buildQuestProgressCard(),
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
        ),
      ),
    );
  }

  Widget _buildQuestProgressCard() {
    return CustomCard(
      borderColor: AppColors.greyMid,
      borderWidth: 2,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        spacing: 16,
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(Assets.hexagonStar, height: 50),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 16,
              children: [
                Text(
                  'Complete your next 2 lessons',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: Constants.neulisNeueFontFamily,
                  ),
                ),
                Stack(
                  alignment: Alignment.centerRight,
                  children: [
                    LinearProgressIndicator(
                      minHeight: 10,
                      borderRadius: BorderRadius.circular(20),
                      value: 0.5,
                      color: AppColors.primary,
                    ),
                    Image.asset(Assets.honeyJar4, height: 30),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
