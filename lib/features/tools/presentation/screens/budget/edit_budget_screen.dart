import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';
import 'package:savvy_bee_mobile/core/utils/number_formatter.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';
import 'package:savvy_bee_mobile/core/widgets/outlined_card.dart';
import 'package:savvy_bee_mobile/core/widgets/section_title_widget.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/screens/budget/set_income_screen.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/assets/app_icons.dart';
import '../../widgets/insight_card.dart';

class EditBudgetScreen extends ConsumerStatefulWidget {
  static String path = '/edit-budget';

  const EditBudgetScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EditBudgetScreenState();
}

class _EditBudgetScreenState extends ConsumerState<EditBudgetScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Budgets')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            spacing: 8,
            children: List.generate(
              3,
              (index) => Expanded(
                child: OutlinedCard(
                  borderColor: index == 2 ? AppColors.primary : null,
                  bgColor: index == 2 ? AppColors.primaryFaint : null,
                  borderRadius: 8,
                  child: Center(child: Text('Aug')),
                ),
              ),
            ),
          ),
          const Gap(24),
          InsightCard(
            insightType: InsightType.nextBestAction,
            text:
                "You've spent 15% more on transport this month. Try adjusting your allocation.",
          ),
          const Gap(28),
          _buildBudgetBasicsCard(),
          const Gap(28),
          SectionTitleWidget(title: 'Category limits'),
          const Gap(8),
          _buildCategoryItem('Dining & drinks', 0, 50000, AppIcons.editIcon),
          const Gap(8),
          _buildCategoryItem('Auto & transport', 0, 40000, AppIcons.editIcon),
          const Gap(8),
          _buildCategoryItem('Everything else', 0, 510000, AppIcons.infoIcon),
          const Gap(28),
          CustomOutlinedButton(text: 'Add category', onPressed: () {}),
          const Gap(8),
          CustomElevatedButton(
            text: 'Save',
            onPressed: () => context.pushNamed(SetIncomeScreen.path),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(
    String title,
    double amountSpent,
    double amount,
    String iconPath,
  ) {
    return OutlinedCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.circle),
              const Gap(16),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: Constants.neulisNeueFontFamily,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '${NumberFormatter.formatCurrency(amount, decimalDigits: 0)} last month',
                    style: TextStyle(
                      fontFamily: Constants.neulisNeueFontFamily,
                      fontSize: 8,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                NumberFormatter.formatCurrency(amount, decimalDigits: 0),
                style: TextStyle(
                  fontFamily: Constants.neulisNeueFontFamily,
                  fontSize: 16,
                ),
              ),
              const Gap(16),
              InkWell(onTap: () {}, child: AppIcon(AppIcons.editIcon)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetBasicsCard() {
    return OutlinedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Budget Basics',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontFamily: Constants.neulisNeueFontFamily,
            ),
          ),
          const Gap(24),
          _buildBudgetBasicsItem('Monthly income', 1000000, AppIcons.editIcon),
          const Gap(16),
          _buildBudgetBasicsItem('Monthly budget', 600000, AppIcons.editIcon),
          const Divider(height: 48),
          _buildBudgetBasicsItem('Monthly income', 400000, AppIcons.editIcon),
        ],
      ),
    );
  }

  Widget _buildBudgetBasicsItem(String title, double amount, String iconPath) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(fontSize: 16)),
        Text(
          NumberFormatter.formatCurrency(amount, decimalDigits: 0),
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        InkWell(onTap: () {}, child: AppIcon(iconPath)),
      ],
    );
  }
}
