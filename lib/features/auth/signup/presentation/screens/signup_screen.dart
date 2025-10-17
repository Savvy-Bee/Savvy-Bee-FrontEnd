import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/breakpoints.dart';
import 'package:savvy_bee_mobile/core/widgets/app_button.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_input_field.dart';
import 'package:savvy_bee_mobile/core/widgets/intro_text.dart';
import 'package:savvy_bee_mobile/features/auth/signup/domain/models/signup_items.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../../../core/utils/constants.dart';
import '../../../../../core/utils/custom_page_indicator.dart';
import 'signup_complete_screen.dart';

class SignupScreen extends StatefulWidget {
  static String path = '/signup-name';

  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _pageController = PageController();

  int _currentPage = 0;

  bool showPassword = false;

  @override
  Widget build(BuildContext context) {
    final int dotCount = 6;
    final double screenWidth = Breakpoints.screenWidth(context);
    final double spacingValue = 5.0;
    final double horizontalPadding = 16.0;

    // 1. Calculate the actual width available for the indicator
    // (ScreenWidth - Left Padding - Right Padding)
    final double availableWidth = screenWidth - (2 * horizontalPadding);

    // 2. Calculate the total space taken up by the gaps
    final double totalSpacing = (dotCount - 1) * spacingValue;

    // 3. Calculate the remaining space for all dots
    final double availableWidthForDots = availableWidth - totalSpacing;

    // 4. Calculate the width for a single dot
    final double calculatedDotWidth = availableWidthForDots / dotCount;

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: Constants.topOnlyBorderRadius,
          ),
          margin: EdgeInsets.only(top: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        BackButton(),
                        IconButton(onPressed: () {}, icon: Icon(Icons.close)),
                      ],
                    ),
                    const Gap(10.0),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                      ),
                      child: SmoothPageIndicator(
                        controller: _pageController,
                        count: dotCount,
                        effect: PreviousColoredSlideEffect(
                          dotHeight: 4.0,
                          dotWidth: calculatedDotWidth,
                          spacing: spacingValue,
                          activeDotColor: AppColors.primary,
                          dotColor: AppColors.grey,
                        ),
                      ),
                    ),
                    const Gap(10.0),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            IntroText(
                              title: SignupItems.items[_currentPage].title,
                              subtitle:
                                  SignupItems.items[_currentPage].description,
                              alignment: TextAlignment.left,
                            ),
                            const Gap(20.0),
                            Expanded(
                              child: PageView(
                                controller: _pageController,
                                onPageChanged: (value) {
                                  setState(() {
                                    _currentPage = value;
                                  });
                                },
                                physics: const NeverScrollableScrollPhysics(),
                                children: [
                                  _nameView(),
                                  _emailView(),
                                  _passwordView(),
                                  _otpView(),
                                  _dobView(),
                                  _countryView(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0).copyWith(bottom: 32.0),
                child: AppButton(
                  text: 'Continue',
                  onPressed: () {
                    if (_currentPage == 5) {
                      context.pushNamed(SignupCompleteScreen.path);
                    }

                    _pageController.nextPage(
                      duration: Duration(milliseconds: 1),
                      curve: Curves.linear,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _nameView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomInputField(hint: 'First Name'),
        const Gap(5.0),
        CustomInputField(hint: 'Last Name'),
      ],
    );
  }

  Widget _emailView() {
    return CustomInputField(hint: 'Email address');
  }

  Widget _passwordView() {
    return CustomInputField(
      hint: 'Password',
      suffix: IconButton(
        onPressed: () {
          setState(() {
            showPassword = !showPassword;
          });
        },
        icon: Icon(
          showPassword
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
        ),
      ),
    );
  }

  Widget _otpView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {},
          child: Text(
            'Send to a different email',
            style: TextStyle(
              decoration: TextDecoration.underline,
              color: AppColors.primary,
              decorationColor: AppColors.primary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const Gap(20.0),
        CustomOtpField(onCompleted: (value) {}),
      ],
    );
  }

  Widget _dobView() {
    return CustomInputField(
      hint: 'Date of birth',
      readOnly: true,
      onTap: () {},
      suffix: Icon(Icons.calendar_today_outlined),
    );
  }

  Widget _countryView() {
    return CustomInputField(
      hint: 'Country of residence',
      readOnly: true,
      onTap: () {},
      suffix: Icon(Icons.keyboard_arrow_down),
    );
  }
}
