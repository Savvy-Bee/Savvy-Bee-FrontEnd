import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';
import 'package:savvy_bee_mobile/core/widgets/app_button.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_input_field.dart';
import 'package:savvy_bee_mobile/core/widgets/intro_text.dart';
import 'package:savvy_bee_mobile/features/password/presentation/screens/password_reset_screen.dart';

import '../../../../../core/utils/assets.dart';

class LoginScreen extends StatefulWidget {
  static String path = '/login';

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool _showPassword = false;

  // This is how much of the image's bottom will overlap the white container
  static const double kImageOverlap = 30.0;

  // The Gap needed at the start of the Column to push content down
  static const double kInitialContentGap = kImageOverlap + 82.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.close))],
      ),
      backgroundColor: AppColors.bgBlue,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: Constants.topOnlyBorderRadius,
            ),
            padding: const EdgeInsets.all(16.0),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  top: -320,
                  left: 0,
                  right: 0,
                  child: Image.asset(Assets.familyBee),
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Gap(kInitialContentGap),

                      IntroText(
                        title: 'WELCOME BACK',
                        subtitle: 'The hive missed you. Log in to continue',
                        alignment: TextAlignment.left,
                      ),
                      const Gap(24.0),
                      CustomInputField(
                        hint: 'Email address',
                        controller: emailController,
                      ),
                      const Gap(8.0),
                      CustomInputField(
                        hint: 'Password',
                        controller: passwordController,
                        textInputAction: TextInputAction.done,
                        obscureText: _showPassword,
                        suffix: IconButton(
                          onPressed: () {
                            setState(() {
                              _showPassword = !_showPassword;
                            });
                          },
                          icon: Icon(
                            _showPassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      const Gap(8.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              context.pushNamed(PasswordResetScreen.path);
                            },
                            child: const Text('Forgot Password?'),
                          ),
                        ],
                      ),
                      const Gap(48.0),
                      AppButton(
                        text: 'Log in',
                        appButtonColor: AppButtonColor.black,
                        onPressed: () {
                          context.pushNamed(LoginScreen.path);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
