import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/utils/assets/assets.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/assets/illustrations.dart';
import '../../../../../core/utils/image_shadow_effect.dart';
import '../../../../../core/widgets/custom_button.dart';
import '../../../../../core/widgets/intro_text.dart';
import 'signup_connect_bank_screen.dart';

class SignupNotificationsScreen extends StatefulWidget {
  static String path = '/signup-notifications';

  const SignupNotificationsScreen({super.key});

  @override
  State<SignupNotificationsScreen> createState() =>
      _SignupNotificationsScreenState();
}

class _SignupNotificationsScreenState extends State<SignupNotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: AppColors.primaryFaded,
          image: DecorationImage(
            image: AssetImage(Assets.hivePatternYellow),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: 100,
              left: 16.0,
              child: IntroText(
                title: "NEVER\nMISS AN\nUPDATE",
                subtitle: '''● Tailored updates on your spending
● Watch Bee grow your portfolio
● Reminders that you're just a girl (lol)''',
                alignment: TextAlignment.left,
                isLarge: true,
                mainTextColor: AppColors.white,
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: imageShadowEffect(Illustrations.interestBee, scale: 1.1),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 32.0,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomElevatedButton(
                      text: 'Turn on notifications',
                      buttonColor: CustomButtonColor.black,
                      onPressed: () {},
                    ),
                    const Gap(10.0),
                    CustomElevatedButton(
                      text: 'Not now',
                      buttonColor: CustomButtonColor.white,
                      onPressed: () {
                        context.pushNamed(SignupConnectBankScreen.path);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
