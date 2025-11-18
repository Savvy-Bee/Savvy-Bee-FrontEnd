import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/assets/app_icons.dart';
import '../../../../../core/utils/assets/assets.dart';
import '../../../../../core/utils/constants.dart';
import '../../../../../core/utils/custom_page_indicator.dart';
import '../../widgets/lesson_card.dart';

class LessonRoomScreen extends ConsumerStatefulWidget {
  static String path = '/lesson-room';

  const LessonRoomScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _LessonRoomScreenState();
}

class _LessonRoomScreenState extends ConsumerState<LessonRoomScreen> {
  final _pageController = PageController();

  final int _dotCount = 6;
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

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    const double spacingValue = 5.0;
    const double horizontalPadding = 16.0;

    // Calculate dynamic dot width for responsive page indicator
    final double availableWidth = screenWidth - (7 * horizontalPadding);
    final double totalSpacing = (_dotCount - 1) * spacingValue;
    final double availableWidthForDots = availableWidth - totalSpacing;
    final double calculatedDotWidth = availableWidthForDots / _dotCount;

    return Scaffold(
      backgroundColor: AppColors.blue,
      // extendBodyBehindAppBar: true,
      appBar: _buildAppBar(calculatedDotWidth, spacingValue, horizontalPadding),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(Assets.quizzesBg),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: LessonCard(
              superscript: 'Highlight',
              isHighlight: true,
              // title: 'There are different ways to save money:',
              // image: Assets.shareUsernameBg,
              // bodyText:
              //     'Saving money is an important habit that helps you prepare for future needs. Choosing the right saving method can keep your money safe and help it grow over time.',
              enumeratedItems: [
                'Bank savings accounts protect your money and may even earn interest.',
                'Savings apps help track and automate savings, making it easier to reach your goals.',
                "Piggy banks are useful for short-term savings, but they don't keep money as secure as a bank.",
              ],
            ),
            // child: Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            //   child: Column(
            //     mainAxisSize: MainAxisSize.min,
            //     children: [
            //       Container(
            //         width: double.maxFinite,
            //         padding: const EdgeInsets.all(16),
            //         decoration: BoxDecoration(
            //           color: AppColors.white,
            //           borderRadius: BorderRadius.circular(16),
            //         ),
            //         child: Column(
            //           crossAxisAlignment: CrossAxisAlignment.start,
            //           mainAxisSize: MainAxisSize.min,
            //           children: [
            //             Row(
            //               mainAxisSize: MainAxisSize.min,
            //               children: [_buildLessonTitle('What is saving?')],
            //             ),
            //             const Gap(16),
            //             Text(
            //               'Saving money is an important habit that helps you prepare for future needs. Choosing the right saving method can keep your money safe and help it grow over time.',
            //               style: TextStyle(
            //                 fontSize: 16,
            //                 fontWeight: FontWeight.w500,
            //                 fontFamily: Constants.neulisNeueFontFamily,
            //               ),
            //             ),
            //             const Gap(16),
            //             SizedBox(
            //               height: 200,
            //               width: double.maxFinite,
            //               child: ClipRRect(
            //                 borderRadius: BorderRadius.circular(16),
            //                 child: Image.asset(
            //                   Assets.shareUsernameBg,
            //                   fit: BoxFit.cover,
            //                 ),
            //               ),
            //             ),
            //           ],
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
          ),
          _buildControls(),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton.filled(
            onPressed: () {},
            icon: AppIcon(AppIcons.shareIcon, color: AppColors.primary),
            style: IconButton.styleFrom(backgroundColor: AppColors.background),
          ),
          Row(
            spacing: 8,
            children: [
              IconButton.filled(
                onPressed: () {},
                icon: Icon(
                  Icons.keyboard_arrow_left_rounded,
                  color: AppColors.primary,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.background,
                ),
              ),
              IconButton.filled(
                onPressed: () {},
                icon: Icon(
                  Icons.keyboard_arrow_right_rounded,
                  color: AppColors.primary,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.background,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar(
    double calculatedDotWidth,
    double spacingValue,
    double horizontalPadding,
  ) {
    return AppBar(
      backgroundColor: AppColors.blue,
      centerTitle: false,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.movie),
            iconSize: 18,
            style: Constants.collapsedButtonStyle,
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.bookmark_outline),
            iconSize: 18,
            style: Constants.collapsedButtonStyle,
          ),
          SmoothPageIndicator(
            controller: _pageController,
            count: _dotCount,
            effect: PreviousColoredSlideEffect(
              dotHeight: 3,
              dotWidth: calculatedDotWidth,
              spacing: spacingValue,
              activeDotColor: AppColors.white,
              dotColor: AppColors.white.withValues(alpha: 0.5),
            ),
          ),
          IconButton(
            onPressed: () => context.pop(),
            icon: Icon(Icons.close),
            iconSize: 18,
            style: Constants.collapsedButtonStyle,
          ),
        ],
      ),
    );
  }
}
