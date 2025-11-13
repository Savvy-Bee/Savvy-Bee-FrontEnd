import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/assets/illustrations.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';
import 'package:savvy_bee_mobile/core/widgets/article_card.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';
import 'package:savvy_bee_mobile/core/widgets/section_title_widget.dart';
import 'package:savvy_bee_mobile/core/widgets/icon_text_row_widget.dart';
import 'package:savvy_bee_mobile/features/hive/presentation/screens/lesson_home_screen.dart';

import '../../../../core/utils/assets/app_icons.dart';
import '../../../../core/widgets/custom_card.dart';

class HiveScreen extends ConsumerStatefulWidget {
  static String path = '/hive';

  const HiveScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HiveScreenState();
}

class _HiveScreenState extends ConsumerState<HiveScreen> {
  final List<Map<String, dynamic>> insights = [
    {
      'title': 'Should you save financially with your partner?',
      'subtitle': 'Let\'s get financially intimate',
      'imagePath': Illustrations.matchingAndQuizBee,
      'color': AppColors.primary,
    },
    {
      'title': 'How to build an emergency fund on a tight budget',
      'subtitle': 'Small steps, big safety net',
      'imagePath': Illustrations.savingsBeePose2,
      'color': AppColors.success,
    },
    {
      'title': 'Investing vs. saving: which is right for you?',
      'subtitle': 'Understanding your financial goals',
      'imagePath': Illustrations.interestBee,
      'color': AppColors.bgBlue,
    },
    {
      'title': 'Smart spending: needs vs. wants',
      'subtitle': 'Make every dollar count',
      'imagePath': Illustrations.familyBee,
      'color': AppColors.primary,
    },
    {
      'title': 'Side-hustle starter guide',
      'subtitle': 'Turn skills into extra income',
      'imagePath': Illustrations.matchingAndQuizBee,
      'color': AppColors.purple,
    },
  ];

  final List<Map<String, String>> courses = [
    {
      'title': 'Savings 101',
      'bodyText':
          'Master the fundamentals of saving money, from setting goals to building emergency funds.',
      'lessonCount': '5',
      'difficultyLevel': 'Beginner-friendly',
    },
    {
      'title': 'Budgeting Basics',
      'bodyText':
          'Learn how to create and stick to a budget that works for your lifestyle and goals.',
      'lessonCount': '7',
      'difficultyLevel': 'Beginner-friendly',
    },
    {
      'title': 'Investing Intro',
      'bodyText':
          'Discover the basics of investing and how to make your money work for you.',
      'lessonCount': '6',
      'difficultyLevel': 'Intermediate',
    },
    {
      'title': 'Debt Management',
      'bodyText':
          'Understand how to tackle debt strategically and avoid common pitfalls.',
      'lessonCount': '4',
      'difficultyLevel': 'Beginner-friendly',
    },
    {
      'title': 'Credit Scores',
      'bodyText':
          'Learn what affects your credit score and how to improve it over time.',
      'lessonCount': '5',
      'difficultyLevel': 'Beginner-friendly',
    },
    {
      'title': 'Emergency Funds',
      'bodyText':
          'Build a safety net that protects you from unexpected financial shocks.',
      'lessonCount': '3',
      'difficultyLevel': 'Beginner-friendly',
    },
    {
      'title': 'Retirement Planning',
      'bodyText':
          'Start planning early for retirement with the right accounts and strategies.',
      'lessonCount': '8',
      'difficultyLevel': 'Intermediate',
    },
    {
      'title': 'Tax Basics',
      'bodyText':
          'Navigate the essentials of income tax and maximize your deductions.',
      'lessonCount': '6',
      'difficultyLevel': 'Intermediate',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Hi Danny!',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.more_vert_rounded)),
        ],
      ),
      body: SafeArea(
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: SectionTitleWidget(title: 'Explore courses'),
            ),
            const Gap(16),
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8,
                children: courses
                    .map(
                      (course) => _buildCourseCard(
                        title: course['title']!,
                        bodyText: course['bodyText']!,
                        lessonCount: int.parse(course['lessonCount']!),
                        difficultyLevel: course['difficultyLevel']!,
                        onStartLesson: () =>
                            context.pushNamed(LessonHomeScreen.path),
                      ),
                    )
                    .toList(),
              ),
            ),
            const Gap(24),
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: SectionTitleWidget(title: 'Recent insights'),
            ),
            const Gap(16),
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              child: Row(
                spacing: 8,
                children: insights
                    .map(
                      (insight) => ArticleCard(
                        title: insight['title']!,
                        backgroundColor: insight['color'],
                        imagePath: insight['imagePath']!,
                        subtitle: insight['subtitle']!,
                        onTap: () {},
                      ),
                    )
                    .toList(),
              ),
            ),
            const Gap(24),
            // SectionTitleWidget(title: 'Arcade'),
            const Gap(16),
          ],
        ),
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
    return CustomCard(
      width: MediaQuery.sizeOf(context).width / 1.3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: Constants.neulisNeueFontFamily,
            ),
          ),
          const Gap(8),
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
          // const Gap(24),
          Image.asset(Illustrations.savingsBeePose1),
          // const Gap(24),
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
