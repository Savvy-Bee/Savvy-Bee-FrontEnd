import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/num_extensions.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/providers/goals_provider.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/screens/goals/goal_success_screen.dart';

// ============================================================================
// Step 4: Finalizing Screen with Backend Integration
// ============================================================================

class GoalFinalizingScreen extends ConsumerStatefulWidget {
  static const String path = '/goal-finalizing';
  final Map<String, dynamic> goalData;

  const GoalFinalizingScreen({super.key, required this.goalData});

  @override
  ConsumerState<GoalFinalizingScreen> createState() =>
      _GoalFinalizingScreenState();
}

class _GoalFinalizingScreenState extends ConsumerState<GoalFinalizingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  bool _isCreating = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();

    // Setup progress animation
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 0.95).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );

    // Delay goal creation to ensure the widget is fully built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _progressController.forward();
      _createGoal();
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  Future<void> _createGoal() async {
    if (_isCreating || _hasError) return;

    try {
      setState(() {
        _isCreating = true;
      });

      // Validate goal data
      if (!widget.goalData.containsKey('goalType') ||
          !widget.goalData.containsKey('amount') ||
          !widget.goalData.containsKey('monthlySavings')) {
        throw Exception('Invalid goal data');
      }

      final goalType = widget.goalData['goalType'] as String;
      final targetAmount = widget.goalData['amount'] as double;
      final monthlySavings = widget.goalData['monthlySavings'] as double;

      // Calculate end date based on monthly savings
      final monthsToGoal = monthlySavings > 0
          ? (targetAmount / monthlySavings).ceil()
          : 12; // Default to 12 months if calculation fails

      final endDate = DateTime.now().add(Duration(days: monthsToGoal * 30));
      final formattedEndDate =
          '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}';

      print('🚀 Creating goal with data:');
      print('  - Name: $goalType');
      print('  - Target: $targetAmount');
      print('  - Monthly: $monthlySavings');
      print('  - End Date: $formattedEndDate');

      // Call the provider to create goal
      await ref
          .read(savingsGoalNotifierProvider.notifier)
          .createGoal(
            name: goalType,
            totalSavings: targetAmount,
            amountSaved: 0.0, // Initial deposit
            endDate: formattedEndDate,
          );

      // Check if we're still mounted before proceeding
      if (!mounted) return;

      // Check if creation was successful
      final state = ref.read(savingsGoalNotifierProvider);

      if (state.error != null) {
        print('❌ Error creating goal: ${state.error}');
        setState(() {
          _hasError = true;
        });

        // Show error message
        _showErrorSnackbar(state.error!);

        // Navigate back after error
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          context.go('/goals');
        }
      } else {
        print('✅ Goal created successfully');

        // Complete the progress animation
        await _progressController.animateTo(1.0);

        if (!mounted) return;

        // Show success message
        _showSuccessSnackbar('Goal created successfully!');

        // Navigate to success screen after brief delay
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          context.go(GoalSuccessScreen.path);
        }
      }
    } catch (e) {
      print('💥 Exception creating goal: $e');

      setState(() {
        _hasError = true;
      });

      if (mounted) {
        _showErrorSnackbar('Failed to create goal: ${e.toString()}');
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          context.go('/goals');
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCreating = false;
        });
      }
    }
  }

  void _showSuccessSnackbar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const Gap(12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontFamily: 'GeneralSans',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const Gap(12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontFamily: 'GeneralSans',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final monthlySavings = widget.goalData['monthlySavings'] as double? ?? 0.0;

    return WillPopScope(
      onWillPop: () async {
        // Prevent back navigation while creating
        return !_isCreating;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),

                  // Loading icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.yellow.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: _hasError
                          ? const Icon(
                              Icons.error_outline,
                              size: 40,
                              color: Colors.red,
                            )
                          : const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.yellow,
                              ),
                              strokeWidth: 3,
                            ),
                    ),
                  ),

                  const Gap(32),

                  Text(
                    _hasError ? 'Error creating goal' : 'Finalizing your goal',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'GeneralSans',
                    ),
                  ),

                  const Gap(24),

                  // Animated Progress bar
                  if (!_hasError)
                    AnimatedBuilder(
                      animation: _progressAnimation,
                      builder: (context, child) {
                        return Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: LinearProgressIndicator(
                                value: _progressAnimation.value,
                                minHeight: 4,
                                backgroundColor: const Color(0xFFE0E0E0),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.black,
                                ),
                              ),
                            ),
                            const Gap(8),
                            Text(
                              '${(_progressAnimation.value * 100).toInt()}%',
                              style: TextStyle(
                                fontSize: 12,
                                fontFamily: 'GeneralSans',
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                  const Gap(32),

                  if (!_hasError) ...[
                    const Text(
                      'FINANCIAL PLAN',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'GeneralSans',
                        letterSpacing: 0.5,
                      ),
                    ),

                    const Gap(16),

                    Text(
                      "We'll send you reminders throughout the months to make small contributions towards your monthly goal of ${monthlySavings.toDouble().formatCurrency(decimalDigits: 0)}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        fontFamily: 'GeneralSans',
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                  ],

                  const Spacer(),

                  // Retry button if error
                  if (_hasError)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => context.go('/goals'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Back to Goals',
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
            ),
          ),
        ),
      ),
    );
  }
}
