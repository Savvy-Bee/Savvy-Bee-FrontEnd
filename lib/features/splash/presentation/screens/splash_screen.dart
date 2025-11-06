import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/assets/assets.dart';
import 'package:savvy_bee_mobile/core/utils/assets/illustrations.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';
import 'package:savvy_bee_mobile/core/widgets/responsive_layout.dart';
import 'package:savvy_bee_mobile/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:savvy_bee_mobile/features/onboarding/presentation/screens/onboarding_screen.dart';

import '../../../auth/presentation/providers/auth_providers.dart';

class SplashScreen extends ConsumerStatefulWidget {
  static String path = '/splash';

  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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

    return Scaffold(
      body: ResponsiveLayout(
        mobile: _buildContent(context, isDesktop: false),
        tablet: _buildContent(context, isDesktop: false),
        desktop: _buildContent(context, isDesktop: true),
      ),
    );
  }

  Widget _buildContent(BuildContext context, {required bool isDesktop}) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(Assets.hivePatternYellow),
          fit: BoxFit.cover,
        ),
      ),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Align(
              alignment: Alignment.center,
              child: Text(
                'SAVVY BEE',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: isDesktop ? 64 : 38,
                  fontFamily: Constants.exconFontFamily,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Positioned(
              bottom: 21,
              right: -45,
              // bottom: -50,
              // right: -115,
              child: Image.asset(Illustrations.savingsBeePose2, scale: 1.15),
            ),
            Positioned(
              bottom: -15,
              right: 75,
              child: Image.asset(Illustrations.loanBee, scale: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
