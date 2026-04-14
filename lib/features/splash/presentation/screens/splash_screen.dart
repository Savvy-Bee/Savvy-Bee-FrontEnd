import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/utils/assets/logos.dart';
import 'package:savvy_bee_mobile/features/auth/presentation/providers/biometric_provider.dart';
import 'package:savvy_bee_mobile/features/auth/presentation/screens/biometric_lock_screen.dart';
import 'package:savvy_bee_mobile/features/home/presentation/screens/home_screen.dart';
import 'package:savvy_bee_mobile/features/onboarding/presentation/screens/onboarding_screen.dart';

import '../../../../core/services/service_locator.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../auth/presentation/screens/login_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  static const String path = '/splash';

  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _hasNavigated = false;

  void _navigateAfterAuth() {
    if (_hasNavigated) return;

    final authState = ref.read(authProvider);
    if (!authState.isInitialized) return;

    _hasNavigated = true;

    Future.delayed(const Duration(seconds: 1), () async {
      if (!mounted) return;

      if (!authState.isAuthenticated) {
        context.goNamed(OnboardingScreen.path);
        return;
      }

      // ── Biometric gate (cold start) ────────────────────────────────────────
      // If the user has biometrics enabled, send them to the lock screen
      // instead of home — regardless of whether the token is still valid.
      // The lock screen will handle token expiry / 30-day refresh internally.
      final biometric = ref.read(biometricProvider);
      if (biometric.isEnabled && biometric.isAvailable) {
        context.goNamed(BiometricLockScreen.path);
        return;
      }

      // No biometrics — check if session is still valid
      final hasSession = await ref
          .read(storageServiceProvider)
          .hasValidSession();
      if (!mounted) return;

      if (hasSession) {
        context.goNamed(HomeScreen.path);
      } else {
        // Token expired and no biometrics to re-auth — go to login
        await ref.read(authProvider.notifier).logout();
        if (mounted) context.goNamed(LoginScreen.path);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.isInitialized) _navigateAfterAuth();
    });

    // Also check immediately in case auth was already initialized
    WidgetsBinding.instance.addPostFrameCallback((_) => _navigateAfterAuth());

    return Scaffold(body: Center(child: Image.asset(Logos.logo, scale: 1.5)));
  }
}
