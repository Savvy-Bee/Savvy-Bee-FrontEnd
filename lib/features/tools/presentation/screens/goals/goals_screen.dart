import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';
import 'package:savvy_bee_mobile/core/widgets/outlined_card.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/screens/goals/create_goal_screen.dart';

import '../../widgets/goal_stats_card.dart';

class GoalsScreen extends ConsumerStatefulWidget {
  static String path = '/goals';

  const GoalsScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends ConsumerState<GoalsScreen>
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
      appBar: AppBar(title: Text('Goals')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        // child: _buildEmptyStateWidget(context),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TabBar(
              controller: _tabController,
              dividerColor: Colors.transparent,
              indicatorSize: TabBarIndicatorSize.tab,
              // labelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              tabs: [
                Tab(text: 'Active'),
                Tab(text: 'Completed'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  ListView.separated(
                    padding: const EdgeInsets.only(top: 24),
                    itemBuilder: (context, index) {
                      return GoalStatsCard(
                        title: 'Save for emergency fund',
                        amountSaved: 800000,
                        totalTarget: 1200000,
                        daysLeft: 90,
                      );
                    },
                    separatorBuilder: (context, index) => const Gap(16),
                    itemCount: 1,
                  ),
                  Text('Completed'),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.buttonPrimary,
        foregroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(50),
        ),
        child: Icon(Icons.add),
      ),
    
    );
  }

  Widget _buildEmptyStateWidget(BuildContext context) {
    return OutlinedCard(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Define what financial success means to you.',
              style: TextStyle(fontSize: 12),
            ),
            const Gap(24),
            CustomElevatedButton(
              text: 'Create a goal',
              isSmall: true,
              isFullWidth: false,
              buttonColor: CustomButtonColor.black,
              onPressed: () => context.pushNamed(CreateGoalScreen.path),
            ),
          ],
        ),
      ),
    );
  }
}
