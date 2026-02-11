import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/features/dashboard/domain/models/dashboard_data.dart';
import 'package:savvy_bee_mobile/features/dashboard/presentation/providers/dashboard_data_provider.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_loading_widget.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_error_widget.dart';

class SpendingScreen extends ConsumerStatefulWidget {
  static const String path = '/spending';

  const SpendingScreen({super.key});

  @override
  ConsumerState<SpendingScreen> createState() => _SpendingScreenState();
}

class _SpendingScreenState extends ConsumerState<SpendingScreen> {
  String _selectedPeriod = 'Month';

  String formatMoney(double amount) {
    // Format without decimals for cleaner look
    return '₦${NumberFormat('#,###').format(amount.round())}';
  }

  @override
  Widget build(BuildContext context) {
    final dashboardDataAsync = ref.watch(dashboardDataProvider('all'));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Spending',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: dashboardDataAsync.when(
        data: (dashboardData) {
          if (dashboardData == null ||
              dashboardData.accounts.isEmpty ||
              dashboardData.accounts[0].history12Months.isEmpty) {
            return _buildEmptyState();
          }
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Period selector tabs
                  _buildPeriodSelector(),
                  const Gap(24),

                  // Bar chart
                  _buildBarChart(dashboardData),
                  const Gap(16),

                  // Income and Total Spend summary
                  _buildSummaryCards(dashboardData),
                  const Gap(24),

                  // Budget section
                  _buildBudgetSection(dashboardData),
                  const Gap(24),

                  // Breakdown section
                  _buildBreakdownSection(dashboardData),
                ],
              ),
            ),
          );
        },
        loading: () =>
            const CustomLoadingWidget(text: 'Loading spending data...'),
        error: (error, stack) => CustomErrorWidget(
          icon: Icons.error_outline,
          title: 'Unable to Load Spending',
          subtitle: 'We couldn\'t fetch your spending data.',
          onActionPressed: () => ref.invalidate(dashboardDataProvider),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Text(
                    'YOUR BUDGET',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                  const Gap(16),
                  const Icon(
                    Icons.info_outline,
                    size: 48,
                    color: AppColors.grey,
                  ),
                  const Gap(8),
                  const Text('No available data'),
                  const Gap(8),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Create a budget >'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _TabButton('Week', _selectedPeriod == 'Week', () {
          setState(() => _selectedPeriod = 'Week');
        }),
        _TabButton('Month', _selectedPeriod == 'Month', () {
          setState(() => _selectedPeriod = 'Month');
        }),
        _TabButton('Quarter', _selectedPeriod == 'Quarter', () {
          setState(() => _selectedPeriod = 'Quarter');
        }),
        _TabButton('Year', _selectedPeriod == 'Year', () {
          setState(() => _selectedPeriod = 'Year');
        }),
      ],
    );
  }

  Widget _buildBarChart(DashboardData dashboardData) {
    final months = _getLastFiveMonths();
    final incomeMap = _getMonthlyIncome(dashboardData);
    final spendMap = _getMonthlySpend(dashboardData);

    // Find max value for scaling
    final maxIncome = incomeMap.values.isEmpty
        ? 0.0
        : incomeMap.values.reduce((a, b) => a > b ? a : b);
    final maxSpend = spendMap.values.isEmpty
        ? 0.0
        : spendMap.values.reduce((a, b) => a > b ? a : b);
    final maxValue = maxIncome > maxSpend ? maxIncome : maxSpend;

    return Column(
      children: [
        SizedBox(
          height: 180,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceEvenly,
              maxY: maxValue > 0 ? maxValue * 1.2 : 100,
              barGroups: months.asMap().entries.map((e) {
                final index = e.key;
                final month = e.value;
                final income = incomeMap[month] ?? 0;
                final spend = spendMap[month] ?? 0;

                return BarChartGroupData(
                  x: index,
                  barsSpace: 4,
                  barRods: [
                    BarChartRodData(
                      toY: income > 0 ? income : 0.1,
                      color: const Color(0xFFD4E8D4), // Light green
                      width: 16,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    BarChartRodData(
                      toY: spend > 0 ? spend : 0.1,
                      color: const Color(0xFFFDD835), // Yellow
                      width: 16,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                );
              }).toList(),
              borderData: FlBorderData(show: false),
              gridData: const FlGridData(show: false),
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= months.length)
                        return const SizedBox();
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          DateFormat('MMM').format(months[index]),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
        const Gap(12),
        // Legend
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem('Income', const Color(0xFFD4E8D4)),
            const Gap(24),
            _buildLegendItem('Total Spend', const Color(0xFFFDD835)),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const Gap(6),
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _buildSummaryCards(DashboardData dashboardData) {
    final totalIncome = _getTotalIncome(dashboardData);
    final totalSpend = _getTotalSpend(dashboardData);

    return Column(
      children: [
        _buildSummaryCard(
          'Income',
          totalIncome,
          Icons.account_balance_wallet_outlined,
        ),
        const Gap(12),
        _buildSummaryCard(
          'Total Spend',
          totalSpend,
          Icons.account_balance_wallet_outlined,
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, double amount, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20),
          ),
          const Gap(12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          Row(
            children: [
              Text(
                formatMoney(amount),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Gap(4),
              const Icon(Icons.keyboard_arrow_down, size: 20),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetSection(DashboardData dashboardData) {
    final spent = _getCurrentMonthSpent(dashboardData);
    final budget = 1000000.0; // Mock budget, replace with actual if available
    final left = budget - spent;
    final progress = spent / budget;
    final monthName = DateFormat('MMMM').format(DateTime.now());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'YOUR BUDGET',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
            color: Colors.black54,
          ),
        ),
        const Gap(12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.calendar_today, size: 20),
                  ),
                  const Gap(12),
                  Expanded(
                    child: Text(
                      '$monthName Budget',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  // const Icon(Icons.chevron_right),
                ],
              ),
              const Gap(16),
              const Text(
                'Left To Spend',
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const Gap(4),
              Text(
                formatMoney(left),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Gap(4),
              Text(
                '${formatMoney(spent)} spent',
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              ),
              const Gap(12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation(
                    progress > 0.8 ? Colors.red : const Color(0xFF66BB6A),
                  ),
                  minHeight: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBreakdownSection(DashboardData dashboardData) {
    final categories = dashboardData.widgets.spendCategoryBreakdown.categories
        .where((cat) => cat.amount > 0)
        .toList();

    if (categories.isEmpty) {
      return const SizedBox.shrink();
    }

    final totalSpent = categories.fold(0.0, (sum, cat) => sum + cat.amount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'BREAKDOWN',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
            color: Colors.black54,
          ),
        ),
        const Gap(12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              // Pie chart
              SizedBox(
                height: 200,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        sections: categories.map((cat) {
                          return PieChartSectionData(
                            value: cat.amount,
                            color: _getColorForCategory(cat.name),
                            title: '',
                            radius: 70,
                          );
                        }).toList(),
                        centerSpaceRadius: 60,
                        sectionsSpace: 2,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          formatMoney(totalSpent),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'Spent this month',
                          style: TextStyle(fontSize: 11, color: Colors.black54),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Gap(24),
              // Category list
              ...categories.map((cat) {
                final percent = (cat.amount / totalSpent * 100).round();
                final color = _getColorForCategory(cat.name);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.category,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                      const Gap(12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              cat.name,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '$percent% of Spend',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        formatMoney(cat.amount),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  // Helper methods for data calculation
  List<DateTime> _getLastFiveMonths() {
    final now = DateTime.now();
    return List.generate(5, (i) => DateTime(now.year, now.month - (4 - i)));
  }

  Map<DateTime, double> _getMonthlyIncome(DashboardData dashboardData) {
    final map = <DateTime, double>{};
    for (var account in dashboardData.accounts) {
      for (var tx in account.history12Months) {
        if (tx.type == 'credit') {
          final month = DateTime(tx.date.year, tx.date.month);
          map.update(
            month,
            (value) => value + (tx.amount / 100), // Convert kobo to naira
            ifAbsent: () => tx.amount / 100,
          );
        }
      }
    }
    return map;
  }

  Map<DateTime, double> _getMonthlySpend(DashboardData dashboardData) {
    final map = <DateTime, double>{};
    for (var account in dashboardData.accounts) {
      for (var tx in account.history12Months) {
        if (tx.type == 'debit') {
          final month = DateTime(tx.date.year, tx.date.month);
          map.update(
            month,
            (value) => value + (tx.amount / 100), // Convert kobo to naira
            ifAbsent: () => tx.amount / 100,
          );
        }
      }
    }
    return map;
  }

  double _getTotalIncome(DashboardData dashboardData) {
    double total = 0;
    for (var account in dashboardData.accounts) {
      for (var tx in account.history12Months) {
        if (tx.type == 'credit') {
          total += tx.amount / 100; // Convert kobo to naira
        }
      }
    }
    return total;
  }

  double _getTotalSpend(DashboardData dashboardData) {
    double total = 0;
    for (var account in dashboardData.accounts) {
      for (var tx in account.history12Months) {
        if (tx.type == 'debit') {
          total += tx.amount / 100; // Convert kobo to naira
        }
      }
    }
    return total;
  }

  double _getCurrentMonthSpent(DashboardData dashboardData) {
    final now = DateTime.now();
    double spent = 0;
    for (var account in dashboardData.accounts) {
      for (var tx in account.history12Months) {
        if (tx.date.year == now.year &&
            tx.date.month == now.month &&
            tx.type == 'debit') {
          spent += tx.amount / 100; // Convert kobo to naira
        }
      }
    }
    return spent;
  }

  Color _getColorForCategory(String name) {
    switch (name.toLowerCase()) {
      case 'groceries':
        return const Color(0xFFE1BEE7); // Purple
      case 'auto & transport':
        return const Color(0xFFFF5252); // Red
      case 'electricity':
        return const Color(0xFFFDD835); // Yellow
      case 'other':
        return const Color(0xFF66BB6A); // Green
      case 'bills & utilities':
        return const Color(0xFFFDD835); // Yellow
      case 'shopping':
        return const Color(0xFF42A5F5); // Blue
      default:
        return Colors.grey;
    }
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _TabButton(this.label, this.active, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFFDD835) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.black : Colors.black54,
            fontSize: 13,
            fontWeight: active ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
