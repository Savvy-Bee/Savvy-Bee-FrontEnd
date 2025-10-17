import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/assets.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';
import 'package:savvy_bee_mobile/core/widgets/responsive_layout.dart';
import 'package:savvy_bee_mobile/features/onboarding/presentation/screens/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  static String path = '/splash';

  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward().then((_) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          context.goNamed(OnboardingScreen.path);
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveLayout(
        mobile: _buildContent(context, isDesktop: false),
        tablet: _buildContent(context, isDesktop: false),
        desktop: _buildContent(context, isDesktop: true),
      ),
    );
  }

  Widget _buildContent(BuildContext context, {required bool isDesktop}) {
    // final maxWidth = Breakpoints.contentMaxWidth(context);
    // final padding = Breakpoints.screenPadding(context);
    // final iconSize = isDesktop ? 150.0 : 100.0;
    // final spacing = isDesktop ? 32.0 : 24.0;

    return Container(
      // constraints: BoxConstraints(maxWidth: maxWidth),
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
              bottom: -50,
              right: -115,
              child: Image.asset(Assets.savingsBeePose2, scale: 1.15),
            ),
            Positioned(
              bottom: -15,
              right: 75,
              child: Image.asset(Assets.loanBee, scale: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
