import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_card.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_error_widget.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_loading_widget.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/providers/goals_provider.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/screens/goals/create_goal_screen.dart';

import '../../widgets/goal_stats_card.dart';

class GoalsScreen extends ConsumerStatefulWidget {
  static const String path = '/goals';

  const GoalsScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends ConsumerState<GoalsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final goalsAsync = ref.watch(savingsGoalsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Goals')),
      body: goalsAsync.when(
        data: (goals) {
          // Show empty state if no goals
          if (goals.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: _buildEmptyStateWidget(context),
            );
          }

          // Show goals with tabs
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TabBar(
                  controller: _tabController,
                  dividerColor: Colors.transparent,
                  indicatorSize: TabBarIndicatorSize.tab,
                  tabs: const [
                    Tab(text: 'Active'),
                    Tab(text: 'Completed'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildActiveGoalsTab(),
                      _buildCompletedGoalsTab(),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const CustomLoadingWidget(text: 'Fetching goals...'),
        error: (error, stack) => CustomErrorWidget.empty(
          onAction: () => ref.invalidate(savingsGoalsProvider),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.pushNamed(CreateGoalScreen.path),
        backgroundColor: AppColors.buttonPrimary,
        foregroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildActiveGoalsTab() {
    final activeGoals = ref.watch(activeGoalsProvider);

    if (activeGoals.isEmpty) {
      return CustomErrorWidget(
        icon: Icons.emoji_events_outlined,
        iconSize: 64,
        iconColor: Colors.grey[400],
        title: 'No active goals yet',
        subtitle: 'Create your first goal to get started',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(top: 24),
      itemBuilder: (context, index) {
        final goal = activeGoals[index];
        final endDate = DateTime.parse(goal.endDate);
        final daysLeft = endDate.difference(DateTime.now()).inDays;

        return GoalStatsCard(
          title: goal.goalName,
          amountSaved: goal.balance,
          totalTarget: goal.targetAmount,
          daysLeft: daysLeft > 0 ? daysLeft : 0,
          // onTap: () => _showGoalDetailsDialog(goal.id),
        );
      },
      separatorBuilder: (context, index) => const Gap(16),
      itemCount: activeGoals.length,
    );
  }

  Widget _buildCompletedGoalsTab() {
    final completedGoals = ref.watch(completedGoalsProvider);

    if (completedGoals.isEmpty) {
      return CustomErrorWidget(
        icon: Icons.emoji_events_outlined,
        iconSize: 64,
        iconColor: Colors.grey[400],
        title: 'No completed goals yet',
        subtitle: 'Keep saving to reach your goals!',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(top: 24),
      itemBuilder: (context, index) {
        final goal = completedGoals[index];
        final endDate = DateTime.parse(goal.endDate);
        final daysLeft = endDate.difference(DateTime.now()).inDays;

        return GoalStatsCard(
          title: goal.goalName,
          amountSaved: goal.balance,
          totalTarget: goal.targetAmount,
          daysLeft: daysLeft > 0 ? daysLeft : 0,
          // onTap: () => _showGoalDetailsDialog(goal.id),
        );
      },
      separatorBuilder: (context, index) => const Gap(16),
      itemCount: completedGoals.length,
    );
  }

  Widget _buildEmptyStateWidget(BuildContext context) {
    return CustomCard(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Define what financial success means to you.',
              style: TextStyle(fontSize: 12),
            ),
            const Gap(24),
            CustomElevatedButton(
              text: 'Create a goal',
              isSmall: true,
              isFullWidth: false,
              buttonColor: CustomButtonColor.black,
              onPressed: () => context.pushNamed(CreateGoalScreen.path),
            ),
          ],
        ),
      ),
    );
  }

  void _showGoalDetailsDialog(String goalId) {
    final goal = ref.read(savingsGoalByIdProvider(goalId));

    if (goal == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _GoalDetailsSheet(goalId: goalId),
    );
  }
}

// Separate widget for the goal details bottom sheet
class _GoalDetailsSheet extends ConsumerWidget {
  final String goalId;

  const _GoalDetailsSheet({required this.goalId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goal = ref.watch(savingsGoalByIdProvider(goalId));
    final state = ref.watch(savingsGoalNotifierProvider);

    if (goal == null) {
      return const SizedBox.shrink();
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Gap(24),

              // Goal name
              Text(
                goal.goalName,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Gap(8),

              // Goal type badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.buttonPrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  goal.goalType,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.buttonPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Gap(24),

              // Balance and target
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Balance',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const Gap(4),
                      Text(
                        '₦${goal.balance.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Target Amount',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const Gap(4),
                      Text(
                        '₦${goal.targetAmount.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Gap(16),

              // Progress bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progress',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        '${goal.progress.toStringAsFixed(1)}%',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Gap(8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: goal.progress / 100,
                      minHeight: 8,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        goal.isCompleted
                            ? Colors.green
                            : AppColors.buttonPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const Gap(24),

              // End date
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const Gap(8),
                  Text(
                    'Target Date: ${goal.endDate}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              const Gap(32),

              // Action buttons
              if (!goal.isCompleted) ...[
                Row(
                  children: [
                    Expanded(
                      child: CustomElevatedButton(
                        text: 'Add Funds',
                        isSmall: true,
                        buttonColor: CustomButtonColor.black,
                        onPressed: state.isLoading
                            ? null
                            : () => _showAddFundsDialog(context, ref, goalId),
                      ),
                    ),
                    const Gap(12),
                    Expanded(
                      child: CustomElevatedButton(
                        text: 'Withdraw',
                        isSmall: true,
                        buttonColor: CustomButtonColor.black,
                        onPressed: state.isLoading || goal.balance <= 0
                            ? null
                            : () => _showWithdrawDialog(context, ref, goalId),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green),
                      const Gap(12),
                      Expanded(
                        child: Text(
                          'Congratulations! You\'ve reached your goal!',
                          style: TextStyle(
                            color: Colors.green[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Loading indicator
              if (state.isLoading) ...[
                const Gap(16),
                const Center(child: CircularProgressIndicator()),
              ],
            ],
          ),
        );
      },
    );
  }

  void _showAddFundsDialog(BuildContext context, WidgetRef ref, String goalId) {
    final amountController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add Funds'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: amountController,
            decoration: const InputDecoration(
              labelText: 'Amount',
              prefixText: '₦',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter an amount';
              }
              if (double.tryParse(value) == null) {
                return 'Please enter a valid number';
              }
              if (double.parse(value) <= 0) {
                return 'Amount must be greater than 0';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final amount = double.parse(amountController.text);
                Navigator.pop(dialogContext);

                await ref
                    .read(savingsGoalNotifierProvider.notifier)
                    .addFunds(goalId: goalId, amount: amount);

                final state = ref.read(savingsGoalNotifierProvider);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.error ?? 'Funds added successfully!'),
                      backgroundColor: state.error != null
                          ? Colors.red
                          : Colors.green,
                    ),
                  );

                  if (state.error == null) {
                    Navigator.pop(context); // Close bottom sheet
                  }
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showWithdrawDialog(BuildContext context, WidgetRef ref, String goalId) {
    final amountController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final goal = ref.read(savingsGoalByIdProvider(goalId));

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Withdraw Funds'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Available: ₦${goal?.balance.toStringAsFixed(2) ?? '0.00'}',
                style: Theme.of(dialogContext).textTheme.bodySmall,
              ),
              const Gap(16),
              TextFormField(
                controller: amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixText: '₦',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null) {
                    return 'Please enter a valid number';
                  }
                  if (amount <= 0) {
                    return 'Amount must be greater than 0';
                  }
                  if (goal != null && amount > goal.balance) {
                    return 'Insufficient balance';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final amount = double.parse(amountController.text);
                Navigator.pop(dialogContext);

                await ref
                    .read(savingsGoalNotifierProvider.notifier)
                    .withdrawFunds(goalId: goalId, amount: amount);

                final state = ref.read(savingsGoalNotifierProvider);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        state.error ?? 'Funds withdrawn successfully!',
                      ),
                      backgroundColor: state.error != null
                          ? Colors.red
                          : Colors.green,
                    ),
                  );

                  if (state.error == null) {
                    Navigator.pop(context); // Close bottom sheet
                  }
                }
              }
            },
            child: const Text('Withdraw'),
          ),
        ],
      ),
    );
  }
}
