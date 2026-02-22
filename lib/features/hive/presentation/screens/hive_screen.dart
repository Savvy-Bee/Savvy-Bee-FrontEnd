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
import 'package:savvy_bee_mobile/features/hive/presentation/screens/arcade_webview.dart';
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

   String _getTimeBasedGreeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return 'Good morning!';
    } else if (hour < 17) {
      return 'Good afternoon!';
    } else {
      return 'Good evening!';
    }
  }

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
                  _getTimeBasedGreeting(),
                  style: TextStyle(
                    fontFamily: 'GeneralSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                    letterSpacing: 12 * 0.02,
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
                            letterSpacing: 12 * 0.02,
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
                          date: 'January, 2026',
                          imagePath: 'assets/images/other/insights-one.jpg',
                          readTimeMinutes: 3,
                          content:
                              '''Credit scoring isn't just an "abroad" thing, it's already shaping financial lives in Nigeria. Every time you apply for a loan, buy a phone on credit, or even use some fintech apps, your credit score is being checked. Yet, many Nigerians still think it's a foreign concept.
The truth? Your financial reputation is now a digital score, and it can open doors or close them. Understanding how it works here, in our own system, is the first step to using it to your advantage.
Ask yourself:
●	Do I know my credit score is being tracked right now?
●	Do I understand how my daily money habits affect it?
●	Am I building a score that will help me or hold me back?
Your credit score is not just a number, it’s your financial CV in today’s Nigeria.''',
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
                          date: 'January, 2026',
                          imagePath: 'assets/images/other/insights-two.jpg',
                          readTimeMinutes: 3,
                          content:
                              '''An emergency fund isn’t a luxury, it’s your financial seatbelt. Life doesn’t wait for you to be ready, and having a safety net can mean the difference between a setback and a crisis. But when money is tight, building one can feel impossible.

The good news? You don’t need to save thousands overnight. The key is starting small, staying consistent, and making your money move without you even noticing.

Ask yourself these three starter questions:

●	Do I know what a true “emergency” is for me?
●	Can I find even ₦100 a day to redirect?
●	Am I willing to automate the process so I don’t have to think about it?

If you answered “yes,” you’re already on your way. The hardest part is simply beginning. Need a plan? We’ve got you covered.''',
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
                          date: 'January, 2026',
                          imagePath: 'assets/images/other/insights-three.jpg',
                          readTimeMinutes: 3,
                          content:
                              '''Saving as a couple is about more than just pooling funds, it’s a powerful way to build trust, strengthen communication, and bring your shared dreams to life. But before you open a joint account, it’s important to pause and reflect.

Not every couple is ready to save together, and that’s okay. The key is honesty and alignment. Start by asking yourselves three important questions:

Do we share the same goals?

Are we both committed to contributing regularly?

Can we talk about money openly?
If you answered “yes” to all these questions, you’re ready to take the next step toward building a stronger financial future together. Still not sure?''',
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
              // Padding(
              //   padding: const EdgeInsets.only(left: 16),
              //   child: SectionTitleWidget(title: 'Arcade'),
              // ),
              // const Gap(16),
              // SingleChildScrollView(
              //   padding: const EdgeInsets.symmetric(horizontal: 16),
              //   scrollDirection: Axis.horizontal,
              //   child: Row(
              //     spacing: 8,
              //     children: [
              //       GestureDetector(
              //         onTap: () => context.pushNamed(ArcadeWebViewScreen.path),
              //         // onTap: () => context.pushNamed(GameMenuScreen.path),
              //         child: Container(
              //           height: 200,
              //           width: MediaQuery.widthOf(context) * 0.6,
              //           decoration: BoxDecoration(
              //             border: Border.all(),
              //             borderRadius: BorderRadius.circular(16),
              //             image: DecorationImage(
              //               image: AssetImage(Assets.arcadeBg),
              //               fit: BoxFit.cover,
              //             ),
              //           ),
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
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
          letterSpacing: 24 * 0.02,
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
            Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'GeneralSans',
              ),
            ),
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
        padding: EdgeInsets.only(top: 4),
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
                      letterSpacing: 16 * 0.02,
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
                      letterSpacing: 12 * 0.02,
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
