import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/utils/assets/app_icons.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_input_field.dart';
import 'package:savvy_bee_mobile/core/widgets/icon_text_row_widget.dart';
import 'package:savvy_bee_mobile/core/widgets/intro_text.dart';
import 'package:savvy_bee_mobile/features/premium/presentation/screens/premium_screen.dart';

import '../../../../../../core/utils/assets/logos.dart';

class ReferrerScreen extends ConsumerStatefulWidget {
  static String path = '/referrer';

  const ReferrerScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ReferrerScreenState();
}

class _ReferrerScreenState extends ConsumerState<ReferrerScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(Logos.logo, scale: 4),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconTextRowWidget(
              'Skip',
              AppIcon(AppIcons.arrowRightIcon),
              reverse: true,
              textStyle: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                fontFamily: Constants.neulisNeueFontFamily,
              ),
              onTap: () => context.pushNamed(PremiumScreen.path, extra: true),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IntroText(
                    title: 'Get Rewarded',
                    subtitle:
                        "Enter your referrer's username to claim your bonus. You both earn rewards!",
                  ),
                  const Gap(24),
                  CustomTextFormField(
                    label: "Referrer's username",
                    hint: 'awesomeJoshua01',
                  ),
                ],
              ),
            ),
            CustomElevatedButton(text: 'Get rewarded', onPressed: () {}),
          ],
        ),
      ),
    );
  }
}
