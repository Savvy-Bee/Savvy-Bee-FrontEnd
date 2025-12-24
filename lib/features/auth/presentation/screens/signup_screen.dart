import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/date_formatter.dart';
import 'package:savvy_bee_mobile/core/utils/date_time_utils.dart';
import 'package:savvy_bee_mobile/core/utils/input_validator.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_dropdown_button.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_input_field.dart';
import 'package:savvy_bee_mobile/core/widgets/intro_text.dart';
import 'package:savvy_bee_mobile/core/widgets/password_requirement_widget.dart';
import 'package:savvy_bee_mobile/features/auth/domain/models/auth_models.dart';
import 'package:savvy_bee_mobile/features/auth/presentation/providers/auth_providers.dart';
import 'package:savvy_bee_mobile/features/auth/domain/models/signup_items.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../../core/utils/assets/logos.dart';
import '../../../../core/utils/custom_page_indicator.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import 'post_signup/signup_complete_screen.dart';

class IncompleteSignUpData {
  final String email;
  final int pageIndex;

  IncompleteSignUpData({required this.email, required this.pageIndex});
}

class SignupScreen extends ConsumerStatefulWidget {
  static String path = '/signup-name';

  final IncompleteSignUpData? incompleteSignUpData;

  const SignupScreen({super.key, this.incompleteSignUpData});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _pageController = PageController();

  // Form keys for step-specific validation
  final _nameFormKey = GlobalKey<FormState>();
  final _emailFormKey = GlobalKey<FormState>();
  final _usernameFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();
  // Note: OTP uses its own field logic, so no FormKey needed for that view.
  final _dobFormKey = GlobalKey<FormState>();
  final _countryFormKey = GlobalKey<FormState>();
  final _languageFormKey = GlobalKey<FormState>();
  final _currencyFormKey = GlobalKey<FormState>();

  // Form controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _otpController = TextEditingController();
  final _dobController = TextEditingController();
  final _countryController = TextEditingController();
  final _languageController = TextEditingController();
  final _currencyController = TextEditingController();

  int _currentPage = 0;
  final int _dotCount = 9;

  bool showPassword = false;

  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    // Listen to page changes to clear error messages
    _pageController.addListener(() {
      final newPage = _pageController.page?.round() ?? 0;
      if (newPage != _currentPage) {
        setState(() {
          _currentPage = newPage;
        });
      }
    });

    // This listener triggers whenever the focus changes
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        // We add a small delay to allow the keyboard animation to complete or start
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted && _focusNode.context != null) {
            Scrollable.ensureVisible(
              _focusNode.context!,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              // alignmentPolicy allows us to position the field nicely in the view
              alignmentPolicy: ScrollPositionAlignmentPolicy.explicit,
              alignment: 0.5, // 0.5 attempts to center the field on screen
            );
          }
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final data = widget.incompleteSignUpData;
      if (data == null) return;

      // Jump to the saved page without animation on first load
      if (data.pageIndex < _dotCount) {
        _pageController.jumpToPage(data.pageIndex);
        _currentPage = data.pageIndex;
      }

      // Pre-fill email only if non-empty
      if (data.email.isNotEmpty) {
        _emailController.text = data.email;
      }

      // Send OTP if on the OTP verification page
      if (widget.incompleteSignUpData != null &&
          widget.incompleteSignUpData?.pageIndex == 4) {
        _sendOtp();
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

    _scrollController.dispose();
    _focusNode.dispose();

    super.dispose();
  }

  // --- Core Navigation and Submission Logic ---

  void _goToPreviousPage() {
    if (widget.incompleteSignUpData != null) return;

    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _sendOtp() async {
    final authNotifier = ref.read(authProvider.notifier);
    final authState = ref.read(authProvider);

    if (_emailFormKey.currentState!.validate()) {
      final success = await authNotifier.resendOtp(
        _emailController.text.trim(),
      );

      if (success) {
        if (mounted) {
          CustomSnackbar.show(
            context,
            'OTP sent successfully',
            type: SnackbarType.success,
          );
        }
      } else {
        _showError(authState.errorMessage ?? 'Failed to send OTP');
      }
    }
  }

  void _goToNextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _showError(String message) {
    CustomSnackbar.show(context, message, type: SnackbarType.error);
  }

  void _handleContinue() async {
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
          // Page 2: Username Input
          if (_usernameFormKey.currentState!.validate()) {
            _goToNextPage();
          }
          break;

        case 3:
          // Page 3: Password Input & API Registration
          if (!_passwordFormKey.currentState!.validate()) return;

          final request = RegisterRequest(
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
            username: _usernameController.text.trim(),
          );

          final success = await authNotifier.register(request);

          if (success) {
            _goToNextPage();
          } else {
            _showError(authState.errorMessage ?? 'Registration failed');
          }
          break;

        case 4:
          // Page 4: OTP Verification
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

        case 5:
          // Page 5: Date of Birth Input
          if (_dobFormKey.currentState!.validate()) {
            _goToNextPage();
          }
          break;
        case 6:
          // Page 6: Date of Birth Input
          if (_countryFormKey.currentState!.validate()) {
            _goToNextPage();
          }
          break;
        case 7:
          // Page 7: Date of Birth Input
          if (_languageFormKey.currentState!.validate()) {
            _goToNextPage();
          }
          break;

        case 8:
          // Page 8: Country Input & Final Profile Update
          if (!_currencyFormKey.currentState!.validate()) return;

          // Register Other Details with DOB and Country
          final registerOtherDetailsRequest = RegisterOtherDetailsRequest(
            email: _emailController.text,
            dob: _dobController.text,
            country: _countryController.text,
            currency: _currencyController.text,
            language: _languageController.text,
          );

          final success = await authNotifier.registerOtherDetails(
            registerOtherDetailsRequest,
          );

          // context.pushNamed(SignupCompleteScreen.path);
          if (success) {
            // Final success, navigate to completion screen
            if (mounted) {
              context.pushReplacementNamed(
                SignupCompleteScreen.path,
                extra: SignupCompleteScreenType.signup,
              );
            }
          } else {
            _showError(
              authState.errorMessage ?? 'Failed to register other details',
            );
          }
          // context.pushNamed(SignupCompleteScreen.path);
          break;

        default:
          // Should not happen, but safe fallback
          break;
      }
    } catch (e) {
      // Catch any synchronous errors during validation or navigation
      _showError('An unexpected error occurred.');
      log('Error in _handleContinue: $e');
    }
  }

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

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
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

            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Gap(24.0),
                    Image.asset(Logos.logo, scale: 3),
                    const Gap(24.0),
                    IntroText(
                      title: SignupItems.items[_currentPage].title,
                      subtitle: _getPageSubtitle(),
                    ),
                    const Gap(20.0),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.4,
                      child: PageView(
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _nameView(),
                          _emailView(),
                          _usernameView(),
                          _passwordView(),
                          _otpView(),
                          _dobView(),
                          _countryView(),
                          _languageView(),
                          _currencyView(),
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
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0).copyWith(bottom: 32),
        child: CustomElevatedButton(
          text: 'Continue',
          isLoading: authState.isLoading,
          onPressed: _handleContinue,
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
            label: 'First name',
            hint: 'First Name',
            controller: _firstNameController,
            textInputAction: TextInputAction.next,
            validator: (value) =>
                InputValidator.validateName(value, 'First name'),
          ),
          const Gap(16.0),
          CustomTextFormField(
            label: 'Last name',
            hint: 'Last Name',
            controller: _lastNameController,
            textInputAction: TextInputAction.done,
            validator: (value) =>
                InputValidator.validateName(value, 'Last name'),
          ),
        ],
      ),
    );
  }

  Widget _emailView() {
    return Form(
      key: _emailFormKey,
      child: CustomTextFormField(
        label: 'Email address',
        hint: 'Email address',
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        validator: (value) => InputValidator.validateEmail(value),
      ),
    );
  }

  Widget _usernameView() {
    return Form(
      key: _usernameFormKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: CustomTextFormField(
        label: 'Username',
        hint: 'Username',
        controller: _usernameController,
        textInputAction: TextInputAction.done,
        validator: (value) => InputValidator.validateUsername(value),
      ),
    );
  }

  Widget _passwordView() {
    return Form(
      key: _passwordFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextFormField(
            label: 'Password',
            hint: 'Password',
            controller: _passwordController,
            obscureText: !showPassword,
            textInputAction: TextInputAction.done,
            suffixIcon: IconButton(
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
            onChanged: (_) {
              setState(() {});
            },
            validator: (value) => InputValidator.validatePassword(value),
          ),
          const Gap(24),
          PasswordRequirementWidget(password: _passwordController.text.trim()),
        ],
      ),
    );
  }

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

  Widget _dobView() {
    return Form(
      key: _dobFormKey,
      child: CustomTextFormField(
        hint: 'Date of birth (DD/MM/YYYY)',
        controller: _dobController,
        readOnly: true,
        onTap: () async {
          final initialDate = DateTime.now().subtract(
            const Duration(days: 365 * 16),
          );
          final date = await DateTimeUtils.pickDate(
            context,
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
        suffixIcon: const Icon(Icons.calendar_today_outlined),
      ),
    );
  }

  Widget _countryView() {
    return Form(
      key: _countryFormKey,
      child: CustomDropdownButton(
        hint: 'Country of residence',
        items: [
          'Nigeria',
          'United States of America',
          'United Kindom',
          'Canada',
        ],
        onChanged: (value) {
          setState(() {
            _countryController.text = value ?? '';
          });
        },
      ),
    );
  }

  Widget _languageView() {
    return Form(
      key: _languageFormKey,
      child: CustomDropdownButton(
        hint: 'Preferred language',
        items: ['English', 'Español', 'Français', 'Deutsch', 'Português'],
        onChanged: (value) {
          setState(() {
            _languageController.text = value ?? '';
          });
        },
      ),
    );
  }

  Widget _currencyView() {
    return Form(
      key: _currencyFormKey,
      child: CustomDropdownButton(
        hint: 'Preferred currency',
        items: [
          'Nigerian Naira (NGN)',
          'US Dollar (USD)',
          'Euro (EUR)',
          'British Pound (GBP)',
          'Japanese Yen (JPY)',
          'Canadian Dollar (CAD)',
          'Australian Dollar (AUD)',
          'Swiss Franc (CHF)',
          'Chinese Yuan (CNY)',
          'Indian Rupee (INR)',
        ],
        onChanged: (value) {
          setState(() {
            _currencyController.text = value ?? '';
          });
        },
      ),
    );
  }
}
