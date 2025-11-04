import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/assets/assets.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';
import 'package:savvy_bee_mobile/core/widgets/intro_text.dart';
import 'package:savvy_bee_mobile/features/auth/presentation/screens/signup/presentation/screens/signup_notifications_screen.dart';

import '../../../../../../../core/utils/assets/illustrations.dart';
import '../../../../../../../core/utils/image_shadow_effect.dart';

class SignupCompleteScreen extends StatefulWidget {
  static String path = '/signup-complete';

  const SignupCompleteScreen({super.key});

  @override
  State<SignupCompleteScreen> createState() => _SignupCompleteScreenState();
}

class _SignupCompleteScreenState extends State<SignupCompleteScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgBlue,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(Assets.hivePatternWhite),
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
                title: "YOU'RE ALL\nSIGNED UP!",
                subtitle: "Welcome to Savvy Bee!",
                alignment: TextAlignment.left,
                isLarge: true,
                mainTextColor: AppColors.white,
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: imageShadowEffect(Illustrations.loanBee, scale: 1.1),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 32.0,
                ),
                child: CustomElevatedButton(
                  text: 'Continue',
                  onPressed: () {
                    context.pushNamed(SignupNotificationsScreen.path);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
