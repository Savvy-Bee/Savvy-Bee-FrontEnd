import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:gap/gap.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/extensions.dart';
import 'package:savvy_bee_mobile/core/widgets/charts/custom_line_chart.dart';
import 'package:savvy_bee_mobile/features/dashboard/domain/models/dashboard_data.dart';

class NetWorthCard extends StatelessWidget {
  final DashboardData dashboardData;

  const NetWorthCard({super.key, required this.dashboardData});

  @override
  Widget build(BuildContext context) {
    final chartData = dashboardData.getAggregatedAccountData();
    final hasData = chartData.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Net Worth',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  fontFamily: 'GeneralSans',
                  letterSpacing: 14 * 0.02,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.trending_up,
                      size: 14,
                      color: AppColors.success,
                    ),
                    const Gap(4),
                    Text(
                      '₦${dashboardData.netAnalysis.totalBalance.toStringAsFixed(2)} below last month',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.success,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'GeneralSans',
                        letterSpacing: 11 * 0.02,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Gap(8),
          Text(
            context.currencyFormat(dashboardData.netAnalysis.totalBalance),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              fontFamily: 'GeneralSans',
              letterSpacing: 32 * 0.02,
            ),
          ),
          const Gap(20),

          // Chart
          if (hasData) ...[
            SizedBox(
              height: 120,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 200000,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: AppColors.greyLight.withOpacity(0.3),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 50,
                        interval: 300000,
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Text(
                              '₦${(value / 1000).toStringAsFixed(0)}k',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 10,
                                fontFamily: 'GeneralSans',
                                letterSpacing: 10 * 0.02,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: chartData.length.toDouble() - 1,
                  minY: 0,
                  maxY: 1200000,
                  lineBarsData: [
                    LineChartBarData(
                      spots: _buildSpots(chartData),
                      isCurved: true,
                      color: AppColors.primary,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.primary.withOpacity(0.1),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    enabled: true,
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          return LineTooltipItem(
                            context.currencyFormat(spot.y),
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              fontFamily: 'GeneralSans',
                              letterSpacing: 12 * 0.02,
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
            const Gap(12),
            GestureDetector(
              onTap: () {
                // Navigate to detailed net worth view
              },
              child: Row(
                children: [
                  const Icon(
                    Icons.show_chart,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                  const Gap(8),
                  const Text(
                    'View Net Worth',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'GeneralSans',
                      letterSpacing: 14 * 0.02,
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.chevron_right,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ] else ...[
            Container(
              height: 120,
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.show_chart,
                    size: 40,
                    color: AppColors.grey.withOpacity(0.3),
                  ),
                  const Gap(8),
                  const Text(
                    'Not enough data for chart',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontFamily: 'GeneralSans',
                      letterSpacing: 12 * 0.02,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<FlSpot> _buildSpots(List<ChartDataPoint> data) {
    // Sample and reduce data points for smoother chart
    if (data.isEmpty) return [];

    final maxPoints = 50; // Limit points for performance
    final interval = (data.length / maxPoints).ceil();

    final sampledData = <ChartDataPoint>[];
    for (int i = 0; i < data.length; i += interval) {
      sampledData.add(data[i]);
    }

    return sampledData.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.value);
    }).toList();
  }
}

// import 'package:flutter/material.dart';
// import 'package:gap/gap.dart';
// import 'package:go_router/go_router.dart';
// import 'package:savvy_bee_mobile/core/utils/constants.dart';
// import 'package:savvy_bee_mobile/core/widgets/custom_card.dart';

// import '../../../../core/theme/app_colors.dart';
// import '../../../../core/utils/num_extensions.dart';
// import '../../../../core/widgets/charts/custom_line_chart.dart';
// import '../../domain/models/dashboard_data.dart';

// class NetWorthCard extends StatelessWidget {
//   final DashboardData dashboardData;

//   const NetWorthCard({super.key, required this.dashboardData});

//   @override
//   Widget build(BuildContext context) {
//     final balance = dashboardData.netAnalysis.totalBalance;

//     return CustomCard(
//       hasShadow: true,
//       width: double.maxFinite,
//       padding: EdgeInsets.zero,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Padding(
//             padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Column(
//                   children: [
//                     Text(
//                       'Total Net Worth',
//                       style: TextStyle(fontSize: 14, color: Colors.grey[600]),
//                     ),
//                     const Gap(8),
//                     Text(
//                       balance.toDouble().formatCurrency(),
//                       style: TextStyle(
//                         fontSize: 32,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//                 IconButton(
//                   onPressed: () => _OptionsBottomSheet.show(context),
//                   icon: Icon(Icons.more_vert, size: 20),
//                   style: Constants.collapsedButtonStyle,
//                 ),
//               ],
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(20),
//             child: CustomLineChart(
//               data: dashboardData.getAggregatedAccountData(),
//               primaryColor: AppColors.primary,
//               enableValueIndicator: true,
//             ),
//           ),
//           if (dashboardData.accounts.isNotEmpty)
//             const Divider(height: 8, color: AppColors.borderLight),
//           ...dashboardData.accounts.map(
//             (e) => _buildBankListTile(
//               bankName: e.details.name,
//               balance: e.details.balance.toDouble().formatCurrency(),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildBankListTile({
//     required String bankName,
//     required String balance,
//     bool showDivider = true,
//   }) {
//     return Column(
//       children: [
//         Padding(
//           padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Row(
//                 spacing: 8,
//                 children: [
//                   Container(
//                     width: 16,
//                     height: 16,
//                     decoration: BoxDecoration(
//                       color: AppColors.primary,
//                       shape: BoxShape.circle,
//                     ),
//                   ),
//                   Text(
//                     bankName,
//                     style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
//                   ),
//                 ],
//               ),
//               Row(
//                 children: [
//                   Text(
//                     balance,
//                     style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
//                   ),

//                   IconButton(
//                     onPressed: () {},
//                     icon: Icon(Icons.more_vert, size: 20),
//                     style: Constants.collapsedButtonStyle,
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//         if (showDivider) const Divider(height: 0, color: AppColors.borderLight),
//       ],
//     );
//   }
// }

// class _OptionsBottomSheet extends StatelessWidget {
//   const _OptionsBottomSheet();

//   static void show(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       useRootNavigator: true,
//       builder: (context) => _OptionsBottomSheet(),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text('OPTIONS'),
//               IconButton(
//                 onPressed: () => context.pop(),
//                 icon: const Icon(Icons.close),
//                 constraints: BoxConstraints(),
//                 style: Constants.collapsedButtonStyle,
//               ),
//             ],
//           ),
//         ),
//         const Divider(),
//         Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             children: [
//               _buildOptionsTile(
//                 title: 'Refresh',
//                 icon: Icons.refresh,
//                 onTap: () => context.pop(),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildOptionsTile({
//     required String title,
//     required IconData icon,
//     required VoidCallback onTap,
//   }) {
//     return ListTile(
//       title: Text(title, style: TextStyle(fontSize: 16)),
//       leading: Icon(icon, size: 20),
//       onTap: onTap,
//       dense: true,
//       horizontalTitleGap: 5,
//       minVerticalPadding: 0,
//       visualDensity: VisualDensity.compact,
//       contentPadding: EdgeInsets.zero,
//     );
//   }
// }
