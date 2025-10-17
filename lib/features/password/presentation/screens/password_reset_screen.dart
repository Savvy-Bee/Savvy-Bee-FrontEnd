import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/utils/text_utils.dart';
import 'package:savvy_bee_mobile/features/password/domain/models/password_reset_items.dart';
import 'package:savvy_bee_mobile/features/password/presentation/screens/password_reset_complete.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/breakpoints.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/utils/custom_page_indicator.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/custom_input_field.dart';
import '../../../../core/widgets/intro_text.dart';

class PasswordResetScreen extends StatefulWidget {
  static String path = '/password-reset';

  const PasswordResetScreen({super.key});

  @override
  State<PasswordResetScreen> createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  final _pageController = PageController();

  final passwordController = TextEditingController();

  bool showPassword = false;

  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final int dotCount = 3;
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
                              title:
                                  PasswordResetItems.items[_currentPage].title,
                              subtitle: PasswordResetItems
                                  .items[_currentPage]
                                  .description,
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
                                  _emailView(),
                                  _otpView(),
                                  _passwordView(),
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
                    if (_currentPage == 2) {
                      context.pushNamed(PasswordResetComplete.path);
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

  Widget _emailView() {
    return CustomInputField(hint: 'Email address');
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

  Widget _passwordView() {
    final password = passwordController.text.trim();

    return ListView(
      shrinkWrap: true,
      children: [
        CustomInputField(
          hint: 'Password',
          controller: passwordController,
          onChanged: (_) {
            setState(() {});
          },
          obscureText: showPassword,
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
        ),
        const Gap(20.0),
        _buildPasswordRequirementItem(
          '1 Uppercase',
          isValid: TextUtils.hasUppercase(password),
          password: passwordController.text.trim(),
        ),
        _buildPasswordRequirementItem(
          '1 Lowerercase',
          isValid: TextUtils.hasLowercase(password),
          password: passwordController.text.trim(),
        ),
        _buildPasswordRequirementItem(
          '1 Number',
          isValid: TextUtils.hasNumber(password),
          password: passwordController.text.trim(),
        ),
        _buildPasswordRequirementItem(
          '1 Special Character',
          isValid: TextUtils.hasSpecialCharacter(password),
          password: passwordController.text.trim(),
        ),
        _buildPasswordRequirementItem(
          '8 to 64 Characters',
          isValid: TextUtils.isAtLeastEightChars(password),
          password: passwordController.text.trim(),
        ),
      ],
    );
  }

  Widget _buildPasswordRequirementItem(
    String label, {
    bool isValid = false,
    required String password,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (password.isEmpty) Text('●'),
          if (isValid) Icon(Icons.check, color: AppColors.success),
          if (password.isNotEmpty && !isValid)
            Icon(Icons.close, color: AppColors.error),
          const Gap(10.0),
          Text(
            label,
            style: TextStyle(
              fontSize: 16.0,
              color: isValid
                  ? AppColors.success
                  : password.isNotEmpty && !isValid
                  ? AppColors.error
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
