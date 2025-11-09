import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';
import 'package:savvy_bee_mobile/core/widgets/outlined_card.dart';
import 'package:savvy_bee_mobile/features/dashboard/presentation/screens/dashboard_screen.dart';

import '../../../../core/utils/number_formatter.dart';
import '../../../../core/widgets/charts/custom_line_chart.dart';

class NetWorthCard extends ConsumerWidget {
  final VoidCallback? onTap;

  const NetWorthCard({super.key, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final netWorth = ref.watch(totalNetWorthProvider);
    final accounts = ref.watch(bankAccountsProvider);
    final chartData = ref.watch(chartDataProvider);
    final selectedRange = ref.watch(selectedTimeRangeProvider);

    return OutlinedCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      hasShadow: true,
      child: Column(
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
                    Column(
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
                    IconButton(
                      onPressed: () =>
                          _OptionsBottomSheet.showOptionsBottomSheet(context),
                      icon: const Icon(Icons.more_vert_outlined),
                      constraints: BoxConstraints(),
                      style: Constants.collapsedButtonStyle,
                    ),
                  ],
                ),

                const Gap(10),
                CustomLineChart(data: chartData),
                const Gap(32),
                _buildTimeRangeSelector(
                  selectedRange: selectedRange,
                  onRangeSelected: (range) {
                    ref.read(selectedTimeRangeProvider.notifier).state = range;
                  },
                ),
                const Gap(20),
              ],
            ),
          ),
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
        ],
      ),
    );
  }

  Widget _buildTimeRangeSelector({
    required String selectedRange,
    required Function(String) onRangeSelected,
  }) {
    final ranges = ['3D', '1W', '1M', '3M', '6M', '1Y'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: ranges.map((range) {
        final isSelected = range == selectedRange;
        return GestureDetector(
          onTap: () => onRangeSelected(range),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryFaint,
              borderRadius: BorderRadius.circular(20),
              border: isSelected ? Border.all(color: AppColors.primary) : null,
            ),
            child: Text(
              range,
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
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
            // '₦${account.balance.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const Gap(5.0),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.more_vert, size: 16),
            constraints: BoxConstraints(),
            style: Constants.collapsedButtonStyle,
          ),
        ],
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
      horizontalTitleGap: 0,
      dense: true,
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
