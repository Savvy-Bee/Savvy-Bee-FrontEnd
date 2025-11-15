import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/assets/app_icons.dart';
import 'package:savvy_bee_mobile/core/utils/assets/logos.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';
import 'package:savvy_bee_mobile/core/utils/custom_page_indicator.dart';
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

class FinancialArchitypeScreen extends ConsumerStatefulWidget {
  static String path = '/architype';

  const FinancialArchitypeScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _FinancialArchitypeScreenState();
}

class _FinancialArchitypeScreenState
    extends ConsumerState<FinancialArchitypeScreen> {
  final _pageController = PageController();

  int _currentPage = 0;

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
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Go to next page
  void _goToNextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      count: 6,
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
                      textDirection: TextDirection.rtl,
                      textStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        fontFamily: Constants.neulisNeueFontFamily,
                      ),
                      onTap: () {},
                    ),
                  ),
                ],
              ),
              const Gap(16),

              Image.asset(Logos.logo, scale: 1.5),
              const Gap(16),

              IntroText(
                title: FinancialArchitypeItems.items[_currentPage].title,
                isLarge: false,
              ),
              const Gap(16),

              Text(
                FinancialArchitypeItems.items[_currentPage].description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  fontFamily: Constants.neulisNeueFontFamily,
                ),
              ),
              const Gap(24),

              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
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
                  text: 'Next',
                  showArrow: true,
                  onPressed: _goToNextPage,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
