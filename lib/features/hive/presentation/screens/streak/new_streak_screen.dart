import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/assets/app_icons.dart';
import 'package:savvy_bee_mobile/core/utils/assets/assets.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_card.dart';

class NewStreakScreen extends ConsumerStatefulWidget {
  static String path = '/new-streak';

  const NewStreakScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _NewStreakScreenState();
}

class _NewStreakScreenState extends ConsumerState<NewStreakScreen> {
  bool showFullInfo = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(Assets.hivePatternYellow),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: !showFullInfo ? MainAxisSize.max : MainAxisSize.min,
            children: [
              if (!showFullInfo) SizedBox(),
              Column(
                children: [
                  Image.asset(Assets.fire, scale: !showFullInfo ? 1.8 : 1),
                  Gap(!showFullInfo ? 24 : 48),
                  Text(
                    '1',
                    style: TextStyle(
                      fontSize: 160,
                      fontWeight: FontWeight.w900,
                      fontFamily: Constants.neulisNeueFontFamily,
                      color: AppColors.primary,
                      height: 1.0,
                    ),
                  ),
                  if (!showFullInfo) const Gap(24),
                  if (!showFullInfo)
                    Text(
                      'day streak',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: Constants.neulisNeueFontFamily,
                      ),
                    ),
                  if (!showFullInfo) const Gap(24),
                  if (!showFullInfo)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: CustomCard(
                        padding: EdgeInsets.zero,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(24),
                              child: Row(
                                children: [
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    spacing: 8,
                                    children: [
                                      Text(
                                        'We',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                          fontFamily:
                                              Constants.neulisNeueFontFamily,
                                        ),
                                      ),
                                      AppIcon(
                                        AppIcons.checkIcon,
                                        useOriginal: true,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const Divider(height: 0),
                            Padding(
                              padding: const EdgeInsets.all(24),
                              child: Text(
                                "Take a quiz everyday so your streak won't reset!",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: Constants.neulisNeueFontFamily,
                                  height: 1.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              if (!showFullInfo)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: CustomElevatedButton(
                    text: 'Continue',
                    onPressed: () {},
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
