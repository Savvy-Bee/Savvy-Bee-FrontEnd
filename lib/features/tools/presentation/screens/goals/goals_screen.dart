import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/num_extensions.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_error_widget.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_loading_widget.dart';
import 'package:savvy_bee_mobile/features/home/presentation/providers/home_data_provider.dart';
import 'package:savvy_bee_mobile/features/home/presentation/widgets/smart_recommendations.dart';
import 'package:savvy_bee_mobile/features/tools/domain/models/savings.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/providers/goals_provider.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/screens/goals/create_goal_onboarding_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Route arguments
// ─────────────────────────────────────────────────────────────────────────────

/// Pass via GoRouter `extra` when navigating from the Tools walkthrough
/// on a fresh account with no goals.
class GoalsScreenArgs {
  const GoalsScreenArgs({this.showCreateGoalWalkthrough = false});
  final bool showCreateGoalWalkthrough;
}

// ─────────────────────────────────────────────────────────────────────────────
// GoalsScreen
// ─────────────────────────────────────────────────────────────────────────────

class GoalsScreen extends ConsumerStatefulWidget {
  static const String path = '/goals';

  const GoalsScreen({super.key, this.args});

  /// Optional args injected by GoRouter from `extra`.
  final GoalsScreenArgs? args;

  @override
  ConsumerState<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends ConsumerState<GoalsScreen> {
  // ── Walkthrough ───────────────────────────────────────────────────────────

  /// Whether the "Create a Goal" spotlight overlay is active.
  bool _showCreateGoalOverlay = false;

  /// GlobalKey attached to the "Create a goal" button in the empty-state view.
  final GlobalKey _createGoalButtonKey = GlobalKey();

  // ─────────────────────────────────────────────────────────────────────────
  // Lifecycle
  // ─────────────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    if (widget.args?.showCreateGoalWalkthrough == true) {
      // Delay by one frame so the key is attached before we try to measure it.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _showCreateGoalOverlay = true);
      });
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Overlay helpers
  // ─────────────────────────────────────────────────────────────────────────

  void _dismissCreateGoalOverlay() {
    setState(() => _showCreateGoalOverlay = false);
  }

  /// Returns the global [Rect] of a widget identified by [key].
  Rect? _globalRect(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx == null) return null;
    final box = ctx.findRenderObject() as RenderBox?;
    if (box == null) return null;
    return box.localToGlobal(Offset.zero) & box.size;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final goalsAsync = ref.watch(savingsGoalsProvider);
    final insightAdvice = ref.watch(homeDataProvider).valueOrNull?.data?.insightAdvice;

    return Stack(
      children: [
        // ── Main Scaffold ─────────────────────────────────────────────────
        Scaffold(
          backgroundColor: AppColors.yellow,
          appBar: AppBar(
            backgroundColor: AppColors.yellow,
            elevation: 0,
            title: const Text(
              'Goals',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                fontFamily: 'GeneralSans',
                color: Colors.black,
              ),
            ),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/tools');
                }
              },
            ),
          ),
          body: goalsAsync.when(
            data: (goals) {
              final totalSaved = goals.fold<double>(
                0,
                (sum, goal) => sum + goal.balance,
              );
              final lastDeposit = goals.isNotEmpty ? goals.first.balance : 0.0;
              final last30DaysAmount = goals.fold<double>(
                0,
                (sum, goal) => sum + goal.balance,
              );

              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(savingsGoalsProvider);
                  await ref.read(savingsGoalsProvider.future);
                },
                color: Colors.black,
                backgroundColor: Colors.white,
                child: Column(
                  children: [
                    // ── Stats card ────────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Total saved',
                              style: TextStyle(
                                fontSize: 12,
                                fontFamily: 'GeneralSans',
                                color: Colors.grey,
                              ),
                            ),
                            const Gap(8),
                            Text(
                              totalSaved.toDouble().formatCurrency(
                                decimalDigits: 0,
                              ),
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'GeneralSans',
                                color: Colors.black,
                              ),
                            ),
                            const Gap(16),
                            const Divider(height: 1),
                            const Gap(16),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildStatItem(
                                    icon: Icons.arrow_upward,
                                    amount: last30DaysAmount,
                                    label: 'Last 30 days',
                                  ),
                                ),
                                Container(
                                  width: 1,
                                  height: 40,
                                  color: Colors.grey.shade300,
                                ),
                                Expanded(
                                  child: _buildStatItem(
                                    icon: Icons.refresh,
                                    amount: lastDeposit,
                                    label: 'Last deposit',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // AI Savings Advice
                    if (insightAdvice?.goalSavingsAdvice.isNotEmpty == true)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: SmartRecommendationCard(
                          title: 'SAVINGS ADVICE',
                          description: insightAdvice!.goalSavingsAdvice,
                          buttonText: 'Got it',
                          showFeedback: false,
                          backgroundColor: const Color(0xFFE8F5E9),
                          onButtonPressed: () {},
                        ),
                      ),

                    // ── Goals list / empty state ───────────────────────────
                    Expanded(
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(24),
                            topRight: Radius.circular(24),
                          ),
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                16,
                                24,
                                16,
                                16,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'MY GOALS',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'GeneralSans',
                                      color: Colors.black87,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () => context.pushNamed(
                                      CreateGoalOnboardingScreen.path,
                                    ),
                                    child: const Text(
                                      'Add goal',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontFamily: 'GeneralSans',
                                        color: Colors.black,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: goals.isEmpty
                                  ? _buildEmptyState(context)
                                  : _buildGoalsList(goals),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
            loading: () =>
                const CustomLoadingWidget(text: 'Loading your goals...'),
            error: (error, stack) => CustomErrorWidget(
              icon: Icons.emoji_events_outlined,
              title: 'Unable to Load Goals',
              subtitle: 'We couldn\'t fetch your goals. Please try again.',
              actionButtonText: 'Retry',
              onActionPressed: () => ref.invalidate(savingsGoalsProvider),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => context.pushNamed(CreateGoalOnboardingScreen.path),
            backgroundColor: AppColors.yellow,
            foregroundColor: Colors.black,
            elevation: 4,
            child: const Icon(Icons.add, size: 28),
          ),
        ),

        // ── Create-a-Goal spotlight overlay ──────────────────────────────
        // Only shown when arriving from the Tools walkthrough with no goals.
        if (_showCreateGoalOverlay)
          _CreateGoalWalkthroughOverlay(
            buttonRect: _globalRect(_createGoalButtonKey),
            onDismiss: _dismissCreateGoalOverlay,
          ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Stat item (unchanged)
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildStatItem({
    required IconData icon,
    required double amount,
    required String label,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: Colors.black87),
        ),
        const Gap(12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              amount.toDouble().formatCurrency(decimalDigits: 0),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontFamily: 'GeneralSans',
                color: Colors.black,
              ),
            ),
            const Gap(2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontFamily: 'GeneralSans',
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Empty state — Create a Goal button gets the GlobalKey
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildEmptyState(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Gap(60),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.info_outline,
                size: 32,
                color: Colors.grey.shade600,
              ),
            ),
            const Gap(16),
            Text(
              'No goals yet',
              style: TextStyle(
                fontSize: 12,
                fontFamily: 'GeneralSans',
                color: Colors.grey.shade600,
              ),
            ),
            const Gap(8),
            const Text(
              'Create Your First Goal',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                fontFamily: 'GeneralSans',
                color: Colors.black,
              ),
            ),
            const Gap(24),

            // ── "Create a goal" button — keyed for walkthrough ────────────
            KeyedSubtree(
              key: _createGoalButtonKey,
              child: InkWell(
                onTap: () {
                  // Dismiss the overlay first, then navigate.
                  _dismissCreateGoalOverlay();
                  context.pushNamed(CreateGoalOnboardingScreen.path);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_box_outlined, size: 20),
                      Gap(8),
                      Text(
                        'Create a goal',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'GeneralSans',
                        ),
                      ),
                      Gap(8),
                      Icon(Icons.chevron_right, size: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Goals list (unchanged)
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildGoalsList(List<SavingsGoal> goals) {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: goals.length + 1,
      separatorBuilder: (context, index) => const Gap(16),
      itemBuilder: (context, index) {
        if (index == goals.length) return _buildPausedDepositsBanner();
        return _buildGoalCard(goals[index]);
      },
    );
  }

  Widget _buildGoalCard(SavingsGoal goal) {
    final progress = goal.targetAmount > 0
        ? (goal.balance / goal.targetAmount).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  goal.goalName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'GeneralSans',
                    color: Colors.black,
                  ),
                ),
              ),
              const Gap(8),
              Image.asset(
                'assets/images/icons/Vacation.png',
                width: 24,
                height: 24,
              ),
            ],
          ),
          const Gap(16),
          Text(
            goal.balance.toDouble().formatCurrency(decimalDigits: 0),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              fontFamily: 'GeneralSans',
              color: Colors.black,
            ),
          ),
          const Gap(4),
          Text(
            'saved of ${goal.targetAmount.toDouble().formatCurrency(decimalDigits: 0)}',
            style: TextStyle(
              fontSize: 12,
              fontFamily: 'GeneralSans',
              color: Colors.grey.shade600,
            ),
          ),
          const Gap(16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                progress >= 1.0 ? Colors.green : AppColors.success,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPausedDepositsBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _CreateGoalWalkthroughOverlay
//
// Shown on GoalsScreen when the user arrives with no goals from the Tools
// walkthrough. Spotlights the "Create a goal" button, arrow below it.
// Tapping anywhere (including the button itself via the underlying InkWell)
// dismisses the overlay.
// ─────────────────────────────────────────────────────────────────────────────

class _CreateGoalWalkthroughOverlay extends StatelessWidget {
  const _CreateGoalWalkthroughOverlay({
    required this.onDismiss,
    this.buttonRect,
  });

  final VoidCallback onDismiss;
  final Rect? buttonRect;

  static const double _hPad = 20.0;
  static const double _vPad = 10.0;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final Rect? paddedRect = buttonRect == null
        ? null
        : Rect.fromLTRB(
            buttonRect!.left - _hPad,
            buttonRect!.top - _vPad,
            buttonRect!.right + _hPad,
            buttonRect!.bottom + _vPad,
          );

    return GestureDetector(
      // Tapping the dark area dismisses without navigating.
      onTap: onDismiss,
      child: Stack(
        children: [
          // ── Cut-out dark backdrop ────────────────────────────────────
          CustomPaint(
            size: size,
            painter: _CutOutOverlayPainter(cutOut: paddedRect),
          ),

          // ── White spotlight behind the button ──────────────────────
          if (paddedRect != null)
            Positioned(
              left: paddedRect.left,
              top: paddedRect.top,
              width: paddedRect.width,
              height: paddedRect.height,
              child: IgnorePointer(
                // IgnorePointer = false so the InkWell underneath still fires.
                ignoring: false,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

          // ── Arrow below the button ────────────────────────────────
          if (paddedRect != null)
            Positioned(
              left: paddedRect.left + 8,
              top: paddedRect.bottom + 6,
              child: GestureDetector(
                onTap: onDismiss,
                child: Image.asset(
                  'assets/images/walk_through/home_arrow.png',
                  width: 72,
                  height: 44,
                  fit: BoxFit.contain,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _CutOutOverlayPainter (same pattern as tools/budgets screens)
// ─────────────────────────────────────────────────────────────────────────────

class _CutOutOverlayPainter extends CustomPainter {
  const _CutOutOverlayPainter({this.cutOut});

  final Rect? cutOut;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withOpacity(0.55);
    final fullRect = Rect.fromLTWH(0, 0, size.width, size.height);

    if (cutOut == null) {
      canvas.drawRect(fullRect, paint);
      return;
    }

    final path = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(fullRect)
      ..addRRect(RRect.fromRectAndRadius(cutOut!, const Radius.circular(12)));

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CutOutOverlayPainter old) => old.cutOut != cutOut;
}



// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:gap/gap.dart';
// import 'package:go_router/go_router.dart';
// import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
// import 'package:savvy_bee_mobile/core/utils/num_extensions.dart';
// import 'package:savvy_bee_mobile/core/widgets/custom_error_widget.dart';
// import 'package:savvy_bee_mobile/core/widgets/custom_loading_widget.dart';
// import 'package:savvy_bee_mobile/features/tools/domain/models/savings.dart';
// import 'package:savvy_bee_mobile/features/tools/presentation/providers/goals_provider.dart';
// import 'package:savvy_bee_mobile/features/tools/presentation/screens/goals/create_goal_onboarding_screen.dart';

// /// Updated Goals Screen with pull-to-refresh functionality
// class GoalsScreen extends ConsumerWidget {
//   static const String path = '/goals';

//   const GoalsScreen({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final goalsAsync = ref.watch(savingsGoalsProvider);

//     return Scaffold(
//       backgroundColor: AppColors.yellow,
//       appBar: AppBar(
//         backgroundColor: AppColors.yellow,
//         elevation: 0,
//         title: const Text(
//           'Goals',
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.w500,
//             fontFamily: 'GeneralSans',
//             color: Colors.black,
//           ),
//         ),
//         centerTitle: true,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () {
//             // Check if we can pop, otherwise go to home
//             if (context.canPop()) {
//               context.pop();
//             } else {
//               context.go('/tools'); // or whatever your home route is
//             }
//           },
//         ),
//       ),
//       body: goalsAsync.when(
//         data: (goals) {
//           // Calculate stats
//           final totalSaved = goals.fold<double>(
//             0,
//             (sum, goal) => sum + goal.balance,
//           );
//           final lastDeposit = goals.isNotEmpty ? goals.first.balance : 0.0;

//           // Get last 30 days activity (placeholder for now)
//           final last30DaysAmount = goals.fold<double>(
//             0,
//             (sum, goal) => sum + goal.balance,
//           );

//           return RefreshIndicator(
//             onRefresh: () async {
//               // Invalidate the provider to trigger a refresh
//               ref.invalidate(savingsGoalsProvider);

//               // Wait for the new data to load
//               await ref.read(savingsGoalsProvider.future);
//             },
//             color: Colors.black,
//             backgroundColor: Colors.white,
//             child: Column(
//               children: [
//                 // Stats Card (Yellow background area)
//                 Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Container(
//                     padding: const EdgeInsets.all(24),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           'Total saved',
//                           style: TextStyle(
//                             fontSize: 12,
//                             fontFamily: 'GeneralSans',
//                             color: Colors.grey,
//                           ),
//                         ),
//                         const Gap(8),
//                         Text(
//                           totalSaved.toDouble().formatCurrency(
//                             decimalDigits: 0,
//                           ),
//                           style: const TextStyle(
//                             fontSize: 32,
//                             fontWeight: FontWeight.bold,
//                             fontFamily: 'GeneralSans',
//                             color: Colors.black,
//                           ),
//                         ),
//                         const Gap(16),
//                         const Divider(height: 1),
//                         const Gap(16),
//                         Row(
//                           children: [
//                             Expanded(
//                               child: _buildStatItem(
//                                 icon: Icons.arrow_upward,
//                                 amount: last30DaysAmount,
//                                 label: 'Last 30 days',
//                               ),
//                             ),
//                             Container(
//                               width: 1,
//                               height: 40,
//                               color: Colors.grey.shade300,
//                             ),
//                             Expanded(
//                               child: _buildStatItem(
//                                 icon: Icons.refresh,
//                                 amount: lastDeposit,
//                                 label: 'Last deposit',
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),

//                 // White Background Container - Everything from MY GOALS down
//                 Expanded(
//                   child: Container(
//                     decoration: const BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.only(
//                         topLeft: Radius.circular(24),
//                         topRight: Radius.circular(24),
//                       ),
//                     ),
//                     child: Column(
//                       children: [
//                         // Goals List Header
//                         Padding(
//                           padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               const Text(
//                                 'MY GOALS',
//                                 style: TextStyle(
//                                   fontSize: 11,
//                                   fontWeight: FontWeight.w600,
//                                   fontFamily: 'GeneralSans',
//                                   color: Colors.black87,
//                                   letterSpacing: 0.5,
//                                 ),
//                               ),
//                               TextButton(
//                                 onPressed: () {
//                                   context.pushNamed(
//                                     CreateGoalOnboardingScreen.path,
//                                   );
//                                 },
//                                 child: const Text(
//                                   'Add goal',
//                                   style: TextStyle(
//                                     fontSize: 14,
//                                     fontFamily: 'GeneralSans',
//                                     color: Colors.black,
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),

//                         // Goals List or Empty State
//                         Expanded(
//                           child: goals.isEmpty
//                               ? _buildEmptyState(context)
//                               : _buildGoalsList(goals),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//         loading: () => const CustomLoadingWidget(text: 'Loading your goals...'),
//         error: (error, stack) => CustomErrorWidget(
//           icon: Icons.emoji_events_outlined,
//           title: 'Unable to Load Goals',
//           subtitle: 'We couldn\'t fetch your goals. Please try again.',
//           actionButtonText: 'Retry',
//           onActionPressed: () => ref.invalidate(savingsGoalsProvider),
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () => context.pushNamed(CreateGoalOnboardingScreen.path),
//         backgroundColor: AppColors.yellow,
//         foregroundColor: Colors.black,
//         elevation: 4,
//         child: const Icon(Icons.add, size: 28),
//       ),
//     );
//   }

//   Widget _buildStatItem({
//     required IconData icon,
//     required double amount,
//     required String label,
//   }) {
//     return Row(
//       children: [
//         Container(
//           padding: const EdgeInsets.all(8),
//           decoration: BoxDecoration(
//             color: Colors.grey.shade100,
//             shape: BoxShape.circle,
//           ),
//           child: Icon(icon, size: 16, color: Colors.black87),
//         ),
//         const Gap(12),
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               amount.toDouble().formatCurrency(decimalDigits: 0),
//               style: const TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w600,
//                 fontFamily: 'GeneralSans',
//                 color: Colors.black,
//               ),
//             ),
//             const Gap(2),
//             Text(
//               label,
//               style: TextStyle(
//                 fontSize: 10,
//                 fontFamily: 'GeneralSans',
//                 color: Colors.grey.shade600,
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildEmptyState(BuildContext context) {
//     return SingleChildScrollView(
//       physics: const AlwaysScrollableScrollPhysics(),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Gap(60),
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade100,
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 Icons.info_outline,
//                 size: 32,
//                 color: Colors.grey.shade600,
//               ),
//             ),
//             const Gap(16),
//             Text(
//               'No goals yet',
//               style: TextStyle(
//                 fontSize: 12,
//                 fontFamily: 'GeneralSans',
//                 color: Colors.grey.shade600,
//               ),
//             ),
//             const Gap(8),
//             const Text(
//               'Create Your First Goal',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.w600,
//                 fontFamily: 'GeneralSans',
//                 color: Colors.black,
//               ),
//             ),
//             const Gap(24),
//             InkWell(
//               onTap: () => context.pushNamed(CreateGoalOnboardingScreen.path),
//               child: Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 12,
//                 ),
//                 decoration: BoxDecoration(
//                   border: Border.all(color: Colors.grey.shade300),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: const Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Icon(Icons.check_box_outlined, size: 20),
//                     Gap(8),
//                     Text(
//                       'Create a goal',
//                       style: TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w500,
//                         fontFamily: 'GeneralSans',
//                       ),
//                     ),
//                     Gap(8),
//                     Icon(Icons.chevron_right, size: 20),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildGoalsList(List<SavingsGoal> goals) {
//     return ListView.separated(
//       physics: const AlwaysScrollableScrollPhysics(),
//       padding: const EdgeInsets.all(16),
//       itemCount: goals.length + 1, // +1 for paused deposits banner
//       separatorBuilder: (context, index) => const Gap(16),
//       itemBuilder: (context, index) {
//         // Show paused deposits banner at the end
//         if (index == goals.length) {
//           return _buildPausedDepositsBanner();
//         }

//         final goal = goals[index];
//         return _buildGoalCard(goal);
//       },
//     );
//   }

//   Widget _buildGoalCard(SavingsGoal goal) {
//     final progress = goal.targetAmount > 0
//         ? (goal.balance / goal.targetAmount).clamp(0.0, 1.0)
//         : 0.0;

//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade50,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: Colors.grey.shade200),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Goal name and icon
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Expanded(
//                 child: Text(
//                   goal.goalName,
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                     fontFamily: 'GeneralSans',
//                     color: Colors.black,
//                   ),
//                 ),
//               ),
//               const Gap(8),
//               // Icon(
//               //   Icons.emoji_events_outlined,
//               //   color: AppColors.yellow,
//               //   size: 24,
//               // ),
//               Image.asset(
//                 'assets/images/icons/Vacation.png',
//                 width: 24,
//                 height: 24, 
//               ),
//             ],
//           ),
//           const Gap(16),

//           // Amount saved
//           Text(
//             goal.balance.toDouble().formatCurrency(decimalDigits: 0),
//             style: const TextStyle(
//               fontSize: 28,
//               fontWeight: FontWeight.bold,
//               fontFamily: 'GeneralSans',
//               color: Colors.black,
//             ),
//           ),
//           const Gap(4),
//           Text(
//             'saved of ${goal.targetAmount.toDouble().formatCurrency(decimalDigits: 0)}',
//             style: TextStyle(
//               fontSize: 12,
//               fontFamily: 'GeneralSans',
//               color: Colors.grey.shade600,
//             ),
//           ),
//           const Gap(16),

//           // Progress bar
//           ClipRRect(
//             borderRadius: BorderRadius.circular(4),
//             child: LinearProgressIndicator(
//               value: progress,
//               minHeight: 8,
//               backgroundColor: Colors.grey.shade200,
//               valueColor: AlwaysStoppedAnimation<Color>(
//                 progress >= 1.0 ? Colors.green : AppColors.success,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPausedDepositsBanner() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade50,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey.shade200),
//       ),
//       // child: Row(
//       //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       //   children: [
//       //     const Text(
//       //       'Deposits paused since Jan 1',
//       //       style: TextStyle(
//       //         fontSize: 14,
//       //         fontFamily: 'GeneralSans',
//       //         color: Colors.black87,
//       //       ),
//       //     ),
//       //     TextButton(
//       //       onPressed: () {
//       //         // Resume deposits logic
//       //       },
//       //       child: const Text(
//       //         'Resume',
//       //         style: TextStyle(
//       //           fontSize: 14,
//       //           fontWeight: FontWeight.w600,
//       //           fontFamily: 'GeneralSans',
//       //           color: Colors.black,
//       //           decoration: TextDecoration.underline,
//       //         ),
//       //       ),
//       //     ),
//       //   ],
//       // ),
//     );
//   }
// }
