import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/date_time_extension.dart';
import 'package:savvy_bee_mobile/core/utils/num_extensions.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_error_widget.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_loading_widget.dart';
import 'package:savvy_bee_mobile/features/chat/presentation/screens/chat_screen.dart';
import 'package:savvy_bee_mobile/features/spend/domain/models/wallet.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/providers/wallet_provider.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/screens/bills/pay_bills_screen.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/screens/transactions/transaction_details_screen.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/screens/transactions/transaction_history_screen.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/screens/transfer/transfer_screen_one.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/screens/wallet/add_money_screen.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/screens/wallet/create_wallet_screen.dart';
import 'package:savvy_bee_mobile/features/home/presentation/providers/home_data_provider.dart';
import 'package:savvy_bee_mobile/features/profile/presentation/screens/profile_screen.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/screens/wallet/quick_actions_screen.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/screens/spending_flow/flow_screen.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/screens/profile/spend_profile_screen.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/screens/profile/spend_goals_screen.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/providers/goals_provider.dart';

class SpendScreen extends ConsumerStatefulWidget {
  static const String path = '/spend';

  const SpendScreen({super.key});

  @override
  ConsumerState<SpendScreen> createState() => _SpendScreenState();
}

class _SpendScreenState extends ConsumerState<SpendScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dashboardAsync = ref.watch(spendDashboardDataProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF8),
      body: SafeArea(
        child: dashboardAsync.when(
          skipLoadingOnRefresh: false,
          data: (response) {
            if (response.data == null) {
              return _buildNoAccountState();
            }

            final dashboard = response.data!;
            final hasWallet = dashboard.accounts.ngnAccount != null;

            if (!hasWallet) {
              return _buildNoAccountState();
            }

            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(spendDashboardDataProvider);
                ref.invalidate(transactionListProvider);
                ref.invalidate(savingsGoalsProvider);
              },
              child: CustomScrollView(
                slivers: [
                  // Top Bar
                  SliverToBoxAdapter(child: _buildTopBar(context)),

                  // Greeting + Balance Card
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildGreetingAndBalanceCard(dashboard),
                    ),
                  ),

                  const SliverGap(16),

                  // Goal Alert Banner
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildGoalAlertBanner(),
                    ),
                  ),

                  const SliverGap(24),

                  // Goals Section
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildGoalsSection(context),
                    ),
                  ),

                  const SliverGap(24),

                  // Features Section
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildFeaturesSection(context),
                    ),
                  ),

                  const SliverGap(24),

                  // Transactions Section Header
                  // SliverToBoxAdapter(
                  //   child: Padding(
                  //     padding: const EdgeInsets.symmetric(horizontal: 16),
                  //     child: Row(
                  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //       children: [
                  //         const Text(
                  //           'Transactions',
                  //           style: TextStyle(
                  //             fontSize: 18,
                  //             fontWeight: FontWeight.w600,
                  //             fontFamily: 'GeneralSans',
                  //             color: Colors.black,
                  //           ),
                  //         ),
                  //         GestureDetector(
                  //           onTap: () => context.pushNamed(
                  //             TransactionHistoryScreen.path,
                  //           ),
                  //           child: const Text(
                  //             'See All',
                  //             style: TextStyle(
                  //               fontSize: 14,
                  //               fontFamily: 'GeneralSans',
                  //               color: Color(0xFFE8A838),
                  //               fontWeight: FontWeight.w500,
                  //             ),
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),

                  // const SliverGap(12),

                  // Transactions List
                  // _buildTransactionsList(),

                  // const SliverGap(24),
                ],
              ),
            );
          },
          loading: () => const CustomLoadingWidget(),
          error: (error, stack) => CustomErrorWidget.error(
            onRetry: () => ref.invalidate(spendDashboardDataProvider),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Arrow
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: const Icon(
                Icons.arrow_back,
                size: 20,
                color: Colors.black,
              ),
            ),
          ),

          // Notification Bell
          Stack(
            children: [
              GestureDetector(
                onTap: () => context.pushNamed(TransactionHistoryScreen.path),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: const Icon(
                    Icons.notifications_outlined,
                    size: 22,
                    color: Colors.black,
                  ),
                ),
              ),
              // Notification dot
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE8A838),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGreetingAndBalanceCard(WalletDashboardData dashboard) {
    final firstName =
        ref.watch(homeDataProvider).valueOrNull?.data?.firstName ?? 'User';
    final primaryAccount = dashboard.accounts;

    final txAsync = ref.watch(transactionListProvider);
    final transactions = txAsync.valueOrNull?.data?.transactions ?? [];
    final totalIncome = transactions
        .where((t) => t.isCredit)
        .fold(0.0, (sum, t) => sum + t.amount);
    final totalSpent = transactions
        .where((t) => t.isDebit)
        .fold(0.0, (sum, t) => sum + t.amount);

    // Derive greeting based on time
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Good morning';
    } else if (hour < 17) {
      greeting = 'Good afternoon';
    } else {
      greeting = 'Good evening';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting
          Text(
            greeting,
            style: const TextStyle(
              fontSize: 14,
              fontFamily: 'GeneralSans',
              color: Color(0xFF9E9E9E),
            ),
          ),
          const Gap(2),
          Text(
            firstName,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              fontFamily: 'GeneralSans',
              color: Colors.black,
              letterSpacing: -0.5,
            ),
          ),

          const Gap(20),

          // Balance Label
          const Text(
            'Available Balance',
            style: TextStyle(
              fontSize: 13,
              fontFamily: 'GeneralSans',
              color: Color(0xFF9E9E9E),
            ),
          ),
          const Gap(6),

          // Balance Amount
          Consumer(
            builder: (context, ref, _) {
              final isPrivate = ref.watch(balancePrivacyProvider);
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    isPrivate
                        ? '₦ ••••••'
                        : primaryAccount.balance.formatCurrency(),
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'GeneralSans',
                      color: Colors.black,
                      letterSpacing: -1.5,
                    ),
                  ),
                  const Gap(12),
                  // Eye toggle
                  GestureDetector(
                    onTap: () =>
                        ref.read(balancePrivacyProvider.notifier).state = !ref
                            .read(balancePrivacyProvider),
                    child: Icon(
                      isPrivate
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 20,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              );
            },
          ),

          const Gap(20),

          // Divider
          Divider(color: Colors.grey.shade100, height: 1),

          const Gap(16),

          // Income and Spent Row
          Row(
            children: [
              // Income
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Income',
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'GeneralSans',
                        color: Color(0xFF9E9E9E),
                      ),
                    ),
                    const Gap(4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            '↑',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF4CAF50),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const Gap(6),
                        Text(
                          txAsync.isLoading
                              ? '...'
                              : '+${totalIncome.formatCurrency(decimalDigits: 0)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'GeneralSans',
                            color: Color(0xFF4CAF50),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Vertical divider
              Container(height: 36, width: 1, color: Colors.grey.shade100),

              const Gap(16),

              // Spent
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Spent',
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'GeneralSans',
                        color: Color(0xFF9E9E9E),
                      ),
                    ),
                    const Gap(4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFEBEE),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            '↓',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFFEF5350),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const Gap(6),
                        Text(
                          txAsync.isLoading
                              ? '...'
                              : '-${totalSpent.formatCurrency(decimalDigits: 0)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'GeneralSans',
                            color: Color(0xFFEF5350),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGoalAlertBanner() {
    final goalsAsync = ref.watch(savingsGoalsProvider);

    return goalsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (goals) {
        final activeGoals = goals.where((g) => !g.isCompleted).toList();
        if (activeGoals.isEmpty) return const SizedBox.shrink();

        // Prefer goals that are >= 80% funded
        final almostDone = activeGoals.where(
          (g) => g.targetAmount > 0 && g.balance / g.targetAmount >= 0.8,
        ).toList();

        final goal = almostDone.isNotEmpty ? almostDone.first : activeGoals.first;
        final remaining = (goal.targetAmount - goal.balance).clamp(0.0, double.infinity);
        final isAlmostDone = almostDone.isNotEmpty;

        final message = isAlmostDone
            ? 'Your ${goal.goalName} goal is almost funded. Consider allocating ${remaining.formatCurrency(decimalDigits: 0)} to complete it!'
            : 'You\'re ${(goal.targetAmount > 0 ? (goal.balance / goal.targetAmount * 100).round() : 0)}% toward your ${goal.goalName} goal. Keep saving!';

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8EC),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFFFE9B0)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFE9B0),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('✨', style: TextStyle(fontSize: 16)),
                ),
              ),
              const Gap(10),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    fontSize: 13,
                    fontFamily: 'GeneralSans',
                    color: Color(0xFF7A5C00),
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGoalsSection(BuildContext context) {
    final goalsAsync = ref.watch(savingsGoalsProvider);
    final transactions =
        ref.watch(transactionListProvider).valueOrNull?.data?.transactions ?? [];

    return Column(
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Goals',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                fontFamily: 'GeneralSans',
                color: Colors.black,
              ),
            ),
            GestureDetector(
              onTap: () => context.push(SpendGoalsScreen.path),
              child: const Text(
                'See All',
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'GeneralSans',
                  color: Color(0xFFE8A838),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const Gap(12),

        goalsAsync.when(
          loading: () => _buildGoalCardSkeleton(),
          error: (_, __) => const SizedBox.shrink(),
          data: (goals) {
            final activeGoals =
                goals.where((g) => !g.isCompleted).toList();

            if (activeGoals.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: const Center(
                  child: Text(
                    'No active goals yet.\nTap "See All" to create one.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontFamily: 'GeneralSans',
                      color: Color(0xFF9E9E9E),
                      height: 1.5,
                    ),
                  ),
                ),
              );
            }

            // Rotate through goals daily
            final goal = activeGoals[DateTime.now().day % activeGoals.length];

            // Sum credit transactions whose narration/transactionFor
            // references this goal name
            final goalLower = goal.goalName.toLowerCase();
            final txSaved = transactions
                .where(
                  (t) =>
                      t.isCredit &&
                      t.isSuccess &&
                      (t.narration.toLowerCase().contains(goalLower) ||
                          t.transactionFor.toLowerCase().contains(goalLower)),
                )
                .fold(0.0, (sum, t) => sum + t.amount);

            final savedAmount = txSaved > 0 ? txSaved : goal.balance;
            final targetAmount = goal.targetAmount;
            final fraction = targetAmount > 0
                ? (savedAmount / targetAmount).clamp(0.0, 1.0)
                : 0.0;

            String dueText = '';
            if (goal.endDate.isNotEmpty) {
              final due = DateTime.tryParse(goal.endDate);
              if (due != null) {
                final daysLeft = due.difference(DateTime.now()).inDays;
                if (daysLeft > 0) {
                  dueText =
                      'Due in $daysLeft ${daysLeft == 1 ? 'day' : 'days'}';
                } else if (daysLeft == 0) {
                  dueText = 'Due today';
                } else {
                  dueText = 'Overdue';
                }
              }
            }

            return GestureDetector(
              onTap: () => context.push(SpendGoalsScreen.path),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade100),
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
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: Colors.grey.shade400,
                        ),
                      ],
                    ),
                    const Gap(8),

                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text:
                                '${savedAmount.formatCurrency(decimalDigits: 0)} ',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'GeneralSans',
                              color: Colors.black,
                              letterSpacing: -0.5,
                            ),
                          ),
                          TextSpan(
                            text:
                                'of ${targetAmount.formatCurrency(decimalDigits: 0)}',
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'GeneralSans',
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Gap(10),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: fraction,
                        minHeight: 6,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFFE8A838),
                        ),
                      ),
                    ),

                    if (dueText.isNotEmpty) ...[
                      const Gap(10),
                      Text(
                        dueText,
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'GeneralSans',
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildGoalCardSkeleton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 16,
            width: 120,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const Gap(12),
          Container(
            height: 24,
            width: 200,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const Gap(12),
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const Gap(10),
          Container(
            height: 12,
            width: 80,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Features',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: 'GeneralSans',
            color: Colors.black,
          ),
        ),
        const Gap(12),

        // 2x2 Grid
        Row(
          children: [
            Expanded(
              child: _buildFeatureTile(
                title: 'AI Chat',
                subtitle: 'Ask Nahl',
                color: const Color(0xFFFFF8EC),
                onTap: () => context.push(ChatScreen.path),
              ),
            ),
            const Gap(12),
            Expanded(
              child: _buildFeatureTile(
                title: 'Quick Actions',
                subtitle: 'Send & Pay',
                color: const Color(0xFFF0F4FF),
                onTap: () => context.push(QuickActionsScreen.path),
              ),
            ),
          ],
        ),
        const Gap(12),
        Row(
          children: [
            Expanded(
              child: _buildFeatureTile(
                title: 'Spending Flow',
                subtitle: 'Track patterns',
                color: const Color(0xFFF5F0FF),
                onTap: () => context.push(FlowScreen.path),
              ),
            ),
            const Gap(12),
            Expanded(
              child: _buildFeatureTile(
                title: 'Profile',
                subtitle: 'Settings & Accounts',
                color: const Color(0xFFF0FFF4),
                onTap: () => context.push(SpendProfileScreen.path),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeatureTile({
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                fontFamily: 'GeneralSans',
                color: Colors.black,
              ),
            ),
            const Gap(4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                fontFamily: 'GeneralSans',
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsList() {
    final transactionsAsync = ref.watch(transactionListProvider);

    return transactionsAsync.when(
      data: (response) {
        final all = response.data?.transactions ?? [];
        final transactions = _searchQuery.isEmpty
            ? all
            : all.where((t) {
                final label =
                    (t.narration.isNotEmpty ? t.narration : t.transactionFor)
                        .toLowerCase();
                return label.contains(_searchQuery);
              }).toList();

        if (transactions.isEmpty) {
          return SliverFillRemaining(
            hasScrollBody: false,
            child: _buildEmptyTransactionsState(),
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final transaction = transactions[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: GestureDetector(
                onTap: () => context.pushNamed(
                  TransactionDetailScreen.path,
                  extra: transaction,
                ),
                behavior: HitTestBehavior.opaque,
                child: _buildTransactionItem(transaction),
              ),
            );
          }, childCount: transactions.length),
        );
      },
      loading: () => const SliverToBoxAdapter(
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) =>
          SliverToBoxAdapter(child: CustomErrorWidget.error()),
    );
  }

  Widget _buildTransactionItem(WalletTransaction transaction) {
    return Row(
      children: [
        // Direction Icon
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: transaction.isCredit
                ? const Color(0xFFE8F5E9)
                : const Color(0xFFFFEBEE),
            shape: BoxShape.circle,
          ),
          child: Icon(
            transaction.isCredit ? Icons.arrow_downward : Icons.arrow_upward,
            size: 20,
            color: transaction.isCredit
                ? const Color(0xFF4CAF50)
                : const Color(0xFFEF5350),
          ),
        ),
        const Gap(12),

        // Details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                transaction.narration.isNotEmpty
                    ? transaction.narration
                    : transaction.transactionFor,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'GeneralSans',
                  color: Colors.black,
                ),
              ),
              const Gap(4),
              Row(
                children: [
                  Text(
                    '${transaction.createdAt.formatRelative()} · ${transaction.createdAt.formatTime()}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'GeneralSans',
                      color: Color(0xFF9E9E9E),
                    ),
                  ),
                  if (!transaction.isSuccess) ...[
                    const Gap(6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: transaction.isPending
                            ? Colors.orange.withOpacity(0.15)
                            : Colors.red.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        transaction.status.value,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'GeneralSans',
                          color: transaction.isPending
                              ? Colors.orange
                              : Colors.red,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        const Gap(12),

        // Amount
        Text(
          '${transaction.isCredit ? '+' : '-'}${transaction.amount.formatCurrency()}',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            fontFamily: 'GeneralSans',
            color: transaction.isCredit
                ? const Color(0xFF4CAF50)
                : const Color(0xFFEF5350),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyTransactionsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.info_outline,
              size: 32,
              color: Colors.grey.shade400,
            ),
          ),
          const Gap(16),
          const Text(
            'No available data',
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'GeneralSans',
              color: Color(0xFF9E9E9E),
            ),
          ),
          const Gap(8),
          const Text(
            'Your transactions will appear here',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              fontFamily: 'GeneralSans',
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoAccountState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.account_balance_wallet_outlined,
                size: 48,
                color: Colors.grey.shade400,
              ),
            ),
            const Gap(32),

            const Text(
              'No Savvy Wallet Account',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                fontFamily: 'GeneralSans',
                color: Colors.black,
              ),
            ),
            const Gap(16),

            const Text(
              'Create your Savvy Wallet Account to start spending, receiving money, and managing your finances.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'GeneralSans',
                color: Colors.black87,
                height: 1.5,
              ),
            ),
            const Gap(48),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.pushNamed(CreateWalletScreen.path),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Create Wallet Account',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'GeneralSans',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:gap/gap.dart';
// import 'package:go_router/go_router.dart';
// import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
// import 'package:savvy_bee_mobile/core/utils/date_time_extension.dart';
// import 'package:savvy_bee_mobile/core/utils/num_extensions.dart';
// import 'package:savvy_bee_mobile/core/widgets/custom_error_widget.dart';
// import 'package:savvy_bee_mobile/core/widgets/custom_loading_widget.dart';
// import 'package:savvy_bee_mobile/features/spend/domain/models/wallet.dart';
// import 'package:savvy_bee_mobile/features/spend/presentation/providers/wallet_provider.dart';
// import 'package:savvy_bee_mobile/features/spend/presentation/screens/bills/pay_bills_screen.dart';
// import 'package:savvy_bee_mobile/features/spend/presentation/screens/transactions/transaction_details_screen.dart';
// import 'package:savvy_bee_mobile/features/spend/presentation/screens/transactions/transaction_history_screen.dart';
// import 'package:savvy_bee_mobile/features/spend/presentation/screens/transfer/transfer_screen_one.dart';
// import 'package:savvy_bee_mobile/features/spend/presentation/screens/wallet/add_money_screen.dart';
// import 'package:savvy_bee_mobile/features/spend/presentation/screens/wallet/create_wallet_screen.dart';
// import 'package:savvy_bee_mobile/features/home/presentation/providers/home_data_provider.dart';
// import 'package:savvy_bee_mobile/features/profile/presentation/screens/profile_screen.dart';

// /// Redesigned Spend Screen matching new UI
// class SpendScreen extends ConsumerStatefulWidget {
//   static const String path = '/spend';

//   const SpendScreen({super.key});

//   @override
//   ConsumerState<SpendScreen> createState() => _SpendScreenState();
// }

// class _SpendScreenState extends ConsumerState<SpendScreen> {
//   final TextEditingController _searchController = TextEditingController();
//   String _searchQuery = '';

//   @override
//   void initState() {
//     super.initState();
//     _searchController.addListener(() {
//       setState(() {
//         _searchQuery = _searchController.text.toLowerCase();
//       });
//     });
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final dashboardAsync = ref.watch(spendDashboardDataProvider);

//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: dashboardAsync.when(
//           skipLoadingOnRefresh: false,
//           data: (response) {
//             if (response.data == null) {
//               return _buildNoAccountState();
//             }

//             final dashboard = response.data!;
//             final hasWallet = dashboard.accounts.ngnAccount != null;

//             if (!hasWallet) {
//               return _buildNoAccountState();
//             }

//             return RefreshIndicator(
//               onRefresh: () async {
//                 ref.invalidate(spendDashboardDataProvider);
//                 ref.invalidate(transactionListProvider);
//               },
//               child: CustomScrollView(
//                 slivers: [
//                   // Top Bar with Profile, Search, and Analytics
//                   SliverToBoxAdapter(
//                     child: Padding(
//                       padding: const EdgeInsets.all(16),
//                       child: _buildTopBar(context),
//                     ),
//                   ),

//                   // Wallet Balance Card
//                   SliverToBoxAdapter(
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 16),
//                       child: _buildWalletCard(dashboard),
//                     ),
//                   ),

//                   const SliverGap(32),

//                   // Action Buttons
//                   SliverToBoxAdapter(child: _buildActionButtons(context)),

//                   const SliverGap(40),

//                   // Transactions Section
//                   SliverToBoxAdapter(
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 16),
//                       child: const Text(
//                         'TRANSACTIONS',
//                         style: TextStyle(
//                           fontSize: 11,
//                           fontWeight: FontWeight.w600,
//                           fontFamily: 'GeneralSans',
//                           color: Color(0xFF757575),
//                           letterSpacing: 0.5,
//                         ),
//                       ),
//                     ),
//                   ),

//                   const SliverGap(16),

//                   // Transactions List
//                   _buildTransactionsList(),
//                 ],
//               ),
//             );
//           },
//           loading: () => const CustomLoadingWidget(),
//           error: (error, stack) => CustomErrorWidget.error(
//             onRetry: () => ref.invalidate(spendDashboardDataProvider),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTopBar(BuildContext context) {
//     final firstName = ref.watch(homeDataProvider).valueOrNull?.data?.firstName ?? '';
//     final initials = firstName.isNotEmpty
//         ? (firstName.length > 1 ? firstName.substring(0, 2).toUpperCase() : firstName[0].toUpperCase())
//         : 'Me';

//     return Row(
//       children: [
//         // Profile Circle
//         GestureDetector(
//           onTap: () => context.pushNamed(ProfileScreen.path),
//           child: Container(
//             width: 48,
//             height: 48,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               border: Border.all(color: Colors.black, width: 2),
//             ),
//             child: Center(
//               child: Text(
//                 initials,
//                 style: const TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                   fontFamily: 'GeneralSans',
//                   color: Colors.black,
//                 ),
//               ),
//             ),
//           ),
//         ),
//         const Gap(12),

//         // Search Bar
//         Expanded(
//           child: Container(
//             height: 48,
//             decoration: BoxDecoration(
//               color: const Color(0xFFF5F5F5),
//               borderRadius: BorderRadius.circular(24),
//             ),
//             child: TextField(
//               controller: _searchController,
//               decoration: InputDecoration(
//                 hintText: 'Search',
//                 hintStyle: TextStyle(
//                   fontSize: 16,
//                   fontFamily: 'GeneralSans',
//                   color: Colors.grey.shade400,
//                 ),
//                 prefixIcon: Icon(
//                   Icons.search,
//                   color: Colors.grey.shade400,
//                   size: 24,
//                 ),
//                 border: InputBorder.none,
//                 contentPadding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 12,
//                 ),
//               ),
//             ),
//           ),
//         ),
//         const Gap(12),

//         // Analytics Icon
//         Container(
//           width: 48,
//           height: 48,
//           decoration: BoxDecoration(
//             color: const Color(0xFFF5F5F5),
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Center(
//             child: Icon(
//               Icons.bar_chart_rounded,
//               color: Colors.grey.shade700,
//               size: 24,
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildWalletCard(WalletDashboardData dashboard) {
//     final primaryAccount = dashboard.accounts;

//     return Container(
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: Colors.grey.shade200),
//       ),
//       child: Column(
//         children: [
//           // Account Number with Copy
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Text(
//                 'Savvy Wallet',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w500,
//                   fontFamily: 'GeneralSans',
//                   color: Colors.black,
//                 ),
//               ),
//               const Gap(4),
//               Text(
//                 '|',
//                 style: TextStyle(fontSize: 16, color: Colors.grey.shade400),
//               ),
//               const Gap(4),
//               Text(
//                 primaryAccount.ngnAccount?.accountNumber ?? '0000000000',
//                 style: const TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w500,
//                   fontFamily: 'GeneralSans',
//                   color: Colors.black,
//                 ),
//               ),
//               const Gap(8),
//               InkWell(
//                 onTap: () {
//                   final acctNo = primaryAccount.ngnAccount?.accountNumber ?? '';
//                   if (acctNo.isNotEmpty) {
//                     Clipboard.setData(ClipboardData(text: acctNo));
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(
//                         content: Text('Account number copied'),
//                         duration: Duration(seconds: 2),
//                       ),
//                     );
//                   }
//                 },
//                 child: Icon(Icons.copy, size: 16, color: Colors.grey.shade600),
//               ),
//             ],
//           ),
//           const Gap(24),

//           // Balance
//           Consumer(
//             builder: (context, ref, _) {
//               final isPrivate = ref.watch(balancePrivacyProvider);
//               return Text(
//                 isPrivate
//                     ? '₦ ••••••'
//                     : primaryAccount.balance.formatCurrency(),
//                 style: const TextStyle(
//                   fontSize: 30,
//                   fontWeight: FontWeight.bold,
//                   fontFamily: 'GeneralSans',
//                   color: Colors.black,
//                   letterSpacing: -1,
//                 ),
//               );
//             },
//           ),
//           const Gap(8),

//           // Available Balance Label
//           const Text(
//             'Available balance',
//             style: TextStyle(
//               fontSize: 14,
//               fontFamily: 'GeneralSans',
//               color: Color(0xFF9E9E9E),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildActionButtons(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       child: Row(
//         children: [
//           Expanded(
//             child: _buildActionButton(
//               icon: Icons.send_outlined,
//               label: 'Send Money',
//               onTap: () => context.push(TransferScreenOne.path),
//             ),
//           ),
//           const Gap(12),
//           Expanded(
//             child: _buildActionButton(
//               icon: Icons.account_balance_wallet_outlined,
//               label: 'Add Money',
//               onTap: () => context.pushNamed(AddMoneyScreen.path),
//             ),
//           ),
//           const Gap(12),
//           Expanded(
//             child: _buildActionButton(
//               icon: Icons.bolt_outlined,
//               label: 'Pay Bills',
//               onTap: () => context.pushNamed(PayBillsScreen.path),
//             ),
//           ),
//           const Gap(12),
//           Expanded(
//             child: _buildActionButton(
//               icon: Icons.description_outlined,
//               label: 'Details',
//               onTap: () => context.pushNamed(TransactionHistoryScreen.path),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildActionButton({
//     required IconData icon,
//     required String label,
//     required VoidCallback onTap,
//   }) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(16),
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 16),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(color: Colors.grey.shade200),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(icon, size: 28, color: Colors.black),
//             const Gap(8),
//             Text(
//               label,
//               textAlign: TextAlign.center,
//               style: const TextStyle(
//                 fontSize: 8,
//                 fontWeight: FontWeight.w500,
//                 fontFamily: 'GeneralSans',
//                 color: Colors.black,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildTransactionsList() {
//     final transactionsAsync = ref.watch(transactionListProvider);

//     return transactionsAsync.when(
//       data: (response) {
//         final all = response.data?.transactions ?? [];
//         final transactions = _searchQuery.isEmpty
//             ? all
//             : all.where((t) {
//                 final label = (t.narration.isNotEmpty ? t.narration : t.transactionFor).toLowerCase();
//                 return label.contains(_searchQuery);
//               }).toList();

//         if (transactions.isEmpty) {
//           return SliverFillRemaining(
//             hasScrollBody: false,
//             child: _buildEmptyTransactionsState(),
//           );
//         }

//         return SliverList(
//           delegate: SliverChildBuilderDelegate((context, index) {
//             final transaction = transactions[index];
//             return Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               child: GestureDetector(
//                 onTap: () => context.pushNamed(
//                   TransactionDetailScreen.path,
//                   extra: transaction,
//                 ),
//                 behavior: HitTestBehavior.opaque,
//                 child: _buildTransactionItem(transaction),
//               ),
//             );
//           }, childCount: transactions.length),
//         );
//       },
//       loading: () => const SliverToBoxAdapter(
//         child: Center(child: CircularProgressIndicator()),
//       ),
//       error: (error, stack) =>
//           SliverToBoxAdapter(child: CustomErrorWidget.error()),
//     );
//   }

//   Widget _buildTransactionItem(WalletTransaction transaction) {
//     return Row(
//       children: [
//         // Direction Icon
//         Container(
//           width: 40,
//           height: 40,
//           decoration: BoxDecoration(
//             color: transaction.isCredit
//                 ? const Color(0xFFE8F5E9)
//                 : const Color(0xFFFFEBEE),
//             shape: BoxShape.circle,
//           ),
//           child: Icon(
//             transaction.isCredit ? Icons.arrow_downward : Icons.arrow_upward,
//             size: 20,
//             color: transaction.isCredit
//                 ? const Color(0xFF4CAF50)
//                 : const Color(0xFFEF5350),
//           ),
//         ),
//         const Gap(12),

//         // Details
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 transaction.narration.isNotEmpty
//                     ? transaction.narration
//                     : transaction.transactionFor,
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//                 style: const TextStyle(
//                   fontSize: 15,
//                   fontWeight: FontWeight.w500,
//                   fontFamily: 'GeneralSans',
//                   color: Colors.black,
//                 ),
//               ),
//               const Gap(4),
//               Row(
//                 children: [
//                   Text(
//                     '${transaction.createdAt.formatRelative()} · ${transaction.createdAt.formatTime()}',
//                     style: const TextStyle(
//                       fontSize: 12,
//                       fontFamily: 'GeneralSans',
//                       color: Color(0xFF9E9E9E),
//                     ),
//                   ),
//                   if (!transaction.isSuccess) ...[
//                     const Gap(6),
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 6,
//                         vertical: 2,
//                       ),
//                       decoration: BoxDecoration(
//                         color: transaction.isPending
//                             ? Colors.orange.withOpacity(0.15)
//                             : Colors.red.withOpacity(0.15),
//                         borderRadius: BorderRadius.circular(4),
//                       ),
//                       child: Text(
//                         transaction.status.value,
//                         style: TextStyle(
//                           fontSize: 10,
//                           fontWeight: FontWeight.w600,
//                           fontFamily: 'GeneralSans',
//                           color: transaction.isPending
//                               ? Colors.orange
//                               : Colors.red,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ],
//               ),
//             ],
//           ),
//         ),
//         const Gap(12),

//         // Amount
//         Text(
//           '${transaction.isCredit ? '+' : '-'}${transaction.amount.formatCurrency()}',
//           style: TextStyle(
//             fontSize: 15,
//             fontWeight: FontWeight.w600,
//             fontFamily: 'GeneralSans',
//             color: transaction.isCredit
//                 ? const Color(0xFF4CAF50)
//                 : const Color(0xFFEF5350),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildEmptyTransactionsState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             width: 64,
//             height: 64,
//             decoration: BoxDecoration(
//               color: Colors.grey.shade100,
//               shape: BoxShape.circle,
//             ),
//             child: Icon(
//               Icons.info_outline,
//               size: 32,
//               color: Colors.grey.shade400,
//             ),
//           ),
//           const Gap(16),
//           const Text(
//             'No available data',
//             style: TextStyle(
//               fontSize: 14,
//               fontFamily: 'GeneralSans',
//               color: Color(0xFF9E9E9E),
//             ),
//           ),
//           const Gap(8),
//           const Text(
//             'Your transactions will appear here',
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w500,
//               fontFamily: 'GeneralSans',
//               color: Colors.black,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildNoAccountState() {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // Sad Flower or Icon
//             Container(
//               width: 120,
//               height: 120,
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade100,
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 Icons.account_balance_wallet_outlined,
//                 size: 48,
//                 color: Colors.grey.shade400,
//               ),
//             ),
//             const Gap(32),

//             const Text(
//               'No Savvy Wallet Account',
//               style: TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.w600,
//                 fontFamily: 'GeneralSans',
//                 color: Colors.black,
//               ),
//             ),
//             const Gap(16),

//             const Text(
//               'Create your Savvy Wallet Account to start spending, receiving money, and managing your finances.',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontSize: 16,
//                 fontFamily: 'GeneralSans',
//                 color: Colors.black87,
//                 height: 1.5,
//               ),
//             ),
//             const Gap(48),

//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: () => context.pushNamed(CreateWalletScreen.path),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.black,
//                   foregroundColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   elevation: 0,
//                 ),
//                 child: const Text(
//                   'Create Wallet Account',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                     fontFamily: 'GeneralSans',
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
