import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/breakpoints.dart';
import 'package:savvy_bee_mobile/core/utils/date_formatter.dart';
import 'package:savvy_bee_mobile/core/utils/input_validator.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_input_field.dart';
import 'package:savvy_bee_mobile/core/widgets/intro_text.dart';
import 'package:savvy_bee_mobile/features/auth/domain/models/auth_models.dart';
import 'package:savvy_bee_mobile/features/auth/presentation/providers/auth_providers.dart';
import 'package:savvy_bee_mobile/features/auth/presentation/screens/signup/domain/models/signup_items.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../../../../../core/utils/constants.dart';
import '../../../../../../../core/utils/custom_page_indicator.dart';
import '../../../../../../../core/widgets/custom_snackbar.dart';
import 'signup_complete_screen.dart';

class SignupScreen extends ConsumerStatefulWidget {
  static String path = '/signup-name';

  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _pageController = PageController();

  // Form keys for step-specific validation
  final _nameFormKey = GlobalKey<FormState>();
  final _emailFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();
  // Note: OTP uses its own field logic, so no FormKey needed for that view.
  final _dobFormKey = GlobalKey<FormState>();
  final _countryFormKey = GlobalKey<FormState>();

  // Form controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _otpController = TextEditingController();
  final _dobController = TextEditingController();
  final _countryController = TextEditingController();

  int _currentPage = 0;
  bool showPassword = false;
  String? _errorMessage;

  // Total number of steps in the signup flow
  final int _dotCount = 6;

  @override
  void initState() {
    super.initState();
    // Listen to page changes to clear error messages
    _pageController.addListener(() {
      final newPage = _pageController.page?.round() ?? 0;
      if (newPage != _currentPage) {
        setState(() {
          _currentPage = newPage;
          _errorMessage = null; // Clear error on page change
        });
      }
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _otpController.dispose();
    _dobController.dispose();
    _countryController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  // --- Core Navigation and Submission Logic ---

  void _goToNextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _showError(String message) {
    CustomSnackbar.show(context, message, type: SnackbarType.error);
    // setState(() {
    //   _errorMessage = message;
    // });
  }

  void _handleContinue() async {
    // Clear previous error message first
    _errorMessage = null;

    final authNotifier = ref.read(authProvider.notifier);
    final authState = ref.read(authProvider);

    if (authState.isLoading) return;

    try {
      switch (_currentPage) {
        case 0:
          // Page 0: Name Input
          if (_nameFormKey.currentState!.validate()) {
            _goToNextPage();
          }
          break;

        case 1:
          // Page 1: Email Input
          if (_emailFormKey.currentState!.validate()) {
            _goToNextPage();
          }
          break;

        case 2:
          // Page 2: Password Input & API Registration
          if (!_passwordFormKey.currentState!.validate()) return;

          final request = RegisterRequest(
            firstName: _firstNameController.text,
            lastName: _lastNameController.text,
            email: _emailController.text,
            password: _passwordController.text,
          );

          final success = await authNotifier.register(request);

          if (success) {
            _goToNextPage();
          } else {
            _showError(authState.errorMessage ?? 'Registration failed');
          }
          break;

        case 3:
          // Page 3: OTP Verification
          if (_otpController.text.length < 4) {
            _showError('Please enter a valid OTP (at least 4 digits)');
            return;
          }

          final verifyRequest = VerifyEmailRequest(
            email: _emailController.text,
            otp: _otpController.text,
          );

          final success = await authNotifier.verifyEmail(verifyRequest);

          if (success) {
            _goToNextPage();
          } else {
            _showError(authState.errorMessage ?? 'Verification failed');
          }
          break;

        case 4:
          // Page 4: Date of Birth Input
          if (_dobFormKey.currentState!.validate()) {
            _goToNextPage();
          }
          break;

        case 5:
          // Page 5: Country Input & Final Profile Update
          if (!_countryFormKey.currentState!.validate()) return;

          // Register Other Details with DOB and Country
          final registerOtherDetailsRequest = RegisterOtherDetailsRequest(
            email: _emailController.text,
            dob: _dobController.text,
            country: _countryController.text,
          );

          final success = await authNotifier.registerOtherDetails(
            registerOtherDetailsRequest,
          );

          if (success) {
            // Final success, navigate to completion screen
            if (mounted) {
              context.pushNamed(SignupCompleteScreen.path);
            }
          } else {
            _showError(
              authState.errorMessage ?? 'Failed to register other details',
            );
          }
          break;

        default:
          // Should not happen, but safe fallback
          _goToNextPage();
          break;
      }
    } catch (e) {
      // Catch any synchronous errors during validation or navigation
      _showError('An unexpected error occurred.');
      log('Error in _handleContinue: $e');
    }
  }

  // --- UI Builder Methods ---

  /// Get the subtitle for the current page with dynamic content
  String _getPageSubtitle() {
    final item = SignupItems.items[_currentPage];

    // For the OTP page (index 3), pass the email
    if (_currentPage == 3) {
      return item.getDescription(_emailController.text.trim());
    }

    // For all other pages, no dynamic value needed
    return item.getDescription();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final double screenWidth = Breakpoints.screenWidth(context);
    const double spacingValue = 5.0;
    const double horizontalPadding = 16.0;

    // Calculate dynamic dot width for responsive page indicator
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
                    // Top Bar (Back and Close buttons)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        BackButton(),
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
                    // Content Area (Intro Text + PageView)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            IntroText(
                              title: SignupItems.items[_currentPage].title,
                              subtitle: _getPageSubtitle(),
                              alignment: TextAlignment.left,
                            ),
                            const Gap(20.0),
                            Expanded(
                              child: PageView(
                                controller: _pageController,
                                // The physics is intentionally disabled for controlled flow
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
              // Bottom CTA and Error Message
              Padding(
                padding: const EdgeInsets.all(16.0).copyWith(bottom: 32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    CustomButton(
                      text: authState.isLoading ? 'Processing...' : 'Continue',
                      onPressed: authState.isLoading ? null : _handleContinue,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Page Views ---

  Widget _nameView() {
    return Form(
      key: _nameFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextFormField(
            hint: 'First Name',
            controller: _firstNameController,
            textInputAction: TextInputAction.next,
            validator: (value) =>
                InputValidator.validateName(value, 'First Name'),
          ),
          const Gap(5.0),
          CustomTextFormField(
            hint: 'Last Name',
            controller: _lastNameController,
            textInputAction: TextInputAction.done,
            validator: (value) =>
                InputValidator.validateName(value, 'Last Name'),
          ),
        ],
      ),
    );
  }

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

  Widget _passwordView() {
    return Form(
      key: _passwordFormKey,
      child: CustomTextFormField(
        hint: 'Password',
        controller: _passwordController,
        obscureText: !showPassword,
        textInputAction: TextInputAction.done,
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
        validator: (value) => InputValidator.validatePassword(value),
      ),
    );
  }

  Widget _otpView() {
    final authNotifier = ref.read(authProvider.notifier);
    final isResending = ref.watch(authProvider).isLoading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
              onTap: isResending
                  ? null
                  : () {
                      // Go back to email page (Page 1)
                      _pageController.jumpToPage(1);
                    },
              child: Text(
                'Send to a different email',
                style: TextStyle(
                  decoration: TextDecoration.underline,
                  color: isResending ? AppColors.grey : AppColors.primary,
                  decorationColor: AppColors.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            InkWell(
              onTap: isResending
                  ? null
                  : () async {
                      setState(() {
                        _errorMessage = null;
                      });
                      final success = await authNotifier.resendOtp(
                        _emailController.text,
                      );
                      if (!success) {
                        _showError(
                          ref.read(authProvider).errorMessage ??
                              'Failed to resend OTP',
                        );
                      } else {
                        if (mounted) {
                          CustomSnackbar.show(
                            context,
                            'OTP sent successfully',
                            type: SnackbarType.success,
                          );
                        }
                      }
                    },
              child: Text(
                'Resend OTP',
                style: TextStyle(
                  decoration: isResending ? null : TextDecoration.underline,
                  color: isResending ? AppColors.grey : AppColors.primary,
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
            _handleContinue(); // Auto-continue on OTP completion
          },
        ),
      ],
    );
  }

  Widget _dobView() {
    return Form(
      key: _dobFormKey,
      child: CustomTextFormField(
        hint: 'Date of birth (DD/MM/YYYY)',
        controller: _dobController,
        readOnly: true,
        onTap: () async {
          final initialDate = DateTime.now().subtract(
            const Duration(days: 365 * 18),
          );
          final date = await showDatePicker(
            context: context,
            initialDate: initialDate,
            firstDate: DateTime(1900),
            lastDate: initialDate, // Ensure user is at least 18
            helpText: 'Select Date of Birth',
          );
          if (date != null) {
            setState(() {
              // Format date consistently
              _dobController.text = DateFormatter.formatDateForRequest(date);
            });
          }
        },
        validator: (value) =>
            InputValidator.validateRequired(value, 'Date of birth'),
        suffix: const Icon(Icons.calendar_today_outlined),
      ),
    );
  }

  Widget _countryView() {
    return Form(
      key: _countryFormKey,
      child: CustomTextFormField(
        hint: 'Country of residence',
        controller: _countryController,
        readOnly: true,
        onTap: () async {
          // TODO: For now, we simulate selection to validate the form.
          final selectedCountry = await showModalBottomSheet<String>(
            context: context,
            builder: (_) => _CountryPicker(
              onCountrySelected: (country) => Navigator.pop(context, country),
            ),
          );

          if (selectedCountry != null) {
            setState(() {
              _countryController.text = selectedCountry;
            });
          }
        },
        validator: (value) =>
            InputValidator.validateRequired(value, 'Country of residence'),
        suffix: const Icon(Icons.keyboard_arrow_down),
      ),
    );
  }
}

// Dummy Widget for Country Picker Simulation
class _CountryPicker extends StatelessWidget {
  final Function(String) onCountrySelected;

  const _CountryPicker({required this.onCountrySelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Select Your Country',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Gap(10),
          ListTile(
            title: const Text('United States'),
            onTap: () => onCountrySelected('United States'),
          ),
          ListTile(
            title: const Text('Canada'),
            onTap: () => onCountrySelected('Canada'),
          ),
          ListTile(
            title: const Text('United Kingdom'),
            onTap: () => onCountrySelected('United Kingdom'),
          ),
        ],
      ),
    );
  }
}
