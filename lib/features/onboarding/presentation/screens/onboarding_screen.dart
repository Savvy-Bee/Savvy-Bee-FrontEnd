import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../auth/presentation/screens/signup/presentation/screens/signup_screen.dart';
import '../../domain/models/onboarding_item.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../../core/utils/breakpoints.dart';
import '../../../../core/widgets/intro_text.dart';
import '../../../auth/presentation/screens/login/presentation/screens/login_screen.dart';

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
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_currentIndex < OnboardingItem.items.length - 1) {
        // If not the last page, go to the next page
        _pageController.nextPage(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeIn,
        );
      } else {
        // If it is the last page, loop back to the first page
        _pageController.animateToPage(
          0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeIn,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // VERY IMPORTANT: Cancel the timer
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: Breakpoints.screenPadding(context),
              child: IntroText(
                title: OnboardingItem.items[_currentIndex].title,
                subtitle: OnboardingItem.items[_currentIndex].description,
                showLogo: true,
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (value) {
                  setState(() {
                    _currentIndex = value;
                  });
                },
                children: OnboardingItem.items
                    .map(
                      (e) => Stack(
                        alignment: Alignment.center,
                        children: [
                          // Glow effect layer
                          Container(
                            width: 350, // Adjust to match your image size
                            height: 350,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  AppColors.primary.withValues(alpha: 0.4),
                                  AppColors.primary.withValues(alpha: 0.2),
                                  AppColors.primary.withValues(alpha: 0.05),
                                  Colors.transparent,
                                ],
                                stops: const [0.0, 0.4, 0.7, 1.0],
                              ),
                            ),
                          ),
                          // Image on top
                          Image.asset(
                            e.imagePath,
                            scale: switch (_currentIndex) {
                              0 => 1.1,
                              1 => 1.1,
                              2 => 0.9,
                              3 => 1.1,
                              _ => 0.5,
                            },
                          ),
                        ],
                      ),
                    )
                    .toList(),
              ),
            ),
            // const Gap(24),
            SmoothPageIndicator(
              controller: _pageController,
              count: OnboardingItem.items.length,
              effect: ColorTransitionEffect(
                dotWidth: 6,
                dotHeight: 6,
                activeDotColor: AppColors.primary,
                dotColor: AppColors.greyDark.withValues(alpha: 0.5),
              ),
            ),
            const Gap(24),
            Padding(
              padding: Breakpoints.screenPadding(context),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomElevatedButton(
                    text: 'Get Started',
                    onPressed: () {
                      context.pushNamed(SignupScreen.path);
                    },
                  ),
                  const Gap(10),
                  CustomElevatedButton(
                    text: 'I already have an account',
                    buttonColor: CustomButtonColor.black,
                    onPressed: () {
                      context.pushNamed(LoginScreen.path);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
