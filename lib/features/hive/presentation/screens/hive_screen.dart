import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/assets/assets.dart';
import 'package:savvy_bee_mobile/core/utils/assets/illustrations.dart';
import 'package:savvy_bee_mobile/core/widgets/article_card.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_loading_widget.dart';
import 'package:savvy_bee_mobile/core/widgets/section_title_widget.dart';
import 'package:savvy_bee_mobile/core/widgets/icon_text_row_widget.dart';
import 'package:savvy_bee_mobile/features/hive/domain/models/course.dart';
import 'package:savvy_bee_mobile/features/hive/presentation/screens/games/game_menu_screen.dart';
import 'package:savvy_bee_mobile/features/hive/presentation/screens/leaderboard/leaderboard_screen.dart';
import 'package:savvy_bee_mobile/features/hive/presentation/screens/lesson/lesson_home_screen.dart';
import 'package:savvy_bee_mobile/features/hive/presentation/screens/streak/streak_dashboard_screen.dart';
import 'package:savvy_bee_mobile/features/hive/presentation/providers/course_providers.dart';
import 'package:savvy_bee_mobile/features/home/domain/models/blog_post.dart';
import 'package:savvy_bee_mobile/features/home/presentation/widgets/blog_post_bottom_sheet.dart';
import 'package:savvy_bee_mobile/features/home/presentation/widgets/insights.dart';
import 'package:savvy_bee_mobile/features/profile/presentation/screens/profile_screen.dart';

import '../../../../core/utils/assets/app_icons.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../../../core/widgets/custom_error_widget.dart';
import '../../../home/domain/models/home_data.dart';
import '../../../home/presentation/providers/home_data_provider.dart';
import '../providers/hive_provider.dart';

class HiveScreen extends ConsumerStatefulWidget {
  static const String path = '/hive';

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
      'imagePath': Illustrations.luna,
      'color': AppColors.success,
    },
    {
      'title': 'Investing vs. saving: which is right for you?',
      'subtitle': 'Understanding your financial goals',
      'imagePath': Illustrations.bloom,
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

  final courseImagePaths = [
    'assets/images/other/learn-one.jpg',
    'assets/images/other/learn-three.jpg',
    'assets/images/other/learn-two.jpg',
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

    final homeDataAsync = ref.watch(homeDataProvider);

    return Scaffold(
      appBar: _buildAppBar(hiveAsync, homeDataAsync),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.read(hiveNotifierProvider.notifier).refreshAll();
            ref.invalidate(allCoursesProvider);
            ref.invalidate(homeDataProvider);
          },
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Text(
                  "Good morning!",
                  style: TextStyle(
                    fontFamily: 'GeneralSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                // child: SectionTitleWidget(title: 'Explore courses'),
              ),
              const Gap(16),
              coursesAsync.when(
                data: (courses) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'LEARN & GROW',
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: 'GeneralSans',
                            fontWeight: FontWeight.w500,
                            color: AppColors.grey,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const Gap(16),
                      SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          spacing: 12,
                          mainAxisSize: MainAxisSize.min,
                          children: courses
                              .map(
                                (course) => _buildCourseCard(
                                  course: course,
                                  color: AppColors.primary,
                                  imagePath:
                                      courseImagePaths[courses.indexOf(course)],
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ],
                  );
                },
                // data: (courses) => _buildCoursesSection(courses),
                loading: () => CustomLoadingWidget(text: 'Loading courses...'),
                error: (error, stack) => CustomErrorWidget.error(
                  subtitle: 'Failed to load courses',
                  onRetry: () => ref.invalidate(allCoursesProvider),
                ),
              ),
              const Gap(24),
              // Learn and grow section
              InsightsSection(
                cards: [
                  LearnCard(
                    imagePath: 'assets/images/other/insights-one.jpg',
                    title: 'The art of credit scoring in Nigeria',
                    description: '📖 3 min story',
                    onTap: () {
                      showBlogPostBottomSheet(
                        context,
                        BlogPost(
                          category: 'FROM SAVVY BLOG',
                          title: 'The Art of Credit Scoring in Nigeria',
                          subtitle:
                              'Are you really listening to what they\'re saying',
                          date: 'October 27, 2025',
                          imagePath: 'assets/images/other/insights-one.jpg',
                          readTimeMinutes: 3,
                          content:
                              '''Afrobeats isn't just about good vibes, dance floors, and catchy hooks—if you're really listening, there's serious money advice tucked between the basslines.

Behind the flashy lyrics about "chilling with the big boys" or "getting that bag" lies a reflection of hustle culture, financial growth, and self-belief.

Take Burna Boy, for instance—he raps about consistency, resilience, and betting on yourself long before anyone believes in you. That's an investment mindset: put in the work, not before, but before expecting returns. Wizkid and Davido often emphasize staying focused on wealth quietly, not loudly, which echoes the mantra to save and invest, not just to live large on credit or do diversification and long-term thinking.

The truth? Afrobeats is a masterclass in ambition, discipline, and financial evolution—wrapped in rhythm. The next time you're vibing to your favorite track, ask yourself: are you just dancing, or are you also learning the game these artists are preaching?''',
                        ),
                      );
                    },
                  ),
                  LearnCard(
                    imagePath: 'assets/images/other/insights-two.jpg',
                    title: 'How to build an emergency fund on a tight budget',
                    description: '📖 3 min story',
                    onTap: () {
                      showBlogPostBottomSheet(
                        context,
                        BlogPost(
                          category: 'FROM SAVVY BLOG',
                          title:
                              'How to build an emergency fund on a tight budget',
                          subtitle: 'Small steps, big security',
                          date: 'November 15, 2025',
                          imagePath: 'assets/images/other/insights-two.jpg',
                          readTimeMinutes: 3,
                          content:
                              '''Building an emergency fund on a tight budget might seem impossible, but it's absolutely achievable with the right strategy.

Start small—even ₦1,000 per week adds up to ₦52,000 in a year. The key is consistency, not the amount.

Here are some practical tips:
- Automate your savings so you never skip it
- Cut one unnecessary expense each month
- Use windfalls wisely (bonuses, gifts, refunds)
- Track every naira that comes in and goes out

Remember, an emergency fund isn't built overnight. It's about creating a habit that protects your future self. Start today, no matter how small.''',
                        ),
                      );
                    },
                  ),
                  LearnCard(
                    imagePath: 'assets/images/other/insights-three.jpg',
                    title: 'Should i save financially with my partner?',
                    description: '📖 3 min story',
                    onTap: () {
                      showBlogPostBottomSheet(
                        context,
                        BlogPost(
                          category: 'FROM SAVVY BLOG',
                          title:
                              'Should you save financially with your partner?',
                          subtitle: 'Let\'s get financially intimate',
                          date: 'December 3, 2025',
                          imagePath: 'assets/images/other/insights-three.jpg',
                          readTimeMinutes: 3,
                          content:
                              '''Joint savings with your partner can strengthen your relationship—or complicate it. Here's what you need to know.

The benefits are clear: shared goals, better accountability, and building something together. But the risks include loss of autonomy, potential conflicts, and what happens if things don't work out.

Best practices:
- Keep personal savings separate too
- Set clear expectations and goals
- Review finances together monthly
- Be honest about spending habits

The bottom line? Joint savings work best when there's trust, communication, and a solid foundation. Don't rush into it—build financial intimacy gradually.''',
                        ),
                      );
                    },
                  ),
                ],
              ),
              // Padding(
              //   padding: const EdgeInsets.only(left: 16),
              //   child: SectionTitleWidget(title: 'Recent insights'),
              // ),
              // const Gap(16),
              // SingleChildScrollView(
              //   padding: const EdgeInsets.symmetric(horizontal: 16),
              //   scrollDirection: Axis.horizontal,
              //   child: Row(
              //     spacing: 8,
              //     children: insights
              //         .map(
              //           (insight) => ArticleCard(
              //             title: insight['title']!,
              //             backgroundColor: insight['color'],
              //             imagePath: insight['imagePath']!,
              //             subtitle: insight['subtitle']!,
              //             onTap: () {},
              //           ),
              //         )
              //         .toList(),
              //   ),
              // ),
              const Gap(24),
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: SectionTitleWidget(title: 'Arcade'),
              ),
              const Gap(16),
              SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                child: Row(
                  spacing: 8,
                  children: [
                    GestureDetector(
                      onTap: () => context.pushNamed(GameMenuScreen.path),
                      child: Container(
                        height: 200,
                        width: MediaQuery.widthOf(context) * 0.6,
                        decoration: BoxDecoration(
                          border: Border.all(),
                          borderRadius: BorderRadius.circular(16),
                          image: DecorationImage(
                            image: AssetImage(Assets.arcadeBg),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
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

  Widget _buildCoursesSection(List<Course> courses) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: courses
            .map(
              (course) => _buildCourseCard(
                course: course,
                color: AppColors.primary,
                imagePath: courseImagePaths[courses.indexOf(course)],
              ),
            )
            .toList(),
      ),
    );
  }

  AppBar _buildAppBar(
    AsyncValue<HiveState> hiveAsync,
    AsyncValue<HomeDataResponse> homeDataAsync,
  ) {
    return AppBar(
      title: Text(
        homeDataAsync.when(
          data: (data) => 'Hi ${data.data.firstName}!',
          error: (error, stackTrace) => 'Hi User!',
          loading: () => 'Hi User!',
        ),
        style: TextStyle(
          fontSize: 24,
          fontFamily: 'GeneralSans',
          fontWeight: FontWeight.w500,
        ),
      ),
      centerTitle: false,
      actions: [
        // Flowers count
        _buildActionButton(
          icon: Image.asset(Illustrations.hiveFlower),
          text: hiveAsync.when(
            data: (hiveState) => '${hiveState.hiveData?.flowers ?? 0}',
            error: (_, __) => '0',
            loading: () => '...',
          ),
          onTap: () => context.pushNamed(ProfileScreen.path),
        ),

        const Gap(4),
        // Streak count
        _buildActionButton(
          icon: Icon(Icons.hive, size: 20, color: AppColors.primary),
          text: hiveAsync.when(
            data: (hiveState) => '${hiveState.hiveData?.streak ?? 0}',
            error: (_, __) => '0',
            loading: () => '...',
          ),
          onTap: () => context.pushNamed(StreakDashboardScreen.path),
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
            Text(text, style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildCourseCard({
    required Course course,
    required Color color,
    required String imagePath,
  }) {
    return GestureDetector(
      onTap: () => context.pushNamed(LessonHomeScreen.path, extra: course),
      child: Container(
        width: 238,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: AppColors.grey.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image section with background color
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(32)),
                child: Image.asset(
                  imagePath,
                  width: 230,
                  height: 230,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Content section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.courseTitle,
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'GeneralSans',
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  const Gap(8),
                  Text(
                    course.courseDescription,
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'GeneralSans',
                      fontWeight: FontWeight.w500,
                      color: AppColors.grey,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildCourseCard({required Course course}) {
  //   final stats = ref.watch(courseStatsProvider(course));
  //   final difficultyLevel = _extractDifficultyLevel(course);

  //   return CustomCard(
  //     width: MediaQuery.sizeOf(context).width / 1.3,
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       mainAxisSize: MainAxisSize.min,
  //       children: [
  //         // Progress indicator if course is started
  //         if (stats.isStarted && !stats.isCompleted)
  //           Column(
  //             children: [
  //               Row(
  //                 children: [
  //                   Expanded(
  //                     child: LinearProgressIndicator(
  //                       value: stats.progressPercentage / 100,
  //                       backgroundColor: AppColors.greyLight,
  //                       color: AppColors.primary,
  //                       borderRadius: BorderRadius.circular(4),
  //                     ),
  //                   ),
  //                   const Gap(8),
  //                   Text(
  //                     '${stats.progressPercentage.toStringAsFixed(0)}%',
  //                     style: TextStyle(
  //                       fontSize: 12,
  //                       fontWeight: FontWeight.bold,
  //                       color: AppColors.primary,
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //               const Gap(12),
  //             ],
  //           ),

  //         // Completed badge
  //         if (stats.isCompleted)
  //           Column(
  //             children: [
  //               Container(
  //                 padding: const EdgeInsets.symmetric(
  //                   horizontal: 8,
  //                   vertical: 4,
  //                 ),
  //                 decoration: BoxDecoration(
  //                   color: AppColors.success.withValues(alpha: 0.1),
  //                   borderRadius: BorderRadius.circular(12),
  //                 ),
  //                 child: Row(
  //                   mainAxisSize: MainAxisSize.min,
  //                   spacing: 4,
  //                   children: [
  //                     Icon(
  //                       Icons.check_circle,
  //                       size: 16,
  //                       color: AppColors.success,
  //                     ),
  //                     Text(
  //                       'Completed',
  //                       style: TextStyle(
  //                         fontSize: 12,
  //                         fontWeight: FontWeight.bold,
  //                         color: AppColors.success,
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //               const Gap(12),
  //             ],
  //           ),

  //         Text(
  //           course.courseTitle,
  //           style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
  //         ),
  //         const Gap(8),
  //         Text(
  //           course.courseDescription,
  //           style: TextStyle(),
  //           maxLines: 3,
  //           overflow: TextOverflow.ellipsis,
  //         ),
  //         const Gap(24),
  //         Row(
  //           spacing: 8,
  //           children: [
  //             IconTextRowWidget(
  //               '${course.lessons.length} Lessons',
  //               AppIcon(AppIcons.openBookIcon, size: 16.0),
  //             ),
  //             IconTextRowWidget(
  //               difficultyLevel,
  //               AppIcon(AppIcons.chartIncreasingIcon, size: 16.0),
  //             ),
  //           ],
  //         ),
  //         CustomElevatedButton(
  //           text: stats.isStarted ? 'Continue' : 'Start lesson',
  //           rounded: true,
  //           icon: Icon(
  //             stats.isStarted
  //                 ? Icons.play_arrow_rounded
  //                 : Icons.play_arrow_rounded,
  //             color: AppColors.black,
  //           ),
  //           onPressed: () {
  //             context.pushNamed(LessonHomeScreen.path, extra: course);
  //           },
  //         ),
  //       ],
  //     ),
  //   );
  // }

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
