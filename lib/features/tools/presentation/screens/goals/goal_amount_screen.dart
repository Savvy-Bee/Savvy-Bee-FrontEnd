import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/num_extensions.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/providers/goals_provider.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/screens/goals/goal_recommendations_screen.dart';

class GoalAmountScreen extends StatefulWidget {
  static const String path = '/goal-amount';
  final String goalType;

  const GoalAmountScreen({super.key, required this.goalType});

  @override
  State<GoalAmountScreen> createState() => _GoalAmountScreenState();
}

class _GoalAmountScreenState extends State<GoalAmountScreen> {
  final _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
      body: Column(
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
                  'How much do you want to save for this goal?',
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

                // Amount Input
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'GeneralSans',
                        ),
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          prefix: const Text(
                            '₦',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'GeneralSans',
                            ),
                          ),
                          hintText: '500,000',
                          hintStyle: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'GeneralSans',
                            color: Colors.grey.shade400,
                          ),
                          border: InputBorder.none,
                        ),
                        onChanged: (_) => setState(() {}),
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
                onPressed: _amountController.text.isNotEmpty
                    ? () {
                        final amount = double.tryParse(_amountController.text);
                        if (amount != null) {
                          // ✅ FIXED: Use context.push instead of context.pushReplacementNamed
                          context.push(
                            GoalRecommendationsScreen.path,
                            extra: {
                              'goalType': widget.goalType,
                              'amount': amount,
                            },
                          );
                        }
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _amountController.text.isNotEmpty
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
      ),
    );
  }
}
