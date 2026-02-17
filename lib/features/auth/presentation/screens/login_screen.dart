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
import 'package:savvy_bee_mobile/features/auth/presentation/screens/post_signup/architype/financial_architype_screen.dart';

import '../../../../core/widgets/custom_snackbar.dart';

class LoginScreen extends ConsumerStatefulWidget {
  static const String path = '/login';

  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _showPassword = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ─── Registration resume logic ───────────────────────────────────────────────
  //
  // The login API always returns a verification object that tells us exactly
  // how far through signup the user got.  We map that to the correct page:
  //
  //   EmailVerification == false  →  OTP page        (SignupScreen page 4)
  //   OtherDetails      == false  →  DOB/country     (SignupScreen page 5)
  //   Postonboarding    == false  →  Financial arch  (FinancialArchitypeScreen)
  //   All true                    →  Home
  //
  // The same helper is called from both the success and failure paths because
  // the API can return success:false yet still tell us which step is missing.

  void _resumeRegistration({
    required bool emailVerified,
    required bool otherDetails,
    required bool postOnboarding,
    required String email,
    String? message,
  }) {
    // Always show the server message if there is one.
    if (message != null && message.isNotEmpty) {
      CustomSnackbar.show(
        context,
        message,
        type: SnackbarType.error,
        position: SnackbarPosition.bottom,
      );
    }

    if (!emailVerified) {
      // User never confirmed their email — send them back to the OTP page.
      context.pushNamed(
        SignupScreen.path,
        extra: IncompleteSignUpData(email: email, pageIndex: 4),
      );
      return;
    }

    if (!otherDetails) {
      // Email confirmed but profile details (DOB, country…) are missing.
      context.pushNamed(
        SignupScreen.path,
        extra: IncompleteSignUpData(email: email, pageIndex: 5),
      );
      return;
    }

    if (!postOnboarding) {
      // Profile complete but the onboarding questionnaire wasn't finished.
      context.pushNamed(FinancialArchitypeScreen.path);
      return;
    }

    // Everything is done — go home.
    context.goNamed(HomeScreen.path);
  }

  // ─── Login handler ──────────────────────────────────────────────────────────

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.toLowerCase().trim();

    final response = await ref
        .read(authProvider.notifier)
        .login(email, _passwordController.text.trim());

    if (!mounted) return;

    // Network / unknown failure — response is null.
    if (response == null) {
      CustomSnackbar.show(
        context,
        ref.read(authProvider).errorMessage ??
            'Login failed. Please try again.',
        type: SnackbarType.error,
        position: SnackbarPosition.bottom,
      );
      return;
    }

    final verification = response.data?.verification;

    if (response.success && response.data != null) {
      // ── Successful login ────────────────────────────────────────────────────
      // Even on success, guard against a partially completed account.
      if (verification != null &&
          (!verification.emailVerification ||
              !verification.otherDetails ||
              !verification.postOnboarding)) {
        _resumeRegistration(
          emailVerified: verification.emailVerification,
          otherDetails: verification.otherDetails,
          postOnboarding: verification.postOnboarding,
          email: email,
          message: response.message,
        );
        return;
      }
      // Fully set-up account — go home.
      context.goNamed(HomeScreen.path);
    } else {
      // ── Failed login ────────────────────────────────────────────────────────
      // The API may still return verification data even on failure (e.g. the
      // sample response above). Use it to resume registration if possible.
      if (verification != null) {
        _resumeRegistration(
          emailVerified: verification.emailVerification,
          otherDetails: verification.otherDetails,
          postOnboarding: verification.postOnboarding,
          email: email,
          message: response.message,
        );
        return;
      }

      // Plain credential error — no verification data in the response.
      CustomSnackbar.show(
        context,
        response.message.isNotEmpty
            ? response.message
            : 'Login failed. Please check your credentials.',
        type: SnackbarType.error,
        position: SnackbarPosition.bottom,
      );
    }
  }

  // ─── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Form(
          key: _formKey,
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(Logos.logo, scale: 3),
                  const Gap(24.0),
                  const IntroText(
                    title: 'Welcome back!',
                    subtitle: 'The hive missed you. Log in to continue',
                    alignment: TextAlignment.center,
                  ),
                  const Gap(24.0),

                  // Email
                  CustomTextFormField(
                    label: 'Email address',
                    hint: 'Email address',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: (v) => InputValidator.validateEmail(v),
                    onChanged: (_) => setState(() {}),
                  ),
                  const Gap(8.0),

                  // Password
                  CustomTextFormField(
                    label: 'Password',
                    hint: 'Password',
                    controller: _passwordController,
                    textInputAction: TextInputAction.done,
                    obscureText: !_showPassword,
                    onFieldSubmitted: (_) => _handleLogin(),
                    suffixIcon: IconButton(
                      onPressed: () =>
                          setState(() => _showPassword = !_showPassword),
                      icon: Icon(
                        _showPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                    validator: (v) => InputValidator.validatePassword(v),
                    onChanged: (_) => setState(() {}),
                  ),
                  const Gap(8.0),

                  // Forgot password
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () =>
                            context.pushNamed(PasswordResetScreen.path),
                        child: const Text('Forgot Password?'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
        ).copyWith(bottom: 32.0),
        child: CustomElevatedButton(
          text: 'Continue',
          isLoading: authState.isLoading,
          onPressed:
              // Disable while loading or if fields are empty.
              authState.isLoading ||
                  _emailController.text.trim().isEmpty ||
                  _passwordController.text.trim().isEmpty
              ? null
              : _handleLogin,
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:gap/gap.dart';
// import 'package:go_router/go_router.dart';
// import 'package:savvy_bee_mobile/core/utils/assets/logos.dart';
// import 'package:savvy_bee_mobile/core/utils/input_validator.dart';
// import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';
// import 'package:savvy_bee_mobile/core/widgets/custom_input_field.dart';
// import 'package:savvy_bee_mobile/core/widgets/intro_text.dart';
// import 'package:savvy_bee_mobile/features/auth/presentation/providers/auth_providers.dart';
// import 'package:savvy_bee_mobile/features/auth/presentation/screens/password_reset/password_reset_screen.dart';
// import 'package:savvy_bee_mobile/features/auth/presentation/screens/signup_screen.dart';
// import 'package:savvy_bee_mobile/features/home/presentation/screens/home_screen.dart';

// import '../../../../core/widgets/custom_snackbar.dart';

// class LoginScreen extends ConsumerStatefulWidget {
//   static const String path = '/login';

//   const LoginScreen({super.key});

//   @override
//   ConsumerState<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends ConsumerState<LoginScreen> {
//   final _formKey = GlobalKey<FormState>();

//   final emailController = TextEditingController();
//   final passwordController = TextEditingController();

//   bool _showPassword = false;

//   @override
//   void dispose() {
//     emailController.dispose();
//     passwordController.dispose();
//     super.dispose();
//   }

//   Future<void> _handleLogin() async {
//     if (!_formKey.currentState!.validate()) return;

//     final authNotifier = ref.read(authProvider.notifier);
//     final response = await authNotifier.login(
//       emailController.text.toLowerCase().trim(),
//       passwordController.text.trim(),
//     );

//     if (!mounted) return;

//     // Check if response is null
//     if (response == null) {
//       CustomSnackbar.show(
//         context,
//         ref.read(authProvider).errorMessage ?? 'Login failed',
//         type: SnackbarType.error,
//         position: SnackbarPosition.bottom,
//       );
//       return;
//     }

//     // Check if login was successful
//     if (!response.success) {
//       // Check verification status even on failure
//       final verification = response.data?.verification;

//       if (verification != null) {
//         // Handle incomplete email verification
//         if (verification.emailVerification == false) {
//           CustomSnackbar.show(
//             context,
//             response.message,
//             type: SnackbarType.error,
//             position: SnackbarPosition.bottom,
//           );

//           context.pushNamed(
//             SignupScreen.path,
//             extra: IncompleteSignUpData(
//               email: emailController.text.trim(),
//               pageIndex: 4,
//             ),
//           );
//           return;
//         }

//         // Handle incomplete profile
//         if (verification.otherDetails == false) {
//           CustomSnackbar.show(
//             context,
//             response.message,
//             type: SnackbarType.error,
//             position: SnackbarPosition.bottom,
//           );
//           context.pushNamed(
//             SignupScreen.path,
//             extra: IncompleteSignUpData(
//               email: emailController.text.trim(),
//               pageIndex: 5,
//             ),
//           );
//           return;
//         }
//       }

//       // Generic error message if no specific verification issue
//       CustomSnackbar.show(
//         context,
//         response.message,
//         type: SnackbarType.error,
//         position: SnackbarPosition.bottom,
//       );
//       return;
//     }

//     // Success case - both response.success is true and data exists
//     if (response.data != null) {
//       final verification = response.data?.verification;

//       // Double-check verification status even on success
//       if (verification?.emailVerification == false) {
//         CustomSnackbar.show(
//           context,
//           'Please verify your email first',
//           type: SnackbarType.error,
//           position: SnackbarPosition.bottom,
//         );
//         context.pushNamed(SignupScreen.path, extra: 4);
//         return;
//       }

//       if (verification?.otherDetails == false) {
//         CustomSnackbar.show(
//           context,
//           'Please complete your profile',
//           type: SnackbarType.error,
//           position: SnackbarPosition.bottom,
//         );
//         context.pushNamed(SignupScreen.path, extra: 5);
//         return;
//       }

//       // All checks passed, proceed to home
//       context.goNamed(HomeScreen.path);
//     } else {
//       CustomSnackbar.show(
//         context,
//         'Login failed - no data received',
//         type: SnackbarType.error,
//         position: SnackbarPosition.bottom,
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final authState = ref.watch(authProvider);
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         surfaceTintColor: Colors.transparent,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 16),
//         child: Form(
//           key: _formKey,
//           child: Center(
//             child: SingleChildScrollView(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Image.asset(Logos.logo, scale: 3),
//                   const Gap(24.0),
//                   IntroText(
//                     title: 'Welcome back!',
//                     subtitle: 'The hive missed you. Log in to continue',
//                     alignment: TextAlignment.center,
//                   ),
//                   const Gap(24.0),
//                   CustomTextFormField(
//                     label: 'Email address',
//                     hint: 'Email address',
//                     controller: emailController,
//                     keyboardType: TextInputType.emailAddress,
//                     validator: (value) => InputValidator.validateEmail(value),
//                     onChanged: (_) {
//                       setState(() {});
//                     },
//                   ),
//                   const Gap(8.0),
//                   CustomTextFormField(
//                     label: 'Password',
//                     hint: 'Password',
//                     controller: passwordController,
//                     textInputAction: TextInputAction.done,
//                     obscureText: !_showPassword,
//                     suffixIcon: IconButton(
//                       onPressed: () {
//                         setState(() {
//                           _showPassword = !_showPassword;
//                         });
//                       },
//                       icon: Icon(
//                         _showPassword
//                             ? Icons.visibility_outlined
//                             : Icons.visibility_off_outlined,
//                       ),
//                     ),
//                     validator: (value) =>
//                         InputValidator.validatePassword(value),
//                     onChanged: (_) {
//                       setState(() {});
//                     },
//                   ),
//                   const Gap(8.0),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     children: [
//                       TextButton(
//                         onPressed: () {
//                           context.pushNamed(PasswordResetScreen.path);
//                         },
//                         child: const Text('Forgot Password?'),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//       bottomNavigationBar: Padding(
//         padding: const EdgeInsets.symmetric(
//           horizontal: 16,
//         ).copyWith(bottom: 32.0),
//         child: CustomElevatedButton(
//           text: 'Continue',
//           isLoading: authState.isLoading,
//           onPressed:
//               emailController.text.trim().isEmpty ||
//                   passwordController.text.trim().isEmpty
//               ? null
//               : _handleLogin,
//         ),
//       ),
//     );
//   }
// }
