import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/num_extensions.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_error_widget.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_loading_widget.dart';
import 'package:savvy_bee_mobile/features/tools/domain/models/savings.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/providers/goals_provider.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/screens/goals/create_goal_onboarding_screen.dart';

/// Updated Goals Screen with pull-to-refresh functionality
class GoalsScreen extends ConsumerWidget {
  static const String path = '/goals';

  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(savingsGoalsProvider);

    return Scaffold(
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
            // Check if we can pop, otherwise go to home
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/tools'); // or whatever your home route is
            }
          },
        ),
      ),
      body: goalsAsync.when(
        data: (goals) {
          // Calculate stats
          final totalSaved = goals.fold<double>(
            0,
            (sum, goal) => sum + goal.balance,
          );
          final lastDeposit = goals.isNotEmpty ? goals.first.balance : 0.0;

          // Get last 30 days activity (placeholder for now)
          final last30DaysAmount = goals.fold<double>(
            0,
            (sum, goal) => sum + goal.balance,
          );

          return RefreshIndicator(
            onRefresh: () async {
              // Invalidate the provider to trigger a refresh
              ref.invalidate(savingsGoalsProvider);

              // Wait for the new data to load
              await ref.read(savingsGoalsProvider.future);
            },
            color: Colors.black,
            backgroundColor: Colors.white,
            child: Column(
              children: [
                // Stats Card (Yellow background area)
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

                // White Background Container - Everything from MY GOALS down
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
                        // Goals List Header
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                onPressed: () {
                                  context.pushNamed(
                                    CreateGoalOnboardingScreen.path,
                                  );
                                },
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

                        // Goals List or Empty State
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
        loading: () => const CustomLoadingWidget(text: 'Loading your goals...'),
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
    );
  }

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
            InkWell(
              onTap: () => context.pushNamed(CreateGoalOnboardingScreen.path),
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
          ],
        ),
      ),
    );
  }

  Widget _buildGoalsList(List<SavingsGoal> goals) {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: goals.length + 1, // +1 for paused deposits banner
      separatorBuilder: (context, index) => const Gap(16),
      itemBuilder: (context, index) {
        // Show paused deposits banner at the end
        if (index == goals.length) {
          return _buildPausedDepositsBanner();
        }

        final goal = goals[index];
        return _buildGoalCard(goal);
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
          // Goal name and icon
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
              Icon(
                Icons.emoji_events_outlined,
                color: AppColors.yellow,
                size: 24,
              ),
            ],
          ),
          const Gap(16),

          // Amount saved
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

          // Progress bar
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
      // child: Row(
      //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //   children: [
      //     const Text(
      //       'Deposits paused since Jan 1',
      //       style: TextStyle(
      //         fontSize: 14,
      //         fontFamily: 'GeneralSans',
      //         color: Colors.black87,
      //       ),
      //     ),
      //     TextButton(
      //       onPressed: () {
      //         // Resume deposits logic
      //       },
      //       child: const Text(
      //         'Resume',
      //         style: TextStyle(
      //           fontSize: 14,
      //           fontWeight: FontWeight.w600,
      //           fontFamily: 'GeneralSans',
      //           color: Colors.black,
      //           decoration: TextDecoration.underline,
      //         ),
      //       ),
      //     ),
      //   ],
      // ),
    );
  }
}



// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:gap/gap.dart';
// import 'package:go_router/go_router.dart';
// import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
// import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';
// import 'package:savvy_bee_mobile/core/widgets/custom_card.dart';
// import 'package:savvy_bee_mobile/core/widgets/custom_error_widget.dart';
// import 'package:savvy_bee_mobile/core/widgets/custom_loading_widget.dart';
// import 'package:savvy_bee_mobile/features/tools/presentation/providers/goals_provider.dart';
// import 'package:savvy_bee_mobile/features/tools/presentation/screens/goals/create_goal_screen.dart';

// import '../../widgets/goal_stats_card.dart';

// class GoalsScreen extends ConsumerStatefulWidget {
//   static const String path = '/goals'; 

//   const GoalsScreen({super.key});

//   @override
//   ConsumerState<ConsumerStatefulWidget> createState() => _GoalsScreenState();
// }

// class _GoalsScreenState extends ConsumerState<GoalsScreen>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final goalsAsync = ref.watch(savingsGoalsProvider);

//     return Scaffold(
//       appBar: AppBar(title: const Text('Goals')),
//       body: goalsAsync.when(
//         data: (goals) {
//           // Show empty state if no goals
//           if (goals.isEmpty) {
//             return Padding(
//               padding: const EdgeInsets.all(16),
//               child: _buildEmptyStateWidget(context),
//             );
//           }

//           // Show goals with tabs
//           return Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 TabBar(
//                   controller: _tabController,
//                   dividerColor: Colors.transparent,
//                   indicatorSize: TabBarIndicatorSize.tab,
//                   tabs: const [
//                     Tab(text: 'Active'),
//                     Tab(text: 'Completed'),
//                   ],
//                 ),
//                 Expanded(
//                   child: TabBarView(
//                     controller: _tabController,
//                     children: [
//                       _buildActiveGoalsTab(),
//                       _buildCompletedGoalsTab(),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//         loading: () => const CustomLoadingWidget(text: 'Fetching goals...'),
//         error: (error, stack) => CustomErrorWidget.empty(
//           onAction: () => ref.invalidate(savingsGoalsProvider),
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () => context.pushNamed(CreateGoalScreen.path),
//         backgroundColor: AppColors.buttonPrimary,
//         foregroundColor: AppColors.white,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
//         child: const Icon(Icons.add),
//       ),
//     );
//   }

//   Widget _buildActiveGoalsTab() {
//     final activeGoals = ref.watch(activeGoalsProvider);

//     if (activeGoals.isEmpty) {
//       return CustomErrorWidget(
//         icon: Icons.emoji_events_outlined,
//         iconSize: 64,
//         iconColor: Colors.grey[400],
//         title: 'No active goals yet',
//         subtitle: 'Create your first goal to get started',
//       );
//     }

//     return ListView.separated(
//       padding: const EdgeInsets.only(top: 24),
//       itemBuilder: (context, index) {
//         final goal = activeGoals[index];
//         final endDate = DateTime.parse(goal.endDate);
//         final daysLeft = endDate.difference(DateTime.now()).inDays;

//         return GoalStatsCard(
//           title: goal.goalName,
//           amountSaved: goal.balance,
//           totalTarget: goal.targetAmount,
//           daysLeft: daysLeft > 0 ? daysLeft : 0,
//           // onTap: () => _showGoalDetailsDialog(goal.id),
//         );
//       },
//       separatorBuilder: (context, index) => const Gap(16),
//       itemCount: activeGoals.length,
//     );
//   }

//   Widget _buildCompletedGoalsTab() {
//     final completedGoals = ref.watch(completedGoalsProvider);

//     if (completedGoals.isEmpty) {
//       return CustomErrorWidget(
//         icon: Icons.emoji_events_outlined,
//         iconSize: 64,
//         iconColor: Colors.grey[400],
//         title: 'No completed goals yet',
//         subtitle: 'Keep saving to reach your goals!',
//       );
//     }

//     return ListView.separated(
//       padding: const EdgeInsets.only(top: 24),
//       itemBuilder: (context, index) {
//         final goal = completedGoals[index];
//         final endDate = DateTime.parse(goal.endDate);
//         final daysLeft = endDate.difference(DateTime.now()).inDays;

//         return GoalStatsCard(
//           title: goal.goalName,
//           amountSaved: goal.balance,
//           totalTarget: goal.targetAmount,
//           daysLeft: daysLeft > 0 ? daysLeft : 0,
//           // onTap: () => _showGoalDetailsDialog(goal.id),
//         );
//       },
//       separatorBuilder: (context, index) => const Gap(16),
//       itemCount: completedGoals.length,
//     );
//   }

//   Widget _buildEmptyStateWidget(BuildContext context) {
//     return CustomCard(
//       child: Center(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Text(
//               'Define what financial success means to you.',
//               style: TextStyle(fontSize: 12),
//             ),
//             const Gap(24),
//             CustomElevatedButton(
//               text: 'Create a goal',
//               isSmall: true,
//               isFullWidth: false,
//               buttonColor: CustomButtonColor.black,
//               onPressed: () => context.pushNamed(CreateGoalScreen.path),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _showGoalDetailsDialog(String goalId) {
//     final goal = ref.read(savingsGoalByIdProvider(goalId));

//     if (goal == null) return;

//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) => _GoalDetailsSheet(goalId: goalId),
//     );
//   }
// }

// // Separate widget for the goal details bottom sheet
// class _GoalDetailsSheet extends ConsumerWidget {
//   final String goalId;

//   const _GoalDetailsSheet({required this.goalId});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final goal = ref.watch(savingsGoalByIdProvider(goalId));
//     final state = ref.watch(savingsGoalNotifierProvider);

//     if (goal == null) {
//       return const SizedBox.shrink();
//     }

//     return DraggableScrollableSheet(
//       initialChildSize: 0.7,
//       minChildSize: 0.5,
//       maxChildSize: 0.95,
//       expand: false,
//       builder: (context, scrollController) {
//         return Padding(
//           padding: const EdgeInsets.all(24),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Handle bar
//               Center(
//                 child: Container(
//                   width: 40,
//                   height: 4,
//                   decoration: BoxDecoration(
//                     color: Colors.grey[300],
//                     borderRadius: BorderRadius.circular(2),
//                   ),
//                 ),
//               ),
//               const Gap(24),

//               // Goal name
//               Text(
//                 goal.goalName,
//                 style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const Gap(8),

//               // Goal type badge
//               Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 12,
//                   vertical: 4,
//                 ),
//                 decoration: BoxDecoration(
//                   color: AppColors.buttonPrimary.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Text(
//                   goal.goalType,
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: AppColors.buttonPrimary,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ),
//               const Gap(24),

//               // Balance and target
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Current Balance',
//                         style: Theme.of(context).textTheme.bodySmall,
//                       ),
//                       const Gap(4),
//                       Text(
//                         '₦${goal.balance.toStringAsFixed(2)}',
//                         style: Theme.of(context).textTheme.headlineSmall
//                             ?.copyWith(fontWeight: FontWeight.bold),
//                       ),
//                     ],
//                   ),
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.end,
//                     children: [
//                       Text(
//                         'Target Amount',
//                         style: Theme.of(context).textTheme.bodySmall,
//                       ),
//                       const Gap(4),
//                       Text(
//                         '₦${goal.targetAmount.toStringAsFixed(2)}',
//                         style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//               const Gap(16),

//               // Progress bar
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         'Progress',
//                         style: Theme.of(context).textTheme.bodySmall,
//                       ),
//                       Text(
//                         '${goal.progress.toStringAsFixed(1)}%',
//                         style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const Gap(8),
//                   ClipRRect(
//                     borderRadius: BorderRadius.circular(10),
//                     child: LinearProgressIndicator(
//                       value: goal.progress / 100,
//                       minHeight: 8,
//                       backgroundColor: Colors.grey[200],
//                       valueColor: AlwaysStoppedAnimation<Color>(
//                         goal.isCompleted
//                             ? Colors.green
//                             : AppColors.buttonPrimary,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const Gap(24),

//               // End date
//               Row(
//                 children: [
//                   Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
//                   const Gap(8),
//                   Text(
//                     'Target Date: ${goal.endDate}',
//                     style: Theme.of(context).textTheme.bodyMedium,
//                   ),
//                 ],
//               ),
//               const Gap(32),

//               // Action buttons
//               if (!goal.isCompleted) ...[
//                 Row(
//                   children: [
//                     Expanded(
//                       child: CustomElevatedButton(
//                         text: 'Add Funds',
//                         isSmall: true,
//                         buttonColor: CustomButtonColor.black,
//                         onPressed: state.isLoading
//                             ? null
//                             : () => _showAddFundsDialog(context, ref, goalId),
//                       ),
//                     ),
//                     const Gap(12),
//                     Expanded(
//                       child: CustomElevatedButton(
//                         text: 'Withdraw',
//                         isSmall: true,
//                         buttonColor: CustomButtonColor.black,
//                         onPressed: state.isLoading || goal.balance <= 0
//                             ? null
//                             : () => _showWithdrawDialog(context, ref, goalId),
//                       ),
//                     ),
//                   ],
//                 ),
//               ] else ...[
//                 Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: Colors.green.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Row(
//                     children: [
//                       Icon(Icons.check_circle, color: Colors.green),
//                       const Gap(12),
//                       Expanded(
//                         child: Text(
//                           'Congratulations! You\'ve reached your goal!',
//                           style: TextStyle(
//                             color: Colors.green[700],
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],

//               // Loading indicator
//               if (state.isLoading) ...[
//                 const Gap(16),
//                 const Center(child: CircularProgressIndicator()),
//               ],
//             ],
//           ),
//         );
//       },
//     );
//   }

//   void _showAddFundsDialog(BuildContext context, WidgetRef ref, String goalId) {
//     final amountController = TextEditingController();
//     final formKey = GlobalKey<FormState>();

//     showDialog(
//       context: context,
//       builder: (dialogContext) => AlertDialog(
//         title: const Text('Add Funds'),
//         content: Form(
//           key: formKey,
//           child: TextFormField(
//             controller: amountController,
//             decoration: const InputDecoration(
//               labelText: 'Amount',
//               prefixText: '₦',
//               border: OutlineInputBorder(),
//             ),
//             keyboardType: TextInputType.number,
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return 'Please enter an amount';
//               }
//               if (double.tryParse(value) == null) {
//                 return 'Please enter a valid number';
//               }
//               if (double.parse(value) <= 0) {
//                 return 'Amount must be greater than 0';
//               }
//               return null;
//             },
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(dialogContext),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () async {
//               if (formKey.currentState!.validate()) {
//                 final amount = double.parse(amountController.text);
//                 Navigator.pop(dialogContext);

//                 await ref
//                     .read(savingsGoalNotifierProvider.notifier)
//                     .addFunds(goalId: goalId, amount: amount);

//                 final state = ref.read(savingsGoalNotifierProvider);
//                 if (context.mounted) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Text(state.error ?? 'Funds added successfully!'),
//                       backgroundColor: state.error != null
//                           ? Colors.red
//                           : Colors.green,
//                     ),
//                   );

//                   if (state.error == null) {
//                     Navigator.pop(context); // Close bottom sheet
//                   }
//                 }
//               }
//             },
//             child: const Text('Add'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showWithdrawDialog(BuildContext context, WidgetRef ref, String goalId) {
//     final amountController = TextEditingController();
//     final formKey = GlobalKey<FormState>();
//     final goal = ref.read(savingsGoalByIdProvider(goalId));

//     showDialog(
//       context: context,
//       builder: (dialogContext) => AlertDialog(
//         title: const Text('Withdraw Funds'),
//         content: Form(
//           key: formKey,
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text(
//                 'Available: ₦${goal?.balance.toStringAsFixed(2) ?? '0.00'}',
//                 style: Theme.of(dialogContext).textTheme.bodySmall,
//               ),
//               const Gap(16),
//               TextFormField(
//                 controller: amountController,
//                 decoration: const InputDecoration(
//                   labelText: 'Amount',
//                   prefixText: '₦',
//                   border: OutlineInputBorder(),
//                 ),
//                 keyboardType: TextInputType.number,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter an amount';
//                   }
//                   final amount = double.tryParse(value);
//                   if (amount == null) {
//                     return 'Please enter a valid number';
//                   }
//                   if (amount <= 0) {
//                     return 'Amount must be greater than 0';
//                   }
//                   if (goal != null && amount > goal.balance) {
//                     return 'Insufficient balance';
//                   }
//                   return null;
//                 },
//               ),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(dialogContext),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () async {
//               if (formKey.currentState!.validate()) {
//                 final amount = double.parse(amountController.text);
//                 Navigator.pop(dialogContext);

//                 await ref
//                     .read(savingsGoalNotifierProvider.notifier)
//                     .withdrawFunds(goalId: goalId, amount: amount);

//                 final state = ref.read(savingsGoalNotifierProvider);
//                 if (context.mounted) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Text(
//                         state.error ?? 'Funds withdrawn successfully!',
//                       ),
//                       backgroundColor: state.error != null
//                           ? Colors.red
//                           : Colors.green,
//                     ),
//                   );

//                   if (state.error == null) {
//                     Navigator.pop(context); // Close bottom sheet
//                   }
//                 }
//               }
//             },
//             child: const Text('Withdraw'),
//           ),
//         ],
//       ),
//     );
//   }
// }
