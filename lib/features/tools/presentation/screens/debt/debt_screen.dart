import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';
import 'package:savvy_bee_mobile/core/utils/number_formatter.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_card.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/providers/debt_provider.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../widgets/goal_stats_card.dart';
import 'add_debt_screen.dart';

class DebtScreen extends ConsumerStatefulWidget {
  static const String path = '/debt';

  const DebtScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DebtScreenState();
}

class _DebtScreenState extends ConsumerState<DebtScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Start fetching data immediately
    ref.read(debtListNotifierProvider.notifier).refresh();

    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // WATCH THE DEBT LIST STATE
    final debtState = ref.watch(debtListNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Debt')),
      body: RefreshIndicator(
        onRefresh: () => ref.read(debtListNotifierProvider.notifier).refresh(),
        child: SingleChildScrollView(
          physics:
              const AlwaysScrollableScrollPhysics(), // Allows pull-to-refresh
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 3. BUILD THE DEBT CARD BASED ON STATE
              debtState.when(
                data: (data) {
                  final activeDebts = data
                      .where((item) => item['status'] == 'active')
                      .toList();
                  final totalRemaining = activeDebts.fold<double>(
                    0.0,
                    (sum, debt) =>
                        sum + (debt['amountRemaining'] as double? ?? 0.0),
                  );
                  return _buildDebtCard(totalRemaining);
                },
                loading: () => _buildDebtCard(0.0, isLoading: true),
                error: (e, st) => _buildDebtCard(
                  0.0,
                  isError: true,
                  errorMessage: 'Failed to load debts',
                ),
              ),
              const Gap(16),

              // TAB BAR
              TabBar(
                controller: _tabController,
                dividerColor: Colors.transparent,
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: const [
                  Tab(text: 'Active'),
                  Tab(text: 'Paid off'),
                ],
              ),

              // 4. DISPLAY LISTS IN TABBARVIEW BASED ON STATE
              debtState.when(
                loading: () => SizedBox(
                  height: 300,
                  child: const Center(child: CircularProgressIndicator()),
                ),
                error: (e, st) => SizedBox(
                  height: 300,
                  child: Center(child: Text('Error: ${e.toString()}')),
                ),
                data: (data) {
                  final activeDebts = data
                      .where((item) => item['status'] == 'active')
                      .toList();
                  final paidOffDebts = data
                      .where((item) => item['status'] == 'paid_off')
                      .toList();

                  return SizedBox(
                    // Dynamically set height based on the active tab content
                    height: _tabController.index == 0
                        ? activeDebts.length * 106.0 + 24.0
                        : 300,
                    child: TabBarView(
                      controller: _tabController,
                      // We can allow scrolling within the ListView, but not the TabBarView itself
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        // Active Debts List
                        _buildDebtList(activeDebts, true),
                        // Paid Off Debts List
                        _buildDebtList(paidOffDebts, false),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.pushNamed(AddDebtScreen.path),
        backgroundColor: AppColors.buttonPrimary,
        foregroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        child: const Icon(Icons.add),
      ),
    );
  }

  // Helper method to build the list of debt items
  Widget _buildDebtList(List<dynamic> debts, bool isActive) {
    if (debts.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 24),
        child: Center(
          child: Text('No ${isActive ? 'active' : 'paid off'} debts yet.'),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(top: 24),
      shrinkWrap: true,
      physics:
          const NeverScrollableScrollPhysics(), // Handled by SingleChildScrollView
      itemBuilder: (context, index) {
        final debt = debts[index];
        return GoalStatsCard(
          // Assuming the API returns these keys:
          title: debt['title'] ?? 'N/A',
          amountSaved: debt['amountPaid'] as double? ?? 0.0,
          totalTarget: debt['totalAmount'] as double? ?? 0.0,
          daysLeft: debt['daysLeft'] as int? ?? 0,
          isDebt: true,
          // You might need to pass the full debt object for navigation/manual funding later
          // debtData: debt,
        );
      },
      separatorBuilder: (context, index) => const Gap(16),
      itemCount: debts.length,
    );
  }

  Widget _buildDebtCard(
    double amountRemaining, {
    bool isLoading = false,
    bool isError = false,
    String errorMessage = '',
  }) {
    return CustomCard(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TOTAL DEBTS REMAINING',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 12,
              fontFamily: Constants.neulisNeueFontFamily,
            ),
          ),
          const Gap(8),
          if (isLoading)
            const SizedBox(
              height: 36,
              child: Center(child: LinearProgressIndicator()),
            )
          else if (isError)
            Text(errorMessage, style: const TextStyle(color: AppColors.error))
          else
            Text(
              NumberFormatter.formatCurrency(amountRemaining),
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 36,
                fontFamily: Constants.neulisNeueFontFamily,
              ),
            ),
          const Gap(8),
          Text(
            isLoading ? 'Loading...' : 'Last updated 49 sec ago',
            style: TextStyle(
              fontSize: 12,
              fontFamily: Constants.neulisNeueFontFamily,
              color: AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }
}
