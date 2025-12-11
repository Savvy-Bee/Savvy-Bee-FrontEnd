import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/utils/assets/logos.dart';
import 'package:savvy_bee_mobile/core/utils/input_validator.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_input_field.dart';
import 'package:savvy_bee_mobile/core/widgets/intro_text.dart';
import 'package:savvy_bee_mobile/features/auth/presentation/providers/auth_providers.dart';
import 'package:savvy_bee_mobile/features/auth/presentation/screens/password_reset/password_reset_screen.dart';
import 'package:savvy_bee_mobile/features/auth/presentation/screens/signup_screen.dart';
import 'package:savvy_bee_mobile/features/home/presentation/screens/home_screen.dart';

import '../../../../core/widgets/custom_snackbar.dart';

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

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authNotifier = ref.read(authProvider.notifier);
    final response = await authNotifier.login(
      emailController.text.toLowerCase().trim(),
      passwordController.text.trim(),
    );

    if (!mounted) return;

    // Check if response is null
    if (response == null) {
      CustomSnackbar.show(
        context,
        ref.read(authProvider).errorMessage ?? 'Login failed',
        type: SnackbarType.error,
      );
      return;
    }

    // Check if login was successful
    if (!response.success) {
      // Check verification status even on failure
      final verification = response.data?.verification;

      if (verification != null) {
        // Handle incomplete email verification
        if (verification.emailVerification == false) {
          CustomSnackbar.show(
            context,
            response.message,
            type: SnackbarType.error,
          );
          
          context.pushNamed(
            SignupScreen.path,
            extra: IncompleteSignUpData(
              email: emailController.text.trim(),
              pageIndex: 4,
            ),
          );
          return;
        }

        // Handle incomplete profile
        if (verification.otherDetails == false) {
          CustomSnackbar.show(
            context,
            response.message,
            type: SnackbarType.error,
          );
          context.pushNamed(
            SignupScreen.path,
            extra: IncompleteSignUpData(
              email: emailController.text.trim(),
              pageIndex: 5,
            ),
          );
          return;
        }
      }

      // Generic error message if no specific verification issue
      CustomSnackbar.show(context, response.message, type: SnackbarType.error);
      return;
    }

    // Success case - both response.success is true and data exists
    if (response.data != null) {
      final verification = response.data?.verification;

      // Double-check verification status even on success
      if (verification?.emailVerification == false) {
        CustomSnackbar.show(
          context,
          'Please verify your email first',
          type: SnackbarType.error,
        );
        context.pushNamed(SignupScreen.path, extra: 4);
        return;
      }

      if (verification?.otherDetails == false) {
        CustomSnackbar.show(
          context,
          'Please complete your profile',
          type: SnackbarType.error,
        );
        context.pushNamed(SignupScreen.path, extra: 5);
        return;
      }

      // All checks passed, proceed to home
      context.goNamed(HomeScreen.path);
    } else {
      CustomSnackbar.show(
        context,
        'Login failed - no data received',
        type: SnackbarType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(),
              ListView(
                shrinkWrap: true,
                children: [
                  Column(
                    children: [
                      Image.asset(Logos.logo, scale: 3),
                      const Gap(24.0),
                      IntroText(
                        title: 'Welcome\nback!',
                        subtitle: 'The hive missed you. Log in to continue',
                      ),
                    ],
                  ),
                  const Gap(24.0),
                  CustomTextFormField(
                    label: 'Email address',
                    hint: 'Email address',
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) => InputValidator.validateEmail(value),
                    onChanged: (_) {
                      setState(() {});
                    },
                  ),
                  const Gap(8.0),
                  CustomTextFormField(
                    label: 'Password',
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
                    onChanged: (_) {
                      setState(() {});
                    },
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
                ],
              ),
              CustomElevatedButton(
                text: 'Continue',
                isLoading: authState.isLoading,
                onPressed:
                    emailController.text.trim().isEmpty &&
                        passwordController.text.trim().isEmpty
                    ? null
                    : _handleLogin,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
