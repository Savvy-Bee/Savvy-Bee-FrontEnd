import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/assets/assets.dart';
import '../../../../core/utils/assets/logos.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/intro_text.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../../auth/presentation/screens/signup_screen.dart';
import '../../domain/models/onboarding_item.dart';

class OnboardingScreen extends StatefulWidget {
  static String path = '/onboarding';

  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentIndex = 0;

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_currentIndex < OnboardingItem.items.length - 1) {
        _pageController.animateToPage(
          _currentIndex + 1,
          duration: const Duration(milliseconds: 300),
          curve: Curves.ease,
        );
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Color get _backgroundColor {
    return switch (_currentIndex) {
      0 => AppColors.primaryFaint,
      1 => AppColors.primaryFaded,
      2 => AppColors.blue,
      3 => AppColors.primary,
      _ => AppColors.primaryFaint,
    };
  }

  bool get _isFirstPage => _currentIndex == 0;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: _backgroundColor,
          image: _isFirstPage
              ? DecorationImage(
                  image: AssetImage(Assets.onboardBg01),
                  fit: BoxFit.contain,
                  alignment: Alignment.bottomCenter,
                )
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: SafeArea(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (value) {
                    setState(() {
                      _currentIndex = value;
                    });
                  },
                  children: OnboardingItem.items
                      .map((item) => _buildPageContent(item, height))
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      ),
      extendBody: true,
      bottomNavigationBar: _buildAuthButtonsAndPageIndicator(context),
    );
  }

  Widget _buildPageContent(OnboardingItem item, double height) {
    return Container(
      decoration: BoxDecoration(
        color: _isFirstPage ? Colors.transparent : _backgroundColor,
      ),
      child: Column(
        children: [
          if (_isFirstPage) ...[
            const Gap(16.0),
            _buildLogo(),
            const Gap(16.0),
            _buildIntroTexts(alignment: TextAlignment.center),
          ] else ...[
            Image.asset(
              item.imagePath,
              height: height / 2,
              width: double.infinity,
              fit: BoxFit.cover,
              alignment: Alignment.bottomCenter,
            ),
            Expanded(child: _buildIntroTexts()),
          ],
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 8,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Image.asset(Logos.logo, scale: 5),
        Image.asset(Logos.logoText),
      ],
    );
  }

  Widget _buildIntroTexts({TextAlignment? alignment}) {
    return Container(
      padding: const EdgeInsets.all(
        16.0,
      ).copyWith(bottom: 0, top: _isFirstPage ? 0 : 32.0),
      decoration: BoxDecoration(
        color: _isFirstPage ? null : AppColors.background,
        border: _isFirstPage ? null : const Border(top: BorderSide()),
      ),
      child: IntroText(
        title: OnboardingItem.items[_currentIndex].title,
        subtitle: OnboardingItem.items[_currentIndex].description,
        alignment: alignment ?? TextAlignment.left,
      ),
    );
  }

  Widget _buildAuthButtonsAndPageIndicator(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0).copyWith(bottom: 32.0),
      color: _isFirstPage ? Colors.transparent : AppColors.background,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SmoothPageIndicator(
            controller: _pageController,
            count: OnboardingItem.items.length,
            effect: ExpandingDotsEffect(
              dotWidth: 6,
              dotHeight: 6,
              activeDotColor: AppColors.primary,
              dotColor: AppColors.greyDark.withValues(alpha: 0.5),
            ),
          ),
          const Gap(32.0),
          Row(
            spacing: 8,
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: CustomOutlinedButton(
                  text: 'Log in',
                  onPressed: () => context.pushNamed(LoginScreen.path),
                ),
              ),
              Expanded(
                child: CustomElevatedButton(
                  text: 'Get started',
                  onPressed: () => context.pushNamed(SignupScreen.path),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
