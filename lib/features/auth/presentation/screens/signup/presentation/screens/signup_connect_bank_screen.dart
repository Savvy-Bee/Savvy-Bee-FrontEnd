import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/assets/assets.dart';
import 'package:savvy_bee_mobile/features/auth/presentation/screens/login/presentation/screens/login_screen.dart';

import '../../../../../../../core/utils/assets/illustrations.dart';
import '../../../../../../../core/widgets/custom_button.dart';
import '../../../../../../../core/widgets/intro_text.dart';

class SignupConnectBankScreen extends StatefulWidget {
  static String path = '/signup-connect-bank';

  const SignupConnectBankScreen({super.key});

  @override
  State<SignupConnectBankScreen> createState() =>
      _SignupConnectBankScreenState();
}

class _SignupConnectBankScreenState extends State<SignupConnectBankScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: AppColors.primary,
          image: DecorationImage(
            image: AssetImage(Assets.hivePatternWhite),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: 10,
              right: -100,
              child: Image.asset(Illustrations.savvyCoin, scale: 4),
            ),
            Positioned(
              top: 100,
              left: 0,
              right: 0,
              child: IntroText(
                title: "CONNECT YOUR\nBANK ACCOUNT",
                subtitle:
                    "Get tailored insights on your finances by connecting\nyour bank accounts",
                mainTextColor: AppColors.white,
                subTextColor: AppColors.white,
              ),
            ),
            Positioned(
              top: 170,
              left: -110,
              child: Image.asset(Illustrations.savvyCoin, scale: 4),
            ),
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Image.asset(Illustrations.coinJar, scale: 1.2),
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
                      text: 'Connect me',
                      buttonColor: CustomButtonColor.black,
                      onPressed: () {
                        // TODO: Connect bank account
                        context.goNamed(LoginScreen.path);
                      },
                    ),
                    const Gap(10.0),
                    CustomElevatedButton(
                      text: 'Tell me more about your security',
                      buttonColor: CustomButtonColor.white,
                      onPressed: () {},
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
