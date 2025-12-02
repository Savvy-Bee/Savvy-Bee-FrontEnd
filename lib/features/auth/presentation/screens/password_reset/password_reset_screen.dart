import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/utils/assets/logos.dart';
import 'package:savvy_bee_mobile/core/utils/input_validator.dart';
import 'package:savvy_bee_mobile/core/widgets/password_requirement_widget.dart';
import 'package:savvy_bee_mobile/features/auth/presentation/providers/auth_providers.dart';
import 'package:savvy_bee_mobile/features/auth/domain/models/password_reset_items.dart';
import 'package:savvy_bee_mobile/features/auth/presentation/screens/password_reset/password_reset_complete.dart';
import 'package:savvy_bee_mobile/features/auth/presentation/screens/post_signup/signup_complete_screen.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/constants.dart';
import '../../../../../core/utils/custom_page_indicator.dart';
import '../../../../../core/widgets/custom_button.dart';
import '../../../../../core/widgets/custom_input_field.dart';
import '../../../../../core/widgets/custom_snackbar.dart';
import '../../../../../core/widgets/intro_text.dart';

class PasswordResetScreen extends ConsumerStatefulWidget {
  static String path = '/password-reset';

  const PasswordResetScreen({super.key});

  @override
  ConsumerState<PasswordResetScreen> createState() =>
      _PasswordResetScreenState();
}

class _PasswordResetScreenState extends ConsumerState<PasswordResetScreen> {
  final _pageController = PageController();

  // Form keys for validation
  final _emailFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  // Controllers
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _showPassword = false;
  final bool _showConfirmPassword = false;
  int _currentPage = 0;

  final int _dotCount = 3;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      final newPage = _pageController.page?.round() ?? 0;
      if (newPage != _currentPage) {
        setState(() {
          _currentPage = newPage;
        });
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  /// Get page subtitle with dynamic email
  String _getPageSubtitle() {
    final item = PasswordResetItems.items[_currentPage];
    if (_currentPage == 1) {
      return item.getDescription(_emailController.text.trim());
    }
    return item.getDescription();
  }

  /// Navigate to next page
  void _goToNextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _goToPreviousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  /// Show error message
  void _showError(String message) {
    CustomSnackbar.show(context, message, type: SnackbarType.error);
  }

  /// Handle continue button press
  Future<void> _handleContinue() async {
    final authNotifier = ref.read(authProvider.notifier);
    final authState = ref.read(authProvider);

    if (authState.isLoading) return;

    try {
      switch (_currentPage) {
        case 0:
          // Page 0: Email Input & Request OTP
          // if (!_emailFormKey.currentState!.validate()) return;

          // final success = await authNotifier.requestPasswordReset(
          //   _emailController.text.trim(),
          // );

          // if (success) {
          //   _goToNextPage();
          //   if (mounted) {
          //     CustomSnackbar.show(
          //       context,
          //       'Verification code sent to your email',
          //       type: SnackbarType.success,
          //     );
          //   }
          // } else {
          //   _showError(authState.errorMessage ?? 'Failed to send reset code');
          // }
          _goToNextPage();
          break;

        case 1:
          // Page 1: OTP Verification
          // if (_otpController.text.length < 4) {
          //   _showError('Please enter a valid verification code');
          //   return;
          // }

          // Verify OTP (optional step - some APIs verify at reset)
          // If your API has a separate verify endpoint, use it here
          // For now, we'll just move to the next page
          _goToNextPage();
          break;

        case 2:
          // Page 2: New Password & Reset
          // if (!_passwordFormKey.currentState!.validate()) return;

          // // Check if passwords match
          // if (_passwordController.text != _confirmPasswordController.text) {
          //   _showError('Passwords do not match');
          //   return;
          // }

          // // Validate password requirements
          // final password = _passwordController.text;
          // if (!TextUtils.isPasswordValid(password)) {
          //   _showError('Password does not meet all requirements');
          //   return;
          // }

          // final success = await authNotifier.resetPassword(
          //   email: _emailController.text.trim(),
          //   otp: _otpController.text.trim(),
          //   newPassword: _passwordController.text,
          // );

          // if (success) {
          //   if (mounted) {
          //     context.pushReplacementNamed(PasswordResetComplete.path);
          //   }
          // } else {
          //   _showError(authState.errorMessage ?? 'Failed to reset password');
          // }
          context.pushReplacementNamed(SignupCompleteScreen.path, extra: true);
          break;

        default:
          _goToNextPage();

          break;
      }
    } catch (e) {
      _showError('An unexpected error occurred');
      debugPrint('Error in _handleContinue: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                children: [
                  // Top Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      BackButton(
                        onPressed: _currentPage == 0 ? null : _goToPreviousPage,
                      ),
                      Expanded(
                        child: SmoothPageIndicator(
                          controller: _pageController,
                          count: _dotCount,
                          effect: PreviousColoredSlideEffect(
                            dotHeight: 4.0,
                            spacing: 5,
                            activeDotColor: AppColors.primary,
                            dotColor: AppColors.grey,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const Gap(10.0),

                  // Content Area
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Gap(24.0),
                          Image.asset(Logos.logo, scale: 3),
                          const Gap(24.0),
                          IntroText(
                            title: PasswordResetItems.items[_currentPage].title,
                            subtitle: _getPageSubtitle(),
                          ),
                          const Gap(20.0),
                          Expanded(
                            child: PageView(
                              controller: _pageController,
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

            // Bottom CTA
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: CustomElevatedButton(
                text: authState.isLoading
                    ? 'Processing...'
                    : _currentPage == 2
                    ? 'Reset Password'
                    : 'Continue',
                onPressed: authState.isLoading ? null : _handleContinue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Email input view
  Widget _emailView() {
    return Form(
      key: _emailFormKey,
      child: CustomTextFormField(
        hint: 'Email address',
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.done,
        validator: (value) => InputValidator.validateEmail(value),
      ),
    );
  }

  /// OTP input view
  Widget _otpView() {
    final isResending = ref.watch(authProvider).isLoading;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              onTap: isResending
                  ? null
                  : () {
                      // Go back to email page (Page 1)
                      _pageController.jumpToPage(1);
                    },
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: Text(
                  'Send to a different email',
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
        const Gap(16),
        CustomOtpField(
          onCompleted: (value) {
            _otpController.text = value;
            _handleContinue(); // Auto-continue on OTP completion
          },
        ),
      ],
    );
  }

  /// Password input view with validation
  Widget _passwordView() {
    final password = _passwordController.text.trim();

    return Form(
      key: _passwordFormKey,
      child: ListView(
        shrinkWrap: true,
        children: [
          CustomTextFormField(
            hint: 'New Password',
            controller: _passwordController,
            onChanged: (_) {
              setState(() {});
            },
            obscureText: !_showPassword,
            textInputAction: TextInputAction.next,
            suffix: IconButton(
              onPressed: () {
                setState(() {
                  _showPassword = !_showPassword;
                });
              },
              icon: Icon(
                _showPassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
            ),
            validator: (value) => InputValidator.validatePassword(value),
          ),
          const Gap(16),
          PasswordRequirementWidget(password: password),
        ],
      ),
    );
  }
}
