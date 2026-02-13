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
  final TextEditingController _manualInputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeSavings();
    });
  }

  @override
  void dispose() {
    _manualInputController.dispose();
    super.dispose();
  }

  void _initializeSavings() {
    final budgetState = ref.read(budgetHomeNotifierProvider);

    budgetState.whenData((data) {
      if (!_isInitialized) {
        setState(() {
          // Set default to 30% of monthly income (conservative)
          _monthlySavings = (data.totalEarnings * 0.3);
          _isInitialized = true;
        });
      }
    });
  }

  // Get slider color based on savings percentage
  Color _getSliderColor(double percentage) {
    if (percentage <= 20) {
      return Colors.green; // Safe - Low savings
    } else if (percentage <= 40) {
      return AppColors.yellow; // Moderate - Good savings
    } else if (percentage <= 60) {
      return Colors.orange; // High - Aggressive savings
    } else {
      return Colors.red; // Very high - May be unsustainable
    }
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
          final hasIncome = monthlyIncome > 0;

          // Initialize if not already done
          if (!_isInitialized && monthlyIncome > 0) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() {
                _monthlySavings = monthlyIncome * 0.3;
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

                    // Conditional rendering based on income
                    if (!hasIncome)
                      _buildManualInputCard(targetAmount)
                    else
                      _buildSavingsPlanCard(
                        monthlyIncome,
                        targetAmount,
                        percentage,
                        formattedDate,
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

                            context.push(
                              GoalFinalizingScreen.path,
                              extra: dataToPass,
                            );
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

  // Manual input card for users with no income
  Widget _buildManualInputCard(double targetAmount) {
    return Container(
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
          const Gap(16),

          // Info message
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                const Gap(12),
                Expanded(
                  child: Text(
                    'No monthly income detected. Enter your desired monthly savings manually.',
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'GeneralSans',
                      color: Colors.blue.shade900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Gap(24),

          // Manual input field
          TextFormField(
            controller: _manualInputController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: 'Monthly savings amount',
              hintText: 'Enter amount',
              prefixText: '₦ ',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.black, width: 2),
              ),
            ),
            onChanged: (value) {
              final amount = double.tryParse(value.replaceAll(',', '')) ?? 0;
              setState(() {
                _monthlySavings = amount;
              });
            },
          ),
          const Gap(16),

          if (_monthlySavings > 0)
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
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const Gap(8),
                      Expanded(
                        child: Text(
                          "You'll reach your ${targetAmount.formatCurrency(decimalDigits: 0)} goal in ${(targetAmount / _monthlySavings).ceil()} months",
                          style: const TextStyle(
                            fontSize: 12,
                            fontFamily: 'GeneralSans',
                            color: Colors.black87,
                          ),
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

  // Savings plan card with slider for users with income
  Widget _buildSavingsPlanCard(
    double monthlyIncome,
    double targetAmount,
    int percentage,
    String formattedDate,
  ) {
    final sliderColor = _getSliderColor(percentage.toDouble());

    return Container(
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: sliderColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const Gap(6),
                    Text(
                      '$percentage% of your income',
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'GeneralSans',
                        color: sliderColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const Gap(8),
                Text(
                  _getSavingsAdvice(percentage),
                  style: TextStyle(
                    fontSize: 11,
                    fontFamily: 'GeneralSans',
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Gap(16),

                // Slider
                SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: sliderColor,
                    inactiveTrackColor: Colors.grey.shade300,
                    thumbColor: sliderColor,
                    overlayColor: sliderColor.withOpacity(0.2),
                    trackHeight: 4,
                  ),
                  child: Slider(
                    value: _monthlySavings.clamp(0, monthlyIncome),
                    min: 0,
                    max: monthlyIncome,
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
                      monthlyIncome.toDouble().formatCurrency(decimalDigits: 0),
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
    );
  }

  String _getSavingsAdvice(int percentage) {
    if (percentage <= 20) {
      return 'Conservative - Safe and sustainable';
    } else if (percentage <= 40) {
      return 'Recommended - Good balance';
    } else if (percentage <= 60) {
      return 'Aggressive - Ensure you have buffer for expenses';
    } else {
      return 'Very high - May impact daily living expenses';
    }
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
