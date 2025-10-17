import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';

import '../../../../../core/utils/assets.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../core/widgets/intro_text.dart';

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
              child: Image.asset(Assets.savvyCoin, scale: 4),
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
              child: Image.asset(Assets.savvyCoin, scale: 4),
            ),
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Image.asset(Assets.coinJar, scale: 1.2),
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
                    AppButton(
                      text: 'Connect me',
                      appButtonColor: AppButtonColor.black,
                      onPressed: () {},
                    ),
                    const Gap(10.0),
                    AppButton(
                      text: 'Tell me more about your security',
                      appButtonColor: AppButtonColor.white,
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
