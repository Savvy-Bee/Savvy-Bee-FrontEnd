import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/utils/assets/logos.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';
import 'package:savvy_bee_mobile/core/widgets/intro_text.dart';
import 'package:savvy_bee_mobile/features/auth/presentation/screens/post_signup/bottom_sheets/referrer_screen.dart';
import 'package:savvy_bee_mobile/features/home/presentation/screens/home_screen.dart';
import 'package:savvy_bee_mobile/features/premium/presentation/screens/premium_screen.dart';

import '../../../../../core/utils/assets/illustrations.dart';

class SignupCompleteScreen extends StatefulWidget {
  static String path = '/signup-complete';

  final bool isPasswordReset;

  const SignupCompleteScreen({super.key, required this.isPasswordReset});

  @override
  State<SignupCompleteScreen> createState() => _SignupCompleteScreenState();
}

class _SignupCompleteScreenState extends State<SignupCompleteScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16).copyWith(bottom: 32),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(Logos.logo, scale: 4),
                  const Gap(24),
                  IntroText(
                    title: widget.isPasswordReset
                        ? "You're all set!"
                        : "You're all\nsigned up!",
                    subtitle: widget.isPasswordReset
                        ? 'Welcome back'
                        : "Welcome to Savvy Bee!",
                  ),
                ],
              ),
              Image.asset(Illustrations.happyBee, scale: 1.2),
              CustomElevatedButton(
                text: 'Continue',
                buttonColor: CustomButtonColor.black,
                showArrow: true,
                onPressed: () {
                  if (widget.isPasswordReset) {
                    context.pop();
                  } else {
                    // context.goNamed(ReferrerScreen.path);
                    context.pushNamed(HomeScreen.path);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
