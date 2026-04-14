import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/services/biometric_service.dart';
import 'package:savvy_bee_mobile/core/utils/assets/logos.dart';
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

    Future.delayed(const Duration(seconds: 1), () => _route());
  }

  /// Determine destination. Reads storage/biometric directly to avoid the
  /// async-init race condition in BiometricNotifier.
  Future<void> _route() async {
    if (!mounted) return;

    final authState = ref.read(authProvider);

    if (!authState.isAuthenticated) {
      context.goNamed(OnboardingScreen.path);
      return;
    }

    final storage = ref.read(storageServiceProvider);

    // ── Biometric gate ────────────────────────────────────────────────────────
    // Read enabled-flag and availability directly from their sources so we
    // never hit the BiometricNotifier async-init race.
    final biometricEnabled = await storage.getBiometricEnabled();
    if (biometricEnabled) {
      final availability =
          await ref.read(biometricServiceProvider).checkAvailability();
      if (availability == BiometricAvailability.available) {
        if (mounted) context.goNamed(BiometricLockScreen.path);
        return;
      }
    }

    // ── No biometric gate — validate token ────────────────────────────────────
    final hasSession = await storage.hasValidSession();
    if (!mounted) return;

    if (hasSession) {
      context.goNamed(HomeScreen.path);
    } else {
      await ref.read(authProvider.notifier).logout();
      if (mounted) context.goNamed(LoginScreen.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.isInitialized) _navigateAfterAuth();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _navigateAfterAuth());

    return Scaffold(body: Center(child: Image.asset(Logos.logo, scale: 1.5)));
  }
}
