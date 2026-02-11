import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/features/dashboard/domain/models/dashboard_data.dart';

class CustomBarChart extends StatelessWidget {
  final DashboardData dashboardData;

  const CustomBarChart({super.key, required this.dashboardData});

  Map<DateTime, double> getMonthlyIncome() {
    final map = <DateTime, double>{};
    for (var account in dashboardData.accounts) {
      for (var tx in account.history12Months) {
        if (tx.type == 'credit') {
          final month = DateTime(tx.date.year, tx.date.month);
          map.update(month, (value) => value + tx.amount, ifAbsent: () => tx.amount);
        }
      }
    }
    return map;
  }

  Map<DateTime, double> getMonthlySpend() {
    final map = <DateTime, double>{};
    for (var account in dashboardData.accounts) {
      for (var tx in account.history12Months) {
        if (tx.type == 'debit') {
          final month = DateTime(tx.date.year, tx.date.month);
          map.update(month, (value) => value + tx.amount, ifAbsent: () => tx.amount);
        }
      }
    }
    return map;
  }

  List<DateTime> getLastFiveMonths() {
    final now = DateTime.now();
    return List.generate(5, (i) => DateTime(now.year, now.month - i));
  }

  @override
  Widget build(BuildContext context) {
    final months = getLastFiveMonths().reversed.toList(); // oldest to newest
    final incomeMap = getMonthlyIncome();
    final spendMap = getMonthlySpend();

    return SizedBox(
      height: 120,
      child: BarChart(
        BarChartData(
          barGroups: months.asMap().entries.map((e) {
            final index = e.key.toDouble();
            final month = e.value;
            final income = incomeMap[month] ?? 0;
            final spend = spendMap[month] ?? 0;
            return BarChartGroupData(
              x: index.toInt(),
              barRods: [
                BarChartRodData(toY: income, color: AppColors.green, width: 8),
                BarChartRodData(toY: spend, color: AppColors.yellow, width: 8),
              ],
            );
          }).toList(),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= months.length) return const SizedBox();
                  return Text(DateFormat('MMM').format(months[index]));
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}