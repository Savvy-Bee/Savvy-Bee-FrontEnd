import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/assets/app_icons.dart';
import 'package:savvy_bee_mobile/core/utils/assets/illustrations.dart';
import 'package:savvy_bee_mobile/core/widgets/charts/custom_line_chart.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_loading_widget.dart';
import 'package:savvy_bee_mobile/features/auth/presentation/screens/post_signup/bottom_sheets/connect_bank_intro_bottom_sheet.dart';
import 'package:savvy_bee_mobile/features/chat/presentation/screens/chat_screen.dart';
import 'package:savvy_bee_mobile/features/dashboard/domain/models/dashboard_data.dart';
import 'package:savvy_bee_mobile/features/dashboard/presentation/providers/dashboard_data_provider.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_error_widget.dart';
import 'package:savvy_bee_mobile/features/dashboard/presentation/screens/spending_screen.dart';
import 'package:savvy_bee_mobile/features/dashboard/presentation/widgets/financial_health_card.dart';
import 'package:savvy_bee_mobile/features/dashboard/presentation/widgets/info_card.dart';
import 'package:savvy_bee_mobile/features/home/presentation/providers/home_data_provider.dart';
import 'package:savvy_bee_mobile/features/profile/presentation/screens/profile_screen.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/screens/goals/goals_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  static const String path = '/dashboard';

  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String formatMoney(double amount) {
    return '₦${NumberFormat('#,###.00').format(amount)}';
  }

  @override
  Widget build(BuildContext context) {
    final dashboardDataAsync = ref.watch(dashboardDataProvider('all'));

    final homeData = ref.watch(homeDataProvider);

    return homeData.when(
      skipLoadingOnRefresh: true, // Changed to true to show cached data

      data: (value) {
        final data = value.data;

        return Scaffold(
          appBar: _buildAppBar(data.firstName, context),
          body: SafeArea(
            child: dashboardDataAsync.when(
              skipLoadingOnRefresh: true, // Changed to true to show cached data
              data: (dashboardData) {
                if (dashboardData == null) {
                  return CustomErrorWidget(
                    icon: Icons.link_off_rounded,
                    title: 'No linked account',
                    subtitle: 'Link your account to keep track of your money',
                    actionButtonText: 'Link account',
                    onActionPressed: () {
                      ConnectBankIntroBottomSheet.show(context);
                    },
                  );
                }
                return RefreshIndicator(
                  onRefresh: () =>
                      ref.read(dashboardDataProvider('all').notifier).refresh(),
                  child: SingleChildScrollView(
                    physics:
                        const AlwaysScrollableScrollPhysics(), // Ensures pull to refresh always works
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 420,
                            child: PageView(
                              controller: _pageController,
                              onPageChanged: (index) {
                                setState(() {
                                  _currentPage = index;
                                });
                              },
                              children: [
                                SpendCard(dashboardData: dashboardData),
                                NetWorthCard(dashboardData: dashboardData),
                                FinancialHealthCard(
                                  healthData:
                                      dashboardData.widgets.financialHealth,
                                ),
                              ],
                            ),
                          ),
                          const Gap(8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(3, (index) {
                              return Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                width: _currentPage == index ? 16 : 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: _currentPage == index
                                      ? AppColors.yellow
                                      : AppColors.greyLight,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              );
                            }),
                          ),
                          const Gap(16),
                          AccountsSection(dashboardData: dashboardData),
                          // const Gap(16),
                          // FinancialGoalsSection(savings: dashboardData.savings),
                          const Gap(16),
                          RecentTransactionsSection(
                            transactions: dashboardData.accounts.isNotEmpty
                                ? dashboardData.accounts[0].history12Months
                                : [],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              loading: () =>
                  const CustomLoadingWidget(text: 'Loading your dashboard...'),
              error: (error, stack) => CustomErrorWidget(
                icon: Icons.dashboard_outlined,
                title: 'Unable to Load Dashboard',
                subtitle:
                    'We couldn\'t fetch your dashboard data. Please check your connection and try again.',
                onActionPressed: () {
                  ref.invalidate(dashboardDataProvider);
                },
                actionButtonText: 'Reload',
              ),
            ),
          ),
        );
      },
      error: (error, stack) => CustomErrorWidget(
        icon: Icons.dashboard_outlined,
        title: 'Unable to Load Dashboard',
        subtitle:
            'We couldn\'t fetch your dashboard data. Please check your connection and try again.',
        onActionPressed: () {
          ref.invalidate(dashboardDataProvider);
          ref.invalidate(homeDataProvider);
        },
      ),
      loading: () =>
          const CustomLoadingWidget(text: 'Loading your dashboard...'),
    );
  }

  AppBar _buildAppBar(String firstName, BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent, // important
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          // gradient: LinearGradient(
          //   begin: Alignment.topLeft,
          //   end: Alignment.topRight, // left → right
          //   colors: [Color(0xFFFFEFB5), Color(0xFFFFC300)],
          // ),
        ),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // LEFT
          GestureDetector(
            onTap: () {
              // Navigator.push(...)
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
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
                          letterSpacing: 12 * 0.02,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 25),

                Image.asset(
                  'assets/images/topbar/nav-center-icon.png',
                  width: 30,
                  height: 32,
                  fit: BoxFit.contain,
                ),
              ],
            ),
          ),

          // RIGHT
          GestureDetector(
            onTap: () => context.pushNamed(ProfileScreen.path),
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
                    letterSpacing: 16 * 0.02,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      centerTitle: false,
      automaticallyImplyLeading: false,
    );
  }
}

// FIXED: Spend Card widget with dynamic time range comparisons
class SpendCard extends StatefulWidget {
  final DashboardData dashboardData;

  const SpendCard({super.key, required this.dashboardData});

  @override
  State<SpendCard> createState() => _SpendCardState();
}

class _SpendCardState extends State<SpendCard> {
  TimeRange _selectedRange = TimeRange.oneMonth;
  bool _forceShowChart = false;

  double _getSpendForRange(TimeRange range) {
    final now = DateTime.now();
    final cutoff = now.subtract(range.duration);
    double spend = 0;

    for (var account in widget.dashboardData.accounts) {
      for (var tx in account.history12Months) {
        if (tx.date.isAfter(cutoff) && tx.type == 'debit') {
          spend += tx.amount / 100;
        }
      }
    }
    return spend;
  }

  double _getPreviousPeriodSpend(TimeRange range) {
    final now = DateTime.now();
    final currentPeriodStart = now.subtract(range.duration);
    final previousPeriodStart = currentPeriodStart.subtract(range.duration);
    double spend = 0;

    for (var account in widget.dashboardData.accounts) {
      for (var tx in account.history12Months) {
        if (tx.date.isAfter(previousPeriodStart) &&
            tx.date.isBefore(currentPeriodStart) &&
            tx.type == 'debit') {
          spend += tx.amount / 100;
        }
      }
    }
    return spend;
  }

  String _getComparisonText(TimeRange range) {
    switch (range) {
      case TimeRange.threeDays:
        return 'previous 3 days';
      case TimeRange.oneWeek:
        return 'previous week';
      case TimeRange.oneMonth:
        return 'last month';
      case TimeRange.threeMonths:
        return 'previous 3 months';
      case TimeRange.sixMonths:
        return 'previous 6 months';
      case TimeRange.oneYear:
        return 'previous year';
    }
  }

  String _getCurrentPeriodLabel(TimeRange range) {
    switch (range) {
      case TimeRange.threeDays:
        return 'Current spend (3 days)';
      case TimeRange.oneWeek:
        return 'Current spend (1 week)';
      case TimeRange.oneMonth:
        return 'Current spend this month';
      case TimeRange.threeMonths:
        return 'Current spend (3 months)';
      case TimeRange.sixMonths:
        return 'Current spend (6 months)';
      case TimeRange.oneYear:
        return 'Current spend (1 year)';
    }
  }

  List<ChartDataPoint> getSpendChartData() {
    final now = DateTime.now();
    final cutoff = now.subtract(_selectedRange.duration);

    // Collect debit transactions within the selected range
    List<Transaction> debits = [];
    for (var account in widget.dashboardData.accounts) {
      debits.addAll(
        account.history12Months.where(
          (tx) => tx.type == 'debit' && tx.date.isAfter(cutoff),
        ),
      );
    }

    if (debits.isEmpty) {
      return [];
    }

    // Sort by date
    debits.sort((a, b) => a.date.compareTo(b.date));

    // Group by day and sum amounts
    Map<DateTime, double> dailySpend = {};
    for (var tx in debits) {
      final dateOnly = DateTime(tx.date.year, tx.date.month, tx.date.day);
      dailySpend[dateOnly] = (dailySpend[dateOnly] ?? 0) + (tx.amount / 100);
    }

    // Convert to chart data points
    final sortedDates = dailySpend.keys.toList()..sort();
    return sortedDates
        .map(
          (date) => ChartDataPoint(value: dailySpend[date]!, timestamp: date),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final currentSpend = _getSpendForRange(_selectedRange);
    final previousSpend = _getPreviousPeriodSpend(_selectedRange);
    final difference = currentSpend - previousSpend;
    final isBelow = difference < 0;
    final chartData = getSpendChartData();

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  _getCurrentPeriodLabel(_selectedRange),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.grey,
                    fontFamily: 'GeneralSans',
                    letterSpacing: 12 * 0.02,
                  ),
                ),

                const Gap(4),
                if (previousSpend > 0)
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(
                          isBelow ? Icons.check_circle : Icons.info_outline,
                          size: 14,
                          color: isBelow ? AppColors.success : AppColors.grey,
                        ),
                        const Gap(4),
                        Flexible(
                          child: Text(
                            '${formatMoney(difference.abs())} ${isBelow ? 'below' : 'above'} ${_getComparisonText(_selectedRange)}',
                            style: TextStyle(
                              color: isBelow
                                  ? AppColors.success
                                  : AppColors.grey,
                              fontSize: 11,
                              fontFamily: 'GeneralSans',
                              letterSpacing: 11 * 0.02,
                            ),
                            softWrap: true,
                            maxLines: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            const Gap(8),
            Text(
              formatMoney(currentSpend),
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                fontFamily: 'GeneralSans',
                letterSpacing: 32 * 0.02,
              ),
            ),
            const Gap(16),
            Expanded(
              child: chartData.isNotEmpty || _forceShowChart
                  ? CustomLineChart(
                      data: chartData.isNotEmpty
                          ? chartData
                          : [
                              ChartDataPoint(
                                value: 0,
                                timestamp: DateTime.now(),
                              ),
                            ],
                      onRangeChanged: (range) {
                        setState(() {
                          _selectedRange = range;
                        });
                      },
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.show_chart,
                            size: 48,
                            color: AppColors.greyLight,
                          ),
                          const Gap(8),
                          const Text(
                            'Not enough spending data',
                            style: TextStyle(
                              color: AppColors.grey,
                              fontSize: 14,
                              fontFamily: 'GeneralSans',
                              letterSpacing: 14 * 0.02,
                            ),
                          ),
                          const Gap(16),
                          OutlinedButton.icon(
                            onPressed: () {
                              setState(() {
                                _forceShowChart = true;
                              });
                            },
                            icon: const Icon(Icons.show_chart, size: 16),
                            label: const Text('Show chart anyway'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
            const Gap(8),
            TextButton(
              onPressed: () => context.pushNamed(SpendingScreen.path),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Row(
                children: [
                  // Icon(Icons.receipt_long, size: 16),
                  Image.asset(
                    'assets/images/icons/Wallet.png',
                    width: 16,
                    height: 16,
                  ),
                  Gap(4),
                  Text(
                    'View Spending',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'GeneralSans',
                      letterSpacing: 14 * 0.02,
                      fontSize: 14,
                    ),
                  ),
                  // Gap(4),
                  Spacer(),
                  Icon(Icons.chevron_right, size: 16, color: Colors.black),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String formatMoney(double amount) {
    return '₦${NumberFormat('#,###.##').format(amount.abs())}';
  }
}

// FIXED: Net Worth Card with dynamic time range comparisons
class NetWorthCard extends StatefulWidget {
  final DashboardData dashboardData;

  const NetWorthCard({super.key, required this.dashboardData});

  @override
  State<NetWorthCard> createState() => _NetWorthCardState();
}

class _NetWorthCardState extends State<NetWorthCard> {
  TimeRange _selectedRange = TimeRange.oneMonth;
  bool _forceShowChart = false;

  double getNetWorth() {
    // Sum all account balances (already in naira from API)
    double accountBalances = widget.dashboardData.accounts.fold(
      0.0,
      (sum, account) => sum + account.details.balance,
    );

    // Sum all savings balances
    double savingsBalance = widget.dashboardData.savings.fold(
      0.0,
      (sum, goal) => sum + goal.balance,
    );

    return accountBalances + savingsBalance;
  }

  double _getNetWorthChangeForRange(TimeRange range) {
    final now = DateTime.now();
    final cutoff = now.subtract(range.duration);
    double income = 0;
    double expenses = 0;

    for (var account in widget.dashboardData.accounts) {
      for (var tx in account.history12Months) {
        if (tx.date.isAfter(cutoff)) {
          if (tx.type == 'credit') {
            income += tx.amount / 100;
          } else if (tx.type == 'debit') {
            expenses += tx.amount / 100;
          }
        }
      }
    }

    return income - expenses;
  }

  String _getComparisonText(TimeRange range) {
    switch (range) {
      case TimeRange.threeDays:
        return 'previous 3 days';
      case TimeRange.oneWeek:
        return 'previous week';
      case TimeRange.oneMonth:
        return 'last month';
      case TimeRange.threeMonths:
        return 'previous 3 months';
      case TimeRange.sixMonths:
        return 'previous 6 months';
      case TimeRange.oneYear:
        return 'previous year';
    }
  }

  List<ChartDataPoint> getNetWorthChartData() {
    final now = DateTime.now();
    final cutoff = now.subtract(_selectedRange.duration);

    // Collect ALL transactions within the selected range
    List<Transaction> allTxs = [];
    for (var account in widget.dashboardData.accounts) {
      allTxs.addAll(
        account.history12Months.where((tx) => tx.date.isAfter(cutoff)),
      );
    }

    if (allTxs.isEmpty) {
      return [];
    }

    // Sort by date
    allTxs.sort((a, b) => a.date.compareTo(b.date));

    // Calculate cumulative balance over time
    double runningBalance = getNetWorth();
    List<ChartDataPoint> data = [];

    // Work backwards from current balance
    for (var tx in allTxs.reversed) {
      // Reverse the transaction effect
      if (tx.type == 'credit') {
        runningBalance -= (tx.amount / 100);
      } else if (tx.type == 'debit') {
        runningBalance += (tx.amount / 100);
      }

      data.insert(
        0,
        ChartDataPoint(
          value: runningBalance.isNegative ? 0 : runningBalance,
          timestamp: tx.date,
        ),
      );
    }

    // Add current balance as the last point
    if (data.isNotEmpty) {
      data.add(ChartDataPoint(value: getNetWorth(), timestamp: now));
    }

    return data;
  }

  @override
  Widget build(BuildContext context) {
    final netWorth = getNetWorth();
    final change = _getNetWorthChangeForRange(_selectedRange);
    final isPositive = change >= 0;
    final chartData = getNetWorthChartData();

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Net Worth',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.grey,
                    fontFamily: 'GeneralSans',
                    letterSpacing: 12 * 0.02,
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      isPositive ? Icons.check_circle : Icons.info_outline,
                      size: 14,
                      color: isPositive ? AppColors.success : AppColors.grey,
                    ),
                    const Gap(4),
                    Text(
                      '${formatMoney(change.abs())} ${isPositive ? 'gain' : 'loss'} vs ${_getComparisonText(_selectedRange)}',
                      style: TextStyle(
                        color: isPositive ? AppColors.success : AppColors.grey,
                        fontSize: 11,
                        fontFamily: 'GeneralSans',
                        letterSpacing: 11 * 0.02,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Gap(8),
            Text(
              formatMoney(netWorth),
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                fontFamily: 'GeneralSans',
                letterSpacing: 32 * 0.02,
              ),
            ),
            const Gap(16),
            Expanded(
              child: chartData.length >= 2 || _forceShowChart
                  ? CustomLineChart(
                      data: chartData.length >= 2
                          ? chartData
                          : [
                              ChartDataPoint(
                                value: netWorth,
                                timestamp: DateTime.now(),
                              ),
                            ],
                      onRangeChanged: (range) {
                        setState(() {
                          _selectedRange = range;
                        });
                      },
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.trending_up,
                            size: 48,
                            color: AppColors.greyLight,
                          ),
                          const Gap(8),
                          const Text(
                            'Not enough data',
                            style: TextStyle(
                              color: AppColors.grey,
                              fontSize: 14,
                              fontFamily: 'GeneralSans',
                              letterSpacing: 14 * 0.02,
                            ),
                          ),
                          const Gap(16),
                          OutlinedButton.icon(
                            onPressed: () {
                              setState(() {
                                _forceShowChart = true;
                              });
                            },
                            icon: const Icon(Icons.show_chart, size: 16),
                            label: const Text('Show chart anyway'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String formatMoney(double amount) {
    return '₦${NumberFormat('#,###.##').format(amount.abs())}';
  }
}

// Rest of the widgets remain the same...
class AccountsSection extends StatefulWidget {
  final DashboardData dashboardData;

  const AccountsSection({super.key, required this.dashboardData});

  @override
  State<AccountsSection> createState() => _AccountsSectionState();
}

class _AccountsSectionState extends State<AccountsSection> {
  bool _isSavingsExpanded = false;

  @override
  Widget build(BuildContext context) {
    double netCash = widget.dashboardData.accounts.fold(
      0.0,
      (sum, account) => sum + account.details.balance,
    );

    double savingsBalance = widget.dashboardData.savings.fold(
      0.0,
      (sum, goal) => sum + goal.balance,
    );

    final displayedGoals = _isSavingsExpanded
        ? widget.dashboardData.savings
        : widget.dashboardData.savings.take(2).toList();

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'ACCOUNTS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'GeneralSans',
                    letterSpacing: 12 * 0.02,
                  ),
                ),
                // TextButton(
                //   onPressed: () {},
                //   style: TextButton.styleFrom(
                //     padding: EdgeInsets.zero,
                //     minimumSize: Size.zero,
                //     tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                //   ),
                //   child: const Text('Add account'),
                // ),
              ],
            ),

            const Gap(8),

            // NET CASH
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.account_balance_wallet_outlined),
              title: const Text('Net cash'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    formatMoney(netCash),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontFamily: 'GeneralSans',
                    ),
                  ),
                  const Gap(8),
                  const Icon(
                    Icons.info_outline,
                    size: 16,
                    color: AppColors.grey,
                  ),
                ],
              ),
            ),

            // SAVINGS (CLICK TO EXPAND)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.savings_outlined),
              title: const Text('Savings'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    formatMoney(savingsBalance),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontFamily: 'GeneralSans',
                    ),
                  ),
                  const Gap(8),
                  Icon(
                    _isSavingsExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 16,
                  ),
                ],
              ),
              onTap: () {
                setState(() {
                  _isSavingsExpanded = !_isSavingsExpanded;
                });
              },
            ),

            // FINANCIAL GOALS (COLLAPSED UNDER SAVINGS)
            if (_isSavingsExpanded) ...[
              const Gap(8),

              if (widget.dashboardData.savings.isEmpty)
                Center(
                  child: Column(
                    children: const [
                      Icon(
                        Icons.flag_outlined,
                        size: 48,
                        color: AppColors.greyLight,
                      ),
                      Gap(8),
                      Text(
                        'No financial goals yet',
                        style: TextStyle(
                          color: AppColors.grey,
                          fontFamily: 'GeneralSans',
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...displayedGoals.map(
                  (goal) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                    leading: Icon(_getIconForGoal(goal.goalName)),
                    title: Text(goal.goalName),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Gap(4),
                        LinearProgressIndicator(
                          value: goal.progressPercentage / 100,
                          backgroundColor: AppColors.greyLight,
                          valueColor: const AlwaysStoppedAnimation(
                            AppColors.success,
                          ),
                          minHeight: 4,
                          borderRadius: BorderRadius.circular(2),
                        ),
                        const Gap(4),
                        Text(
                          goal.isCompleted ? 'Completed' : 'Ongoing',
                          style: const TextStyle(
                            fontSize: 11,
                            fontFamily: 'GeneralSans',
                            letterSpacing: 11 * 0.02,
                          ),
                        ),
                      ],
                    ),
                    trailing: Text(
                      formatMoney(goal.balance),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontFamily: 'GeneralSans',
                      ),
                    ),
                  ),
                ),

              if (widget.dashboardData.savings.length > 2) const Gap(8),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => context.pushNamed(GoalsScreen.path),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add new goal'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String formatMoney(double amount) {
    return '₦${NumberFormat('#,###.00').format(amount)}';
  }

  IconData _getIconForGoal(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('vacation')) return Icons.beach_access;
    if (lower.contains('rent') || lower.contains('house')) return Icons.home;
    if (lower.contains('emergency')) return Icons.shield;
    if (lower.contains('car')) return Icons.directions_car;
    if (lower.contains('debt')) return Icons.credit_card;
    if (lower.contains('dog') || lower.contains('pet')) return Icons.pets;
    return Icons.savings;
  }
}

class RecentTransactionsSection extends StatelessWidget {
  final List<Transaction> transactions;

  const RecentTransactionsSection({super.key, required this.transactions});

  void _showAllTransactions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          AllTransactionsBottomSheet(transactions: transactions),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Show recent transactions of all types, not just debits
    final recent = transactions.take(5).toList();

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'RECENT TRANSACTIONS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                TextButton(
                  onPressed: () => _showAllTransactions(context),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('See all'),
                ),
              ],
            ),
            const Gap(8),
            if (recent.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Center(
                  child: Column(
                    children: const [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 48,
                        color: AppColors.greyLight,
                      ),
                      Gap(8),
                      Text(
                        'No recent transactions',
                        style: TextStyle(
                          color: AppColors.grey,
                          fontFamily: 'GeneralSans',
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...recent.map(
                (tx) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  leading: CircleAvatar(
                    backgroundColor: tx.type == 'credit'
                        ? AppColors.success.withOpacity(0.1)
                        : AppColors.greyLight,
                    child: Icon(
                      _getIconForTransaction(tx.narration),
                      size: 20,
                      color: tx.type == 'credit'
                          ? AppColors.success
                          : AppColors.black,
                    ),
                  ),
                  title: Text(
                    tx.narration,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    _formatDate(tx.date),
                    style: const TextStyle(fontSize: 11),
                  ),
                  trailing: Text(
                    '${tx.type == 'credit' ? '+' : '-'}${formatMoney(tx.amount / 100)}',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: tx.type == 'credit'
                          ? AppColors.success
                          : AppColors.black,
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

  String _formatDate(DateTime date) {
    final day = date.day;
    String suffix = 'th';
    if (day == 1 || day == 21 || day == 31) {
      suffix = 'st';
    } else if (day == 2 || day == 22) {
      suffix = 'nd';
    } else if (day == 3 || day == 23) {
      suffix = 'rd';
    }
    return '${DateFormat('MMMM').format(date)} $day$suffix';
  }

  IconData _getIconForTransaction(String narration) {
    final lower = narration.toLowerCase();
    if (lower.contains('groceries') || lower.contains('food'))
      return Icons.shopping_cart;
    if (lower.contains('electricity') || lower.contains('bill'))
      return Icons.bolt;
    if (lower.contains('spotify') ||
        lower.contains('music') ||
        lower.contains('netflix'))
      return Icons.music_note;
    if (lower.contains('transfer') || lower.contains('sent')) return Icons.send;
    if (lower.contains('deposit') || lower.contains('received'))
      return Icons.account_balance;
    if (lower.contains('card') || lower.contains('payment'))
      return Icons.credit_card;
    if (lower.contains('airtime') || lower.contains('data'))
      return Icons.phone_android;
    if (lower.contains('interest') || lower.contains('cashback'))
      return Icons.trending_up;
    if (lower.contains('withdrawal')) return Icons.money;
    if (lower.contains('save') || lower.contains('saving'))
      return Icons.savings;
    if (lower.contains('fuel') || lower.contains('diesel'))
      return Icons.local_gas_station;
    if (lower.contains('school')) return Icons.school;
    if (lower.contains('transport')) return Icons.directions_bus;
    if (lower.contains('cloth') || lower.contains('hair'))
      return Icons.shopping_bag;
    return Icons.payment;
  }

  String formatMoney(double amount) {
    return '₦${NumberFormat('#,###.00').format(amount)}';
  }
}

// NEW: Bottom sheet to show all transactions
class AllTransactionsBottomSheet extends StatelessWidget {
  final List<Transaction> transactions;

  const AllTransactionsBottomSheet({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'All Transactions',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'GeneralSans',
                        letterSpacing: 20 * 0.02,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Transaction list
              Expanded(
                child: transactions.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.receipt_long_outlined,
                              size: 64,
                              color: AppColors.greyLight,
                            ),
                            Gap(16),
                            Text(
                              'No transactions yet',
                              style: TextStyle(
                                color: AppColors.grey,
                                fontSize: 16,
                                fontFamily: 'GeneralSans',
                                letterSpacing: 16 * 0.02,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: transactions.length,
                        itemBuilder: (context, index) {
                          final tx = transactions[index];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              backgroundColor: tx.type == 'credit'
                                  ? AppColors.success.withOpacity(0.1)
                                  : AppColors.greyLight,
                              child: Icon(
                                _getIconForTransaction(tx.narration),
                                size: 20,
                                color: tx.type == 'credit'
                                    ? AppColors.success
                                    : AppColors.black,
                              ),
                            ),
                            title: Text(tx.narration),
                            subtitle: Text(
                              _formatDate(tx.date),
                              style: const TextStyle(fontSize: 11),
                            ),
                            trailing: Text(
                              '${tx.type == 'credit' ? '+' : '-'}${_formatMoney(tx.amount / 100)}',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: tx.type == 'credit'
                                    ? AppColors.success
                                    : AppColors.black,
                                fontFamily: 'GeneralSans',
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day;
    String suffix = 'th';
    if (day == 1 || day == 21 || day == 31) {
      suffix = 'st';
    } else if (day == 2 || day == 22) {
      suffix = 'nd';
    } else if (day == 3 || day == 23) {
      suffix = 'rd';
    }
    return '${DateFormat('MMMM').format(date)} $day$suffix';
  }

  IconData _getIconForTransaction(String narration) {
    final lower = narration.toLowerCase();
    if (lower.contains('groceries') || lower.contains('food'))
      return Icons.shopping_cart;
    if (lower.contains('electricity') || lower.contains('bill'))
      return Icons.bolt;
    if (lower.contains('spotify') ||
        lower.contains('music') ||
        lower.contains('netflix'))
      return Icons.music_note;
    if (lower.contains('transfer') || lower.contains('sent')) return Icons.send;
    if (lower.contains('deposit') || lower.contains('received'))
      return Icons.account_balance;
    if (lower.contains('card') || lower.contains('payment'))
      return Icons.credit_card;
    if (lower.contains('airtime') || lower.contains('data'))
      return Icons.phone_android;
    if (lower.contains('interest') || lower.contains('cashback'))
      return Icons.trending_up;
    if (lower.contains('withdrawal')) return Icons.money;
    if (lower.contains('save') || lower.contains('saving'))
      return Icons.savings;
    if (lower.contains('fuel') || lower.contains('diesel'))
      return Icons.local_gas_station;
    if (lower.contains('school')) return Icons.school;
    if (lower.contains('transport')) return Icons.directions_bus;
    if (lower.contains('cloth') || lower.contains('hair'))
      return Icons.shopping_bag;
    return Icons.payment;
  }

  String _formatMoney(double amount) {
    return '₦${NumberFormat('#,###.00').format(amount)}';
  }
}

// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:gap/gap.dart';
// import 'package:go_router/go_router.dart';
// import 'package:intl/intl.dart';
// import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
// import 'package:savvy_bee_mobile/core/utils/assets/app_icons.dart';
// import 'package:savvy_bee_mobile/core/utils/assets/illustrations.dart';
// import 'package:savvy_bee_mobile/core/widgets/charts/custom_line_chart.dart';
// import 'package:savvy_bee_mobile/core/widgets/custom_loading_widget.dart';
// import 'package:savvy_bee_mobile/features/auth/presentation/screens/post_signup/bottom_sheets/connect_bank_intro_bottom_sheet.dart';
// import 'package:savvy_bee_mobile/features/chat/presentation/screens/chat_screen.dart';
// import 'package:savvy_bee_mobile/features/dashboard/domain/models/dashboard_data.dart';
// import 'package:savvy_bee_mobile/features/dashboard/presentation/providers/dashboard_data_provider.dart';
// import 'package:savvy_bee_mobile/core/widgets/custom_error_widget.dart';
// import 'package:savvy_bee_mobile/features/dashboard/presentation/screens/spending_screen.dart';
// import 'package:savvy_bee_mobile/features/dashboard/presentation/widgets/financial_health_card.dart';
// import 'package:savvy_bee_mobile/features/dashboard/presentation/widgets/info_card.dart';
// import 'package:savvy_bee_mobile/features/home/presentation/providers/home_data_provider.dart';
// import 'package:savvy_bee_mobile/features/profile/presentation/screens/profile_screen.dart';
// import 'package:savvy_bee_mobile/features/tools/presentation/screens/goals/goals_screen.dart';

// class DashboardScreen extends ConsumerStatefulWidget {
//   static const String path = '/dashboard';

//   const DashboardScreen({super.key});

//   @override
//   ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
// }

// class _DashboardScreenState extends ConsumerState<DashboardScreen> {
//   final PageController _pageController = PageController();
//   int _currentPage = 0;

//   @override
//   void dispose() {
//     _pageController.dispose();
//     super.dispose();
//   }

//   String formatMoney(double amount) {
//     return '₦${NumberFormat('#,###.00').format(amount)}';
//   }

//   @override
//   Widget build(BuildContext context) {
//     final dashboardDataAsync = ref.watch(dashboardDataProvider('all'));

//     final homeData = ref.watch(homeDataProvider);

//     return homeData.when(
//       skipLoadingOnRefresh: false,

//       data: (value) {
//         final data = value.data;

//         return Scaffold(
//           appBar: _buildAppBar(data.firstName, context),
//           body: SafeArea(
//             child: dashboardDataAsync.when(
//               skipLoadingOnRefresh: false,
//               data: (dashboardData) {
//                 if (dashboardData == null) {
//                   return CustomErrorWidget(
//                     icon: Icons.link_off_rounded,
//                     title: 'No linked account',
//                     subtitle: 'Link your account to keep track of your money',
//                     actionButtonText: 'Link account',
//                     onActionPressed: () {
//                       ConnectBankIntroBottomSheet.show(context);
//                     },
//                   );
//                 }
//                 return RefreshIndicator(
//                   onRefresh: () =>
//                       ref.read(dashboardDataProvider('all').notifier).refresh(),
//                   child: SingleChildScrollView(
//                     child: Padding(
//                       padding: const EdgeInsets.all(16.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           SizedBox(
//                             height: 420,
//                             child: PageView(
//                               controller: _pageController,
//                               onPageChanged: (index) {
//                                 setState(() {
//                                   _currentPage = index;
//                                 });
//                               },
//                               children: [
//                                 SpendCard(dashboardData: dashboardData),
//                                 NetWorthCard(dashboardData: dashboardData),
//                                 FinancialHealthCard(
//                                   healthData:
//                                       dashboardData.widgets.financialHealth,
//                                 ),
//                               ],
//                             ),
//                           ),
//                           const Gap(8),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: List.generate(3, (index) {
//                               return Container(
//                                 margin: const EdgeInsets.symmetric(
//                                   horizontal: 4,
//                                 ),
//                                 width: _currentPage == index ? 16 : 8,
//                                 height: 8,
//                                 decoration: BoxDecoration(
//                                   color: _currentPage == index
//                                       ? AppColors.yellow
//                                       : AppColors.greyLight,
//                                   borderRadius: BorderRadius.circular(4),
//                                 ),
//                               );
//                             }),
//                           ),
//                           const Gap(16),
//                           AccountsSection(dashboardData: dashboardData),
//                           // const Gap(16),
//                           // FinancialGoalsSection(savings: dashboardData.savings),
//                           const Gap(16),
//                           RecentTransactionsSection(
//                             transactions: dashboardData.accounts.isNotEmpty
//                                 ? dashboardData.accounts[0].history12Months
//                                 : [],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 );
//               },
//               loading: () =>
//                   const CustomLoadingWidget(text: 'Loading your dashboard...'),
//               error: (error, stack) => CustomErrorWidget(
//                 icon: Icons.dashboard_outlined,
//                 title: 'Unable to Load Dashboard',
//                 subtitle:
//                     'We couldn\'t fetch your dashboard data. Please check your connection and try again.',
//                 onActionPressed: () {
//                   ref.invalidate(dashboardDataProvider);
//                 },
//                 actionButtonText: 'Reload',
//               ),
//             ),
//           ),
//         );
//       },
//       error: (error, stack) => CustomErrorWidget(
//         icon: Icons.dashboard_outlined,
//         title: 'Unable to Load Dashboard',
//         subtitle:
//             'We couldn\'t fetch your dashboard data. Please check your connection and try again.',
//         onActionPressed: () {
//           ref.invalidate(dashboardDataProvider);
//         },
//       ),
//       loading: () =>
//           const CustomLoadingWidget(text: 'Loading your dashboard...'),
//     );
//   }

//   AppBar _buildAppBar(String firstName, BuildContext context) {
//     return AppBar(
//       elevation: 0,
//       backgroundColor: Colors.transparent, // important
//       flexibleSpace: Container(
//         decoration: const BoxDecoration(
//           // gradient: LinearGradient(
//           //   begin: Alignment.topLeft,
//           //   end: Alignment.topRight, // left → right
//           //   colors: [Color(0xFFFFEFB5), Color(0xFFFFC300)],
//           // ),
//         ),
//       ),
//       title: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           // LEFT
//           GestureDetector(
//             onTap: () {
//               // Navigator.push(...)
//             },
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 InkWell(
//                   onTap: () => context.pushNamed(ChatScreen.path),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Container(
//                         width: 32,
//                         height: 32,
//                         decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           border: Border.all(color: AppColors.primary),
//                         ),
//                         child: Center(
//                           child: Image.asset(
//                             'assets/images/topbar/nav-left-icon.png',
//                             width: 32,
//                             height: 32,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 6),
//                       const Text(
//                         'Chat with Nahl',
//                         style: TextStyle(
//                           fontFamily: 'GeneralSans',
//                           fontSize: 12,
//                           fontWeight: FontWeight.w500,
//                           color: Colors.black,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 const SizedBox(width: 25),

//                 Image.asset(
//                   'assets/images/topbar/nav-center-icon.png',
//                   width: 30,
//                   height: 32,
//                   fit: BoxFit.contain,
//                 ),
//               ],
//             ),
//           ),

//           // RIGHT
//           GestureDetector(
//             onTap: () => context.pushNamed(ProfileScreen.path),
//             child: Container(
//               width: 32,
//               height: 32,
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 shape: BoxShape.circle,
//                 border: Border.all(color: Colors.black, width: 1),
//               ),
//               child: Center(
//                 child: Text(
//                   firstName.isNotEmpty
//                       ? (firstName.length > 1
//                             ? firstName.substring(0, 2).toUpperCase()
//                             : firstName[0].toUpperCase())
//                       : 'DT',
//                   style: const TextStyle(
//                     fontFamily: 'GeneralSans',
//                     fontWeight: FontWeight.w500,
//                     fontSize: 16,
//                     color: Colors.black,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//       centerTitle: false,
//       automaticallyImplyLeading: false,
//     );
//   }
// }

// // FIXED: Spend Card widget with proper data filtering
// class SpendCard extends StatelessWidget {
//   final DashboardData dashboardData;

//   const SpendCard({super.key, required this.dashboardData});

//   double getCurrentMonthSpend() {
//     final now = DateTime.now();
//     double spend = 0;

//     for (var account in dashboardData.accounts) {
//       for (var tx in account.history12Months) {
//         if (tx.date.year == now.year &&
//             tx.date.month == now.month &&
//             tx.type == 'debit') {
//           spend += tx.amount / 100; // Convert kobo to naira
//         }
//       }
//     }
//     return spend;
//   }

//   double getLastMonthSpend() {
//     final now = DateTime.now();
//     final lastMonth = DateTime(now.year, now.month - 1, 1);
//     double spend = 0;

//     for (var account in dashboardData.accounts) {
//       for (var tx in account.history12Months) {
//         if (tx.date.year == lastMonth.year &&
//             tx.date.month == lastMonth.month &&
//             tx.type == 'debit') {
//           spend += tx.amount / 100; // Convert kobo to naira
//         }
//       }
//     }
//     return spend;
//   }

//   List<ChartDataPoint> getSpendChartData() {
//     // Collect all debit transactions
//     List<Transaction> debits = [];
//     for (var account in dashboardData.accounts) {
//       debits.addAll(account.history12Months.where((tx) => tx.type == 'debit'));
//     }

//     if (debits.isEmpty) {
//       return [];
//     }

//     // Sort by date
//     debits.sort((a, b) => a.date.compareTo(b.date));

//     // Group by day and sum amounts
//     Map<DateTime, double> dailySpend = {};
//     for (var tx in debits) {
//       final dateOnly = DateTime(tx.date.year, tx.date.month, tx.date.day);
//       dailySpend[dateOnly] = (dailySpend[dateOnly] ?? 0) + (tx.amount / 100);
//     }

//     // Convert to chart data points
//     final sortedDates = dailySpend.keys.toList()..sort();
//     return sortedDates
//         .map(
//           (date) => ChartDataPoint(value: dailySpend[date]!, timestamp: date),
//         )
//         .toList();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final currentSpend = getCurrentMonthSpend();
//     final lastMonthSpend = getLastMonthSpend();
//     final difference = currentSpend - lastMonthSpend;
//     final isBelow = difference < 0;
//     final chartData = getSpendChartData();

//     return Card(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 const Text(
//                   'Current spend this month',
//                   style: TextStyle(fontSize: 12, color: AppColors.grey),
//                 ),

//                 // const Spacer(), // instead of spaceBetween
//                 const Gap(4),
//                 if (lastMonthSpend > 0)
//                   Expanded(
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.end,
//                       children: [
//                         Icon(
//                           isBelow ? Icons.check_circle : Icons.info_outline,
//                           size: 14,
//                           color: isBelow ? AppColors.success : AppColors.grey,
//                         ),
//                         const Gap(4),
//                         Flexible(
//                           child: Text(
//                             '${formatMoney(difference.abs())} ${isBelow ? 'below' : 'above'} last month',
//                             style: TextStyle(
//                               color: isBelow
//                                   ? AppColors.success
//                                   : AppColors.grey,
//                               fontSize: 11,
//                             ),
//                             softWrap: true,
//                             maxLines: 2,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//               ],
//             ),

//             const Gap(8),
//             Text(
//               formatMoney(currentSpend),
//               style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
//             ),
//             const Gap(16),
//             Expanded(
//               child: chartData.isNotEmpty
//                   ? CustomLineChart(data: chartData)
//                   : Center(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: const [
//                           Icon(
//                             Icons.show_chart,
//                             size: 48,
//                             color: AppColors.greyLight,
//                           ),
//                           Gap(8),
//                           Text(
//                             'Not enough spending data',
//                             style: TextStyle(
//                               color: AppColors.grey,
//                               fontSize: 14,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//             ),
//             const Gap(8),
//             TextButton(
//               onPressed: () => context.pushNamed(SpendingScreen.path),
//               style: TextButton.styleFrom(
//                 padding: EdgeInsets.zero,
//                 minimumSize: Size.zero,
//                 tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//               ),
//               child: Row(
//                 children: const [
//                   Icon(Icons.receipt_long, size: 16),
//                   Gap(4),
//                   Text('View Spending'),
//                   Gap(4),
//                   Icon(Icons.chevron_right, size: 16),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   String formatMoney(double amount) {
//     return '₦${NumberFormat('#,###.##').format(amount.abs())}';
//   }
// }

// // FIXED: Net Worth Card with proper balance calculation
// class NetWorthCard extends StatelessWidget {
//   final DashboardData dashboardData;

//   const NetWorthCard({super.key, required this.dashboardData});

//   double getNetWorth() {
//     // Sum all account balances (already in naira from API)
//     double accountBalances = dashboardData.accounts.fold(
//       0.0,
//       (sum, account) => sum + account.details.balance,
//     );

//     // Sum all savings balances
//     double savingsBalance = dashboardData.savings.fold(
//       0.0,
//       (sum, goal) => sum + goal.balance,
//     );

//     return accountBalances + savingsBalance;
//   }

//   double getMonthChange() {
//     final now = DateTime.now();
//     double income = 0;
//     double expenses = 0;

//     for (var account in dashboardData.accounts) {
//       for (var tx in account.history12Months) {
//         if (tx.date.year == now.year && tx.date.month == now.month) {
//           if (tx.type == 'credit') {
//             income += tx.amount / 100;
//           } else if (tx.type == 'debit') {
//             expenses += tx.amount / 100;
//           }
//         }
//       }
//     }

//     return income - expenses;
//   }

//   List<ChartDataPoint> getNetWorthChartData() {
//     // Collect ALL transactions (both credit and debit)
//     List<Transaction> allTxs = [];
//     for (var account in dashboardData.accounts) {
//       allTxs.addAll(account.history12Months);
//     }

//     if (allTxs.isEmpty) {
//       return [];
//     }

//     // Sort by date
//     allTxs.sort((a, b) => a.date.compareTo(b.date));

//     // Calculate cumulative balance over time
//     double runningBalance = getNetWorth();
//     List<ChartDataPoint> data = [];

//     // Work backwards from current balance
//     for (var tx in allTxs.reversed) {
//       // Reverse the transaction effect
//       if (tx.type == 'credit') {
//         runningBalance -= (tx.amount / 100);
//       } else if (tx.type == 'debit') {
//         runningBalance += (tx.amount / 100);
//       }

//       data.insert(
//         0,
//         ChartDataPoint(
//           value: runningBalance.isNegative ? 0 : runningBalance,
//           timestamp: tx.date,
//         ),
//       );
//     }

//     // Add current balance as the last point
//     if (data.isNotEmpty) {
//       data.add(ChartDataPoint(value: getNetWorth(), timestamp: DateTime.now()));
//     }

//     return data;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final netWorth = getNetWorth();
//     final change = getMonthChange();
//     final isPositive = change >= 0;
//     final chartData = getNetWorthChartData();

//     return Card(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text(
//                   'Net Worth',
//                   style: TextStyle(fontSize: 12, color: AppColors.grey),
//                 ),
//                 Row(
//                   children: [
//                     Icon(
//                       isPositive ? Icons.check_circle : Icons.info_outline,
//                       size: 14,
//                       color: isPositive ? AppColors.success : AppColors.grey,
//                     ),
//                     const Gap(4),
//                     Text(
//                       '${formatMoney(change.abs())} ${isPositive ? 'above' : 'below'} last month',
//                       style: TextStyle(
//                         color: isPositive ? AppColors.success : AppColors.grey,
//                         fontSize: 11,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//             const Gap(8),
//             Text(
//               formatMoney(netWorth),
//               style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
//             ),
//             const Gap(16),
//             Expanded(
//               child: chartData.length >= 2
//                   ? CustomLineChart(data: chartData)
//                   : Center(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: const [
//                           Icon(
//                             Icons.trending_up,
//                             size: 48,
//                             color: AppColors.greyLight,
//                           ),
//                           Gap(8),
//                           Text(
//                             'Not enough data',
//                             style: TextStyle(
//                               color: AppColors.grey,
//                               fontSize: 14,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//             ),
//             // const Gap(8),
//             // TextButton(
//             //   onPressed: () {},
//             //   style: TextButton.styleFrom(
//             //     padding: EdgeInsets.zero,
//             //     minimumSize: Size.zero,
//             //     tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//             //   ),
//             //   child: Row(
//             //     children: const [
//             //       Icon(Icons.account_balance_wallet, size: 16),
//             //       Gap(4),
//             //       Text('View Net Worth'),
//             //       Gap(4),
//             //       Icon(Icons.chevron_right, size: 16),
//             //     ],
//             //   ),
//             // ),
//           ],
//         ),
//       ),
//     );
//   }

//   String formatMoney(double amount) {
//     return '₦${NumberFormat('#,###.##').format(amount.abs())}';
//   }
// }

// // Rest of the widgets remain the same...
// class AccountsSection extends StatefulWidget {
//   final DashboardData dashboardData;

//   const AccountsSection({super.key, required this.dashboardData});

//   @override
//   State<AccountsSection> createState() => _AccountsSectionState();
// }

// class _AccountsSectionState extends State<AccountsSection> {
//   bool _isSavingsExpanded = false;

//   @override
//   Widget build(BuildContext context) {
//     double netCash = widget.dashboardData.accounts.fold(
//       0.0,
//       (sum, account) => sum + account.details.balance,
//     );

//     double savingsBalance = widget.dashboardData.savings.fold(
//       0.0,
//       (sum, goal) => sum + goal.balance,
//     );

//     final displayedGoals = _isSavingsExpanded
//         ? widget.dashboardData.savings
//         : widget.dashboardData.savings.take(2).toList();

//     return Card(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // HEADER
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text(
//                   'ACCOUNTS',
//                   style: TextStyle(
//                     fontSize: 12,
//                     fontWeight: FontWeight.w600,
//                     letterSpacing: 0.5,
//                   ),
//                 ),
//                 // TextButton(
//                 //   onPressed: () {},
//                 //   style: TextButton.styleFrom(
//                 //     padding: EdgeInsets.zero,
//                 //     minimumSize: Size.zero,
//                 //     tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                 //   ),
//                 //   child: const Text('Add account'),
//                 // ),
//               ],
//             ),

//             const Gap(8),

//             // NET CASH
//             ListTile(
//               contentPadding: EdgeInsets.zero,
//               leading: const Icon(Icons.account_balance_wallet_outlined),
//               title: const Text('Net cash'),
//               trailing: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(
//                     formatMoney(netCash),
//                     style: const TextStyle(fontWeight: FontWeight.w600),
//                   ),
//                   const Gap(8),
//                   const Icon(
//                     Icons.info_outline,
//                     size: 16,
//                     color: AppColors.grey,
//                   ),
//                 ],
//               ),
//             ),

//             // SAVINGS (CLICK TO EXPAND)
//             ListTile(
//               contentPadding: EdgeInsets.zero,
//               leading: const Icon(Icons.savings_outlined),
//               title: const Text('Savings'),
//               trailing: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(
//                     formatMoney(savingsBalance),
//                     style: const TextStyle(fontWeight: FontWeight.w600),
//                   ),
//                   const Gap(8),
//                   Icon(
//                     _isSavingsExpanded
//                         ? Icons.keyboard_arrow_up
//                         : Icons.keyboard_arrow_down,
//                     size: 16,
//                   ),
//                 ],
//               ),
//               onTap: () {
//                 setState(() {
//                   _isSavingsExpanded = !_isSavingsExpanded;
//                 });
//               },
//             ),

//             // FINANCIAL GOALS (COLLAPSED UNDER SAVINGS)
//             if (_isSavingsExpanded) ...[
//               const Gap(8),

//               if (widget.dashboardData.savings.isEmpty)
//                 Center(
//                   child: Column(
//                     children: const [
//                       Icon(
//                         Icons.flag_outlined,
//                         size: 48,
//                         color: AppColors.greyLight,
//                       ),
//                       Gap(8),
//                       Text(
//                         'No financial goals yet',
//                         style: TextStyle(color: AppColors.grey),
//                       ),
//                     ],
//                   ),
//                 )
//               else
//                 ...displayedGoals.map(
//                   (goal) => ListTile(
//                     contentPadding: EdgeInsets.zero,
//                     visualDensity: VisualDensity.compact,
//                     leading: Icon(_getIconForGoal(goal.goalName)),
//                     title: Text(goal.goalName),
//                     subtitle: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Gap(4),
//                         LinearProgressIndicator(
//                           value: goal.progressPercentage / 100,
//                           backgroundColor: AppColors.greyLight,
//                           valueColor: const AlwaysStoppedAnimation(
//                             AppColors.success,
//                           ),
//                           minHeight: 4,
//                           borderRadius: BorderRadius.circular(2),
//                         ),
//                         const Gap(4),
//                         Text(
//                           goal.isCompleted ? 'Completed' : 'Ongoing',
//                           style: const TextStyle(fontSize: 11),
//                         ),
//                       ],
//                     ),
//                     trailing: Text(
//                       formatMoney(goal.balance),
//                       style: const TextStyle(fontWeight: FontWeight.w600),
//                     ),
//                   ),
//                 ),

//               if (widget.dashboardData.savings.length > 2)
//                 // TextButton(
//                 //   onPressed: () {
//                 //     setState(() {});
//                 //   },
//                 //   style: TextButton.styleFrom(
//                 //     padding: EdgeInsets.zero,
//                 //     minimumSize: Size.zero,
//                 //     tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                 //   ),
//                 //   // child: Row(
//                 //   //   mainAxisSize: MainAxisSize.min,
//                 //   //   children: [
//                 //   //     // Text(_isSavingsExpanded ? 'Show less' : 'Show more'),
//                 //   //     Icon(
//                 //   //       _isSavingsExpanded
//                 //   //           ? Icons.keyboard_arrow_up
//                 //   //           : Icons.keyboard_arrow_down,
//                 //   //       size: 16,
//                 //   //     ),
//                 //   //   ],
//                 //   // ),
//                 // ),
//                 const Gap(8),

//               SizedBox(
//                 width: double.infinity,
//                 child: OutlinedButton.icon(
//                   onPressed: () => context.pushNamed(GoalsScreen.path),
//                   icon: const Icon(Icons.add, size: 16),
//                   label: const Text('Add new goal'),
//                   style: OutlinedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(vertical: 12),
//                   ),
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }

//   String formatMoney(double amount) {
//     return '₦${NumberFormat('#,###.00').format(amount)}';
//   }

//   IconData _getIconForGoal(String name) {
//     final lower = name.toLowerCase();
//     if (lower.contains('vacation')) return Icons.beach_access;
//     if (lower.contains('rent') || lower.contains('house')) return Icons.home;
//     if (lower.contains('emergency')) return Icons.shield;
//     if (lower.contains('car')) return Icons.directions_car;
//     if (lower.contains('debt')) return Icons.credit_card;
//     if (lower.contains('dog') || lower.contains('pet')) return Icons.pets;
//     return Icons.savings;
//   }
// }

// class RecentTransactionsSection extends StatelessWidget {
//   final List<Transaction> transactions;

//   const RecentTransactionsSection({super.key, required this.transactions});

//   void _showAllTransactions(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) =>
//           AllTransactionsBottomSheet(transactions: transactions),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Show recent transactions of all types, not just debits
//     final recent = transactions.take(5).toList();

//     return Card(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text(
//                   'RECENT TRANSACTIONS',
//                   style: TextStyle(
//                     fontSize: 12,
//                     fontWeight: FontWeight.w600,
//                     letterSpacing: 0.5,
//                   ),
//                 ),
//                 TextButton(
//                   onPressed: () => _showAllTransactions(context),
//                   style: TextButton.styleFrom(
//                     padding: EdgeInsets.zero,
//                     minimumSize: Size.zero,
//                     tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                   ),
//                   child: const Text('See all'),
//                 ),
//               ],
//             ),
//             const Gap(8),
//             if (recent.isEmpty)
//               Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 16.0),
//                 child: Center(
//                   child: Column(
//                     children: const [
//                       Icon(
//                         Icons.receipt_long_outlined,
//                         size: 48,
//                         color: AppColors.greyLight,
//                       ),
//                       Gap(8),
//                       Text(
//                         'No recent transactions',
//                         style: TextStyle(color: AppColors.grey),
//                       ),
//                     ],
//                   ),
//                 ),
//               )
//             else
//               ...recent.map(
//                 (tx) => ListTile(
//                   contentPadding: EdgeInsets.zero,
//                   visualDensity: VisualDensity.compact,
//                   leading: CircleAvatar(
//                     backgroundColor: tx.type == 'credit'
//                         ? AppColors.success.withOpacity(0.1)
//                         : AppColors.greyLight,
//                     child: Icon(
//                       _getIconForTransaction(tx.narration),
//                       size: 20,
//                       color: tx.type == 'credit'
//                           ? AppColors.success
//                           : AppColors.black,
//                     ),
//                   ),
//                   title: Text(
//                     tx.narration,
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                   subtitle: Text(
//                     _formatDate(tx.date),
//                     style: const TextStyle(fontSize: 11),
//                   ),
//                   trailing: Text(
//                     '${tx.type == 'credit' ? '+' : '-'}${formatMoney(tx.amount / 100)}',
//                     style: TextStyle(
//                       fontWeight: FontWeight.w600,
//                       color: tx.type == 'credit'
//                           ? AppColors.success
//                           : AppColors.black,
//                     ),
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   String _formatDate(DateTime date) {
//     final day = date.day;
//     String suffix = 'th';
//     if (day == 1 || day == 21 || day == 31) {
//       suffix = 'st';
//     } else if (day == 2 || day == 22) {
//       suffix = 'nd';
//     } else if (day == 3 || day == 23) {
//       suffix = 'rd';
//     }
//     return '${DateFormat('MMMM').format(date)} $day$suffix';
//   }

//   IconData _getIconForTransaction(String narration) {
//     final lower = narration.toLowerCase();
//     if (lower.contains('groceries') || lower.contains('food'))
//       return Icons.shopping_cart;
//     if (lower.contains('electricity') || lower.contains('bill'))
//       return Icons.bolt;
//     if (lower.contains('spotify') ||
//         lower.contains('music') ||
//         lower.contains('netflix'))
//       return Icons.music_note;
//     if (lower.contains('transfer') || lower.contains('sent')) return Icons.send;
//     if (lower.contains('deposit') || lower.contains('received'))
//       return Icons.account_balance;
//     if (lower.contains('card') || lower.contains('payment'))
//       return Icons.credit_card;
//     if (lower.contains('airtime') || lower.contains('data'))
//       return Icons.phone_android;
//     if (lower.contains('interest') || lower.contains('cashback'))
//       return Icons.trending_up;
//     if (lower.contains('withdrawal')) return Icons.money;
//     if (lower.contains('save') || lower.contains('saving'))
//       return Icons.savings;
//     if (lower.contains('fuel') || lower.contains('diesel'))
//       return Icons.local_gas_station;
//     if (lower.contains('school')) return Icons.school;
//     if (lower.contains('transport')) return Icons.directions_bus;
//     if (lower.contains('cloth') || lower.contains('hair'))
//       return Icons.shopping_bag;
//     return Icons.payment;
//   }

//   String formatMoney(double amount) {
//     return '₦${NumberFormat('#,###.00').format(amount)}';
//   }
// }

// // NEW: Bottom sheet to show all transactions
// class AllTransactionsBottomSheet extends StatelessWidget {
//   final List<Transaction> transactions;

//   const AllTransactionsBottomSheet({super.key, required this.transactions});

//   @override
//   Widget build(BuildContext context) {
//     return DraggableScrollableSheet(
//       initialChildSize: 0.9,
//       minChildSize: 0.5,
//       maxChildSize: 0.95,
//       builder: (context, scrollController) {
//         return Container(
//           decoration: const BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//           ),
//           child: Column(
//             children: [
//               // Header
//               Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     const Text(
//                       'All Transactions',
//                       style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.w600,
//                         fontFamily: 'GeneralSans',
//                       ),
//                     ),
//                     IconButton(
//                       icon: const Icon(Icons.close),
//                       onPressed: () => Navigator.pop(context),
//                     ),
//                   ],
//                 ),
//               ),
//               const Divider(height: 1),

//               // Transaction list
//               Expanded(
//                 child: transactions.isEmpty
//                     ? Center(
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: const [
//                             Icon(
//                               Icons.receipt_long_outlined,
//                               size: 64,
//                               color: AppColors.greyLight,
//                             ),
//                             Gap(16),
//                             Text(
//                               'No transactions yet',
//                               style: TextStyle(
//                                 color: AppColors.grey,
//                                 fontSize: 16,
//                               ),
//                             ),
//                           ],
//                         ),
//                       )
//                     : ListView.builder(
//                         controller: scrollController,
//                         padding: const EdgeInsets.all(16),
//                         itemCount: transactions.length,
//                         itemBuilder: (context, index) {
//                           final tx = transactions[index];
//                           return ListTile(
//                             contentPadding: EdgeInsets.zero,
//                             leading: CircleAvatar(
//                               backgroundColor: tx.type == 'credit'
//                                   ? AppColors.success.withOpacity(0.1)
//                                   : AppColors.greyLight,
//                               child: Icon(
//                                 _getIconForTransaction(tx.narration),
//                                 size: 20,
//                                 color: tx.type == 'credit'
//                                     ? AppColors.success
//                                     : AppColors.black,
//                               ),
//                             ),
//                             title: Text(tx.narration),
//                             subtitle: Text(
//                               _formatDate(tx.date),
//                               style: const TextStyle(fontSize: 11),
//                             ),
//                             trailing: Text(
//                               '${tx.type == 'credit' ? '+' : '-'}${_formatMoney(tx.amount / 100)}',
//                               style: TextStyle(
//                                 fontWeight: FontWeight.w600,
//                                 color: tx.type == 'credit'
//                                     ? AppColors.success
//                                     : AppColors.black,
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   String _formatDate(DateTime date) {
//     final day = date.day;
//     String suffix = 'th';
//     if (day == 1 || day == 21 || day == 31) {
//       suffix = 'st';
//     } else if (day == 2 || day == 22) {
//       suffix = 'nd';
//     } else if (day == 3 || day == 23) {
//       suffix = 'rd';
//     }
//     return '${DateFormat('MMMM').format(date)} $day$suffix';
//   }

//   IconData _getIconForTransaction(String narration) {
//     final lower = narration.toLowerCase();
//     if (lower.contains('groceries') || lower.contains('food'))
//       return Icons.shopping_cart;
//     if (lower.contains('electricity') || lower.contains('bill'))
//       return Icons.bolt;
//     if (lower.contains('spotify') ||
//         lower.contains('music') ||
//         lower.contains('netflix'))
//       return Icons.music_note;
//     if (lower.contains('transfer') || lower.contains('sent')) return Icons.send;
//     if (lower.contains('deposit') || lower.contains('received'))
//       return Icons.account_balance;
//     if (lower.contains('card') || lower.contains('payment'))
//       return Icons.credit_card;
//     if (lower.contains('airtime') || lower.contains('data'))
//       return Icons.phone_android;
//     if (lower.contains('interest') || lower.contains('cashback'))
//       return Icons.trending_up;
//     if (lower.contains('withdrawal')) return Icons.money;
//     if (lower.contains('save') || lower.contains('saving'))
//       return Icons.savings;
//     if (lower.contains('fuel') || lower.contains('diesel'))
//       return Icons.local_gas_station;
//     if (lower.contains('school')) return Icons.school;
//     if (lower.contains('transport')) return Icons.directions_bus;
//     if (lower.contains('cloth') || lower.contains('hair'))
//       return Icons.shopping_bag;
//     return Icons.payment;
//   }

//   String _formatMoney(double amount) {
//     return '₦${NumberFormat('#,###.00').format(amount)}';
//   }
// }
