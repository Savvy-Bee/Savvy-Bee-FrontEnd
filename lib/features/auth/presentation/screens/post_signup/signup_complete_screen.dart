import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/utils/assets/logos.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';
import 'package:savvy_bee_mobile/core/widgets/intro_text.dart';
import 'package:savvy_bee_mobile/features/auth/presentation/screens/login_screen.dart';

import '../../../../../core/utils/assets/illustrations.dart';

enum SignupCompleteScreenType { passwordReset, signup }

class SignupCompleteScreen extends StatefulWidget {
  static const String path = '/signup-complete';

  final SignupCompleteScreenType type;

  const SignupCompleteScreen({super.key, required this.type});

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
                    title: widget.type == SignupCompleteScreenType.passwordReset
                        ? "You're all set!"
                        : "You're all\nsigned up!",
                    subtitle:
                        widget.type == SignupCompleteScreenType.passwordReset
                        ? 'Welcome back'
                        : "Welcome to Savvy Bee!",
                  ),
                ],
              ),
              Image.asset(Illustrations.susu, scale: 1.2),
              CustomElevatedButton(
                text: 'Continue',
                buttonColor: CustomButtonColor.black,
                showArrow: true,
                onPressed: () {
                  if (widget.type == SignupCompleteScreenType.passwordReset) {
                    context.pop();
                  } else {
                    // context.goNamed(ReferrerScreen.path);
                    // context.pushNamed(HomeScreen.path);
                    context.pushReplacementNamed(LoginScreen.path);
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
