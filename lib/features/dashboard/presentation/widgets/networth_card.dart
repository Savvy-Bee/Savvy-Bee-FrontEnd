import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';
import 'package:savvy_bee_mobile/core/widgets/outlined_card.dart';
import 'package:savvy_bee_mobile/features/dashboard/domain/models/dashboard_data.dart';
import 'package:savvy_bee_mobile/features/dashboard/presentation/providers/dashboard_data_provider.dart';
import 'package:savvy_bee_mobile/features/dashboard/presentation/screens/dashboard_screen.dart';

import '../../../../core/utils/number_formatter.dart';
import '../../../../core/widgets/charts/custom_line_chart.dart';

class NetWorthCard extends ConsumerWidget {
  final VoidCallback? onTap;
  final String bankId;

  const NetWorthCard({
    super.key, 
    this.onTap,
    required this.bankId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardDataProvider(bankId));
    final selectedRange = ref.watch(selectedTimeRangeProvider);

    return OutlinedCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      hasShadow: true,
      child: dashboardAsync.when(
        data: (dashboardData) => _buildContent(
          context: context,
          ref: ref,
          dashboardData: dashboardData,
          selectedRange: selectedRange,
          isLoading: false,
        ),
        loading: () => _buildContent(
          context: context,
          ref: ref,
          dashboardData: null,
          selectedRange: selectedRange,
          isLoading: true,
        ),
        error: (error, stack) => _buildContent(
          context: context,
          ref: ref,
          dashboardData: null,
          selectedRange: selectedRange,
          isLoading: false,
          hasError: true,
        ),
      ),
    );
  }

  Widget _buildContent({
    required BuildContext context,
    required WidgetRef ref,
    required DashboardData? dashboardData,
    required String selectedRange,
    required bool isLoading,
    bool hasError = false,
  }) {
    // Calculate net worth from dashboard data if available
    final netWorth = dashboardData?.details.balance.toDouble() ?? 0.0;
    
    // Get accounts - for now using the single account from details
    // You may need to adjust this based on your actual data structure
    final accounts = dashboardData != null
        ? [
            BankAccount(
              name: dashboardData.details.institution.name??'',
              icon: '', // TODO: Add appropriate icon based on bank
              balance: dashboardData.details.balance.toDouble(),
              color: AppColors.primary,
            )
          ]
        : <BankAccount>[];

    // Get chart data if available
    final chartData = dashboardData != null 
        ? _extractChartData(dashboardData, selectedRange)
        : <ChartDataPoint>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'TOTAL NET WORTH',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.grey,
                            letterSpacing: 0.5,
                            height: 0,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (isLoading)
                          Container(
                            width: 150,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.grey.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          )
                        else if (hasError)
                          const Text(
                            'Unable to load',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w500,
                              height: 0,
                              color: AppColors.grey,
                            ),
                          )
                        else
                          Text(
                            NumberFormatter.formatCurrency(netWorth),
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w500,
                              height: 0,
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: hasError || isLoading
                        ? null
                        : () => _OptionsBottomSheet.showOptionsBottomSheet(context, ref),
                    icon: const Icon(Icons.more_vert_outlined),
                    constraints: const BoxConstraints(),
                    style: Constants.collapsedButtonStyle,
                  ),
                ],
              ),
              const Gap(10),
              
              // Chart section
              if (isLoading)
                Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              else if (hasError)
                Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Icon(Icons.error_outline, color: AppColors.grey),
                  ),
                )
              else if (chartData.isNotEmpty)
                CustomLineChart(data: chartData)
              else
                Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text(
                      'No chart data available',
                      style: TextStyle(color: AppColors.grey, fontSize: 12),
                    ),
                  ),
                ),
              
              const Gap(32),
              _buildTimeRangeSelector(
                selectedRange: selectedRange,
                onRangeSelected: (range) {
                  ref.read(selectedTimeRangeProvider.notifier).state = range;
                },
                isDisabled: isLoading || hasError,
              ),
              const Gap(20),
            ],
          ),
        ),
        
        // Accounts section
        if (!isLoading && !hasError && accounts.isNotEmpty) ...[
          const Divider(height: 0),
          ...accounts.indexed.expand((item) {
            final index = item.$1;
            final account = item.$2;
            final isLast = index == accounts.length - 1;
            return [
              _buildBankListTile(account),
              if (!isLast) const Divider(height: 0),
            ];
          }),
        ] else if (isLoading) ...[
          const Divider(height: 0),
          _buildLoadingListTile(),
        ],
      ],
    );
  }

  /// Extract chart data from dashboard history based on selected time range
  List<ChartDataPoint> _extractChartData(DashboardData data, String range) {
    // If no history data, return empty list
    if (data.history12Months == null) return [];
    
    try {
      // Assuming history12Months is a Map<String, dynamic> with month keys
      // Example: {"Jan": 50000, "Feb": 55000, "Mar": 60000, ...}
      final Map<String, dynamic> historyMap = data.history12Months is Map
          ? Map<String, dynamic>.from(data.history12Months)
          : {};
      
      if (historyMap.isEmpty) return [];
      
      // Convert map entries to list of chart points
      final allPoints = historyMap.entries.map((entry) {
        final value = entry.value is num 
            ? (entry.value as num).toDouble() 
            : 0.0;
        return ChartDataPoint(entry.key, value);
      }).toList();
      
      // Filter based on selected range
      return _filterDataByRange(allPoints, range);
    } catch (e) {
      // If parsing fails, return empty list
      return [];
    }
  }

  /// Filter chart data points based on selected time range
  List<ChartDataPoint> _filterDataByRange(
    List<ChartDataPoint> points,
    String range,
  ) {
    if (points.isEmpty) return points;
    
    // Define how many data points to show for each range
    final int pointsToShow;
    switch (range) {
      case '3D':
        pointsToShow = 3;
        break;
      case '1W':
        pointsToShow = 4; // Weekly view - show 4 weeks
        break;
      case '1M':
        pointsToShow = 1;
        break;
      case '3M':
        pointsToShow = 3;
        break;
      case '6M':
        pointsToShow = 6;
        break;
      case '1Y':
      default:
        pointsToShow = 12;
        break;
    }
    
    // Return the last N points (most recent)
    if (points.length <= pointsToShow) {
      return points;
    }
    
    return points.sublist(points.length - pointsToShow);
  }

  Widget _buildTimeRangeSelector({
    required String selectedRange,
    required Function(String) onRangeSelected,
    bool isDisabled = false,
  }) {
    final ranges = ['3D', '1W', '1M', '3M', '6M', '1Y'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: ranges.map((range) {
        final isSelected = range == selectedRange;
        return GestureDetector(
          onTap: isDisabled ? null : () => onRangeSelected(range),
          child: Opacity(
            opacity: isDisabled ? 0.5 : 1.0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryFaint,
                borderRadius: BorderRadius.circular(20),
                border: isSelected ? Border.all(color: AppColors.primary) : null,
              ),
              child: Text(
                range,
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBankListTile(BankAccount account) {
    return ListTile(
      leading: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(color: account.color, shape: BoxShape.circle),
      ),
      title: Text(
        account.name,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            NumberFormatter.formatCurrency(account.balance),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const Gap(5.0),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert, size: 16),
            constraints: const BoxConstraints(),
            style: Constants.collapsedButtonStyle,
          ),
        ],
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12.0),
      horizontalTitleGap: 0,
      dense: true,
    );
  }

  Widget _buildLoadingListTile() {
    return ListTile(
      leading: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: AppColors.grey.withOpacity(0.3),
          shape: BoxShape.circle,
        ),
      ),
      title: Container(
        width: 100,
        height: 14,
        decoration: BoxDecoration(
          color: AppColors.grey.withOpacity(0.2),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      trailing: Container(
        width: 80,
        height: 14,
        decoration: BoxDecoration(
          color: AppColors.grey.withOpacity(0.2),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12.0),
      horizontalTitleGap: 0,
      dense: true,
    );
  }
}

class _OptionsBottomSheet extends ConsumerWidget {
  const _OptionsBottomSheet();

  static void showOptionsBottomSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _OptionsBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               Text(
                'OPTIONS',
                style: TextStyle(fontFamily: Constants.neulisNeueFontFamily),
              ),
              IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.close),
                constraints: const BoxConstraints(),
                style: Constants.collapsedButtonStyle,
              ),
            ],
          ),
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildOptionsTile(
                title: 'Refresh',
                icon: Icons.refresh,
                onTap: () {
                  ref.invalidate(dashboardDataProvider);
                  context.pop();
                },
              ),
              _buildOptionsTile(
                title: 'View Details',
                icon: Icons.visibility_outlined,
                onTap: () => context.pop(),
              ),
              _buildOptionsTile(
                title: 'Export Data',
                icon: Icons.download_outlined,
                onTap: () => context.pop(),
              ),
              _buildOptionsTile(
                title: 'Settings',
                icon: Icons.settings_outlined,
                onTap: () => context.pop(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOptionsTile({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontSize: 16)),
      leading: Icon(icon, size: 20),
      onTap: onTap,
      dense: true,
      horizontalTitleGap: 5,
      minVerticalPadding: 0,
      visualDensity: VisualDensity.compact,
      contentPadding: EdgeInsets.zero,
    );
  }
}