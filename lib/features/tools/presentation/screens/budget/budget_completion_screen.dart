import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/num_extensions.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/providers/budget_provider.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/screens/budget/edit_budget_screen.dart';

class BudgetCompletionScreen extends ConsumerStatefulWidget {
  static const String path = '/budget-completion';

  const BudgetCompletionScreen({super.key});

  @override
  ConsumerState<BudgetCompletionScreen> createState() =>
      _BudgetCompletionScreenState();
}

class _BudgetCompletionScreenState
    extends ConsumerState<BudgetCompletionScreen> {
  @override
  void initState() {
    super.initState();
    // Force refresh data when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(budgetHomeNotifierProvider.notifier).fetchBudgetHomeData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final budgetState = ref.watch(budgetHomeNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Set monthly budget',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            fontFamily: 'GeneralSans',
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
      ),
      body: budgetState.when(
        data: (data) {
          print('📊 Budget Completion Screen Data:');
          print('  Total Earnings: ${data.totalEarnings}');
          print('  Budgets Count: ${data.budgets.length}');
          for (final budget in data.budgets) {
            print('  - ${budget.budgetName}: ${budget.targetAmountMonthly}');
          }

          final monthlyIncome = data.totalEarnings;
          final totalBudget = data.budgets.fold<num>(
            0,
            (prev, budget) => prev + budget.targetAmountMonthly,
          );
          final monthlySavings = monthlyIncome - totalBudget;

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                const Text(
                  "Perfect. You're all set",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'GeneralSans',
                    height: 1.2,
                    color: Colors.black,
                  ),
                ),
                const Gap(14),

                // Subtitle
                const Text(
                  "You'll see how much you have to budget for your needs and wants. Don't spend it all in one place!",
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'GeneralSans',
                    height: 1.4,
                    color: Colors.black87,
                  ),
                ),
                const Gap(40),

                // Summary Cards
                _buildSummaryCard(
                  icon: Icons.account_balance_wallet_outlined,
                  label: 'Monthly Income',
                  amount: monthlyIncome,
                ),
                const Gap(16),

                _buildSummaryCard(
                  icon: Icons.calculate_outlined,
                  label: 'Monthly Budget',
                  amount: totalBudget,
                ),
                const Gap(16),

                _buildSummaryCard(
                  icon: Icons.savings_outlined,
                  label: 'Monthly Savings',
                  amount: monthlySavings,
                  isHighlighted: true,
                ),

                const Spacer(),

                // Set up budget categories button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      context.pushReplacementNamed(EditBudgetScreen.path);
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.black),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Set up budget categories',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'GeneralSans',
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                const Gap(16),

                // Done button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      context.goNamed('/budgets');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Done',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'GeneralSans',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) {
          print('❌ Budget Completion Error: $error');
          return Center(child: Text('Error: $error'));
        },
      ),
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required String label,
    required num amount,
    bool isHighlighted = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isHighlighted ? AppColors.yellow.withOpacity(0.1) : Colors.white,
        border: Border.all(
          color: isHighlighted ? AppColors.yellow : Colors.grey.shade300,
          width: isHighlighted ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isHighlighted
                  ? AppColors.yellow.withOpacity(0.2)
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 24,
              color: isHighlighted ? AppColors.yellow : Colors.black,
            ),
          ),
          const Gap(16),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                fontFamily: 'GeneralSans',
                color: Colors.black,
              ),
            ),
          ),
          const Gap(12),
          Flexible(
            child: Text(
              amount.toDouble().formatCurrency(decimalDigits: 2),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                fontFamily: 'GeneralSans',
                color: Colors.black,
              ),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}
