import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/services/device_info_service.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/assets/logos.dart';
import 'package:savvy_bee_mobile/core/utils/input_validator.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_input_field.dart';
import 'package:savvy_bee_mobile/core/widgets/intro_text.dart';
import 'package:savvy_bee_mobile/core/services/service_locator.dart';
import 'package:savvy_bee_mobile/features/auth/presentation/providers/auth_providers.dart';
import 'package:savvy_bee_mobile/features/auth/presentation/providers/biometric_provider.dart';
import 'package:savvy_bee_mobile/features/auth/presentation/widgets/biometric_enrollment_sheet.dart';
import 'package:savvy_bee_mobile/features/auth/presentation/screens/password_reset/password_reset_screen.dart';
import 'package:savvy_bee_mobile/features/auth/presentation/screens/signup_screen.dart';
import 'package:savvy_bee_mobile/features/home/presentation/providers/home_data_provider.dart';
import 'package:savvy_bee_mobile/features/home/presentation/screens/home_screen.dart';
import 'package:savvy_bee_mobile/features/auth/presentation/screens/post_signup/architype/financial_architype_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/widgets/custom_snackbar.dart';

const _kSavedEmailKey = 'last_login_email';

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

  String? _deviceID;
  String? _savedEmail;

  @override
  void initState() {
    super.initState();
    _getDeviceId();
    _loadSavedEmail();
    // Trigger biometric auto-login on screen entry if enabled
    WidgetsBinding.instance.addPostFrameCallback((_) => _tryBiometricLogin());
  }

  Future<void> _tryBiometricLogin() async {
    final biometric = ref.read(biometricProvider);
    if (!biometric.isEnabled || !biometric.isAvailable) return;

    final result =
        await ref.read(biometricProvider.notifier).authenticateWithBiometrics();

    if (!mounted) return;

    switch (result) {
      case BiometricAuthResult.success:
        ref.invalidate(homeDataProvider);
        context.goNamed(HomeScreen.path);
      case BiometricAuthResult.passwordLoginRequired:
        CustomSnackbar.show(
          context,
          'Please log in with your password. This is required every 30 days.',
          type: SnackbarType.neutral,
        );
      case BiometricAuthResult.permanentlyFailed:
        CustomSnackbar.show(
          context,
          'Biometric login disabled after too many failed attempts.',
          type: SnackbarType.error,
        );
      case BiometricAuthResult.tokenExpired:
        CustomSnackbar.show(
          context,
          'Your session expired. Please log in again.',
          type: SnackbarType.neutral,
        );
      case BiometricAuthResult.lockedOut:
        final error = ref.read(biometricProvider).errorMessage;
        if (error != null) {
          CustomSnackbar.show(context, error, type: SnackbarType.error);
        }
      default:
        break;
    }
  }

  Future<void> _loadSavedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString(_kSavedEmailKey);
    if (email != null && mounted) {
      setState(() => _savedEmail = email);
    }
  }

  Future<void> _saveEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kSavedEmailKey, email);
  }

  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _getDeviceId() async {
    try {
      final deviceId = await DeviceInfoService.getDeviceId();
      setState(() => _deviceID = deviceId);
      debugPrint('Device ID: $deviceId');
    } catch (e) {
      debugPrint('Failed to get device ID: $e');
      setState(() {
        _deviceID = 'fallback_${DateTime.now().millisecondsSinceEpoch}';
      });
    }
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
    // required bool postOnboarding,
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

    // if (!postOnboarding) {
    //   // Profile complete but the onboarding questionnaire wasn't finished.
    //   context.pushNamed(FinancialArchitypeScreen.path);
    //   return;
    // }

    // Everything is done — go home.
    context.goNamed(HomeScreen.path);
  }

  // ─── Biometric enrollment prompt ────────────────────────────────────────────
  //
  // Shown once after every successful password login, as long as biometrics are
  // available on the device but not yet enabled. If the user taps "Not Now" the
  // sheet dismisses and they proceed to home — next login, the sheet appears
  // again. Enrollment is triggered directly from the sheet so the OS prompt
  // happens in context before the app navigates away.

  Future<void> _maybePromptBiometricEnrollment(String email) async {
    final biometric = ref.read(biometricProvider);
    if (!biometric.isAvailable || biometric.isEnabled) return;
    await BiometricEnrollmentSheet.show(context, email);
  }

  // ─── Login handler ──────────────────────────────────────────────────────────

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.toLowerCase().trim();

    final response = await ref
        .read(authProvider.notifier)
        .login(email, _passwordController.text.trim(), _deviceID!);

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
          (!verification.emailVerification || !verification.otherDetails
          // || !verification.postOnboarding
          )) {
        _resumeRegistration(
          emailVerified: verification.emailVerification,
          otherDetails: verification.otherDetails,
          // postOnboarding: verification.postOnboarding,
          email: email,
          message: response.message,
        );
        return;
      }
      // Fully set-up account — persist credentials for silent biometric re-auth,
      // then optionally prompt enrollment, then go home.
      await _saveEmail(email);
      final storage = ref.read(storageServiceProvider);
      await storage.saveBiometricCredentials(
          email, _passwordController.text.trim());
      await storage.saveBiometricLastFullLoginDate();
      ref.invalidate(homeDataProvider);
      if (!mounted) return;
      await _maybePromptBiometricEnrollment(email);
      if (!mounted) return;
      context.goNamed(HomeScreen.path);
    } else {
      // ── Failed login ────────────────────────────────────────────────────────
      // The API may still return verification data even on failure (e.g. the
      // sample response above). Use it to resume registration if possible.
      if (verification != null) {
        _resumeRegistration(
          emailVerified: verification.emailVerification,
          otherDetails: verification.otherDetails,
          // postOnboarding: verification.postOnboarding,
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

                  // Saved email suggestion
                  if (_savedEmail != null && _emailController.text.isEmpty) ...[
                    const Gap(8),
                    GestureDetector(
                      onTap: () {
                        _emailController.text = _savedEmail!;
                        setState(() {});
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.person_outline, size: 16),
                            const Gap(8),
                            Text(
                              _savedEmail!,
                              style: const TextStyle(
                                fontSize: 14,
                                fontFamily: 'GeneralSans',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Biometric quick-login (only shown when enabled)
            if (ref.watch(biometricProvider).isEnabled &&
                ref.watch(biometricProvider).isAvailable) ...[
              OutlinedButton.icon(
                onPressed: ref.watch(biometricProvider).isAuthenticating
                    ? null
                    : _tryBiometricLogin,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: const BorderSide(color: AppColors.primary),
                ),
                icon: ref.watch(biometricProvider).isAuthenticating
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      )
                    : const Icon(Icons.fingerprint_rounded,
                        color: AppColors.primary),
                label: Text(
                  ref.watch(biometricProvider).isAuthenticating
                      ? 'Authenticating…'
                      : 'Use Biometrics',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontFamily: 'GeneralSans',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Gap(12),
            ],
            CustomElevatedButton(
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
          ],
        ),
      ),
    );
  }
}
