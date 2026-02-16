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
import 'package:savvy_bee_mobile/core/widgets/main_wrapper.dart';
import 'package:savvy_bee_mobile/core/widgets/section_title_widget.dart';
import 'package:savvy_bee_mobile/features/auth/presentation/providers/auth_providers.dart';
import 'package:savvy_bee_mobile/features/auth/presentation/screens/login_screen.dart';
import 'package:savvy_bee_mobile/features/chat/presentation/screens/chat_screen.dart';
import 'package:savvy_bee_mobile/features/hive/domain/models/course.dart';
import 'package:savvy_bee_mobile/features/home/domain/models/blog_post.dart';
import 'package:savvy_bee_mobile/features/home/presentation/providers/home_data_provider.dart';
import 'package:savvy_bee_mobile/features/home/presentation/screens/feedback_webview.dart';
import 'package:savvy_bee_mobile/features/home/presentation/widgets/action_prompt_card.dart';
import 'package:savvy_bee_mobile/features/home/presentation/widgets/blog_post_bottom_sheet.dart';
import 'package:savvy_bee_mobile/features/home/presentation/widgets/complete_setup.dart';
import 'package:savvy_bee_mobile/features/home/presentation/widgets/insights.dart';
import 'package:savvy_bee_mobile/features/home/presentation/widgets/smart_recommendations.dart';
import 'package:savvy_bee_mobile/features/profile/presentation/screens/contact_us_screen.dart';
import 'package:savvy_bee_mobile/features/profile/presentation/screens/profile_screen.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/screens/wallet/nin_verification_screen.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/screens/budget/budget_screen.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/screens/budget/budgets_screen.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/screens/debt/debt_screen.dart';
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

  bool _showRecommendation = true;
  String? _selectedFeedback;

  @override
  void initState() {
    super.initState();
    // Reset recommendation visibility when screen is opened
    _showRecommendation = true;
  }

  void _handleFeedback(String feedback) {
    setState(() {
      _selectedFeedback = feedback;
    });
    // You can add analytics or API call here
    print('User feedback: $feedback');
    // Immediately open the form in WebView
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const FeedbackWebViewScreen()),
    );
  }

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
                      onTap: () => context.pushNamed(BudgetsScreen.path),
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
                      onTap: () => context.pushNamed(DebtScreen.path),
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
Your credit score is not just a number, it’s your financial CV in today’s Nigeria.
''',
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

If you answered “yes,” you’re already on your way. The hardest part is simply beginning. Need a plan? We’ve got you covered.
''',
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
If you answered “yes” to all these questions, you’re ready to take the next step toward building a stronger financial future together. Still not sure?
''',
                        ),
                      );
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
                child: Text(
                  'WAYS TO SAVE',
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ActionPromptCard(
                  title: 'Manage your bills and expenses',
                  description:
                      'Create smart budgets, track spending, and get personalized insights.',
                  buttonText: 'Set up Categories',
                  backgroundColor: AppColors.yellow, // Yellow color
                  onButtonPressed: () {
                    // Navigate to categories setup
                    context.pushNamed(BudgetsScreen.path);
                  },
                ),
              ),
              const Gap(24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ActionPromptCard(
                  title: 'Set your financial goals',
                  description:
                      'Create smart budgets, track spending, and get personalized insights.',
                  buttonText: 'Start saving with Goals',
                  backgroundColor: Colors.white, // Yellow color
                  borderColor: Colors.black,
                  onButtonPressed: () {
                    // Navigate to categories setup
                    context.pushNamed(GoalsScreen.path);
                  },
                ),
              ),
              const Gap(24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ActionPromptCard(
                  title: 'Reduce your existing debt',
                  description:
                      'Create smart budgets, track spending, and get personalized insights.',
                  buttonText: 'Manage your Debt',
                  backgroundColor: AppColors.green, // Green color
                  onButtonPressed: () {
                    // Navigate to categories setup
                    context.pushNamed(DebtScreen.path);
                  },
                ),
              ),
              const Gap(24),

              // Smart Recommendation Card
              // if (_showRecommendation)
              //   Padding(
              //     padding: const EdgeInsets.symmetric(horizontal: 16),
              //     child: SmartRecommendationCard(
              //       title: 'SMART RECOMMENDATION',
              //       description:
              //           'Hey Danaerys, we detected you could save approximately ₦200k in the next 12 months using Goals.',
              //       highlightedText: '\₦200k',
              //       buttonText: 'Set a new Saving Goal',
              //       onButtonPressed: () {
              //         context.pushNamed(GoalsScreen.path);
              //       },
              //       onClose: () {
              //         setState(() {
              //           _showRecommendation = false;
              //         });
              //       },
              //     ),
              //   ),
              if (_showRecommendation) const Gap(24),
              _buildFeedbackSection(),
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 16),
              //   child: InfoCard(
              //     title: 'Smart Recommendation',
              //     description:
              //         'Your expenses are high, consider a budget review this week.',
              //     avatar: Illustrations.lunaAvatar,
              //     borderRadius: 32,
              //   ),
              // ),
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
          onLogoutPressed: () {
            ref.read(authProvider.notifier).logout();
            ref.read(bottomNavIndexProvider.notifier).state = 0;
            context.goNamed(LoginScreen.path);
          },
          logoutButtonText: 'Logout',
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
        padding: const EdgeInsets.only(top: 4),
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
      automaticallyImplyLeading: false,
      toolbarHeight: 56, // Standard AppBar height
      title: Row(
        children: [
          // LEFT: "Chat with Nahl" section
          InkWell(
            onTap: () => context.pushNamed(ChatScreen.path),
            child: Row(
              mainAxisSize: MainAxisSize.min,
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
                const SizedBox(width: 6),
                const Text(
                  'Chat with Nahl',
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

          // Spacer to push center icon to middle
          const Spacer(),

          // CENTER: Icon
          Image.asset(
            'assets/images/topbar/nav-center-icon.png',
            width: 30,
            height: 32,
            fit: BoxFit.contain,
          ),

          // Spacer to balance and push avatar to right
          const Spacer(),
        ],
      ),
      actions: [
        // RIGHT: User avatar
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: GestureDetector(
            onTap: () => context.pushNamed(ProfileScreen.path, extra: ''),
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
        ),
      ],
    );
  }

  Widget _buildFeedbackSection() {
    return Column(
      children: [
        Text(
          'HOW ARE YOU LIKING SAVVY BEE?',
          style: TextStyle(
            fontSize: 12,
            fontFamily: 'GeneralSans',
            fontWeight: FontWeight.w500,
            color: Colors.black,
            letterSpacing: 0.5,
          ),
        ),
        const Gap(16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildFeedbackIcon(
              'very_sad',
              '😞',
              _selectedFeedback == 'very_sad',
            ),
            _buildFeedbackIcon('sad', '😕', _selectedFeedback == 'sad'),
            _buildFeedbackIcon('neutral', '😊', _selectedFeedback == 'neutral'),
            _buildFeedbackIcon('happy', '😃', _selectedFeedback == 'happy'),
          ],
        ),
        const Gap(16),
        TextButton(
          onPressed: () => context.pushNamed(ContactUsScreen.path),
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(
                fontSize: 12,
                fontFamily: 'GeneralSans',
                color: Colors.black87,
              ),
              children: [
                TextSpan(text: 'How can we help? '),
                TextSpan(
                  text: 'Contact Us.',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeedbackIcon(String value, String emoji, bool isSelected) {
    return GestureDetector(
      onTap: () => _handleFeedback(value),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.success.withValues(alpha: 0.2)
              : Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected
                ? AppColors.success
                : Colors.black.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Center(child: Text(emoji, style: TextStyle(fontSize: 24))),
      ),
    );
  }
}
