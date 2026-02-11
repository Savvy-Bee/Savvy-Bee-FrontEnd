import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/features/dashboard/domain/models/dashboard_data.dart';

class CustomPieChart extends StatelessWidget {
  final List<CategoryAmount> categories;

  const CustomPieChart({super.key, required this.categories});

  Color _getColorForCategory(String name) {
    switch (name.toLowerCase()) {
      case 'groceries':
        return AppColors.purple;
      case 'auto & transport':
        return AppColors.error;
      case 'electricity':
        return AppColors.yellow;
      case 'other':
        return AppColors.green;
      default:
        return AppColors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = categories.where((cat) => cat.amount > 0).toList();
    if (filtered.isEmpty) {
      return const Center(child: Text('No data'));
    }
    double total = filtered.fold(0, (sum, cat) => sum + cat.amount);

    return PieChart(
      PieChartData(
        sections: filtered.map((cat) {
          return PieChartSectionData(
            value: cat.amount,
            color: _getColorForCategory(cat.name),
            title: '',
            radius: 50,
            titleStyle: const TextStyle(fontSize: 12, color: AppColors.white),
          );
        }).toList(),
        centerSpaceRadius: 40,
        sectionsSpace: 0,
      ),
    );
  }
}