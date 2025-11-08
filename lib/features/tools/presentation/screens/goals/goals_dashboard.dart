import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/assets/assets.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';
import 'package:savvy_bee_mobile/core/widgets/outlined_card.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/screens/goals/create_goal_screen.dart';

class GoalsDashboard extends ConsumerStatefulWidget {
  static String path = '/goals-dashboard';

  const GoalsDashboard({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _GoalsDashboardState();
}

class _GoalsDashboardState extends ConsumerState<GoalsDashboard>
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
                      return _buildGoalCard();
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

  Widget _buildGoalCard() {
    Widget buildStatItem(String title, String value) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              fontFamily: Constants.neulisNeueFontFamily,
            ),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
          ),
        ],
      );
    }

    return OutlinedCard(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(Assets.honeyJarSvg),
          const Gap(24),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Save for emergency fund',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: Constants.neulisNeueFontFamily,
                  ),
                ),
                const Gap(8),
                Row(
                  spacing: 24,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    buildStatItem('₦800k', 'Saved'),
                    buildStatItem('₦1.2M', 'Total Target'),
                    buildStatItem('90', 'Days Left'),
                  ],
                ),
                const Gap(8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: 0.67,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const Gap(4),
                    Text(
                      '67%',
                      style: TextStyle(
                        fontSize: 8,
                        fontFamily: Constants.neulisNeueFontFamily,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
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
