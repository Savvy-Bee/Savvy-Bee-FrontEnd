import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:savvy_bee_mobile/core/utils/assets/assets.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';

import '../../utils/constants.dart';

class NotificationPromptBottomSheet extends StatelessWidget {
  const NotificationPromptBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => NotificationPromptBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(Assets.savvyBeeNotificationSvg),
          const Gap(32),
          Text(
            "Don't miss a beat",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32,
              height: 1.0,
              fontWeight: FontWeight.bold,
              fontFamily: Constants.neulisNeueFontFamily,
            ),
          ),
          const Gap(16),
          Text(
            'Get notifications Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontFamily: Constants.neulisNeueFontFamily,
            ),
          ),
          const Gap(24),
          CustomElevatedButton(
            text: 'Remind me',
            buttonColor: CustomButtonColor.black,
            onPressed: () {},
          ),
          const Gap(8),
          CustomOutlinedButton(text: 'Maybe later', onPressed: () {}),
        ],
      ),
    );
  }
}
