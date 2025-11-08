import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';
import 'package:savvy_bee_mobile/core/utils/number_formatter.dart';
import 'package:savvy_bee_mobile/core/widgets/outlined_card.dart';

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

    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Debt')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildDebtCard(800000),
              TabBar(
                controller: _tabController,
                dividerColor: Colors.transparent,
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: const [
                  Tab(text: 'Active'),
                  Tab(text: 'Paid off'),
                ],
              ),
              // Constrain the TabBarView height to its content
              SizedBox(
                height: 300, // Adjust as needed or calculate dynamically
                child: TabBarView(
                  controller: _tabController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    ListView.separated(
                      padding: const EdgeInsets.only(top: 24),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return const GoalStatsCard(
                          title: 'Student loan',
                          amountSaved: 800000,
                          totalTarget: 1200000,
                          daysLeft: 90,
                          isDebt: true,
                        );
                      },
                      separatorBuilder: (context, index) => const Gap(16),
                      itemCount: 1,
                    ),
                    const Center(child: Text('Paid off')),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.pushNamed(AddDebtScreen.path),
        backgroundColor: AppColors.buttonPrimary,
        foregroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(50),
        ),
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildDebtCard(double amountRemaining) {
    return OutlinedCard(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DEBTS',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 12,
              fontFamily: Constants.neulisNeueFontFamily,
            ),
          ),
          const Gap(8),
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
            'Last updated 49 sec ago',
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
