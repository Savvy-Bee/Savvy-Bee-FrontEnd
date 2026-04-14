import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/assets/app_icons.dart';
import 'package:savvy_bee_mobile/core/utils/assets/logos.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';
import 'package:savvy_bee_mobile/core/utils/custom_page_indicator.dart';
import 'package:savvy_bee_mobile/core/widgets/icon_text_row_widget.dart';
import 'package:savvy_bee_mobile/core/widgets/intro_text.dart';
import 'package:savvy_bee_mobile/features/auth/domain/models/financial_architype_items.dart';
import 'package:savvy_bee_mobile/features/auth/presentation/screens/login_screen.dart';
import 'package:savvy_bee_mobile/features/auth/presentation/screens/post_signup/architype/pages/financial_architype_page_five.dart';
import 'package:savvy_bee_mobile/features/auth/presentation/screens/post_signup/architype/pages/financial_architype_page_four.dart';
import 'package:savvy_bee_mobile/features/auth/presentation/screens/post_signup/architype/pages/financial_architype_page_one.dart';
import 'package:savvy_bee_mobile/features/auth/presentation/screens/post_signup/architype/pages/financial_architype_page_six.dart';
import 'package:savvy_bee_mobile/features/auth/presentation/screens/post_signup/architype/pages/financial_architype_page_three.dart';
import 'package:savvy_bee_mobile/features/auth/presentation/screens/post_signup/architype/pages/financial_architype_page_two.dart';
import 'package:savvy_bee_mobile/features/home/presentation/providers/home_data_provider.dart';
import 'package:savvy_bee_mobile/features/home/presentation/screens/home_screen.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../../../../core/services/device_info_service.dart';
import '../../../../../../core/widgets/custom_snackbar.dart';
import '../../../../domain/models/auth_models.dart';
import '../../../providers/architype_providers.dart';
import '../../../providers/auth_providers.dart';
import '../../../providers/post_onboarding_provider.dart';

// ─── Route args ──────────────────────────────────────────────────────────────

/// Passed as go_router `extra` when navigating to [FinancialArchitypeScreen].
class FinancialArchitypeArgs {
  /// The "what matters most" priority selected on the previous screen.
  final String? priority;

  /// When true the screen was opened from the profile page.
  /// After completion or skip, pop back to profile instead of going home.
  final bool fromProfile;

  const FinancialArchitypeArgs({this.priority, this.fromProfile = false});
}

// ─── Screen ──────────────────────────────────────────────────────────────────

class FinancialArchitypeScreen extends ConsumerStatefulWidget {
  static const String path = '/architype';

  /// Kept for backward-compat with any existing `extra: String?` call sites.
  /// New code should pass [FinancialArchitypeArgs] instead.
  final String? priority;
  final bool fromProfile;

  const FinancialArchitypeScreen({
    super.key,
    this.priority,
    this.fromProfile = false,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _FinancialArchitypeScreenState();
}

class _FinancialArchitypeScreenState
    extends ConsumerState<FinancialArchitypeScreen> {
  final _pageController = PageController();
  static const int _totalPages = 6;

  int _currentPage = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      final newPage = _pageController.page?.round() ?? 0;
      if (newPage != _currentPage) {
        setState(() => _currentPage = newPage);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // ─── Validation ─────────────────────────────────────────────────────────────

  bool _isCurrentPageValid() {
    switch (_currentPage) {
      case 0:
        return ref.read(userArchetypeProvider) != null;
      case 1:
        return ref.read(financialPrioritiesProvider).isNotEmpty;
      case 2:
        return ref.read(financeManagementProvider) != null;
      case 3:
        return ref.read(confusingTopicsProvider).isNotEmpty;
      case 4:
        return ref.read(financialChallengesProvider).isNotEmpty;
      case 5:
        return ref.read(financialMotivationsProvider).isNotEmpty;
      default:
        return false;
    }
  }

  // ─── Navigation ─────────────────────────────────────────────────────────────

  void _handleNextOrSubmit() {
    if (!_isCurrentPageValid()) {
      CustomSnackbar.show(
        context,
        'Please select at least one option to continue',
        type: SnackbarType.error,
      );
      return;
    }

    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _submitOnboarding();
    }
  }

  // ─── Skip ───────────────────────────────────────────────────────────────────
  //
  // Skipping does NOT mark onboarding as complete — the profile card will
  // remain visible so the user can return any time.

  void _handleSkip() {
    _clearAllSelections();
    if (widget.fromProfile) {
      // Pop this screen, then pop SelectPriorityScreen underneath it.
      Navigator.of(context).pop();
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    } else {
      context.goNamed(HomeScreen.path);
    }
  }

  // ─── Submission ─────────────────────────────────────────────────────────────

  Future<void> _submitOnboarding() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final user = ref.read(currentUserProvider);
      final email = user?.email;

      if (email == null || email.isEmpty) {
        throw Exception('No user email found. Please log in again.');
      }

      final request = PostOnboardRequest(
        email: email,
        whatMatters: widget.priority ?? '',
        userArchetype: ref.read(userArchetypeProvider)?.text ?? '',
        financePriorities: ref
            .read(financialPrioritiesProvider)
            .map((e) => e.text)
            .join(', '),
        howFinanceManaged: ref.read(financeManagementProvider)?.text ?? '',
        confusingTopics: ref
            .read(confusingTopicsProvider)
            .map((e) => e.text)
            .join(', '),
        challengesWithYou: ref
            .read(financialChallengesProvider)
            .map((e) => e.text)
            .join(', '),
        motivatesyou: ref
            .read(financialMotivationsProvider)
            .map((e) => e.text)
            .join(', '),
      );

      final success =
          await ref.read(authProvider.notifier).postOnboardData(request);

      if (!mounted) return;

      if (success) {
        _clearAllSelections();

        // Mark locally so the profile card disappears.
        await ref.read(postOnboardingProvider.notifier).markCompleted();

        if (!mounted) return;

        if (widget.fromProfile) {
          // Came from profile — go back and refresh.
          ref.invalidate(homeDataProvider);
          context.pop();
          CustomSnackbar.show(
            context,
            'Financial profile complete!',
            type: SnackbarType.success,
          );
          return;
        }

        // Came from the signup/login flow — auto-login with stored credentials.
        final credentials = ref.read(signupCredentialsProvider);
        ref.read(signupCredentialsProvider.notifier).state = null;

        if (credentials != null) {
          try {
            final deviceId = await DeviceInfoService.getDeviceId();
            if (!mounted) return;
            final loginResponse = await ref.read(authProvider.notifier).login(
                  credentials.email,
                  credentials.password,
                  deviceId,
                );
            if (!mounted) return;
            if (loginResponse != null && loginResponse.success) {
              context.goNamed(HomeScreen.path);
              return;
            }
          } catch (_) {}
        }

        if (mounted) context.goNamed(LoginScreen.path);
      } else {
        final errorMsg = ref.read(authProvider).errorMessage;
        CustomSnackbar.show(
          context,
          errorMsg ?? 'Failed to complete setup. Please try again.',
          type: SnackbarType.error,
        );
      }
    } catch (e) {
      if (mounted) {
        CustomSnackbar.show(
          context,
          'An error occurred: ${e.toString()}',
          type: SnackbarType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _clearAllSelections() {
    ref.read(userArchetypeProvider.notifier).state = null;
    ref.read(financialPrioritiesProvider.notifier).state = const [];
    ref.read(financeManagementProvider.notifier).state = null;
    ref.read(confusingTopicsProvider.notifier).state = const [];
    ref.read(financialChallengesProvider.notifier).state = const [];
    ref.read(financialMotivationsProvider.notifier).state = const [];
  }

  // ─── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == _totalPages - 1;

    return PopScope(
      canPop: _currentPage == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _currentPage > 0) {
          _pageController.previousPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // ── Progress + Skip row ──────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: SmoothPageIndicator(
                        controller: _pageController,
                        count: _totalPages,
                        effect: PreviousColoredSlideEffect(
                          dotHeight: 4.0,
                          spacing: 5,
                          activeDotColor: AppColors.primary,
                          dotColor: AppColors.grey,
                        ),
                      ),
                    ),
                    const Gap(8),
                    IconTextRowWidget(
                      'Skip',
                      AppIcon(AppIcons.arrowRightIcon),
                      reverse: true,
                      textStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'GeneralSans',
                        letterSpacing: 12 * 0.02,
                      ),
                      onTap: _isLoading ? null : _handleSkip,
                    ),
                  ],
                ),
                const Gap(40),

                Image.asset(Logos.logo, scale: 4),
                const Gap(16),

                IntroText(
                  title: FinancialArchitypeItems.items[_currentPage].title,
                  isLarge: false,
                ),
                const Gap(16),

                Text(
                  FinancialArchitypeItems.items[_currentPage].description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'GeneralSans',
                    letterSpacing: 14 * 0.02,
                  ),
                ),
                const Gap(24),

                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: const [
                      FinancialArchitypePageOne(),
                      FinancialArchitypePageTwo(),
                      FinancialArchitypePageThree(),
                      FinancialArchitypePageFour(),
                      FinancialArchitypePageFive(),
                      FinancialArchitypePageSix(),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: CustomElevatedButton(
                    text: isLastPage ? 'Complete' : 'Next',
                    showArrow: !isLastPage,
                    isLoading: _isLoading,
                    onPressed: _isLoading ? null : _handleNextOrSubmit,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
