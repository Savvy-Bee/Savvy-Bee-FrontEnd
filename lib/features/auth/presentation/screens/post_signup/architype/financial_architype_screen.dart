import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/assets/app_icons.dart';
import 'package:savvy_bee_mobile/core/utils/assets/logos.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';
import 'package:savvy_bee_mobile/core/utils/custom_page_indicator.dart';
import 'package:savvy_bee_mobile/core/widgets/bottom_sheets/notification_prompt_bottom_sheet.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';
import 'package:savvy_bee_mobile/core/widgets/icon_text_row_widget.dart';
import 'package:savvy_bee_mobile/core/widgets/intro_text.dart';
import 'package:savvy_bee_mobile/features/auth/domain/models/financial_architype_items.dart';
import 'package:savvy_bee_mobile/features/auth/presentation/screens/post_signup/architype/pages/financial_architype_page_five.dart';
import 'package:savvy_bee_mobile/features/auth/presentation/screens/post_signup/architype/pages/financial_architype_page_four.dart';
import 'package:savvy_bee_mobile/features/auth/presentation/screens/post_signup/architype/pages/financial_architype_page_one.dart';
import 'package:savvy_bee_mobile/features/auth/presentation/screens/post_signup/architype/pages/financial_architype_page_six.dart';
import 'package:savvy_bee_mobile/features/auth/presentation/screens/post_signup/architype/pages/financial_architype_page_three.dart';
import 'package:savvy_bee_mobile/features/auth/presentation/screens/post_signup/architype/pages/financial_architype_page_two.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../../../../core/services/service_locator.dart';
import '../../../../../../core/widgets/custom_snackbar.dart';
import '../../../../domain/models/auth_models.dart';
import '../../../providers/architype_providers.dart';

class FinancialArchitypeScreen extends ConsumerStatefulWidget {
  static const String path = '/architype';

  final String? priority;

  const FinancialArchitypeScreen({super.key, this.priority});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _FinancialArchitypeScreenState();
}

class _FinancialArchitypeScreenState
    extends ConsumerState<FinancialArchitypeScreen> {
  final _pageController = PageController();
  final int _totalPages = 6;

  int _currentPage = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Listen to page changes
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
    _pageController.dispose();
    super.dispose();
  }

  // Check if current page has a selection
  bool _isCurrentPageValid() {
    switch (_currentPage) {
      case 0:
        return ref.read(userArchetypeProvider) != null;
      case 1:
        return ref.read(financialPriorityProvider) != null;
      case 2:
        return ref.read(financeManagementProvider) != null;
      case 3:
        return ref.read(confusingTopicProvider) != null;
      case 4:
        return ref.read(financialChallengeProvider) != null;
      case 5:
        return ref.read(financialMotivationProvider) != null;
      default:
        return false;
    }
  }

  // Go to next page or submit on last page
  void _handleNextOrSubmit() {
    if (!_isCurrentPageValid()) {
      CustomSnackbar.show(
        context,
        'Please select an option to continue',
        type: SnackbarType.error,
      );
      return;
    }

    if (_currentPage < _totalPages - 1) {
      _goToNextPage();
    } else {
      _handleProceed();
    }
  }

  // Go to next page
  void _goToNextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // Skip to the end (or handle skip logic as needed)
  void _handleSkip() {
    NotificationPromptBottomSheet.show(context);
  }

  // Clear all selections
  void _clearAllSelections() {
    ref.read(userArchetypeProvider.notifier).state = null;
    ref.read(financialPriorityProvider.notifier).state = null;
    ref.read(financeManagementProvider.notifier).state = null;
    ref.read(confusingTopicProvider.notifier).state = null;
    ref.read(financialChallengeProvider.notifier).state = null;
    ref.read(financialMotivationProvider.notifier).state = null;
  }

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
                Row(
                  spacing: 8,
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
                    Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: IconTextRowWidget(
                        'Skip',
                        AppIcon(AppIcons.arrowRightIcon),
                        reverse: true,
                        textStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        onTap: _isLoading ? null : _handleSkip,
                      ),
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
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
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

  void _handleProceed({bool skipMode = false}) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final userArchetype = ref.read(userArchetypeProvider);
      final financePriority = ref.read(financialPriorityProvider);
      final financeManagement = ref.read(financeManagementProvider);
      final confusingTopic = ref.read(confusingTopicProvider);
      final challenge = ref.read(financialChallengeProvider);
      final motivation = ref.read(financialMotivationProvider);

      final request = PostOnboardRequest(
        whatMatters: widget.priority ?? '',
        userArchetype: userArchetype?.text ?? '',
        financePriorities: financePriority?.text ?? '',
        howFinanceManaged: financeManagement?.text ?? '',
        confusingTopics: confusingTopic?.text ?? '',
        challengesWithYou: challenge?.text ?? '',
        motivatesyou: motivation?.text ?? '',
      );

      final response = await ref
          .read(authRepositoryProvider)
          .postOnboardData(request);

      if (!mounted) return;

      if (response.success) {
        // Clear selections after successful submission
        _clearAllSelections();

        // Navigate to next screen (update this with your actual route)
        // context.goNamed('dashboard'); // or whatever your next screen is

        CustomSnackbar.show(
          context,
          'Profile setup completed successfully!',
          type: SnackbarType.success,
        );
      } else {
        CustomSnackbar.show(
          context,
          response.message,
          //  ?? 'Oops! Please try that again',
          type: SnackbarType.error,
        );
      }
    } catch (e) {
      if (mounted) {
        CustomSnackbar.show(
          context,
          'An error occurred! Please try again',
          type: SnackbarType.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
