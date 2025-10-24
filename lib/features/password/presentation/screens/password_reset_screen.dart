import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/utils/input_validator.dart';
import 'package:savvy_bee_mobile/core/utils/text_utils.dart';
import 'package:savvy_bee_mobile/features/auth/presentation/providers/auth_providers.dart';
import 'package:savvy_bee_mobile/features/password/domain/models/password_reset_items.dart';
import 'package:savvy_bee_mobile/features/password/presentation/screens/password_reset_complete.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/breakpoints.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/utils/custom_page_indicator.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_input_field.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../core/widgets/intro_text.dart';

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
  bool _showConfirmPassword = false;
  int _currentPage = 0;
  String? _errorMessage;

  final int _dotCount = 3;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      final newPage = _pageController.page?.round() ?? 0;
      if (newPage != _currentPage) {
        setState(() {
          _currentPage = newPage;
          _errorMessage = null;
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

  /// Go back to email page
  void _goToEmailPage() {
    _pageController.jumpToPage(0);
  }

  /// Show error message
  void _showError(String message) {
    CustomSnackbar.show(context, message, type: SnackbarType.error);
    // setState(() {
    //   _errorMessage = message;
    // });
  }

  /// Handle continue button press
  Future<void> _handleContinue() async {
    _errorMessage = null;

    final authNotifier = ref.read(authProvider.notifier);
    final authState = ref.read(authProvider);

    if (authState.isLoading) return;

    try {
      switch (_currentPage) {
        case 0:
          // Page 0: Email Input & Request OTP
          if (!_emailFormKey.currentState!.validate()) return;

          final success = await authNotifier.requestPasswordReset(
            _emailController.text.trim(),
          );

          if (success) {
            _goToNextPage();
            if (mounted) {
              CustomSnackbar.show(
                context,
                'Verification code sent to your email',
                type: SnackbarType.success,
              );
            }
          } else {
            _showError(authState.errorMessage ?? 'Failed to send reset code');
          }
          break;

        case 1:
          // Page 1: OTP Verification
          if (_otpController.text.length < 4) {
            _showError('Please enter a valid verification code');
            return;
          }

          // Verify OTP (optional step - some APIs verify at reset)
          // If your API has a separate verify endpoint, use it here
          // For now, we'll just move to the next page
          _goToNextPage();
          break;

        case 2:
          // Page 2: New Password & Reset
          if (!_passwordFormKey.currentState!.validate()) return;

          // Check if passwords match
          if (_passwordController.text != _confirmPasswordController.text) {
            _showError('Passwords do not match');
            return;
          }

          // Validate password requirements
          final password = _passwordController.text;
          if (!TextUtils.isPasswordValid(password)) {
            _showError('Password does not meet all requirements');
            return;
          }

          final success = await authNotifier.resetPassword(
            email: _emailController.text.trim(),
            otp: _otpController.text.trim(),
            newPassword: _passwordController.text,
          );

          if (success) {
            if (mounted) {
              context.pushReplacementNamed(PasswordResetComplete.path);
            }
          } else {
            _showError(authState.errorMessage ?? 'Failed to reset password');
          }
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
    final double screenWidth = Breakpoints.screenWidth(context);
    const double spacingValue = 5.0;
    const double horizontalPadding = 16.0;

    final double availableWidth = screenWidth - (2 * horizontalPadding);
    final double totalSpacing = (_dotCount - 1) * spacingValue;
    final double availableWidthForDots = availableWidth - totalSpacing;
    final double calculatedDotWidth = availableWidthForDots / _dotCount;

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: Constants.topOnlyBorderRadius,
          ),
          margin: const EdgeInsets.only(top: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    // Top Bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        BackButton(onPressed: () => context.pop()),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const Gap(10.0),

                    // Page Indicator
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                      ),
                      child: SmoothPageIndicator(
                        controller: _pageController,
                        count: _dotCount,
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

                    // Content Area
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            IntroText(
                              title:
                                  PasswordResetItems.items[_currentPage].title,
                              subtitle: _getPageSubtitle(),
                              alignment: TextAlignment.left,
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
                padding: const EdgeInsets.all(16.0).copyWith(bottom: 32.0),
                child: CustomButton(
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
    final authNotifier = ref.read(authProvider.notifier);
    final authState = ref.read(authProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
              onTap: authState.isLoading ? null : _goToEmailPage,
              child: Text(
                'Send to a different email',
                style: TextStyle(
                  decoration: TextDecoration.underline,
                  color: authState.isLoading
                      ? AppColors.grey
                      : AppColors.primary,
                  decorationColor: AppColors.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            InkWell(
              onTap: authState.isLoading
                  ? null
                  : () async {
                      setState(() {
                        _errorMessage = null;
                      });
                      final success = await authNotifier.requestPasswordReset(
                        _emailController.text.trim(),
                      );
                      if (!success) {
                        _showError(
                          authState.errorMessage ?? 'Failed to resend code',
                        );
                      } else {
                        if (mounted) {
                          CustomSnackbar.show(
                            context,
                            'Code resent successfully',
                            type: SnackbarType.success,
                          );
                        }
                      }
                    },
              child: Text(
                'Resend Code',
                style: TextStyle(
                  decoration: TextDecoration.underline,
                  color: authState.isLoading
                      ? AppColors.grey
                      : AppColors.primary,
                  decorationColor: AppColors.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const Gap(20.0),
        CustomOtpField(
          onCompleted: (value) {
            _otpController.text = value;
            _handleContinue();
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
          const Gap(12.0),
          CustomTextFormField(
            hint: 'Confirm Password',
            controller: _confirmPasswordController,
            obscureText: !_showConfirmPassword,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _handleContinue(),
            suffix: IconButton(
              onPressed: () {
                setState(() {
                  _showConfirmPassword = !_showConfirmPassword;
                });
              },
              icon: Icon(
                _showConfirmPassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please confirm your password';
              }
              if (value != _passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
          const Gap(20.0),
          Text(
            'Password Requirements:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const Gap(12.0),
          _buildPasswordRequirementItem(
            '1 Uppercase letter',
            isValid: TextUtils.hasUppercase(password),
            password: password,
          ),
          _buildPasswordRequirementItem(
            '1 Lowercase letter',
            isValid: TextUtils.hasLowercase(password),
            password: password,
          ),
          _buildPasswordRequirementItem(
            '1 Number',
            isValid: TextUtils.hasNumber(password),
            password: password,
          ),
          _buildPasswordRequirementItem(
            '1 Special character',
            isValid: TextUtils.hasSpecialCharacter(password),
            password: password,
          ),
          _buildPasswordRequirementItem(
            '8 to 64 characters',
            isValid: TextUtils.isAtLeastEightChars(password),
            password: password,
          ),
        ],
      ),
    );
  }

  /// Build password requirement item with status indicator
  Widget _buildPasswordRequirementItem(
    String label, {
    bool isValid = false,
    required String password,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (password.isEmpty)
            Container(
              width: 20,
              height: 20,
              alignment: Alignment.center,
              child: const Text('●', style: TextStyle(fontSize: 8)),
            ),
          if (isValid)
            Icon(Icons.check_circle, color: AppColors.success, size: 20),
          if (password.isNotEmpty && !isValid)
            Icon(Icons.cancel, color: AppColors.error, size: 20),
          const Gap(10.0),
          Text(
            label,
            style: TextStyle(
              fontSize: 15.0,
              color: isValid
                  ? AppColors.success
                  : password.isNotEmpty && !isValid
                  ? AppColors.error
                  : Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
