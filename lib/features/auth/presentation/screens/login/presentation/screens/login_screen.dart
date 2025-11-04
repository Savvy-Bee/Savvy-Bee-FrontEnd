import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';
import 'package:savvy_bee_mobile/core/utils/input_validator.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_input_field.dart';
import 'package:savvy_bee_mobile/core/widgets/intro_text.dart';
import 'package:savvy_bee_mobile/features/auth/presentation/providers/auth_providers.dart';
import 'package:savvy_bee_mobile/features/chat/presentation/screens/chat_screen.dart';
import 'package:savvy_bee_mobile/features/password/presentation/screens/password_reset_screen.dart';

import '../../../../../../../core/utils/assets/illustrations.dart';
import '../../../../../../../core/widgets/custom_snackbar.dart';

class LoginScreen extends ConsumerStatefulWidget {
  static String path = '/login';

  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool _showPassword = false;

  // This is how much of the image's bottom will overlap the white container
  static const double kImageOverlap = 30.0;

  // The Gap needed at the start of the Column to push content down
  static const double kInitialContentGap = kImageOverlap + 52.0;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authNotifier = ref.read(authProvider.notifier);
    final success = await authNotifier.login(
      emailController.text.trim(),
      passwordController.text.trim(),
    );

    if (!success) {
      if (mounted) {
        CustomSnackbar.show(
          context,
          ref.read(authProvider).errorMessage ?? 'Login failed',
          type: SnackbarType.error,
        );
      }
    } else {
      if (mounted) context.goNamed(ChatScreen.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.close))],
      ),
      backgroundColor: AppColors.bgBlue,
      body: ListView(
        reverse: true,
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
                  child: Image.asset(Illustrations.familyBee, scale: 1.1),
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Gap(kInitialContentGap),

                      IntroText(
                        title: 'WELCOME BACK',
                        subtitle: 'The hive missed you. Log in to continue',
                        alignment: TextAlignment.left,
                      ),
                      const Gap(24.0),
                      CustomTextFormField(
                        hint: 'Email address',
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) =>
                            InputValidator.validateEmail(value),
                      ),
                      const Gap(8.0),
                      CustomTextFormField(
                        hint: 'Password',
                        controller: passwordController,
                        textInputAction: TextInputAction.done,
                        obscureText: !_showPassword,
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
                        validator: (value) =>
                            InputValidator.validatePassword(value),
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
                      const Gap(24.0),
                      CustomElevatedButton(
                        text: authState.isLoading ? 'Please wait...' : 'Log in',
                        buttonColor: CustomButtonColor.black,
                        onPressed: authState.isLoading ? null : _handleLogin,
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
