import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/num_extensions.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/providers/budget_provider.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/providers/goals_provider.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/screens/goals/goal_finalyzing_screen.dart';

// ============================================================================
// Step 3: Goal Recommendations / Savings Plan
// ============================================================================

class GoalRecommendationsScreen extends ConsumerStatefulWidget {
  static const String path = '/goal-recommendations';
  final Map<String, dynamic> goalData;

  const GoalRecommendationsScreen({super.key, required this.goalData});

  @override
  ConsumerState<GoalRecommendationsScreen> createState() =>
      _GoalRecommendationsScreenState();
}

class _GoalRecommendationsScreenState
    extends ConsumerState<GoalRecommendationsScreen> {
  double _monthlySavings = 0;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Initialize savings amount after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeSavings();
    });
  }

  void _initializeSavings() {
    final budgetState = ref.read(budgetHomeNotifierProvider);

    budgetState.whenData((data) {
      if (!_isInitialized) {
        setState(() {
          // Set default to 50% of monthly income
          _monthlySavings = (data.totalEarnings * 0.5);
          _isInitialized = true;
        });
      }
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: () => context.go('/goals'),
          ),
        ],
      ),
      body: budgetState.when(
        data: (budgetData) {
          final monthlyIncome = budgetData.totalEarnings.toDouble();

          // Initialize if not already done
          if (!_isInitialized && monthlyIncome > 0) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() {
                _monthlySavings = monthlyIncome * 0.5;
                _isInitialized = true;
              });
            });
          }

          final targetAmount = widget.goalData['amount'] as double;
          final percentage = monthlyIncome > 0
              ? (_monthlySavings / monthlyIncome * 100).round()
              : 0;

          // Calculate months to reach goal
          final monthsToGoal = _monthlySavings > 0
              ? (targetAmount / _monthlySavings).ceil()
              : 0;
          final targetDate = DateTime.now().add(
            Duration(days: monthsToGoal * 30),
          );
          final formattedDate =
              '${_getMonthName(targetDate.month)} ${targetDate.year}';

          return Column(
            children: [
              // Progress bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const Gap(4),
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(32),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    // Title
                    const Text(
                      'How much do you want to save each month?',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'GeneralSans',
                        height: 1.2,
                        color: Colors.black,
                      ),
                    ),
                    const Gap(12),

                    // Subtitle
                    const Text(
                      'Setting the right goal target is very important.',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'GeneralSans',
                        color: Colors.black87,
                      ),
                    ),
                    const Gap(32),

                    // Savings Plan Card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Savings Plan',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'GeneralSans',
                              color: Colors.black87,
                            ),
                          ),
                          const Gap(24),

                          // Amount with slider
                          Center(
                            child: Column(
                              children: [
                                Text(
                                  '${_monthlySavings.toDouble().formatCurrency(decimalDigits: 0)} / month',
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'GeneralSans',
                                  ),
                                ),
                                const Gap(4),
                                Text(
                                  '$percentage% of your income',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontFamily: 'GeneralSans',
                                    color: AppColors.yellow.withOpacity(0.8),
                                  ),
                                ),
                                const Gap(16),

                                // Slider
                                SliderTheme(
                                  data: SliderThemeData(
                                    activeTrackColor: AppColors.yellow,
                                    inactiveTrackColor: Colors.grey.shade300,
                                    thumbColor: AppColors.yellow,
                                    overlayColor: AppColors.yellow.withOpacity(
                                      0.2,
                                    ),
                                    trackHeight: 4,
                                  ),
                                  child: Slider(
                                    value: _monthlySavings.clamp(
                                      0,
                                      monthlyIncome,
                                    ),
                                    min: 0,
                                    max: monthlyIncome > 0
                                        ? monthlyIncome
                                        : 1000000,
                                    divisions: monthlyIncome > 10000
                                        ? (monthlyIncome / 10000).toInt()
                                        : 100,
                                    onChanged: (value) {
                                      setState(() {
                                        _monthlySavings = value;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Gap(24),

                          // Info section
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    const Text(
                                      'Based on your monthly income of',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontFamily: 'GeneralSans',
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const Gap(4),
                                    Text(
                                      monthlyIncome.toDouble().formatCurrency(
                                        decimalDigits: 0,
                                      ),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'GeneralSans',
                                      ),
                                    ),
                                  ],
                                ),
                                const Gap(12),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      size: 16,
                                      color: Colors.grey.shade600,
                                    ),
                                    const Gap(8),
                                    Text(
                                      "You'll reach your goal $formattedDate",
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontFamily: 'GeneralSans',
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Continue Button
              Padding(
                padding: const EdgeInsets.all(24),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _monthlySavings > 0
                        ? () {
                            final dataToPass = {
                              ...widget.goalData,
                              'monthlySavings': _monthlySavings,
                              'monthlyIncome': monthlyIncome,
                            };

                            print('📊 Passing data to finalizing screen:');
                            print('  - goalType: ${dataToPass['goalType']}');
                            print('  - amount: ${dataToPass['amount']}');
                            print(
                              '  - monthlySavings: ${dataToPass['monthlySavings']}',
                            );
                            print(
                              '  - monthlyIncome: ${dataToPass['monthlyIncome']}',
                            );

                            // ✅ FIXED: Use context.push instead of context.pushReplacementNamed
                            try {
                              context.push(
                                GoalFinalizingScreen.path,
                                extra: dataToPass,
                              );
                            } catch (e) {
                              print('❌ Navigation error: $e');
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Navigation failed: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _monthlySavings > 0
                          ? Colors.black
                          : Colors.grey.shade300,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'GeneralSans',
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const Gap(16),
              const Text(
                'Unable to load budget data',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'GeneralSans',
                ),
              ),
              const Gap(8),
              Text(
                'Please set up your budget first',
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'GeneralSans',
                  color: Colors.grey.shade600,
                ),
              ),
              const Gap(24),
              ElevatedButton(
                onPressed: () => context.go('/budgets'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: const Text(
                  'Set Up Budget',
                  style: TextStyle(
                    fontFamily: 'GeneralSans',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month];
  }
}
