import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/assets/logos.dart' show Logos;
import 'package:savvy_bee_mobile/features/auth/presentation/providers/auth_providers.dart';
import 'package:savvy_bee_mobile/features/auth/presentation/providers/biometric_provider.dart';
import 'package:savvy_bee_mobile/features/auth/presentation/screens/login_screen.dart';
import 'package:savvy_bee_mobile/features/home/presentation/screens/home_screen.dart';

class BiometricLockScreen extends ConsumerStatefulWidget {
  static const String path = '/biometric-lock';

  const BiometricLockScreen({super.key});

  @override
  ConsumerState<BiometricLockScreen> createState() =>
      _BiometricLockScreenState();
}

class _BiometricLockScreenState extends ConsumerState<BiometricLockScreen> {
  // Message shown when the user must use their password instead
  String? _forcedMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _authenticate());
  }

  Future<void> _authenticate() async {
    final result = await ref
        .read(biometricProvider.notifier)
        .authenticateWithBiometrics();

    if (!mounted) return;
    _handleResult(result);
  }

  void _handleResult(BiometricAuthResult result) {
    switch (result) {
      case BiometricAuthResult.success:
        context.go(HomeScreen.path);

      case BiometricAuthResult.passwordLoginRequired:
        // 30-day limit reached — user must log in with email + password
        setState(() {
          _forcedMessage =
              'For your security, please log in with your password.\n'
              'This is required every 30 days.';
        });
        // Auto-redirect after a short pause so the user can read the message
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) _redirectToLogin();
        });

      case BiometricAuthResult.permanentlyFailed:
        setState(() {
          _forcedMessage =
              'Too many failed attempts. Biometric login has been disabled.\n'
              'Please log in with your password.';
        });
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) _redirectToLogin();
        });

      case BiometricAuthResult.tokenExpired:
        _redirectToLogin();

      case BiometricAuthResult.lockedOut:
        // Error already in state — user sees retry button
        break;

      case BiometricAuthResult.cancelled:
      case BiometricAuthResult.failed:
      case BiometricAuthResult.notAvailable:
        break;
    }
  }

  Future<void> _redirectToLogin() async {
    await ref.read(authProvider.notifier).logout();
    if (mounted) context.go(LoginScreen.path);
  }

  Future<void> _usePassword() async {
    await ref.read(authProvider.notifier).logout();
    if (mounted) context.go(LoginScreen.path);
  }

  @override
  Widget build(BuildContext context) {
    final biometric = ref.watch(biometricProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),

              Image.asset(Logos.logoText, height: 48),
              const SizedBox(height: 48),

              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: AppColors.primaryFaint,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_outline_rounded,
                  size: 40,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'App Locked',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Excon',
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                _forcedMessage ?? 'Authenticate to continue',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      fontFamily: 'GeneralSans',
                      height: 1.5,
                    ),
                textAlign: TextAlign.center,
              ),

              // Error message from OS failures
              if (biometric.errorMessage != null &&
                  _forcedMessage == null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    biometric.errorMessage!,
                    style: const TextStyle(
                      color: AppColors.error,
                      fontSize: 13,
                      fontFamily: 'GeneralSans',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],

              const Spacer(flex: 3),

              // Show biometric button only when no forced redirect is pending
              if (_forcedMessage == null) ...[
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed:
                        biometric.isAuthenticating ? null : _authenticate,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: biometric.isAuthenticating
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.black,
                            ),
                          )
                        : const Icon(Icons.fingerprint_rounded, size: 22),
                    label: Text(
                      biometric.isAuthenticating
                          ? 'Authenticating…'
                          : 'Use Biometrics',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'GeneralSans',
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: biometric.isAuthenticating ? null : _usePassword,
                  child: const Text(
                    'Use Password Instead',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      fontFamily: 'GeneralSans',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ] else ...[
                // Forced redirect — show spinner
                const CircularProgressIndicator(color: AppColors.primary),
              ],

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
