import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/utils/assets/illustrations.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';
import 'package:savvy_bee_mobile/core/widgets/section_title_widget.dart';
import 'package:savvy_bee_mobile/features/chat/presentation/screens/chat_screen.dart';
import 'package:savvy_bee_mobile/features/dashboard/presentation/widgets/savings_target_widget.dart';

import '../../../../core/widgets/outlined_card.dart';
import '../../../articles/presentation/widgets/article_bottom_sheet.dart';
import '../widgets/article_card.dart';
import '../widgets/budget_analysis_widget.dart';
import '../widgets/financial_health_widget.dart';
import '../widgets/spending_category_widget.dart';
import '../widgets/info_card.dart';
import '../widgets/networth_card.dart';

// Models
class BankAccount {
  final String name;
  final String icon;
  final double balance;
  final Color color;

  BankAccount({
    required this.name,
    required this.icon,
    required this.balance,
    required this.color,
  });
}

class ExpenseCategory {
  final String name;
  final double amount;
  final Color color;
  final IconData icon;

  ExpenseCategory({
    required this.name,
    required this.amount,
    required this.color,
    required this.icon,
  });
}

class ChartDataPoint {
  final String month;
  final double value;

  ChartDataPoint(this.month, this.value);
}

// Providers
final totalNetWorthProvider = StateProvider<double>((ref) => 63418.78);

final bankAccountsProvider = StateProvider<List<BankAccount>>(
  (ref) => [
    BankAccount(
      name: 'GTBank',
      icon: '🟠',
      balance: 40000.77,
      color: Colors.orange,
    ),
    BankAccount(
      name: 'Kuda',
      icon: '🟣',
      balance: 23418.01,
      color: Colors.purple,
    ),
  ],
);

final expenseCategoriesProvider = StateProvider<List<ExpenseCategory>>(
  (ref) => [
    ExpenseCategory(
      name: 'Auto & transport',
      amount: 40000,
      color: const Color(0xFFFF3B30),
      icon: Icons.directions_car,
    ),
    ExpenseCategory(
      name: 'Auto & transport',
      amount: 40000,
      color: const Color(0xFFE4B5FF),
      icon: Icons.directions_car,
    ),
    ExpenseCategory(
      name: 'Shopping',
      amount: 52000,
      color: const Color(0xFFFFCC00),
      icon: Icons.shopping_bag,
    ),
    ExpenseCategory(
      name: 'Entertainment',
      amount: 60000,
      color: const Color(0xFF8BC34A),
      icon: Icons.movie,
    ),
  ],
);

final chartDataProvider = StateProvider<List<ChartDataPoint>>(
  (ref) => [
    ChartDataPoint('Jan', 45000),
    ChartDataPoint('Feb', 48000),
    ChartDataPoint('Mar', 52000),
    ChartDataPoint('Apr', 50000),
    ChartDataPoint('May', 56000),
    ChartDataPoint('Jun', 63418.78),
  ],
);

final selectedTimeRangeProvider = StateProvider<String>((ref) => '1M');

// Main Dashboard Screen
class DashboardScreen extends ConsumerStatefulWidget {
  static const String path = '/dashboard';

  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Gap(20),
                NetWorthCard(),
                const Gap(16),
                InfoCard(
                  title: 'Smart Recommendation',
                  description:
                      'Your expenses are high, consider a budget review this week.',
                  avatar: Illustrations.interestBeeAvatar,
                  borderRadius: 32,
                ),
                const Gap(24),
                _buildWidgetsSection(context),
                const Gap(16),
                InfoCard(
                  title: 'Ask Nahl',
                  description:
                      'Get answers to questions on your spending, saving, budgets and cashflow!',
                  avatar: Illustrations.interestBeeAvatar,
                  borderRadius: 32,
                  onTap: () => context.pushNamed(ChatScreen.path),
                ),
                const Divider(height: 40),
                const Gap(10),
                _buildArticlesSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWidgetsSection(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,

      children: [
        SectionTitleWidget(
          title: 'Widgets',
          actionWidget: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.edit_square),
            constraints: BoxConstraints(),
            style: Constants.collapsedIconButtonStyle,
          ),
        ),
        const Gap(16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 16,
            children: [
              const SpendingCategoryWidget(),
              const FinancialHealthWidget(),
              const SavingsTargetWidget(),
              // const BudgetAnalysisWidget(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildArticlesSection() {
    return Column(
      mainAxisSize: MainAxisSize.min,

      children: [
        SectionTitleWidget(title: 'The latest'),
        const Gap(24),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            spacing: 12.0,
            children: [
              ArticleCard(
                title: 'Should you save financially with your partner?',
                backgroundColor: Colors.amber,
                imagePath: Illustrations.matchingAndQuizBee,
                subtitle: "Let's get financially literate!",
                onTap: () => ArticleBottomSheet.show(context),
              ),
              ArticleCard(
                title: 'Money lessons from afrobeats',
                backgroundColor: const Color(0xFFB8E986),
                imagePath: Illustrations.loanBee,
                subtitle: 'Are you really listening to what they\'re saying?',
                onTap: () => ArticleBottomSheet.show(context),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
