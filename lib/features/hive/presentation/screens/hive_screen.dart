import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/assets/assets.dart';
import 'package:savvy_bee_mobile/core/utils/assets/illustrations.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';
import 'package:savvy_bee_mobile/core/widgets/article_card.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';
import 'package:savvy_bee_mobile/core/widgets/section_title_widget.dart';
import 'package:savvy_bee_mobile/core/widgets/icon_text_row_widget.dart';
import 'package:savvy_bee_mobile/features/hive/domain/models/course.dart';
import 'package:savvy_bee_mobile/features/hive/presentation/screens/leaderboard/leaderboard_screen.dart';
import 'package:savvy_bee_mobile/features/hive/presentation/screens/lesson/lesson_home_screen.dart';
import 'package:savvy_bee_mobile/features/hive/presentation/screens/streak/streak_dashboard_screen.dart';
import 'package:savvy_bee_mobile/features/hive/presentation/providers/course_providers.dart';
import 'package:savvy_bee_mobile/features/profile/presentation/screens/profile_screen.dart';

import '../../../../core/utils/assets/app_icons.dart';
import '../../../../core/widgets/custom_card.dart';
import '../providers/hive_provider.dart';

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
      'color': AppColors.blue,
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

  @override
  void initState() {
    super.initState();
    // Fetch hive data when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(hiveNotifierProvider.notifier).fetchHiveDetails();
    });
  }

  @override
  Widget build(BuildContext context) {
    final coursesAsync = ref.watch(allCoursesProvider);
    final hiveAsync = ref.watch(hiveNotifierProvider);

    return Scaffold(
      appBar: _buildAppBar(hiveAsync),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await ref.read(hiveNotifierProvider.notifier).refreshAll();
            ref.invalidate(allCoursesProvider);
          },
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: SectionTitleWidget(title: 'Explore courses'),
              ),
              const Gap(16),
              coursesAsync.when(
                data: (courses) => _buildCoursesSection(courses),
                loading: () => _buildLoadingSection(),
                error: (error, stack) => _buildErrorSection(error),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoursesSection(List<Course> courses) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: courses
            .map((course) => _buildCourseCard(course: course))
            .toList(),
      ),
    );
  }

  Widget _buildLoadingSection() {
    return Container(
      height: 400,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            const Gap(16),
            Text(
              'Loading courses...',
              style: TextStyle(color: AppColors.greyDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorSection(Object error) {
    return Container(
      height: 400,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const Gap(16),
            Text(
              'Failed to load courses',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Gap(8),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.greyDark),
            ),
            const Gap(16),
            CustomElevatedButton(
              text: 'Retry',
              onPressed: () {
                ref.invalidate(allCoursesProvider);
              },
            ),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(AsyncValue<HiveState> hiveAsync) {
    return AppBar(
      title: Text(
        'Hi Danny!',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      centerTitle: false,
      actions: [
        // Flowers count
        hiveAsync.when(
          data: (hiveState) => _buildActionButton(
            icon: Image.asset(Illustrations.hiveFlower),
            text: '${hiveState.hiveData?.flowers ?? 0}',
            onTap: () => context.pushNamed(ProfileScreen.path),
          ),
          loading: () => _buildActionButton(
            icon: Image.asset(Illustrations.hiveFlower),
            text: '...',
          ),
          error: (_, __) => _buildActionButton(
            icon: Image.asset(Illustrations.hiveFlower),
            text: '0',
          ),
        ),
        const Gap(4),
        // Streak count
        hiveAsync.when(
          data: (hiveState) => _buildActionButton(
            icon: Icon(Icons.hive, size: 20, color: AppColors.primary),
            text: '${hiveState.hiveData?.streak ?? 0}',
            onTap: () => context.pushNamed(StreakDashboardScreen.path),
          ),
          loading: () => _buildActionButton(
            icon: Icon(Icons.hive, size: 20, color: AppColors.primary),
            text: '...',
            onTap: () => context.pushNamed(StreakDashboardScreen.path),
          ),
          error: (_, __) => _buildActionButton(
            icon: Icon(Icons.hive, size: 20, color: AppColors.primary),
            text: '0',
            onTap: () => context.pushNamed(StreakDashboardScreen.path),
          ),
        ),
        const Gap(4),
        // Trophy/Leaderboard
        _buildActionButton(
          icon: Image.asset(Assets.trophy, height: 20, width: 20),
          onTap: () => context.pushNamed(LeaderboardScreen.path),
        ),
        const Gap(12),
      ],
    );
  }

  Widget _buildActionButton({
    required Widget icon,
    String? text,
    VoidCallback? onTap,
  }) {
    return CustomCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      borderColor: AppColors.greyMid,
      child: Row(
        spacing: 4,
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          if (text != null && text.isNotEmpty)
            Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: Constants.neulisNeueFontFamily,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCourseCard({required Course course}) {
    final stats = ref.watch(courseStatsProvider(course));
    final difficultyLevel = _extractDifficultyLevel(course);

    return CustomCard(
      width: MediaQuery.sizeOf(context).width / 1.3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Progress indicator if course is started
          if (stats.isStarted && !stats.isCompleted)
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: stats.progressPercentage / 100,
                        backgroundColor: AppColors.greyLight,
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const Gap(8),
                    Text(
                      '${stats.progressPercentage.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const Gap(12),
              ],
            ),

          // Completed badge
          if (stats.isCompleted)
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 4,
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 16,
                        color: AppColors.success,
                      ),
                      Text(
                        'Completed',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(12),
              ],
            ),

          Text(
            course.courseTitle,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: Constants.neulisNeueFontFamily,
            ),
          ),
          const Gap(8),
          Text(
            course.courseDescription,
            style: TextStyle(),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const Gap(24),
          Row(
            spacing: 8,
            children: [
              IconTextRowWidget(
                '${course.lessons.length} Lessons',
                AppIcon(AppIcons.openBookIcon, size: 16.0),
              ),
              IconTextRowWidget(
                difficultyLevel,
                AppIcon(AppIcons.chartIncreasingIcon, size: 16.0),
              ),
            ],
          ),
          CustomElevatedButton(
            text: stats.isStarted ? 'Continue' : 'Start lesson',
            rounded: true,
            icon: Icon(
              stats.isStarted
                  ? Icons.play_arrow_rounded
                  : Icons.play_arrow_rounded,
              color: AppColors.black,
            ),
            onPressed: () {
              context.pushNamed(LessonHomeScreen.path, extra: course);
            },
          ),
        ],
      ),
    );
  }

  String _extractDifficultyLevel(Course course) {
    final totalLevels = 3;

    if (totalLevels <= 3) {
      return 'Beginner-friendly';
    } else if (totalLevels <= 6) {
      return 'Intermediate';
    } else {
      return 'Advanced';
    }
  }
}
