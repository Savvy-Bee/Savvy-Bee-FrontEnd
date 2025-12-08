import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_card.dart';

import '../../../../core/utils/num_extensions.dart';
import '../../domain/models/dashboard_data.dart';

class NetWorthCard extends StatelessWidget {
  final DashboardData dashboardData;

  const NetWorthCard({super.key, required this.dashboardData});

  @override
  Widget build(BuildContext context) {
    final balance = dashboardData.details.balance;

    return CustomCard(
      hasShadow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
              fontFamily: Constants.neulisNeueFontFamily,
            ),
          ),
          const Gap(8),
          Text(
            dashboardData.details.institution.name ?? 'Bank Account',
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}

class _OptionsBottomSheet extends StatelessWidget {
  const _OptionsBottomSheet();

  static void showOptionsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
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
              Text(
                'OPTIONS',
                style: TextStyle(fontFamily: Constants.neulisNeueFontFamily),
              ),
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
              _buildOptionsTile(
                title: 'Refresh',
                icon: Icons.refresh,
                onTap: () => context.pop(),
              ),
              _buildOptionsTile(
                title: 'Refresh',
                icon: Icons.refresh,
                onTap: () => context.pop(),
              ),
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
