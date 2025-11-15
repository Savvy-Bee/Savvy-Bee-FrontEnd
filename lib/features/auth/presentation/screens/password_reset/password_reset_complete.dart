import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';
import 'package:savvy_bee_mobile/core/widgets/intro_text.dart';

import '../../../../../core/utils/assets/assets.dart';
import '../../../../../core/utils/assets/illustrations.dart';
import '../../../../../../core/utils/image_shadow_effect.dart';
import '../login_screen.dart';

class PasswordResetComplete extends StatefulWidget {
  static String path = '/password-reset-complete';

  const PasswordResetComplete({super.key});

  @override
  State<PasswordResetComplete> createState() => _PasswordResetCompleteState();
}

class _PasswordResetCompleteState extends State<PasswordResetComplete> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blue,
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
                title: "YOU'RE\nALL SET",
                subtitle: "Welcome back!",
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
                    context.goNamed(LoginScreen.path);
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
