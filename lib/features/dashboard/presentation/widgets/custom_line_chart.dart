import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';

class CustomLineChart extends StatelessWidget {
  final List<FlSpot> spots;

  const CustomLineChart({super.key, required this.spots});

  @override
  Widget build(BuildContext context) {
    if (spots.isEmpty) {
      return const Center(child: Text('No data'));
    }
    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppColors.yellow,
            barWidth: 2,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(show: false),
          ),
        ],
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
      ),
    );
  }
}