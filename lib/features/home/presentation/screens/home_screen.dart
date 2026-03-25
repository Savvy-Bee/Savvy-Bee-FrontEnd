import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

// ─────────────────────────────────────────────────────────────────────────────
// Walkthrough step enum
// ─────────────────────────────────────────────────────────────────────────────
enum _WalkthroughStep { welcome, cheerful, budget, done }

// ─────────────────────────────────────────────────────────────────────────────
// SharedPreferences key
// ─────────────────────────────────────────────────────────────────────────────
const _kWalkthroughCompletedKey = 'home_walkthrough_completed';

class HomeScreen extends ConsumerStatefulWidget {
  static const String path = '/home';

  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // ── Walkthrough state ─────────────────────────────────────────────────────
  _WalkthroughStep _walkthroughStep = _WalkthroughStep.done;
  bool _walkthroughChecked = false;

  // ── New: Retry / loading state ────────────────────────────────────────────
  bool _isRetrying = false;

  // ── Budget item key ───────────────────────────────────────────────────────
  final GlobalKey _budgetItemKey = GlobalKey();

  // ── Original state (unchanged) ────────────────────────────────────────────
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
    _showRecommendation = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(homeDataProvider);
      ref.invalidate(allCoursesProvider);
      _checkWalkthrough();
    });
  }

  Future<void> _checkWalkthrough() async {
    final prefs = await SharedPreferences.getInstance();
    final completed = prefs.getBool(_kWalkthroughCompletedKey) ?? false;
    if (!completed && mounted) {
      setState(() {
        _walkthroughStep = _WalkthroughStep.welcome;
        _walkthroughChecked = true;
      });
    } else {
      setState(() => _walkthroughChecked = true);
    }
  }

  Future<void> _advanceWalkthrough() async {
    switch (_walkthroughStep) {
      case _WalkthroughStep.welcome:
        setState(() => _walkthroughStep = _WalkthroughStep.cheerful);
        break;
      case _WalkthroughStep.cheerful:
        setState(() => _walkthroughStep = _WalkthroughStep.budget);
        break;
      case _WalkthroughStep.budget:
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_kWalkthroughCompletedKey, true);
        if (mounted) {
          setState(() => _walkthroughStep = _WalkthroughStep.done);
        }
        break;
      case _WalkthroughStep.done:
        break;
    }
  }

  bool get _isWalkthroughActive => _walkthroughStep != _WalkthroughStep.done;

  String? get _currentWalkthroughImage {
    switch (_walkthroughStep) {
      case _WalkthroughStep.welcome:
        return 'assets/images/walk_through/home_welcome.png';
      case _WalkthroughStep.cheerful:
        return 'assets/images/walk_through/home_cheerful.png';
      case _WalkthroughStep.budget:
        return 'assets/images/walk_through/home_budget.png';
      case _WalkthroughStep.done:
        return null;
    }
  }

  double? _getBudgetItemArrowY() {
    final ctx = _budgetItemKey.currentContext;
    if (ctx == null) return null;
    final box = ctx.findRenderObject() as RenderBox?;
    if (box == null) return null;
    final pos = box.localToGlobal(Offset.zero);
    return pos.dy + box.size.height;
  }

  String _getTimeBasedGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  void _handleFeedback(String feedback) {
    setState(() => _selectedFeedback = feedback);
    print('User feedback: $feedback');
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const FeedbackWebViewScreen()),
    );
  }

  String _getHealthImage(String status) {
    final normalized = status.toLowerCase().trim();
    switch (normalized) {
      case 'stabilizing':
        return 'assets/images/Financial_Health/JARS/HIVE BAR STABILISING.png';
      case 'surviving':
        return 'assets/images/Financial_Health/JARS/HIVE BAR SURVIVING.png';
      case 'flourishing':
        return 'assets/images/Financial_Health/JARS/HIVE BAR FLOURISHING.png';
      case 'thriving':
        return 'assets/images/Financial_Health/JARS/HIVE BAR THRIVING.png';
      case 'building':
        return 'assets/images/Financial_Health/JARS/HIVE BAR BUILDING.png';
      default:
        return 'assets/images/Financial_Health/JARS/HIVE BAR EMPTY.png';
    }
  }

  String _getPopUpImage(String status) {
    final normalized = status.toLowerCase().trim();
    switch (normalized) {
      case 'stabilizing':
        return 'assets/images/illustrations/health/stabilizing.png';
      case 'surviving':
        return 'assets/images/illustrations/health/surviving.png';
      case 'flourishing':
        return 'assets/images/illustrations/health/flourishing.png';
      case 'thriving':
        return 'assets/images/illustrations/health/thriving.png';
      case 'building':
        return 'assets/images/illustrations/health/building.png';
      default:
        return 'assets/images/illustrations/health/stabilizing.png';
    }
  }

  void _showHealthPopup(String statusText) {
    final popupImage = _getPopUpImage(statusText);
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.9,
                  maxHeight: MediaQuery.of(context).size.height * 0.7,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(popupImage, fit: BoxFit.contain),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // ── Logout handler ────────────────────────────────────────────────────────
  void _handleLoggedOut() {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('You are logged out. Please login again.'),
        backgroundColor: Colors.redAccent,
        duration: Duration(seconds: 4),
      ),
    );

    // Invalidate stale data so they don't re-trigger logout on the next login.
    ref.invalidate(homeDataProvider);
    ref.invalidate(allCoursesProvider);

    ref.read(authProvider.notifier).logout();
    ref.read(bottomNavIndexProvider.notifier).state = 0;

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        context.goNamed(LoginScreen.path);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final homeDataAsync = ref.watch(homeDataProvider);
    final coursesAsync = ref.watch(allCoursesProvider);

    final firstName = homeDataAsync.valueOrNull?.data?.firstName ?? '';
    final isInitialLoading = homeDataAsync.isLoading && !homeDataAsync.hasValue;
    final hasError = homeDataAsync.hasError;

    // Extract error safely
    final error = homeDataAsync.error;
    final errorMsgLower = error?.toString().toLowerCase() ?? '';
    final isLoggedOutError =
        error != null &&
        (errorMsgLower.contains('logged out') ||
            errorMsgLower.contains('session expired') ||
            errorMsgLower.contains('unauthorized') ||
            errorMsgLower.contains('401'));

    // Auto-logout on detected logged-out / unauthorized error
    if (hasError && isLoggedOutError && !_isRetrying) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _handleLoggedOut();
      });
    }

    return Stack(
      children: [
        Scaffold(
          appBar: _buildAppBar(
            firstName,
            context,
            !isInitialLoading && !hasError,
          ),
          floatingActionButton: _buildHealthJarFAB(
            homeDataAsync.valueOrNull?.data?.aiData?.status ?? '',
          ),
          body: Stack(
            children: [
              // ── Main content ───────────────────────────────────────────────
              ListView(
                children: [
                  const Gap(6),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Hi, $firstName",
                          style: const TextStyle(
                            fontFamily: 'GeneralSans',
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                            letterSpacing: 0.48,
                          ),
                        ),
                        Text(
                          _getTimeBasedGreeting(),
                          style: const TextStyle(
                            fontFamily: 'GeneralSans',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                            letterSpacing: 0.24,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Gap(24),

                  // Complete Setup card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: CompleteSetupCard(
                      completedCount: 0,
                      totalCount: 3,
                      firstItemKey: _budgetItemKey,
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

                  // Courses section
                  coursesAsync.when(
                    data: (courses) => Column(
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
                              letterSpacing: 0.24,
                            ),
                          ),
                        ),
                        const Gap(16),
                        SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            spacing: 12,
                            children: courses
                                .asMap()
                                .entries
                                .map(
                                  (e) => _buildCourseCard(
                                    course: e.value,
                                    color: AppColors.primary,
                                    imagePath:
                                        courseImagePaths[e.key %
                                            courseImagePaths.length],
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ],
                    ),
                    error: (_, __) => const SizedBox.shrink(),
                    loading: () => const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 32,
                      ),
                      child: Center(child: CustomLoadingWidget()),
                    ),
                  ),

                  const Gap(24),

                  // Insights
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
Your credit score is not just a number, it's your financial CV in today's Nigeria.
''',
                            ),
                          );
                        },
                      ),
                      LearnCard(
                        imagePath: 'assets/images/other/insights-two.jpg',
                        title: 'How to build an emergency fund on a...',
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
                                  '''An emergency fund isn't a luxury, it's your financial seatbelt. Life doesn't wait for you to be ready, and having a safety net can mean the difference between a setback and a crisis. But when money is tight, building one can feel impossible.

The good news? You don't need to save thousands overnight. The key is starting small, staying consistent, and making your money move without you even noticing.

Ask yourself these three starter questions:

●	Do I know what a true "emergency" is for me?
●	Can I find even ₦100 a day to redirect?
●	Am I willing to automate the process so I don't have to think about it?

If you answered "yes," you're already on your way. The hardest part is simply beginning. Need a plan? We've got you covered.
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
                              imagePath:
                                  'assets/images/other/insights-three.jpg',
                              readTimeMinutes: 3,
                              content:
                                  '''Saving as a couple is about more than just pooling funds, it's a powerful way to build trust, strengthen communication, and bring your shared dreams to life. But before you open a joint account, it's important to pause and reflect.

Not every couple is ready to save together, and that's okay. The key is honesty and alignment. Start by asking yourselves three important questions:

Do we share the same goals?

Are we both committed to contributing regularly?

Can we talk about money openly?
If you answered "yes" to all these questions, you're ready to take the next step toward building a stronger financial future together. Still not sure?
''',
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const Gap(24),

                  // AI Budget Insight
                  if (homeDataAsync.valueOrNull?.data?.insightAdvice?.budgetInsight.isNotEmpty == true) ...[
                    const Gap(24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SmartRecommendationCard(
                        title: 'BUDGET INSIGHT',
                        description: homeDataAsync.valueOrNull!.data!.insightAdvice!.budgetInsight,
                        buttonText: 'View Spending',
                        showFeedback: false,
                        onButtonPressed: () => context.pushNamed(BudgetsScreen.path),
                      ),
                    ),
                  ],

                  if (_showRecommendation) const Gap(24),
                  _buildFeedbackSection(),
                ],
              ),

              // ── Loading / Retrying overlay ─────────────────────────────────
              if (_isRetrying || (isInitialLoading && !hasError))
                Positioned.fill(
                  child: Container(
                    color: Colors.white.withOpacity(0.9),
                    child: const Center(child: CustomLoadingWidget()),
                  ),
                ),

              // ── Error overlay ──────────────────────────────────────────────
              if (hasError && !_isRetrying)
                Positioned.fill(
                  child: Material(
                    color: Colors.white,
                    child: SafeArea(
                      child: CustomErrorWidget(
                        icon: Icons.person_outline,
                        title: 'Unable to Load User Info',
                        subtitle: isLoggedOutError
                            ? 'Your session has expired. Logging you out...'
                            : 'We couldn\'t fetch your account data. Please check your connection and try again.',
                        actionButtonText: _isRetrying ? 'Retrying...' : 'Retry',
                        onActionPressed: isLoggedOutError || _isRetrying
                            ? null
                            : () async {
                                setState(() => _isRetrying = true);
                                try {
                                  ref.invalidate(homeDataProvider);
                                  ref.invalidate(allCoursesProvider);
                                  await Future.delayed(
                                    const Duration(milliseconds: 3000),
                                  );
                                } finally {
                                  if (mounted) {
                                    setState(() => _isRetrying = false);
                                  }
                                }
                              },
                        onLogoutPressed: _handleLoggedOut,
                        logoutButtonText: 'Logout',
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Walkthrough overlay
        if (_walkthroughChecked && _isWalkthroughActive)
          Positioned.fill(
            child: _WalkthroughOverlay(
              step: _walkthroughStep,
              currentImage: _currentWalkthroughImage!,
              budgetArrowY: _walkthroughStep == _WalkthroughStep.budget
                  ? _getBudgetItemArrowY()
                  : null,
              onTap: _advanceWalkthrough,
            ),
          ),
      ],
    );
  }

  // ── AppBar, FAB, Course card, Feedback section ─────────────────────────────
  // (These remain unchanged – included here only for completeness)

  AppBar _buildAppBar(String firstName, BuildContext context, bool isEnabled) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      toolbarHeight: 56,
      titleSpacing: 0,
      title: Row(
        children: [
          Expanded(
            flex: 27,
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
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
                  Image.asset(
                    'assets/images/topbar/nav-center-icon.png',
                    width: 30,
                    height: 32,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 23,
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Opacity(
                    opacity: isEnabled ? 1.0 : 0.5,
                    child: GestureDetector(
                      onTap: isEnabled
                          ? () =>
                                context.pushNamed(ProfileScreen.path, extra: '')
                          : null,
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
                                ? firstName
                                      .substring(
                                        0,
                                        firstName.length > 1 ? 2 : 1,
                                      )
                                      .toUpperCase()
                                : 'Me',
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
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthJarFAB(String statusText) {
    final healthImage = _getHealthImage(statusText);
    return FloatingActionButton(
      onPressed: () => _showHealthPopup(statusText),
      backgroundColor: Colors.transparent,
      elevation: 4,
      shape: const CircleBorder(),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFFFEFB5),
          border: Border.all(color: const Color(0xFFFFC300), width: 1),
        ),
        child: Image.asset(
          healthImage,
          fit: BoxFit.contain,
          width: 40,
          height: 40,
        ),
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
          border: Border.all(color: AppColors.grey.withOpacity(0.2), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(32)),
                child: Image.asset(
                  imagePath,
                  width: 230,
                  height: 230,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.courseTitle,
                    style: const TextStyle(
                      fontSize: 16,
                      fontFamily: 'GeneralSans',
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                      letterSpacing: 0.32,
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
                      letterSpacing: 0.24,
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
              style: const TextStyle(
                fontSize: 12,
                fontFamily: 'GeneralSans',
                color: Colors.black87,
              ),
              children: [
                const TextSpan(text: 'How can we help? '),
                const TextSpan(
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
          color: isSelected ? AppColors.success.withOpacity(0.2) : Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected
                ? AppColors.success
                : Colors.black.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Center(child: Text(emoji, style: const TextStyle(fontSize: 24))),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Walkthrough Overlay (unchanged)
// ─────────────────────────────────────────────────────────────────────────────

class _WalkthroughOverlay extends StatelessWidget {
  const _WalkthroughOverlay({
    required this.step,
    required this.currentImage,
    required this.onTap,
    this.budgetArrowY,
  });

  final _WalkthroughStep step;
  final String currentImage;
  final VoidCallback onTap;
  final double? budgetArrowY;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final appWidth = constraints.maxWidth;

        return GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Stack(
            fit: StackFit.expand,
            children: [
              ColoredBox(color: Colors.black.withOpacity(0.55)),
              if (step == _WalkthroughStep.budget && budgetArrowY != null)
                Positioned(
                  top: budgetArrowY! + 4,
                  left: 24,
                  child: IgnorePointer(
                    child: Image.asset(
                      'assets/images/walk_through/home_arrow.png',
                      width: 80,
                      height: 48,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Image.asset(
                  currentImage,
                  width: appWidth * 0.65,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:gap/gap.dart';
// import 'package:go_router/go_router.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
// import 'package:savvy_bee_mobile/core/utils/assets/app_icons.dart';
// import 'package:savvy_bee_mobile/core/utils/assets/illustrations.dart';
// import 'package:savvy_bee_mobile/core/utils/constants.dart';
// import 'package:savvy_bee_mobile/core/widgets/article_card.dart';
// import 'package:savvy_bee_mobile/core/widgets/custom_card.dart';
// import 'package:savvy_bee_mobile/core/widgets/dot.dart';
// import 'package:savvy_bee_mobile/core/widgets/icon_text_row_widget.dart';
// import 'package:savvy_bee_mobile/core/widgets/main_wrapper.dart';
// import 'package:savvy_bee_mobile/core/widgets/section_title_widget.dart';
// import 'package:savvy_bee_mobile/features/auth/presentation/providers/auth_providers.dart';
// import 'package:savvy_bee_mobile/features/auth/presentation/screens/login_screen.dart';
// import 'package:savvy_bee_mobile/features/chat/presentation/screens/chat_screen.dart';
// import 'package:savvy_bee_mobile/features/hive/domain/models/course.dart';
// import 'package:savvy_bee_mobile/features/home/domain/models/blog_post.dart';
// import 'package:savvy_bee_mobile/features/home/presentation/providers/home_data_provider.dart';
// import 'package:savvy_bee_mobile/features/home/presentation/screens/feedback_webview.dart';
// import 'package:savvy_bee_mobile/features/home/presentation/widgets/action_prompt_card.dart';
// import 'package:savvy_bee_mobile/features/home/presentation/widgets/blog_post_bottom_sheet.dart';
// import 'package:savvy_bee_mobile/features/home/presentation/widgets/complete_setup.dart';
// import 'package:savvy_bee_mobile/features/home/presentation/widgets/insights.dart';
// import 'package:savvy_bee_mobile/features/home/presentation/widgets/smart_recommendations.dart';
// import 'package:savvy_bee_mobile/features/profile/presentation/screens/contact_us_screen.dart';
// import 'package:savvy_bee_mobile/features/profile/presentation/screens/profile_screen.dart';
// import 'package:savvy_bee_mobile/features/spend/presentation/screens/wallet/nin_verification_screen.dart';
// import 'package:savvy_bee_mobile/features/tools/presentation/screens/budget/budget_screen.dart';
// import 'package:savvy_bee_mobile/features/tools/presentation/screens/budget/budgets_screen.dart';
// import 'package:savvy_bee_mobile/features/tools/presentation/screens/debt/debt_screen.dart';
// import 'package:savvy_bee_mobile/features/tools/presentation/screens/goals/goals_screen.dart';

// import '../../../../core/widgets/custom_error_widget.dart';
// import '../../../../core/widgets/custom_loading_widget.dart';
// import '../../../dashboard/presentation/widgets/info_card.dart';
// import '../../../hive/presentation/providers/course_providers.dart';
// import '../../../hive/presentation/screens/lesson/lesson_home_screen.dart';
// import '../widgets/health_card.dart';

// // ─────────────────────────────────────────────────────────────────────────────
// // Walkthrough step enum
// // ─────────────────────────────────────────────────────────────────────────────
// enum _WalkthroughStep { welcome, cheerful, budget, done }

// // ─────────────────────────────────────────────────────────────────────────────
// // SharedPreferences key
// // ─────────────────────────────────────────────────────────────────────────────
// const _kWalkthroughCompletedKey = 'home_walkthrough_completed';

// class HomeScreen extends ConsumerStatefulWidget {
//   static const String path = '/home';

//   const HomeScreen({super.key});

//   @override
//   ConsumerState<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends ConsumerState<HomeScreen> {
//   // ── Walkthrough state ─────────────────────────────────────────────────────
//   _WalkthroughStep _walkthroughStep = _WalkthroughStep.done; // hidden until checked
//   bool _walkthroughChecked = false;

//   // ── Budget item key (used to position the arrow) ──────────────────────────
//   final GlobalKey _budgetItemKey = GlobalKey();

//   // ── Original state ────────────────────────────────────────────────────────
//   final courseImagePaths = [
//     'assets/images/other/learn-one.jpg',
//     'assets/images/other/learn-three.jpg',
//     'assets/images/other/learn-two.jpg',
//   ];
//   final recentInsightsImagePaths = [
//     Illustrations.matchingAndQuizBee,
//     Illustrations.dash,
//   ];

//   bool _showRecommendation = true;
//   String? _selectedFeedback;

//   // ─────────────────────────────────────────────────────────────────────────
//   // Lifecycle
//   // ─────────────────────────────────────────────────────────────────────────
//   @override
//   void initState() {
//     super.initState();
//     _showRecommendation = true;

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       ref.invalidate(homeDataProvider);
//       ref.invalidate(allCoursesProvider);
//       _checkWalkthrough();
//     });
//   }

//   // ─────────────────────────────────────────────────────────────────────────
//   // Walkthrough helpers
//   // ─────────────────────────────────────────────────────────────────────────

//   Future<void> _checkWalkthrough() async {
//     final prefs = await SharedPreferences.getInstance();
//     final completed = prefs.getBool(_kWalkthroughCompletedKey) ?? false;
//     if (!completed && mounted) {
//       setState(() {
//         _walkthroughStep = _WalkthroughStep.welcome;
//         _walkthroughChecked = true;
//       });
//     } else {
//       setState(() => _walkthroughChecked = true);
//     }
//   }

//   Future<void> _advanceWalkthrough() async {
//     switch (_walkthroughStep) {
//       case _WalkthroughStep.welcome:
//         setState(() => _walkthroughStep = _WalkthroughStep.cheerful);
//         break;
//       case _WalkthroughStep.cheerful:
//         setState(() => _walkthroughStep = _WalkthroughStep.budget);
//         break;
//       case _WalkthroughStep.budget:
//         // Mark as completed persistently
//         final prefs = await SharedPreferences.getInstance();
//         await prefs.setBool(_kWalkthroughCompletedKey, true);
//         if (mounted) {
//           setState(() => _walkthroughStep = _WalkthroughStep.done);
//         }
//         break;
//       case _WalkthroughStep.done:
//         break;
//     }
//   }

//   bool get _isWalkthroughActive => _walkthroughStep != _WalkthroughStep.done;

//   String? get _currentWalkthroughImage {
//     switch (_walkthroughStep) {
//       case _WalkthroughStep.welcome:
//         return 'assets/images/walk_through/home_welcome.png';
//       case _WalkthroughStep.cheerful:
//         return 'assets/images/walk_through/home_cheerful.png';
//       case _WalkthroughStep.budget:
//         return 'assets/images/walk_through/home_budget.png';
//       case _WalkthroughStep.done:
//         return null;
//     }
//   }

//   // Returns the Y offset (from top of screen) just below the "Set up Budgeting"
//   // row so we can absolutely position the arrow.
//   double? _getBudgetItemArrowY() {
//     final ctx = _budgetItemKey.currentContext;
//     if (ctx == null) return null;
//     final box = ctx.findRenderObject() as RenderBox?;
//     if (box == null) return null;
//     final pos = box.localToGlobal(Offset.zero);
//     return pos.dy + box.size.height; // just below the item
//   }

//   // ─────────────────────────────────────────────────────────────────────────
//   // Original helpers (unchanged)
//   // ─────────────────────────────────────────────────────────────────────────

//   String _getTimeBasedGreeting() {
//     final hour = DateTime.now().hour;
//     if (hour < 12) return 'Good morning';
//     if (hour < 17) return 'Good afternoon';
//     return 'Good evening';
//   }

//   void _handleFeedback(String feedback) {
//     setState(() => _selectedFeedback = feedback);
//     print('User feedback: $feedback');
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (_) => const FeedbackWebViewScreen()),
//     );
//   }

//   String _getHealthImage(String status) {
//     final normalizedStatus = status.toLowerCase().trim();
//     switch (normalizedStatus) {
//       case 'stabilizing':
//         return 'assets/images/Financial_Health/JARS/HIVE BAR STABILISING.png';
//       case 'surviving':
//         return 'assets/images/Financial_Health/JARS/HIVE BAR SURVIVING.png';
//       case 'flourishing':
//         return 'assets/images/Financial_Health/JARS/HIVE BAR FLOURISHING.png';
//       case 'thriving':
//         return 'assets/images/Financial_Health/JARS/HIVE BAR THRIVING.png';
//       case 'building':
//         return 'assets/images/Financial_Health/JARS/HIVE BAR BUILDING.png';
//       default:
//         return 'assets/images/Financial_Health/JARS/HIVE BAR EMPTY.png';
//     }
//   }

//   String _getPopUpImage(String status) {
//     final normalizedStatus = status.toLowerCase().trim();
//     switch (normalizedStatus) {
//       case 'stabilizing':
//         return 'assets/images/illustrations/health/stabilizing.png';
//       case 'surviving':
//         return 'assets/images/illustrations/health/surviving.png';
//       case 'flourishing':
//         return 'assets/images/illustrations/health/flourishing.png';
//       case 'thriving':
//         return 'assets/images/illustrations/health/thriving.png';
//       case 'building':
//         return 'assets/images/illustrations/health/building.png';
//       default:
//         return 'assets/images/illustrations/health/stabilizing.png';
//     }
//   }

//   void _showHealthPopup(String statusText) {
//     final popupImage = _getPopUpImage(statusText);
//     showDialog(
//       context: context,
//       barrierDismissible: true,
//       barrierColor: Colors.black.withOpacity(0.7),
//       builder: (context) => Dialog(
//         backgroundColor: Colors.transparent,
//         insetPadding: const EdgeInsets.symmetric(horizontal: 24),
//         child: GestureDetector(
//           onTap: () => Navigator.of(context).pop(),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Container(
//                 constraints: BoxConstraints(
//                   maxWidth: MediaQuery.of(context).size.width * 0.9,
//                   maxHeight: MediaQuery.of(context).size.height * 0.7,
//                 ),
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(16),
//                   child: Image.asset(popupImage, fit: BoxFit.contain),
//                 ),
//               ),
//               const SizedBox(height: 16),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // ─────────────────────────────────────────────────────────────────────────
//   // Build
//   // ─────────────────────────────────────────────────────────────────────────

//   @override
//   Widget build(BuildContext context) {
//     final homeDataAsync = ref.watch(homeDataProvider);
//     final coursesAsync = ref.watch(allCoursesProvider);

//     final firstName = homeDataAsync.valueOrNull?.data?.firstName ?? '';
//     final isInitialLoading = homeDataAsync.isLoading && !homeDataAsync.hasValue;
//     final hasError = homeDataAsync.hasError && homeDataAsync.error != null;
//     final isAvatarEnabled = !isInitialLoading;
//     final healthData = homeDataAsync.valueOrNull?.data?.aiData;
//     final statusText = healthData?.status ?? '';

//     return Stack(
//       children: [
//         Scaffold(
//           appBar: _buildAppBar(firstName, context, isAvatarEnabled),
//           floatingActionButton: _buildHealthJarFAB(statusText),
//           body: Stack(
//             children: [
//           // ── Main content ──────────────────────────────────────────────────
//           ListView(
//             children: [
//               const Gap(6),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       "Hi, $firstName",
//                       style: const TextStyle(
//                         fontFamily: 'GeneralSans',
//                         fontSize: 24,
//                         fontWeight: FontWeight.w500,
//                         color: Colors.black,
//                         letterSpacing: 0.48,
//                       ),
//                     ),
//                     Text(
//                       _getTimeBasedGreeting(),
//                       style: const TextStyle(
//                         fontFamily: 'GeneralSans',
//                         fontSize: 12,
//                         fontWeight: FontWeight.w500,
//                         color: Colors.black,
//                         letterSpacing: 0.24,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const Gap(24),

//               // ── Complete Setup card – firstItemKey measures the budget row ──
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 child: CompleteSetupCard(
//                   completedCount: 0,
//                   totalCount: 3,
//                   firstItemKey: _budgetItemKey, // ← attaches to the first _SetupItemTile widget
//                   items: [
//                     SetupItem(
//                       icon: 'assets/icons/Calculator.png',
//                       title: 'Set up Budgeting',
//                       subtitle: 'Take control of your spending',
//                       onTap: () => context.pushNamed(BudgetsScreen.path),
//                     ),
//                     SetupItem(
//                       icon: 'assets/icons/Square-Check.png',
//                       title: 'Start saving with Goals',
//                       subtitle: 'Start a new goal',
//                       onTap: () => context.pushNamed(GoalsScreen.path),
//                     ),
//                     SetupItem(
//                       icon: 'assets/icons/BookOpen.png',
//                       title: 'Reduce your Debt',
//                       subtitle: 'A smarter way to track existing debt',
//                       onTap: () => context.pushNamed(DebtScreen.path),
//                     ),
//                   ],
//                 ),
//               ),
//               const Gap(24),

//               // ── Courses ───────────────────────────────────────────────────
//               coursesAsync.when(
//                 data: (courses) => Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 16),
//                       child: Text(
//                         'LEARN & GROW',
//                         style: TextStyle(
//                           fontSize: 12,
//                           fontFamily: 'GeneralSans',
//                           fontWeight: FontWeight.w500,
//                           color: AppColors.grey,
//                           letterSpacing: 0.24,
//                         ),
//                       ),
//                     ),
//                     const Gap(16),
//                     SingleChildScrollView(
//                       padding: const EdgeInsets.symmetric(horizontal: 16),
//                       scrollDirection: Axis.horizontal,
//                       child: Row(
//                         spacing: 12,
//                         mainAxisSize: MainAxisSize.min,
//                         children: courses
//                             .map(
//                               (course) => _buildCourseCard(
//                                 course: course,
//                                 color: AppColors.primary,
//                                 imagePath: courseImagePaths[courses.indexOf(course)],
//                               ),
//                             )
//                             .toList(),
//                       ),
//                     ),
//                   ],
//                 ),
//                 error: (_, __) => const SizedBox.shrink(),
//                 loading: () => Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
//                   child: Center(
//                     child: SizedBox(
//                       width: 32,
//                       height: 32,
//                       child: CircularProgressIndicator(
//                         strokeWidth: 2.5,
//                         valueColor: AlwaysStoppedAnimation<Color>(
//                           AppColors.primary.withOpacity(0.7),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),

//               const Gap(24),

//               InsightsSection(
//                 cards: [
//                   LearnCard(
//                     imagePath: 'assets/images/other/insights-one.jpg',
//                     title: 'The art of credit scoring in Nigeria',
//                     description: '📖 3 min story',
//                     onTap: () {
//                       showBlogPostBottomSheet(
//                         context,
//                         BlogPost(
//                           category: 'FROM SAVVY BLOG',
//                           title: 'The Art of Credit Scoring in Nigeria',
//                           subtitle: 'Are you really listening to what they\'re saying',
//                           date: 'January, 2026',
//                           imagePath: 'assets/images/other/insights-one.jpg',
//                           readTimeMinutes: 3,
//                           content:
//                               '''Credit scoring isn't just an "abroad" thing, it's already shaping financial lives in Nigeria. Every time you apply for a loan, buy a phone on credit, or even use some fintech apps, your credit score is being checked. Yet, many Nigerians still think it's a foreign concept.
// The truth? Your financial reputation is now a digital score, and it can open doors or close them. Understanding how it works here, in our own system, is the first step to using it to your advantage.
// Ask yourself:
// ●	Do I know my credit score is being tracked right now?
// ●	Do I understand how my daily money habits affect it?
// ●	Am I building a score that will help me or hold me back?
// Your credit score is not just a number, it's your financial CV in today's Nigeria.
// ''',
//                         ),
//                       );
//                     },
//                   ),
//                   LearnCard(
//                     imagePath: 'assets/images/other/insights-two.jpg',
//                     title: 'How to build an emergency fund on a...',
//                     description: '📖 3 min story',
//                     onTap: () {
//                       showBlogPostBottomSheet(
//                         context,
//                         BlogPost(
//                           category: 'FROM SAVVY BLOG',
//                           title: 'How to build an emergency fund on a tight budget',
//                           subtitle: 'Small steps, big security',
//                           date: 'January, 2026',
//                           imagePath: 'assets/images/other/insights-two.jpg',
//                           readTimeMinutes: 3,
//                           content:
//                               '''An emergency fund isn't a luxury, it's your financial seatbelt. Life doesn't wait for you to be ready, and having a safety net can mean the difference between a setback and a crisis. But when money is tight, building one can feel impossible.

// The good news? You don't need to save thousands overnight. The key is starting small, staying consistent, and making your money move without you even noticing.

// Ask yourself these three starter questions:

// ●	Do I know what a true "emergency" is for me?
// ●	Can I find even ₦100 a day to redirect?
// ●	Am I willing to automate the process so I don't have to think about it?

// If you answered "yes," you're already on your way. The hardest part is simply beginning. Need a plan? We've got you covered.
// ''',
//                         ),
//                       );
//                     },
//                   ),
//                   LearnCard(
//                     imagePath: 'assets/images/other/insights-three.jpg',
//                     title: 'Should i save financially with my partner?',
//                     description: '📖 3 min story',
//                     onTap: () {
//                       showBlogPostBottomSheet(
//                         context,
//                         BlogPost(
//                           category: 'FROM SAVVY BLOG',
//                           title: 'Should you save financially with your partner?',
//                           subtitle: 'Let\'s get financially intimate',
//                           date: 'January, 2026',
//                           imagePath: 'assets/images/other/insights-three.jpg',
//                           readTimeMinutes: 3,
//                           content:
//                               '''Saving as a couple is about more than just pooling funds, it's a powerful way to build trust, strengthen communication, and bring your shared dreams to life. But before you open a joint account, it's important to pause and reflect.

// Not every couple is ready to save together, and that's okay. The key is honesty and alignment. Start by asking yourselves three important questions:

// Do we share the same goals?

// Are we both committed to contributing regularly?

// Can we talk about money openly?
// If you answered "yes" to all these questions, you're ready to take the next step toward building a stronger financial future together. Still not sure?
// ''',
//                         ),
//                       );
//                     },
//                   ),
//                 ],
//               ),
//               const Gap(24),

//               if (_showRecommendation) const Gap(24),
//               _buildFeedbackSection(),
//             ],
//           ),

//         ],
//       ),
//         ), // end Scaffold

//         // ── Walkthrough overlay – sits above the entire Scaffold (AppBar + FAB included) ──
//         if (_walkthroughChecked && _isWalkthroughActive)
//           _WalkthroughOverlay(
//             step: _walkthroughStep,
//             currentImage: _currentWalkthroughImage!,
//             budgetArrowY: _walkthroughStep == _WalkthroughStep.budget
//                 ? _getBudgetItemArrowY()
//                 : null,
//             onTap: _advanceWalkthrough,
//           ),

//         // ── Error overlay – topmost layer, covers AppBar + FAB + walkthrough ──
//         // Uses a white full-screen background so nothing beneath bleeds through.
//         if (hasError)
//           Positioned.fill(
//             child: Material(
//               color: Colors.white,
//               child: SafeArea(
//                 child: CustomErrorWidget(
//                   icon: Icons.person_outline,
//                   title: 'Unable to Load User Info',
//                   subtitle:
//                       'We couldn\'t fetch your account data. Please check your connection and try again.',
//                   actionButtonText: 'Retry',
//                   onActionPressed: () {
//                     ref.invalidate(homeDataProvider);
//                     ref.invalidate(allCoursesProvider);
//                   },
//                   onLogoutPressed: () {
//                     ref.read(authProvider.notifier).logout();
//                     ref.read(bottomNavIndexProvider.notifier).state = 0;
//                     context.goNamed(LoginScreen.path);
//                   },
//                   logoutButtonText: 'Logout',
//                 ),
//               ),
//             ),
//           ),
//       ],
//     );
//   }

//   // ─────────────────────────────────────────────────────────────────────────
//   // AppBar (unchanged)
//   // ─────────────────────────────────────────────────────────────────────────

//   AppBar _buildAppBar(String firstName, BuildContext context, bool isEnabled) {
//     return AppBar(
//       backgroundColor: Colors.white,
//       elevation: 0,
//       automaticallyImplyLeading: false,
//       toolbarHeight: 56,
//       titleSpacing: 0,
//       title: Row(
//         children: [
//           Expanded(
//             flex: 27,
//             child: Padding(
//               padding: const EdgeInsets.only(left: 16),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   InkWell(
//                     onTap: () => context.pushNamed(ChatScreen.path),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Container(
//                           width: 32,
//                           height: 32,
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             border: Border.all(color: AppColors.primary),
//                           ),
//                           child: Center(
//                             child: Image.asset(
//                               'assets/images/topbar/nav-left-icon.png',
//                               width: 32,
//                               height: 32,
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 6),
//                         const Text(
//                           'Chat with Nahl',
//                           style: TextStyle(
//                             fontFamily: 'GeneralSans',
//                             fontSize: 12,
//                             fontWeight: FontWeight.w500,
//                             color: Colors.black,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Image.asset(
//                     'assets/images/topbar/nav-center-icon.png',
//                     width: 30,
//                     height: 32,
//                     fit: BoxFit.contain,
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           Expanded(
//             flex: 23,
//             child: Padding(
//               padding: const EdgeInsets.only(right: 16),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   Opacity(
//                     opacity: isEnabled ? 1.0 : 0.5,
//                     child: GestureDetector(
//                       onTap: isEnabled
//                           ? () => context.pushNamed(ProfileScreen.path, extra: '')
//                           : null,
//                       child: Container(
//                         width: 32,
//                         height: 32,
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           shape: BoxShape.circle,
//                           border: Border.all(color: Colors.black, width: 1),
//                         ),
//                         child: Center(
//                           child: Text(
//                             firstName.isNotEmpty
//                                 ? (firstName.length > 1
//                                       ? firstName.substring(0, 2).toUpperCase()
//                                       : firstName[0].toUpperCase())
//                                 : 'Me',
//                             style: const TextStyle(
//                               fontFamily: 'GeneralSans',
//                               fontWeight: FontWeight.w500,
//                               fontSize: 16,
//                               color: Colors.black,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ─────────────────────────────────────────────────────────────────────────
//   // FAB (unchanged)
//   // ─────────────────────────────────────────────────────────────────────────

//   Widget _buildHealthJarFAB(String statusText) {
//     final healthImage = _getHealthImage(statusText);
//     return FloatingActionButton(
//       onPressed: () => _showHealthPopup(statusText),
//       backgroundColor: Colors.transparent,
//       elevation: 4,
//       shape: const CircleBorder(),
//       child: Container(
//         width: 48,
//         height: 48,
//         decoration: BoxDecoration(
//           shape: BoxShape.circle,
//           color: const Color(0xFFFFEFB5),
//           border: Border.all(color: const Color(0xFFFFC300), width: 1),
//         ),
//         child: Image.asset(healthImage, fit: BoxFit.contain, width: 40, height: 40),
//       ),
//     );
//   }

//   // ─────────────────────────────────────────────────────────────────────────
//   // Course card (unchanged)
//   // ─────────────────────────────────────────────────────────────────────────

//   Widget _buildCourseCard({
//     required Course course,
//     required Color color,
//     required String imagePath,
//   }) {
//     return GestureDetector(
//       onTap: () => context.pushNamed(LessonHomeScreen.path, extra: course),
//       child: Container(
//         width: 238,
//         padding: const EdgeInsets.only(top: 4),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(32),
//           border: Border.all(color: AppColors.grey.withOpacity(0.2), width: 1),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 8,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Center(
//               child: ClipRRect(
//                 borderRadius: const BorderRadius.all(Radius.circular(32)),
//                 child: Image.asset(imagePath, width: 230, height: 230, fit: BoxFit.cover),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     course.courseTitle,
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontFamily: 'GeneralSans',
//                       fontWeight: FontWeight.w500,
//                       color: Colors.black,
//                       letterSpacing: 0.32,
//                     ),
//                   ),
//                   const Gap(8),
//                   Text(
//                     course.courseDescription,
//                     style: TextStyle(
//                       fontSize: 12,
//                       fontFamily: 'GeneralSans',
//                       fontWeight: FontWeight.w500,
//                       color: AppColors.grey,
//                       height: 1.4,
//                       letterSpacing: 0.24,
//                     ),
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ─────────────────────────────────────────────────────────────────────────
//   // Feedback section (unchanged)
//   // ─────────────────────────────────────────────────────────────────────────

//   Widget _buildFeedbackSection() {
//     return Column(
//       children: [
//         Text(
//           'HOW ARE YOU LIKING SAVVY BEE?',
//           style: TextStyle(
//             fontSize: 12,
//             fontFamily: 'GeneralSans',
//             fontWeight: FontWeight.w500,
//             color: Colors.black,
//             letterSpacing: 0.5,
//           ),
//         ),
//         const Gap(16),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           children: [
//             _buildFeedbackIcon('very_sad', '😞', _selectedFeedback == 'very_sad'),
//             _buildFeedbackIcon('sad', '😕', _selectedFeedback == 'sad'),
//             _buildFeedbackIcon('neutral', '😊', _selectedFeedback == 'neutral'),
//             _buildFeedbackIcon('happy', '😃', _selectedFeedback == 'happy'),
//           ],
//         ),
//         const Gap(16),
//         TextButton(
//           onPressed: () => context.pushNamed(ContactUsScreen.path),
//           child: RichText(
//             textAlign: TextAlign.center,
//             text: TextSpan(
//               style: const TextStyle(
//                 fontSize: 12,
//                 fontFamily: 'GeneralSans',
//                 color: Colors.black87,
//               ),
//               children: [
//                 const TextSpan(text: 'How can we help? '),
//                 const TextSpan(
//                   text: 'Contact Us.',
//                   style: TextStyle(
//                     fontWeight: FontWeight.w600,
//                     decoration: TextDecoration.underline,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildFeedbackIcon(String value, String emoji, bool isSelected) {
//     return GestureDetector(
//       onTap: () => _handleFeedback(value),
//       child: Container(
//         width: 48,
//         height: 48,
//         decoration: BoxDecoration(
//           color: isSelected ? AppColors.success.withOpacity(0.2) : Colors.white,
//           shape: BoxShape.circle,
//           border: Border.all(
//             color: isSelected ? AppColors.success : Colors.black.withOpacity(0.2),
//             width: isSelected ? 2 : 1,
//           ),
//         ),
//         child: Center(child: Text(emoji, style: const TextStyle(fontSize: 24))),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────────────────────
// // _WalkthroughOverlay  (pure widget, no business logic)
// // ─────────────────────────────────────────────────────────────────────────────

// class _WalkthroughOverlay extends StatelessWidget {
//   const _WalkthroughOverlay({
//     required this.step,
//     required this.currentImage,
//     required this.onTap,
//     this.budgetArrowY,
//   });

//   final _WalkthroughStep step;
//   final String currentImage;
//   final VoidCallback onTap;

//   /// Absolute Y position (from top of screen) where the arrow should appear.
//   /// Only used when [step] == [_WalkthroughStep.budget].
//   final double? budgetArrowY;

//   @override
//   Widget build(BuildContext context) {
//     final screenSize = MediaQuery.of(context).size;

//     return GestureDetector(
//       // Tapping anywhere on the overlay (including the dark area) advances the
//       // walkthrough, keeping the UX frictionless.
//       onTap: onTap,
//       child: Stack(
//         children: [
//           // ── Dark semi-transparent backdrop ────────────────────────────────
//           Container(
//             width: screenSize.width,
//             height: screenSize.height,
//             color: Colors.black.withOpacity(0.55),
//           ),

//           // ── Arrow (only on the budget step) ──────────────────────────────
//           if (step == _WalkthroughStep.budget && budgetArrowY != null)
//             Positioned(
//               top: budgetArrowY! + 4,  // 4 px gap below the row
//               left: 24,
//               child: IgnorePointer(
//                 child: Image.asset(
//                   'assets/images/walk_through/home_arrow.png',
//                   width: 80,
//                   height: 48,
//                   fit: BoxFit.contain,
//                 ),
//               ),
//             ),

//           // ── Character image (bottom-right corner) ────────────────────────
//           Positioned(
//             bottom: 0,
//             right: 0,
//             child: Image.asset(
//               currentImage,
//               width: screenSize.width * 0.65,  // ~65% of screen width
//               fit: BoxFit.contain,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
