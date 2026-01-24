import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_card.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/num_extensions.dart';
import '../../../../core/widgets/charts/custom_line_chart.dart';
import '../../domain/models/dashboard_data.dart';

class NetWorthCard extends StatelessWidget {
  final DashboardData dashboardData;

  const NetWorthCard({super.key, required this.dashboardData});

  @override
  Widget build(BuildContext context) {
    final balance = dashboardData.netAnalysis.totalBalance;

    return CustomCard(
      hasShadow: true,
      width: double.maxFinite,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Text(
                      'Total Net Worth',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const Gap(8),
                    Text(
                      balance.toDouble().formatCurrency(),
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => _OptionsBottomSheet.show(context),
                  icon: Icon(Icons.more_vert, size: 20),
                  style: Constants.collapsedButtonStyle,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: CustomLineChart(
              data: dashboardData.getAggregatedAccountData(),
              primaryColor: AppColors.primary,
              enableValueIndicator: true,
            ),
          ),
          if (dashboardData.accounts.isNotEmpty)
            const Divider(height: 8, color: AppColors.borderLight),
          ...dashboardData.accounts.map(
            (e) => _buildBankListTile(
              bankName: e.details.name,
              balance: e.details.balance.toDouble().formatCurrency(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankListTile({
    required String bankName,
    required String balance,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                spacing: 8,
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Text(
                    bankName,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    balance,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),

                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.more_vert, size: 20),
                    style: Constants.collapsedButtonStyle,
                  ),
                ],
              ),
            ],
          ),
        ),
        if (showDivider) const Divider(height: 0, color: AppColors.borderLight),
      ],
    );
  }
}

class _OptionsBottomSheet extends StatelessWidget {
  const _OptionsBottomSheet();

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      builder: (context) => _OptionsBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('OPTIONS'),
              IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.close),
                constraints: BoxConstraints(),
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
      title: Text(title, style: TextStyle(fontSize: 16)),
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
