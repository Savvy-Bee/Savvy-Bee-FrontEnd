import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/assets/app_icons.dart';
import 'package:savvy_bee_mobile/core/utils/assets/illustrations.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';
import 'package:savvy_bee_mobile/core/widgets/article_card.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_card.dart';
import 'package:savvy_bee_mobile/core/widgets/dot.dart';
import 'package:savvy_bee_mobile/core/widgets/icon_text_row_widget.dart';
import 'package:savvy_bee_mobile/core/widgets/section_title_widget.dart';
import 'package:savvy_bee_mobile/features/hive/domain/models/course.dart';
import 'package:savvy_bee_mobile/features/home/presentation/providers/home_data_provider.dart';
import 'package:savvy_bee_mobile/features/home/presentation/widgets/complete_setup.dart';
import 'package:savvy_bee_mobile/features/home/presentation/widgets/insights.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/screens/wallet/nin_verification_screen.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/screens/budget/budget_screen.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/screens/goals/goals_screen.dart';

import '../../../../core/widgets/custom_error_widget.dart';
import '../../../../core/widgets/custom_loading_widget.dart';
import '../../../dashboard/presentation/widgets/info_card.dart';
import '../../../hive/presentation/providers/course_providers.dart';
import '../../../hive/presentation/screens/lesson/lesson_home_screen.dart';
import '../widgets/health_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  static const String path = '/home';

  const HomeScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final courseImagePaths = [
    'assets/images/other/learn-one.jpg',
    'assets/images/other/learn-three.jpg',
    'assets/images/other/learn-two.jpg',
  ];
  final recentInsightsImagePaths = [
    Illustrations.matchingAndQuizBee,
    Illustrations.dash,
  ];
  @override
  Widget build(BuildContext context) {
    final homeData = ref.watch(homeDataProvider);
    final coursesAsync = ref.watch(allCoursesProvider);

    return homeData.when(
      skipLoadingOnRefresh: false,
      data: (value) {
        final data = value.data;

        // The choice of using a Scaffold for each state is for the purpose of
        // hiding the AppBar while loading
        return Scaffold(
          appBar: _buildAppBar(data.firstName, context),
          body: ListView(
            children: [
              const Gap(6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hi, ${data.firstName}!",
                      style: TextStyle(
                        fontFamily: 'GeneralSans',
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      "Good morning!",
                      style: TextStyle(
                        fontFamily: 'GeneralSans',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),

              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 16),
              //   child: HealthCardWidget(
              //     statusText: data.aiData.status,
              //     descriptionText: data.aiData.message,
              //     rating: data.aiData.ratings.toDouble(),
              //   ),
              // ),
              // const Gap(24),
              // _buildSectionTitle(
              //   title: 'To-dos',
              //   actionText: 'Hide',
              //   actionColor: AppColors.error,
              //   onactionTap: () {},
              // ),
              // const Gap(16),
              // SingleChildScrollView(
              //   padding: const EdgeInsets.symmetric(horizontal: 16),
              //   scrollDirection: Axis.horizontal,
              //   child: Row(
              //     spacing: 12,
              //     mainAxisSize: MainAxisSize.min,
              //     children: [
              //       if (!data.kyc.nin || !data.kyc.bvn)
              //         _buildTodoItem(
              //           title: 'Verify your identity',
              //           iconPath: AppIcons.scanFaceIcon,
              //           ctaText: 'VERIFY',
              //           onTap: () =>
              //               context.pushNamed(NinVerificationScreen.path),
              //         ),
              //       _buildTodoItem(
              //         title: 'Enable FaceID/fingerprint',
              //         iconPath: AppIcons.scanFaceIcon,
              //         ctaText: 'ENABLE',
              //       ),
              //     ],
              //   ),
              // ),
              const Gap(24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: CompleteSetupCard(
                  completedCount: 0,
                  totalCount: 3,
                  items: [
                    SetupItem(
                      icon: 'assets/icons/Calculator.png',
                      title: 'Set up Budgeting',
                      subtitle: 'Take control of your spending',
                      onTap: () => context.pushNamed(BudgetScreen.path),
                    ),
                    SetupItem(
                      icon: 'assets/icons/Square-Check.png',
                      title: 'Start saving with Goals',
                      subtitle: 'Start a new goal',
                      onTap: () => context.pushNamed(GoalsScreen.path),
                    ),
                    SetupItem(
                      icon: 'assets/icons/BookOpen.png',
                      title: 'Reduce your Debt',
                      subtitle: 'A smarter way to track existing debt',
                      onTap: () {
                        // Navigate to debt screen
                      },
                    ),
                  ],
                ),
              ),
              const Gap(24),

              // _buildSectionTitle(
              //   title: 'My tools',
              //   actionText: 'View all',
              //   actionColor: AppColors.primary,
              //   onactionTap: () {},
              // ),
              // const Gap(16),
              // SingleChildScrollView(
              //   padding: const EdgeInsets.symmetric(horizontal: 16),
              //   scrollDirection: Axis.horizontal,
              //   child: Row(
              //     spacing: 12,
              //     mainAxisSize: MainAxisSize.min,
              //     children: [
              //       _buildToolCard(
              //         title: 'My budgets',
              //         subtitle:
              //             'Create smart budgets, track spending, and get personalized insights.',
              //         superscript: 'EDIT BUDGET',
              //         color: AppColors.primary,
              //         onTap: () => context.pushNamed(BudgetScreen.path),
              //       ),
              //       _buildToolCard(
              //         title: 'My goals',
              //         subtitle:
              //             'Set goals, get AI-powered suggestions, and track your progress.',
              //         superscript: 'EDIT GOAL',
              //         color: AppColors.success,
              //         onTap: () => context.pushNamed(GoalsScreen.path),
              //       ),
              //     ],
              //   ),
              // ),
              // const Gap(24),
              const Gap(24),

              // LearnAndGrowSection(
              //   cards: [
              //     LearnCard(
              //       imagePath: 'assets/images/other/learn-one.jpg', // Your asset path
              //       title: 'Savings 101',
              //       description:
              //           'Create smart budgets, track spending, and get personalized insights.',
              //       onTap: () {
              //         () => context.pushNamed(LessonHomeScreen.path, extra: course),
              //       },
              //     ),
              //     LearnCard(
              //       imagePath: 'assets/images/other/learn-two.jpg', // Your asset path
              //       title: 'Budgeting Basics',
              //       description:
              //           'Create smart budgets, track spending, and get personalized insights.',
              //       onTap: () {
              //         () => context.pushNamed(LessonHomeScreen.path, extra: course),
              //       },
              //     ),
              //     LearnCard(
              //       imagePath: 'assets/images/other/learn-three.jpg', // Your asset path
              //       title: 'Numeracy',
              //       description:
              //           'Create smart budgets, track spending, and get personalized insights.',
              //       onTap: () {
              //         () => context.pushNamed(LessonHomeScreen.path, extra: course),
              //       },
              //     ),
              //   ],
              // ),
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
                error: (error, stackTrace) => const SizedBox.shrink(),
                loading: () => const SizedBox.shrink(),
              ),
              const Gap(24),
              // Learn and grow section
              InsightsSection(
                cards: [
                  LearnCard(
                    imagePath:
                        'assets/images/other/insights-one.jpg', // Your asset path
                    title: 'The art of credit scoring in Nigeria',
                    description: '📖 3 min story',
                    onTap: () {
                      // () => context.pushNamed(LessonHomeScreen.path, extra: course),
                    },
                  ),
                  LearnCard(
                    imagePath:
                        'assets/images/other/insights-two.jpg', // Your asset path
                    title: 'How to build an emergency fund on a tight budget',
                    description: '📖 3 min story',
                    onTap: () {
                      // () => context.pushNamed(LessonHomeScreen.path, extra: course),
                    },
                  ),
                  LearnCard(
                    imagePath:
                        'assets/images/other/insights-three.jpg', // Your asset path
                    title: 'Should i save financially with my partner?',
                    description: '📖 3 min story',
                    onTap: () {
                      // () => context.pushNamed(LessonHomeScreen.path, extra: course),
                    },
                  ),
                ],
              ),
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 16),
              //   child: SectionTitleWidget(title: 'Recent insights'),
              // ),
              // const Gap(16),
              // SingleChildScrollView(
              //   padding: const EdgeInsets.symmetric(horizontal: 16),
              //   scrollDirection: Axis.horizontal,
              //   child: Row(
              //     spacing: 12,
              //     mainAxisSize: MainAxisSize.min,
              //     children: [
              //       ArticleCard(
              //         title: 'Should you save financially with your partner?',
              //         subtitle: "Let's get financially intimate",
              //         backgroundColor: AppColors.primary,
              //         imagePath: recentInsightsImagePaths[0],
              //         onTap: () {},
              //       ),
              //       ArticleCard(
              //         title: 'Money lessons from afrobeats',
              //         subtitle:
              //             "Are you really listening to what they're saying?",
              //         backgroundColor: AppColors.success,
              //         imagePath: recentInsightsImagePaths[1],
              //         onTap: () {},
              //       ),
              //     ],
              //   ),
              // ),
              const Gap(24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: InfoCard(
                  title: 'Smart Recommendation',
                  description:
                      'Your expenses are high, consider a budget review this week.',
                  avatar: Illustrations.lunaAvatar,
                  borderRadius: 32,
                ),
              ),
            ],
          ),
        );
      },
      error: (error, stackTrace) => Scaffold(
        body: CustomErrorWidget(
          icon: Icons.person_outline,
          title: 'Unable to Load User Info',
          subtitle:
              'We couldn\'t fetch your account data. Please check your connection and try again.',
          actionButtonText: 'Retry',
          onActionPressed: () {
            ref.invalidate(homeDataProvider);
          },
        ),
      ),
      loading: () => Scaffold(
        body: CustomLoadingWidget(text: 'Loading your account info...'),
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

  // Widget _buildCourseCard({
  //   required Course course,
  //   required Color color,
  //   required String imagePath,
  // }) {
  //   final width = MediaQuery.sizeOf(context).width / 1.9;

  //   return CustomCard(
  //     onTap: () => context.pushNamed(LessonHomeScreen.path, extra: course),
  //     bgColor: color.withValues(alpha: 0.25),
  //     borderColor: color,
  //     width: width,
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       mainAxisSize: MainAxisSize.min,
  //       children: [
  //         Row(
  //           mainAxisAlignment: MainAxisAlignment.center,
  //           children: [Image.asset(imagePath, height: 140, width: 140)],
  //         ),
  //         // const Gap(16),
  //         Text(
  //           course.courseTitle,
  //           style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
  //         ),
  //         const Gap(4),
  //         Text(
  //           course.courseDescription,
  //           maxLines: 2,
  //           overflow: TextOverflow.ellipsis,
  //           style: TextStyle(fontSize: 10),
  //         ),
  //         const Gap(8),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildToolCard({
    required String title,
    required String subtitle,
    required String superscript, // The little text at the top-right
    required Color color,
    VoidCallback? onTap,
  }) {
    final width = MediaQuery.sizeOf(context).width / 1.9;

    return CustomCard(
      onTap: onTap,
      bgColor: color.withValues(alpha: 0.25),
      borderColor: color,
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Gap(8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  superscript,
                  style: TextStyle(fontSize: 8, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          // const Gap(16),
          Text(
            title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const Gap(4),
          Text(subtitle, style: TextStyle(fontSize: 10)),
          const Gap(8),
        ],
      ),
    );
  }

  Widget _buildTodoItem({
    required String title,
    required String iconPath,
    required String ctaText,
    VoidCallback? onTap,
  }) {
    return CustomCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      borderColor: AppColors.grey,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: [
          AppIcon(iconPath, size: 32),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              Text(
                ctaText,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,

                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle({
    required String title,
    required String actionText,
    required Color actionColor,
    required VoidCallback onactionTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SectionTitleWidget(
        title: title,
        actionWidget: IconTextRowWidget(
          actionText,
          textStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,

            color: actionColor,
          ),
          spacing: 0,
          Icon(
            Icons.keyboard_arrow_right_rounded,
            color: actionColor,
            size: 20,
          ),
          reverse: true,
          padding: EdgeInsets.zero,
          onTap: onactionTap,
        ),
      ),
    );
  }

  AppBar _buildAppBar(String firstName, BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // LEFT: "Chat with Nahl" section – stays left-aligned
          Positioned(
            left: 0,
            child: GestureDetector(
              onTap: () {
                // Uncomment when ready
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (_) => const ChatWithNahlScreen()),
                // );
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                // sub row
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primary),
                        ),
                        child: Center(
                          child: Image.asset(
                            'assets/images/topbar/nav-left-icon.png',
                            width: 32,
                            height: 32,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 6,
                      ), // Replaced Gap with SizedBox (standard)
                      const Text(
                        'Chat with Nahl',
                        style: TextStyle(
                          fontFamily: 'GeneralSans',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(width: 25),
                      // CENTER: Icon – always stays exactly in the horizontal center
                      Image.asset(
                        'assets/images/topbar/nav-center-icon.png',
                        width: 30,
                        height: 32,
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // RIGHT: User avatar/initials – stays right-aligned
          Positioned(
            right: 0,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 1),
              ),
              child: Center(
                child: Text(
                  firstName.isNotEmpty
                      ? (firstName.length > 1
                            ? firstName.substring(0, 2).toUpperCase()
                            : firstName[0].toUpperCase())
                      : 'DT',
                  style: const TextStyle(
                    fontFamily: 'GeneralSans',
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      centerTitle: false, // We control positioning manually → must be false
      automaticallyImplyLeading:
          false, // Optional: remove default back button if not needed
    );
  }

  // AppBar _buildAppBar(String firstName, BuildContext context) {
  //   return AppBar(
  //     centerTitle: false,
  //     title: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       mainAxisSize: MainAxisSize.min,
  //       children: [
  //         Text(
  //           'Hello $firstName',
  //           style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
  //         ),
  //         Text(
  //           'Welcome back!',
  //           style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
  //         ),
  //       ],
  //     ),
  //     actions: [
  //       Padding(
  //         padding: const EdgeInsets.only(right: 16),
  //         child: Dot(size: 35),
  //       ),
  //     ],
  //   );
  // }

  // AppBar _buildAppBar(String firstName, BuildContext context) {
  //   return AppBar(
  //     backgroundColor: Colors.white,
  //     elevation: 0,
  //     title: Stack(
  //       alignment: Alignment.center,
  //       children: [
  //         // LEFT HALF: Up to 50% width – contains left content + center icon
  //         Positioned(
  //           left: 0,
  //           top: 0,
  //           bottom: 0,
  //           // width:
  //           //     MediaQuery.of(context).size.width *
  //           //     0.5, // Exactly 50% of screen
  //           child: Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             children: [
  //               // Left content: back icon + "Chat with Nahl" text
  //               GestureDetector(
  //                 onTap: () {
  //                   // Navigator.push(
  //                   //   context,
  //                   //   MaterialPageRoute(builder: (_) => const ChatWithNahlScreen()),
  //                   // );
  //                 },
  //                 child: Row(
  //                   mainAxisSize: MainAxisSize.min,
  //                   children: [
  //                     Container(
  //                       width: 32,
  //                       height: 32,
  //                       decoration: BoxDecoration(
  //                         shape: BoxShape.circle,
  //                         border: Border.all(color: AppColors.primary),
  //                       ),
  //                       child: Center(
  //                         child: Image.asset(
  //                           'assets/images/topbar/nav-left-icon.png',
  //                           width: 32,
  //                           height: 32,
  //                         ),
  //                       ),
  //                     ),
  //                     const SizedBox(width: 6),
  //                     const Text(
  //                       'Chat with Nahl',
  //                       style: TextStyle(
  //                         fontFamily: 'GeneralSans',
  //                         fontSize: 12,
  //                         fontWeight: FontWeight.w500,
  //                         color: Colors.black,
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),

  //               // Center icon – pushed to the right edge of this 50% container → screen center
  //               Image.asset(
  //                 'assets/images/topbar/nav-center-icon.png',
  //                 width: 30,
  //                 height: 32,
  //                 fit: BoxFit.contain,
  //               ),
  //             ],
  //           ),
  //         ),

  //         // RIGHT: User avatar – pinned to the far right
  //         Positioned(
  //           right: 0,
  //           top: 0,
  //           bottom: 0,
  //           // width:
  //           //     MediaQuery.of(context).size.width *
  //           //     0.5, // Exactly 50% of screen
  //           child: Container(
  //             width: 32,
  //             height: 32,
  //             decoration: BoxDecoration(
  //               color: Colors.white,
  //               shape: BoxShape.circle,
  //               border: Border.all(color: Colors.black, width: 1),
  //             ),
  //             child: Center(
  //               child: Text(
  //                 firstName.isNotEmpty
  //                     ? (firstName.length > 1
  //                           ? firstName.substring(0, 2).toUpperCase()
  //                           : firstName[0].toUpperCase())
  //                     : 'DT',
  //                 style: const TextStyle(
  //                   fontFamily: 'GeneralSans',
  //                   fontWeight: FontWeight.w500,
  //                   fontSize: 16,
  //                   color: Colors.black,
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //     centerTitle: false,
  //     automaticallyImplyLeading: false, // Prevents default back button
  //   );
  // }
}
