import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/utils/assets/logos.dart';
import 'package:savvy_bee_mobile/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:savvy_bee_mobile/features/onboarding/presentation/screens/onboarding_screen.dart';

import '../../../auth/presentation/providers/auth_providers.dart';

class SplashScreen extends ConsumerStatefulWidget {
  static String path = '/splash';

  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _hasNavigated = false;

  void _navigateAfterAuth() {
    if (_hasNavigated) return;

    final authState = ref.read(authProvider);
    final isInitialized = authState.isInitialized;

    if (!isInitialized) return; // Wait for auth to initialize

    _hasNavigated = true;

    // Delay for splash screen animation
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;

      if (authState.isAuthenticated) {
        // User is logged in - go to home
        // context.goNamed(HomeScreen.path);
        context.goNamed(DashboardScreen.path);
      } else {
        // User not logged in - go to onboarding
        context.goNamed(OnboardingScreen.path);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Listen to auth state changes
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.isInitialized) {
        _navigateAfterAuth();
      }
    });

    // Also check on build in case we missed the initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigateAfterAuth();
    });

    return Scaffold(body: Center(child: Image.asset(Logos.logo, scale: 1.5)));
  }
}
