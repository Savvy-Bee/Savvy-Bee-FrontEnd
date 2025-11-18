import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/assets/illustrations.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';
import 'package:savvy_bee_mobile/core/utils/custom_page_indicator.dart';

class QuizHeader extends StatelessWidget {
  final PageController pageController;
  final int quizCount;
  final int score;

  const QuizHeader({
    super.key,
    required this.pageController,
    required this.quizCount,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () => context.pop(),
          icon: Icon(Icons.close),
          style: Constants.collapsedButtonStyle,
        ),
        Expanded(
          child: SmoothPageIndicator(
            controller: pageController,
            count: quizCount,
            effect: PreviousColoredSlideEffect(
              dotHeight: 4.0,
              spacing: 2,
              activeDotColor: AppColors.primary,
              dotColor: AppColors.primaryFaded,
            ),
          ),
        ),
        const Gap(5),
        Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 4,
          children: [
            Image.asset(Illustrations.hiveFlower, scale: 1.2),
            Text(
              '$score',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: Constants.neulisNeueFontFamily,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
