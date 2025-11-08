import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/assets/app_icons.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/screens/budget/edit_budget_screen.dart';

import '../../../../../core/widgets/category_progress_widget.dart';
import '../../widgets/insight_card.dart';

class BudgetScreen extends ConsumerStatefulWidget {
  static String path = '/budget-screen';

  const BudgetScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _BudgetScreenState();
}

class _BudgetScreenState extends ConsumerState<BudgetScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Budgets')),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          CircularProgressIndicator(),
          const Gap(37),
          CustomElevatedButton(
            text: 'Edit budget',
            icon: AppIcon(AppIcons.editIcon),
            onPressed: () => context.pushNamed(EditBudgetScreen.path),
          ),
          const Gap(37),
          InsightCard(
            text: 'You saved 12% more than last month — amazing work!',
            insightType: InsightType.nahlInsight,
          ),
          const Gap(8),
          InsightCard(
            insightType: InsightType.nextBestAction,
            text:
                'Your dining expenses are trending upward. Try setting a ₦10,000 cap next month.',
          ),
          const Gap(16),
          CategoryProgressWidget(
            title: 'Dining & drinks',
            totalAmount: 100000,
            totalSpent: 10000,
            color: AppColors.primary,
          ),
          const Gap(8),
          CategoryProgressWidget(
            title: 'Dining & drinks',
            totalAmount: 100000,
            totalSpent: 10000,
            color: AppColors.success,
          ),
        ],
      ),
    );
  }
}
