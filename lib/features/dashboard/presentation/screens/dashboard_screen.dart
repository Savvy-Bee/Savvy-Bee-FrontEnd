import 'dart:developer';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:savvy_bee_mobile/features/dashboard/domain/models/linked_account.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
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

const _kDashboardWalkthroughKey = 'dashboard_walkthrough_completed';

// Matches the exact error message from the backend
const _kReauthErrorSubstring = 'Accts require Reauths';

class DashboardScreen extends ConsumerStatefulWidget {
  static const String path = '/dashboard';

  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // ── Walkthrough ───────────────────────────────────────────────────────────
  bool _showWalkthrough = false;

  // ── Reload button loading state ───────────────────────────────────────────
  bool _isReloading = false;

  // ── Reauth loading state ──────────────────────────────────────────────────
  bool _isReauthing = false;

  // ── Link account prompt (shown once per session) ──────────────────────────
  bool _hasShownLinkAccountPrompt = false;

  // ─────────────────────────────────────────────────────────────────────────
  // Lifecycle
  // ─────────────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkWalkthrough());
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Walkthrough helpers
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _checkWalkthrough() async {
    final prefs = await SharedPreferences.getInstance();
    final completed = prefs.getBool(_kDashboardWalkthroughKey) ?? false;
    if (!completed && mounted) {
      setState(() => _showWalkthrough = true);
    }
  }

  Future<void> _dismissWalkthrough() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kDashboardWalkthroughKey, true);
    if (mounted) setState(() => _showWalkthrough = false);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Reload with loading state
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _handleReload() async {
    setState(() => _isReloading = true);
    try {
      ref.invalidate(dashboardDataProvider);
      ref.invalidate(homeDataProvider);
      await Future.wait([
        ref.read(dashboardDataProvider('all').future).catchError((_) => null),
        ref.read(homeDataProvider.future).catchError((_) => null),
      ]);
    } finally {
      if (mounted) setState(() => _isReloading = false);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Reauth flow
  // ─────────────────────────────────────────────────────────────────────────

  /// Checks whether a given error string is a reauth error.
  bool _isReauthError(Object error) {
    return error.toString().contains(_kReauthErrorSubstring);
  }

  /// Fetches linked accounts, picks the first one, calls the reauth
  /// endpoint, launches the Mono URL, then waits for the user to return
  /// before refreshing the dashboard.
  Future<void> _handleReauth() async {
    if (_isReauthing) return;
    setState(() => _isReauthing = true);

    try {
      // 1️⃣ Await the linked accounts future directly — avoids the
      //    race condition where valueOrNull is null while the
      //    AutoDispose provider is still loading.
      final linkedAccounts = await ref
          .read(linkedAccountsProvider.future)
          .catchError((_) => <LinkedAccount>[]);

      if (linkedAccounts.isEmpty) {
        _showSnackBar('No linked accounts found. Please link a bank account.');
        return;
      }

      // print('Linked Accounts: $linkedAccounts');

      final accountId = linkedAccounts.first.monoLinkedAcctId;

      // 2️⃣ Call the reauth endpoint
      final reauthUrl = await ref
          .read(linkedAccountsProvider.notifier)
          .reauthorizeAccount(accountId);

      if (reauthUrl == null || reauthUrl.isEmpty) {
        _showSnackBar('Could not get reauthorization link. Please try again.');
        return;
      }

      // 3️⃣ Launch the Mono reauth URL
      final uri = Uri.parse(reauthUrl);
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        _showSnackBar('Could not open reauthorization link.');
        return;
      }

      // 4️⃣ Tell user to come back after finishing reauth in browser
      if (mounted) {
        await showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'Complete Reauthorization',
              style: TextStyle(
                fontFamily: 'GeneralSans',
                fontWeight: FontWeight.w600,
              ),
            ),
            content: const Text(
              'Please complete the reauthorization in your browser, then tap "Done" to refresh your dashboard.',
              style: TextStyle(fontFamily: 'GeneralSans'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text(
                  'Done',
                  style: TextStyle(
                    fontFamily: 'GeneralSans',
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        );
      }

      // 5️⃣ Refresh dashboard after user confirms reauth complete
      await _handleReload();
    } catch (e) {
      _showSnackBar(
        'Reauthorization failed: ${e.toString().replaceFirst('Exception: ', '')}',
      );
    } finally {
      if (mounted) setState(() => _isReauthing = false);
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontFamily: 'GeneralSans'),
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────────────

  String formatMoney(double amount) {
    return '₦${NumberFormat('#,###.00').format(amount)}';
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Link account prompt (auto-shown when no account is linked)
  // ─────────────────────────────────────────────────────────────────────────

  void _showLinkAccountPrompt(BuildContext scaffoldContext) {
    if (_hasShownLinkAccountPrompt) return;
    _hasShownLinkAccountPrompt = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showModalBottomSheet<void>(
        context: scaffoldContext,
        isScrollControlled: true,
        useSafeArea: true,
        useRootNavigator: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (_) => _LinkAccountSafetySheet(
          onLinkTapped: () => ConnectBankIntroBottomSheet.show(scaffoldContext),
        ),
      );
    });
  }

  /// Builds the correct error widget depending on whether this is a
  /// reauth error or a generic load failure.
  Widget _buildDashboardError(Object error, [StackTrace? stack]) {
    log('[Dashboard] UI Error caught\nError: $error\nStack: $stack');
    final isReauth = _isReauthError(error);

    if (isReauth) {
      return CustomErrorWidget(
        icon: Icons.lock_reset_rounded,
        title: 'Reauthorization Required',
        subtitle:
            'Your bank account needs to be reauthorized before we can load your dashboard.',
        actionButtonText: 'Reauthorize Account',
        isActionLoading: _isReauthing,
        onActionPressed: _isReauthing ? null : _handleReauth,
      );
    }

    return CustomErrorWidget(
      icon: Icons.dashboard_outlined,
      title: 'Unable to Load Dashboard',
      subtitle:
          'We couldn\'t fetch your dashboard data. Please check your connection and try again.',
      actionButtonText: 'Reload',
      isActionLoading: _isReloading,
      onActionPressed: _isReloading ? null : _handleReload,
    );
  }

  @override
  Widget build(BuildContext context) {
    final dashboardDataAsync = ref.watch(dashboardDataProvider('all'));
    final homeData = ref.watch(homeDataProvider);

    return Stack(
      children: [
        // ── Main Scaffold ─────────────────────────────────────────────────
        homeData.when(
          skipLoadingOnRefresh: true,
          data: (value) {
            final data = value.data;

            return Scaffold(
              appBar: _buildAppBar(data.firstName, context),
              body: SafeArea(
                child: dashboardDataAsync.when(
                  skipLoadingOnRefresh: true,
                  data: (dashboardData) {
                    if (dashboardData == null) {
                      _showLinkAccountPrompt(context);
                      return CustomErrorWidget(
                        icon: Icons.link_off_rounded,
                        title: 'No linked account',
                        subtitle:
                            'Link your account to keep track of your money',
                        actionButtonText: 'Link account',
                        onActionPressed: () {
                          ConnectBankIntroBottomSheet.show(context);
                        },
                      );
                    }
                    return RefreshIndicator(
                      onRefresh: () => ref
                          .read(dashboardDataProvider('all').notifier)
                          .refresh(),
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
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
                                    setState(() => _currentPage = index);
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
                              const Gap(16),
                              if (dashboardData.widgets.savingTargetInsight
                                  .isNotEmpty)
                                _SavingsInsightCard(
                                  insight: dashboardData
                                      .widgets.savingTargetInsight,
                                ),
                              if (dashboardData.widgets.savingTargetInsight
                                  .isNotEmpty)
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
                  loading: () => const CustomLoadingWidget(
                    text: 'Loading your dashboard...',
                  ),
                  // ✅ Use the smart error builder here
                  error: (error, stack) => _buildDashboardError(error, stack),
                ),
              ),
            );
          },
          error: (error, stack) => Scaffold(body: _buildDashboardError(error, stack)),
          loading: () => const Scaffold(
            body: CustomLoadingWidget(text: 'Loading your dashboard...'),
          ),
        ),

        // ── Walkthrough overlay (above AppBar + body) ─────────────────────
        if (_showWalkthrough)
          GestureDetector(
            onTap: _dismissWalkthrough,
            child: Stack(
              children: [
                Container(color: Colors.black.withOpacity(0.55)),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Image.asset(
                    'assets/images/walk_through/dashboard.png',
                    width: MediaQuery.of(context).size.width * 0.65,
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // AppBar
  // ─────────────────────────────────────────────────────────────────────────

  AppBar _buildAppBar(String firstName, BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(decoration: const BoxDecoration()),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {},
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

// ─────────────────────────────────────────────────────────────────────────────
// Link Account Safety Bottom Sheet
// ─────────────────────────────────────────────────────────────────────────────

class _LinkAccountSafetySheet extends StatelessWidget {
  final VoidCallback onLinkTapped;

  const _LinkAccountSafetySheet({required this.onLinkTapped});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const Gap(24),
          // Shield icon
          Center(
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shield_outlined,
                color: AppColors.primary,
                size: 32,
              ),
            ),
          ),
          const Gap(16),
          const Text(
            'Your info is safe',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'GeneralSans',
              height: 1.1,
              letterSpacing: 24 * 0.02,
            ),
          ),
          const Gap(8),
          const Text(
            'Connect your bank to get a complete picture of your finances. Here\'s why you can trust us.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'GeneralSans',
              color: Color(0xFF666666),
              height: 1.4,
              letterSpacing: 14 * 0.02,
            ),
          ),
          const Gap(24),
          _SafetyPoint(
            icon: Icons.lock_outline,
            title: 'Bank-level encryption',
            subtitle:
                'All data is encrypted in transit and at rest using 256-bit SSL.',
          ),
          const Gap(12),
          _SafetyPoint(
            icon: Icons.visibility_off_outlined,
            title: 'We never see your password',
            subtitle:
                'Mono handles the connection — Savvy Bee never stores your login credentials.',
          ),
          const Gap(12),
          _SafetyPoint(
            icon: Icons.block_outlined,
            title: 'Read-only access',
            subtitle:
                'We can only read your transactions and balances. We cannot move your money.',
          ),
          const Gap(12),
          _SafetyPoint(
            icon: Icons.cancel_outlined,
            title: 'Disconnect any time',
            subtitle:
                'You are in full control — unlink your bank account whenever you want.',
          ),
          const Gap(28),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onLinkTapped();
            },
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
              'Link my account',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'GeneralSans',
                letterSpacing: 16 * 0.02,
              ),
            ),
          ),
          const Gap(8),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Maybe later',
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'GeneralSans',
                color: Color(0xFF666666),
                letterSpacing: 14 * 0.02,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SafetyPoint extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SafetyPoint({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20, color: Colors.black87),
        ),
        const Gap(12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'GeneralSans',
                  letterSpacing: 14 * 0.02,
                ),
              ),
              const Gap(2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  fontFamily: 'GeneralSans',
                  color: Color(0xFF666666),
                  height: 1.4,
                  letterSpacing: 12 * 0.02,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// All widgets below are unchanged from the original
// ─────────────────────────────────────────────────────────────────────────────

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
    List<Transaction> debits = [];
    for (var account in widget.dashboardData.accounts) {
      debits.addAll(
        account.history12Months.where(
          (tx) => tx.type == 'debit' && tx.date.isAfter(cutoff),
        ),
      );
    }
    if (debits.isEmpty) return [];
    debits.sort((a, b) => a.date.compareTo(b.date));
    Map<DateTime, double> dailySpend = {};
    for (var tx in debits) {
      final dateOnly = DateTime(tx.date.year, tx.date.month, tx.date.day);
      dailySpend[dateOnly] = (dailySpend[dateOnly] ?? 0) + (tx.amount / 100);
    }
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
                      onRangeChanged: (range) =>
                          setState(() => _selectedRange = range),
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
                            onPressed: () =>
                                setState(() => _forceShowChart = true),
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
                  Image.asset(
                    'assets/images/icons/Wallet.png',
                    width: 16,
                    height: 16,
                  ),
                  const Gap(4),
                  const Text(
                    'View Spending',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'GeneralSans',
                      letterSpacing: 14 * 0.02,
                      fontSize: 14,
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.chevron_right,
                    size: 16,
                    color: Colors.black,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String formatMoney(double amount) =>
      '₦${NumberFormat('#,###.##').format(amount.abs())}';
}

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
    double accountBalances = widget.dashboardData.accounts.fold(
      0.0,
      (sum, a) => sum + a.details.balance,
    );
    double savingsBalance = widget.dashboardData.savings.fold(
      0.0,
      (sum, g) => sum + g.balance,
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
          if (tx.type == 'credit')
            income += tx.amount / 100;
          else if (tx.type == 'debit')
            expenses += tx.amount / 100;
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
    List<Transaction> allTxs = [];
    for (var account in widget.dashboardData.accounts) {
      allTxs.addAll(
        account.history12Months.where((tx) => tx.date.isAfter(cutoff)),
      );
    }
    if (allTxs.isEmpty) return [];
    allTxs.sort((a, b) => a.date.compareTo(b.date));
    double runningBalance = getNetWorth();
    List<ChartDataPoint> data = [];
    for (var tx in allTxs.reversed) {
      if (tx.type == 'credit')
        runningBalance -= (tx.amount / 100);
      else if (tx.type == 'debit')
        runningBalance += (tx.amount / 100);
      data.insert(
        0,
        ChartDataPoint(
          value: runningBalance.isNegative ? 0 : runningBalance,
          timestamp: tx.date,
        ),
      );
    }
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
                      onRangeChanged: (range) =>
                          setState(() => _selectedRange = range),
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
                            onPressed: () =>
                                setState(() => _forceShowChart = true),
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

  String formatMoney(double amount) =>
      '₦${NumberFormat('#,###.##').format(amount.abs())}';
}

class _SavingsInsightCard extends StatelessWidget {
  final String insight;
  const _SavingsInsightCard({required this.insight});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: AppColors.primaryFaint,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.savings_outlined,
              color: AppColors.primaryDark,
              size: 20,
            ),
            const Gap(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Savings Insight',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'GeneralSans',
                      color: AppColors.primaryDark,
                      letterSpacing: 12 * 0.02,
                    ),
                  ),
                  const Gap(4),
                  Text(
                    insight,
                    style: const TextStyle(
                      fontSize: 13,
                      fontFamily: 'GeneralSans',
                      color: AppColors.textPrimary,
                      letterSpacing: 13 * 0.02,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AccountsSection extends StatefulWidget {
  final DashboardData dashboardData;
  const AccountsSection({super.key, required this.dashboardData});
  @override
  State<AccountsSection> createState() => _AccountsSectionState();
}

class _AccountsSectionState extends State<AccountsSection> {
  bool _isSavingsExpanded = false;
  bool _isDebtsExpanded = false;

  @override
  Widget build(BuildContext context) {
    final double netCash =
        widget.dashboardData.netAnalysis.totalBalance / 100;
    double savingsBalance = widget.dashboardData.savings.fold(
      0.0,
      (sum, g) => sum + g.balance,
    );
    double debtsTotal = widget.dashboardData.debts.fold(
      0.0,
      (sum, d) => sum + d.owed,
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
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ACCOUNTS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'GeneralSans',
                    letterSpacing: 12 * 0.02,
                  ),
                ),
              ],
            ),
            const Gap(8),
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
              onTap: () =>
                  setState(() => _isSavingsExpanded = !_isSavingsExpanded),
            ),
            if (_isSavingsExpanded) ...[
              const Gap(8),
              if (widget.dashboardData.savings.isEmpty)
                const Center(
                  child: Column(
                    children: [
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
                  (goal) {
                    final bool completed =
                        goal.targetAmount > 0 && goal.isCompleted;
                    final double progress = completed
                        ? 1.0
                        : (goal.targetAmount > 0
                            ? goal.progressPercentage / 100
                            : 0.0);
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                      leading: completed
                          ? const Icon(
                              Icons.check_circle,
                              color: AppColors.success,
                            )
                          : Icon(_getIconForGoal(goal.goalName)),
                      title: Text(goal.goalName),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Gap(4),
                          LinearProgressIndicator(
                            value: progress,
                            backgroundColor: AppColors.greyLight,
                            valueColor: AlwaysStoppedAnimation(
                              completed
                                  ? AppColors.success
                                  : AppColors.primary,
                            ),
                            minHeight: 4,
                            borderRadius: BorderRadius.circular(2),
                          ),
                          const Gap(4),
                          Text(
                            '${formatMoney(goal.balance)} of ${formatMoney(goal.targetAmount)}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontFamily: 'GeneralSans',
                              letterSpacing: 11 * 0.02,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            completed
                                ? 'Completed'
                                : '${goal.progressPercentage.toStringAsFixed(0)}% complete',
                            style: TextStyle(
                              fontSize: 11,
                              fontFamily: 'GeneralSans',
                              letterSpacing: 11 * 0.02,
                              color: completed
                                  ? AppColors.success
                                  : AppColors.textSecondary,
                              fontWeight: completed
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            formatMoney(goal.balance),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontFamily: 'GeneralSans',
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            'of ${formatMoney(goal.targetAmount)}',
                            style: const TextStyle(
                              fontSize: 10,
                              fontFamily: 'GeneralSans',
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
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
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.credit_card_outlined),
              title: const Text('Debts'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    formatMoney(debtsTotal),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontFamily: 'GeneralSans',
                    ),
                  ),
                  const Gap(8),
                  Icon(
                    _isDebtsExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 16,
                  ),
                ],
              ),
              onTap: () =>
                  setState(() => _isDebtsExpanded = !_isDebtsExpanded),
            ),
            if (_isDebtsExpanded) ...[
              const Gap(8),
              if (widget.dashboardData.debts.isEmpty)
                const Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 48,
                        color: AppColors.greyLight,
                      ),
                      Gap(8),
                      Text(
                        'No debts',
                        style: TextStyle(
                          color: AppColors.grey,
                          fontFamily: 'GeneralSans',
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...widget.dashboardData.debts.map(
                  (debt) {
                    final bool paidOff =
                        debt.owed > 0 && debt.isPaidOff;
                    final double progress = paidOff
                        ? 1.0
                        : (debt.owed > 0
                            ? debt.payoffPercentage / 100
                            : 0.0);
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                      leading: paidOff
                          ? const Icon(
                              Icons.check_circle,
                              color: AppColors.success,
                            )
                          : const Icon(Icons.credit_card),
                      title: Text(debt.name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Gap(4),
                          LinearProgressIndicator(
                            value: progress,
                            backgroundColor: AppColors.greyLight,
                            valueColor: AlwaysStoppedAnimation(
                              paidOff
                                  ? AppColors.success
                                  : AppColors.error,
                            ),
                            minHeight: 4,
                            borderRadius: BorderRadius.circular(2),
                          ),
                          const Gap(4),
                          Text(
                            '${formatMoney(debt.balance)} paid of ${formatMoney(debt.owed)}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontFamily: 'GeneralSans',
                              letterSpacing: 11 * 0.02,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            paidOff
                                ? 'Paid off'
                                : '${debt.payoffPercentage.toStringAsFixed(0)}% paid',
                            style: TextStyle(
                              fontSize: 11,
                              fontFamily: 'GeneralSans',
                              letterSpacing: 11 * 0.02,
                              color: paidOff
                                  ? AppColors.success
                                  : AppColors.error,
                              fontWeight: paidOff
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            formatMoney(debt.owed),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontFamily: 'GeneralSans',
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            '${formatMoney(debt.balance)} paid',
                            style: const TextStyle(
                              fontSize: 10,
                              fontFamily: 'GeneralSans',
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ],
        ),
      ),
    );
  }

  String formatMoney(double amount) =>
      '₦${NumberFormat('#,###.00').format(amount)}';

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
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Center(
                  child: Column(
                    children: [
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
    if (day == 1 || day == 21 || day == 31)
      suffix = 'st';
    else if (day == 2 || day == 22)
      suffix = 'nd';
    else if (day == 3 || day == 23)
      suffix = 'rd';
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

  String formatMoney(double amount) =>
      '₦${NumberFormat('#,###.00').format(amount)}';
}

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
              Expanded(
                child: transactions.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
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
    if (day == 1 || day == 21 || day == 31)
      suffix = 'st';
    else if (day == 2 || day == 22)
      suffix = 'nd';
    else if (day == 3 || day == 23)
      suffix = 'rd';
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

  String _formatMoney(double amount) =>
      '₦${NumberFormat('#,###.00').format(amount)}';
}





// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:gap/gap.dart';
// import 'package:go_router/go_router.dart';
// import 'package:intl/intl.dart';
// import 'package:shared_preferences/shared_preferences.dart';
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

// const _kDashboardWalkthroughKey = 'dashboard_walkthrough_completed';

// class DashboardScreen extends ConsumerStatefulWidget {
//   static const String path = '/dashboard';

//   const DashboardScreen({super.key});

//   @override
//   ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
// }

// class _DashboardScreenState extends ConsumerState<DashboardScreen> {
//   final PageController _pageController = PageController();
//   int _currentPage = 0;

//   // ── Walkthrough ───────────────────────────────────────────────────────────
//   bool _showWalkthrough = false;

//   // ── Reload button loading state ───────────────────────────────────────────
//   bool _isReloading = false;

//   // ─────────────────────────────────────────────────────────────────────────
//   // Lifecycle
//   // ─────────────────────────────────────────────────────────────────────────

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) => _checkWalkthrough());
//   }

//   @override
//   void dispose() {
//     _pageController.dispose();
//     super.dispose();
//   }

//   // ─────────────────────────────────────────────────────────────────────────
//   // Walkthrough helpers
//   // ─────────────────────────────────────────────────────────────────────────

//   Future<void> _checkWalkthrough() async {
//     final prefs = await SharedPreferences.getInstance();
//     final completed = prefs.getBool(_kDashboardWalkthroughKey) ?? false;
//     if (!completed && mounted) {
//       setState(() => _showWalkthrough = true);
//     }
//   }

//   Future<void> _dismissWalkthrough() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setBool(_kDashboardWalkthroughKey, true);
//     if (mounted) setState(() => _showWalkthrough = false);
//   }

//   // ─────────────────────────────────────────────────────────────────────────
//   // Reload with loading state
//   // ─────────────────────────────────────────────────────────────────────────

//   Future<void> _handleReload() async {
//     setState(() => _isReloading = true);
//     try {
//       ref.invalidate(dashboardDataProvider);
//       ref.invalidate(homeDataProvider);
//       // Wait for both providers to settle
//       await Future.wait([
//         ref.read(dashboardDataProvider('all').future).catchError((_) => null),
//         ref.read(homeDataProvider.future).catchError((_) => null),
//       ]);
//     } finally {
//       if (mounted) setState(() => _isReloading = false);
//     }
//   }

//   // ─────────────────────────────────────────────────────────────────────────
//   // Build
//   // ─────────────────────────────────────────────────────────────────────────

//   String formatMoney(double amount) {
//     return '₦${NumberFormat('#,###.00').format(amount)}';
//   }

//   @override
//   Widget build(BuildContext context) {
//     final dashboardDataAsync = ref.watch(dashboardDataProvider('all'));
//     final homeData = ref.watch(homeDataProvider);

//     return Stack(
//       children: [
//         // ── Main Scaffold ─────────────────────────────────────────────────
//         homeData.when(
//           skipLoadingOnRefresh: true,
//           data: (value) {
//             final data = value.data;

//             return Scaffold(
//               appBar: _buildAppBar(data.firstName, context),
//               body: SafeArea(
//                 child: dashboardDataAsync.when(
//                   skipLoadingOnRefresh: true,
//                   data: (dashboardData) {
//                     if (dashboardData == null) {
//                       return CustomErrorWidget(
//                         icon: Icons.link_off_rounded,
//                         title: 'No linked account',
//                         subtitle:
//                             'Link your account to keep track of your money',
//                         actionButtonText: 'Link account',
//                         onActionPressed: () {
//                           ConnectBankIntroBottomSheet.show(context);
//                         },
//                       );
//                     }
//                     return RefreshIndicator(
//                       onRefresh: () => ref
//                           .read(dashboardDataProvider('all').notifier)
//                           .refresh(),
//                       child: SingleChildScrollView(
//                         physics: const AlwaysScrollableScrollPhysics(),
//                         child: Padding(
//                           padding: const EdgeInsets.all(16.0),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               SizedBox(
//                                 height: 420,
//                                 child: PageView(
//                                   controller: _pageController,
//                                   onPageChanged: (index) {
//                                     setState(() => _currentPage = index);
//                                   },
//                                   children: [
//                                     SpendCard(dashboardData: dashboardData),
//                                     NetWorthCard(dashboardData: dashboardData),
//                                     FinancialHealthCard(
//                                       healthData:
//                                           dashboardData.widgets.financialHealth,
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               const Gap(8),
//                               Row(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: List.generate(3, (index) {
//                                   return Container(
//                                     margin: const EdgeInsets.symmetric(
//                                       horizontal: 4,
//                                     ),
//                                     width: _currentPage == index ? 16 : 8,
//                                     height: 8,
//                                     decoration: BoxDecoration(
//                                       color: _currentPage == index
//                                           ? AppColors.yellow
//                                           : AppColors.greyLight,
//                                       borderRadius: BorderRadius.circular(4),
//                                     ),
//                                   );
//                                 }),
//                               ),
//                               const Gap(16),
//                               AccountsSection(dashboardData: dashboardData),
//                               const Gap(16),
//                               RecentTransactionsSection(
//                                 transactions: dashboardData.accounts.isNotEmpty
//                                     ? dashboardData.accounts[0].history12Months
//                                     : [],
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                   loading: () => const CustomLoadingWidget(
//                     text: 'Loading your dashboard...',
//                   ),
//                   error: (error, stack) => CustomErrorWidget(
//                     icon: Icons.dashboard_outlined,
//                     title: 'Unable to Load Dashboard',
//                     subtitle:
//                         'We couldn\'t fetch your dashboard data. Please check your connection and try again.',
//                     actionButtonText: 'Reload',
//                     isActionLoading: _isReloading,
//                     onActionPressed: _isReloading ? null : _handleReload,
//                   ),
//                 ),
//               ),
//             );
//           },
//           error: (error, stack) => Scaffold(
//             body: CustomErrorWidget(
//               icon: Icons.dashboard_outlined,
//               title: 'Unable to Load Dashboard',
//               subtitle:
//                   'We couldn\'t fetch your dashboard data. Please check your connection and try again.',
//               actionButtonText: 'Reload',
//               isActionLoading: _isReloading,
//               onActionPressed: _isReloading ? null : _handleReload,
//             ),
//           ),
//           loading: () => const Scaffold(
//             body: CustomLoadingWidget(text: 'Loading your dashboard...'),
//           ),
//         ),

//         // ── Walkthrough overlay (above AppBar + body) ─────────────────────
//         // Shown only on the first visit when there is no linked account.
//         if (_showWalkthrough)
//           GestureDetector(
//             onTap: _dismissWalkthrough,
//             child: Stack(
//               children: [
//                 // Full-screen dark backdrop
//                 Container(color: Colors.black.withOpacity(0.55)),
//                 // Character image anchored to bottom-right
//                 Align(
//                   alignment: Alignment.bottomRight,
//                   child: Image.asset(
//                     'assets/images/walk_through/dashboard.png',
//                     width: MediaQuery.of(context).size.width * 0.65,
//                     fit: BoxFit.contain,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//       ],
//     );
//   }

//   // ─────────────────────────────────────────────────────────────────────────
//   // AppBar (unchanged)
//   // ─────────────────────────────────────────────────────────────────────────

//   AppBar _buildAppBar(String firstName, BuildContext context) {
//     return AppBar(
//       elevation: 0,
//       backgroundColor: Colors.transparent,
//       flexibleSpace: Container(decoration: const BoxDecoration()),
//       title: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           GestureDetector(
//             onTap: () {},
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
//                           letterSpacing: 12 * 0.02,
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
//                     letterSpacing: 16 * 0.02,
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

// // ─────────────────────────────────────────────────────────────────────────────
// // All widgets below are unchanged from the original
// // ─────────────────────────────────────────────────────────────────────────────

// class SpendCard extends StatefulWidget {
//   final DashboardData dashboardData;
//   const SpendCard({super.key, required this.dashboardData});
//   @override
//   State<SpendCard> createState() => _SpendCardState();
// }

// class _SpendCardState extends State<SpendCard> {
//   TimeRange _selectedRange = TimeRange.oneMonth;
//   bool _forceShowChart = false;

//   double _getSpendForRange(TimeRange range) {
//     final now = DateTime.now();
//     final cutoff = now.subtract(range.duration);
//     double spend = 0;
//     for (var account in widget.dashboardData.accounts) {
//       for (var tx in account.history12Months) {
//         if (tx.date.isAfter(cutoff) && tx.type == 'debit') {
//           spend += tx.amount / 100;
//         }
//       }
//     }
//     return spend;
//   }

//   double _getPreviousPeriodSpend(TimeRange range) {
//     final now = DateTime.now();
//     final currentPeriodStart = now.subtract(range.duration);
//     final previousPeriodStart = currentPeriodStart.subtract(range.duration);
//     double spend = 0;
//     for (var account in widget.dashboardData.accounts) {
//       for (var tx in account.history12Months) {
//         if (tx.date.isAfter(previousPeriodStart) &&
//             tx.date.isBefore(currentPeriodStart) &&
//             tx.type == 'debit') {
//           spend += tx.amount / 100;
//         }
//       }
//     }
//     return spend;
//   }

//   String _getComparisonText(TimeRange range) {
//     switch (range) {
//       case TimeRange.threeDays:
//         return 'previous 3 days';
//       case TimeRange.oneWeek:
//         return 'previous week';
//       case TimeRange.oneMonth:
//         return 'last month';
//       case TimeRange.threeMonths:
//         return 'previous 3 months';
//       case TimeRange.sixMonths:
//         return 'previous 6 months';
//       case TimeRange.oneYear:
//         return 'previous year';
//     }
//   }

//   String _getCurrentPeriodLabel(TimeRange range) {
//     switch (range) {
//       case TimeRange.threeDays:
//         return 'Current spend (3 days)';
//       case TimeRange.oneWeek:
//         return 'Current spend (1 week)';
//       case TimeRange.oneMonth:
//         return 'Current spend this month';
//       case TimeRange.threeMonths:
//         return 'Current spend (3 months)';
//       case TimeRange.sixMonths:
//         return 'Current spend (6 months)';
//       case TimeRange.oneYear:
//         return 'Current spend (1 year)';
//     }
//   }

//   List<ChartDataPoint> getSpendChartData() {
//     final now = DateTime.now();
//     final cutoff = now.subtract(_selectedRange.duration);
//     List<Transaction> debits = [];
//     for (var account in widget.dashboardData.accounts) {
//       debits.addAll(
//         account.history12Months.where(
//           (tx) => tx.type == 'debit' && tx.date.isAfter(cutoff),
//         ),
//       );
//     }
//     if (debits.isEmpty) return [];
//     debits.sort((a, b) => a.date.compareTo(b.date));
//     Map<DateTime, double> dailySpend = {};
//     for (var tx in debits) {
//       final dateOnly = DateTime(tx.date.year, tx.date.month, tx.date.day);
//       dailySpend[dateOnly] = (dailySpend[dateOnly] ?? 0) + (tx.amount / 100);
//     }
//     final sortedDates = dailySpend.keys.toList()..sort();
//     return sortedDates
//         .map(
//           (date) => ChartDataPoint(value: dailySpend[date]!, timestamp: date),
//         )
//         .toList();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final currentSpend = _getSpendForRange(_selectedRange);
//     final previousSpend = _getPreviousPeriodSpend(_selectedRange);
//     final difference = currentSpend - previousSpend;
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
//                 Text(
//                   _getCurrentPeriodLabel(_selectedRange),
//                   style: const TextStyle(
//                     fontSize: 12,
//                     color: AppColors.grey,
//                     fontFamily: 'GeneralSans',
//                     letterSpacing: 12 * 0.02,
//                   ),
//                 ),
//                 const Gap(4),
//                 if (previousSpend > 0)
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
//                             '${formatMoney(difference.abs())} ${isBelow ? 'below' : 'above'} ${_getComparisonText(_selectedRange)}',
//                             style: TextStyle(
//                               color: isBelow
//                                   ? AppColors.success
//                                   : AppColors.grey,
//                               fontSize: 11,
//                               fontFamily: 'GeneralSans',
//                               letterSpacing: 11 * 0.02,
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
//               style: const TextStyle(
//                 fontSize: 32,
//                 fontWeight: FontWeight.bold,
//                 fontFamily: 'GeneralSans',
//                 letterSpacing: 32 * 0.02,
//               ),
//             ),
//             const Gap(16),
//             Expanded(
//               child: chartData.isNotEmpty || _forceShowChart
//                   ? CustomLineChart(
//                       data: chartData.isNotEmpty
//                           ? chartData
//                           : [
//                               ChartDataPoint(
//                                 value: 0,
//                                 timestamp: DateTime.now(),
//                               ),
//                             ],
//                       onRangeChanged: (range) =>
//                           setState(() => _selectedRange = range),
//                     )
//                   : Center(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           const Icon(
//                             Icons.show_chart,
//                             size: 48,
//                             color: AppColors.greyLight,
//                           ),
//                           const Gap(8),
//                           const Text(
//                             'Not enough spending data',
//                             style: TextStyle(
//                               color: AppColors.grey,
//                               fontSize: 14,
//                               fontFamily: 'GeneralSans',
//                               letterSpacing: 14 * 0.02,
//                             ),
//                           ),
//                           const Gap(16),
//                           OutlinedButton.icon(
//                             onPressed: () =>
//                                 setState(() => _forceShowChart = true),
//                             icon: const Icon(Icons.show_chart, size: 16),
//                             label: const Text('Show chart anyway'),
//                             style: OutlinedButton.styleFrom(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 16,
//                                 vertical: 8,
//                               ),
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
//                 children: [
//                   Image.asset(
//                     'assets/images/icons/Wallet.png',
//                     width: 16,
//                     height: 16,
//                   ),
//                   const Gap(4),
//                   const Text(
//                     'View Spending',
//                     style: TextStyle(
//                       color: Colors.black,
//                       fontWeight: FontWeight.w500,
//                       fontFamily: 'GeneralSans',
//                       letterSpacing: 14 * 0.02,
//                       fontSize: 14,
//                     ),
//                   ),
//                   const Spacer(),
//                   const Icon(
//                     Icons.chevron_right,
//                     size: 16,
//                     color: Colors.black,
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   String formatMoney(double amount) =>
//       '₦${NumberFormat('#,###.##').format(amount.abs())}';
// }

// class NetWorthCard extends StatefulWidget {
//   final DashboardData dashboardData;
//   const NetWorthCard({super.key, required this.dashboardData});
//   @override
//   State<NetWorthCard> createState() => _NetWorthCardState();
// }

// class _NetWorthCardState extends State<NetWorthCard> {
//   TimeRange _selectedRange = TimeRange.oneMonth;
//   bool _forceShowChart = false;

//   double getNetWorth() {
//     double accountBalances = widget.dashboardData.accounts.fold(
//       0.0,
//       (sum, a) => sum + a.details.balance,
//     );
//     double savingsBalance = widget.dashboardData.savings.fold(
//       0.0,
//       (sum, g) => sum + g.balance,
//     );
//     return accountBalances + savingsBalance;
//   }

//   double _getNetWorthChangeForRange(TimeRange range) {
//     final now = DateTime.now();
//     final cutoff = now.subtract(range.duration);
//     double income = 0;
//     double expenses = 0;
//     for (var account in widget.dashboardData.accounts) {
//       for (var tx in account.history12Months) {
//         if (tx.date.isAfter(cutoff)) {
//           if (tx.type == 'credit')
//             income += tx.amount / 100;
//           else if (tx.type == 'debit')
//             expenses += tx.amount / 100;
//         }
//       }
//     }
//     return income - expenses;
//   }

//   String _getComparisonText(TimeRange range) {
//     switch (range) {
//       case TimeRange.threeDays:
//         return 'previous 3 days';
//       case TimeRange.oneWeek:
//         return 'previous week';
//       case TimeRange.oneMonth:
//         return 'last month';
//       case TimeRange.threeMonths:
//         return 'previous 3 months';
//       case TimeRange.sixMonths:
//         return 'previous 6 months';
//       case TimeRange.oneYear:
//         return 'previous year';
//     }
//   }

//   List<ChartDataPoint> getNetWorthChartData() {
//     final now = DateTime.now();
//     final cutoff = now.subtract(_selectedRange.duration);
//     List<Transaction> allTxs = [];
//     for (var account in widget.dashboardData.accounts) {
//       allTxs.addAll(
//         account.history12Months.where((tx) => tx.date.isAfter(cutoff)),
//       );
//     }
//     if (allTxs.isEmpty) return [];
//     allTxs.sort((a, b) => a.date.compareTo(b.date));
//     double runningBalance = getNetWorth();
//     List<ChartDataPoint> data = [];
//     for (var tx in allTxs.reversed) {
//       if (tx.type == 'credit')
//         runningBalance -= (tx.amount / 100);
//       else if (tx.type == 'debit')
//         runningBalance += (tx.amount / 100);
//       data.insert(
//         0,
//         ChartDataPoint(
//           value: runningBalance.isNegative ? 0 : runningBalance,
//           timestamp: tx.date,
//         ),
//       );
//     }
//     if (data.isNotEmpty) {
//       data.add(ChartDataPoint(value: getNetWorth(), timestamp: now));
//     }
//     return data;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final netWorth = getNetWorth();
//     final change = _getNetWorthChangeForRange(_selectedRange);
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
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: AppColors.grey,
//                     fontFamily: 'GeneralSans',
//                     letterSpacing: 12 * 0.02,
//                   ),
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
//                       '${formatMoney(change.abs())} ${isPositive ? 'gain' : 'loss'} vs ${_getComparisonText(_selectedRange)}',
//                       style: TextStyle(
//                         color: isPositive ? AppColors.success : AppColors.grey,
//                         fontSize: 11,
//                         fontFamily: 'GeneralSans',
//                         letterSpacing: 11 * 0.02,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//             const Gap(8),
//             Text(
//               formatMoney(netWorth),
//               style: const TextStyle(
//                 fontSize: 32,
//                 fontWeight: FontWeight.bold,
//                 fontFamily: 'GeneralSans',
//                 letterSpacing: 32 * 0.02,
//               ),
//             ),
//             const Gap(16),
//             Expanded(
//               child: chartData.length >= 2 || _forceShowChart
//                   ? CustomLineChart(
//                       data: chartData.length >= 2
//                           ? chartData
//                           : [
//                               ChartDataPoint(
//                                 value: netWorth,
//                                 timestamp: DateTime.now(),
//                               ),
//                             ],
//                       onRangeChanged: (range) =>
//                           setState(() => _selectedRange = range),
//                     )
//                   : Center(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           const Icon(
//                             Icons.trending_up,
//                             size: 48,
//                             color: AppColors.greyLight,
//                           ),
//                           const Gap(8),
//                           const Text(
//                             'Not enough data',
//                             style: TextStyle(
//                               color: AppColors.grey,
//                               fontSize: 14,
//                               fontFamily: 'GeneralSans',
//                               letterSpacing: 14 * 0.02,
//                             ),
//                           ),
//                           const Gap(16),
//                           OutlinedButton.icon(
//                             onPressed: () =>
//                                 setState(() => _forceShowChart = true),
//                             icon: const Icon(Icons.show_chart, size: 16),
//                             label: const Text('Show chart anyway'),
//                             style: OutlinedButton.styleFrom(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 16,
//                                 vertical: 8,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   String formatMoney(double amount) =>
//       '₦${NumberFormat('#,###.##').format(amount.abs())}';
// }

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
//       (sum, a) => sum + a.details.balance,
//     );
//     double savingsBalance = widget.dashboardData.savings.fold(
//       0.0,
//       (sum, g) => sum + g.balance,
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
//             const Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'ACCOUNTS',
//                   style: TextStyle(
//                     fontSize: 12,
//                     fontWeight: FontWeight.w600,
//                     fontFamily: 'GeneralSans',
//                     letterSpacing: 12 * 0.02,
//                   ),
//                 ),
//               ],
//             ),
//             const Gap(8),
//             ListTile(
//               contentPadding: EdgeInsets.zero,
//               leading: const Icon(Icons.account_balance_wallet_outlined),
//               title: const Text('Net cash'),
//               trailing: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(
//                     formatMoney(netCash),
//                     style: const TextStyle(
//                       fontWeight: FontWeight.w600,
//                       fontFamily: 'GeneralSans',
//                     ),
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
//             ListTile(
//               contentPadding: EdgeInsets.zero,
//               leading: const Icon(Icons.savings_outlined),
//               title: const Text('Savings'),
//               trailing: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(
//                     formatMoney(savingsBalance),
//                     style: const TextStyle(
//                       fontWeight: FontWeight.w600,
//                       fontFamily: 'GeneralSans',
//                     ),
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
//               onTap: () =>
//                   setState(() => _isSavingsExpanded = !_isSavingsExpanded),
//             ),
//             if (_isSavingsExpanded) ...[
//               const Gap(8),
//               if (widget.dashboardData.savings.isEmpty)
//                 const Center(
//                   child: Column(
//                     children: [
//                       Icon(
//                         Icons.flag_outlined,
//                         size: 48,
//                         color: AppColors.greyLight,
//                       ),
//                       Gap(8),
//                       Text(
//                         'No financial goals yet',
//                         style: TextStyle(
//                           color: AppColors.grey,
//                           fontFamily: 'GeneralSans',
//                         ),
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
//                           style: const TextStyle(
//                             fontSize: 11,
//                             fontFamily: 'GeneralSans',
//                             letterSpacing: 11 * 0.02,
//                           ),
//                         ),
//                       ],
//                     ),
//                     trailing: Text(
//                       formatMoney(goal.balance),
//                       style: const TextStyle(
//                         fontWeight: FontWeight.w600,
//                         fontFamily: 'GeneralSans',
//                       ),
//                     ),
//                   ),
//                 ),
//               if (widget.dashboardData.savings.length > 2) const Gap(8),
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

//   String formatMoney(double amount) =>
//       '₦${NumberFormat('#,###.00').format(amount)}';

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
//               const Padding(
//                 padding: EdgeInsets.symmetric(vertical: 16.0),
//                 child: Center(
//                   child: Column(
//                     children: [
//                       Icon(
//                         Icons.receipt_long_outlined,
//                         size: 48,
//                         color: AppColors.greyLight,
//                       ),
//                       Gap(8),
//                       Text(
//                         'No recent transactions',
//                         style: TextStyle(
//                           color: AppColors.grey,
//                           fontFamily: 'GeneralSans',
//                         ),
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
//                       fontFamily: 'GeneralSans',
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
//     if (day == 1 || day == 21 || day == 31)
//       suffix = 'st';
//     else if (day == 2 || day == 22)
//       suffix = 'nd';
//     else if (day == 3 || day == 23)
//       suffix = 'rd';
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

//   String formatMoney(double amount) =>
//       '₦${NumberFormat('#,###.00').format(amount)}';
// }

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
//                         letterSpacing: 20 * 0.02,
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
//               Expanded(
//                 child: transactions.isEmpty
//                     ? const Center(
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
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
//                                 fontFamily: 'GeneralSans',
//                                 letterSpacing: 16 * 0.02,
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
//                                 fontFamily: 'GeneralSans',
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
//     if (day == 1 || day == 21 || day == 31)
//       suffix = 'st';
//     else if (day == 2 || day == 22)
//       suffix = 'nd';
//     else if (day == 3 || day == 23)
//       suffix = 'rd';
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

//   String _formatMoney(double amount) =>
//       '₦${NumberFormat('#,###.00').format(amount)}';
// }