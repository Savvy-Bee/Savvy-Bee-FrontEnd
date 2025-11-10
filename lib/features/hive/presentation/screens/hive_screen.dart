import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/assets/illustrations.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';
import 'package:savvy_bee_mobile/core/widgets/article_card.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';
import 'package:savvy_bee_mobile/core/widgets/outlined_card.dart';
import 'package:savvy_bee_mobile/core/widgets/section_title_widget.dart';
import 'package:savvy_bee_mobile/core/widgets/icon_text_row_widget.dart';
import 'package:savvy_bee_mobile/features/hive/presentation/screens/lesson_home_screen.dart';

import '../../../../core/utils/assets/app_icons.dart';

class HiveScreen extends ConsumerStatefulWidget {
  static String path = '/hive';

  const HiveScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HiveScreenState();
}

class _HiveScreenState extends ConsumerState<HiveScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SectionTitleWidget(title: 'Explore courses'),
          const Gap(16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              spacing: 8,
              children: List.generate(
                3,
                (index) => _buildCourseCard(
                  title: 'Savings 101',
                  bodyText:
                      'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
                  lessonCount: 5,
                  difficultyLevel: 'Beginner-friendly',
                  onStartLesson: () => context.pushNamed(LessonHomeScreen.path),
                ),
              ),
            ),
          ),
          const Gap(24),
          SectionTitleWidget(title: 'Recent insights'),
          const Gap(16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              spacing: 8,
              children: List.generate(
                3,
                (index) => ArticleCard(
                  title: 'Should you save financially with your partner?',
                  backgroundColor: AppColors.primary,
                  imagePath: Illustrations.matchingAndQuizBee,
                  subtitle: "Let's get financially intimate",
                  onTap: () {},
                ),
              ),
            ),
          ),
          const Gap(24),
          SectionTitleWidget(title: 'Arcade'),
          const Gap(16),
        ],
      ),
    );
  }

  Widget _buildCourseCard({
    required String title,
    required String bodyText,
    required int lessonCount,
    required String difficultyLevel,
    required VoidCallback onStartLesson,
  }) {
    return OutlinedCard(
      width: MediaQuery.sizeOf(context).width / 1.3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              fontFamily: Constants.neulisNeueFontFamily,
            ),
          ),
          const Gap(24),
          Text(bodyText, style: TextStyle()),
          const Gap(24),
          Row(
            spacing: 8,
            children: [
              IconTextRowWidget(
                '$lessonCount Lessons',
                AppIcon(AppIcons.openBookIcon, size: 16.0),
              ),
              IconTextRowWidget(
                difficultyLevel,
                AppIcon(AppIcons.chartIncreasingIcon, size: 16.0),
              ),
            ],
          ),
          const Gap(24),
          CustomElevatedButton(
            text: 'Start lesson',
            rounded: true,
            icon: Icon(Icons.play_arrow_rounded, color: AppColors.black),
            onPressed: onStartLesson,
          ),
        ],
      ),
    );
  }
}
