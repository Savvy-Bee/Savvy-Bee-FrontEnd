import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/num_extensions.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/providers/goals_provider.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/screens/goals/goal_amount_screen.dart';

// ============================================================================
// GOAL ONBOARDING FLOW - Step 1: Goal Type Selection
// ============================================================================

class CreateGoalOnboardingScreen extends StatefulWidget {
  static const String path = '/create-goal-onboarding';

  const CreateGoalOnboardingScreen({super.key});

  @override
  State<CreateGoalOnboardingScreen> createState() =>
      _CreateGoalOnboardingScreenState();
}

class _CreateGoalOnboardingScreenState
    extends State<CreateGoalOnboardingScreen> {
  String? _selectedGoalType;

  final List<Map<String, dynamic>> _recommendedGoals = [
    {
      'title': 'Save for an emergency',
      'subtitle': 'Based off your current income and account balance',
      'icon': Icons.umbrella_outlined,
    },
  ];

  final List<Map<String, dynamic>> _savingGoals = [
    {'title': 'Pay Off Debt', 'icon': Icons.umbrella_outlined},
    {'title': 'Save for a Car', 'icon': Icons.umbrella_outlined},
    {'title': 'Save for a House', 'icon': Icons.umbrella_outlined},
    {'title': 'Save for Vacation', 'icon': Icons.umbrella_outlined},
    {'title': 'Save for Something Else', 'icon': Icons.umbrella_outlined},
  ];

  final List<Map<String, dynamic>> _additionalGoals = [
    {'title': 'Increase Income', 'icon': Icons.umbrella_outlined},
    {'title': 'Reduce Spending', 'icon': Icons.umbrella_outlined},
  ];

  @override
  Widget build(BuildContext context) {
    final hasSelection = _selectedGoalType != null;

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
            onPressed: () => context.pop(),
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
                      color: Colors.grey.shade300,
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
                  "Let's work towards your top goals.",
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
                  'Select one of the goals below to get started.',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'GeneralSans',
                    color: Colors.black87,
                  ),
                ),
                const Gap(32),

                // Recommended Section
                _buildSection(
                  'Recommended for you',
                  _recommendedGoals.map((goal) {
                    return _buildGoalOption(
                      goal['title'],
                      subtitle: goal['subtitle'],
                      icon: goal['icon'],
                    );
                  }).toList(),
                ),
                const Gap(24),

                // Saving Goals Section
                _buildSection(
                  'Saving goals',
                  _savingGoals.map((goal) {
                    return _buildGoalOption(goal['title'], icon: goal['icon']);
                  }).toList(),
                ),
                const Gap(24),

                // Additional Goals Section
                _buildSection(
                  'Additional goals',
                  _additionalGoals.map((goal) {
                    return _buildGoalOption(goal['title'], icon: goal['icon']);
                  }).toList(),
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
                onPressed: hasSelection
                    ? () {
                        // ✅ FIXED: Use context.push instead of context.pushReplacementNamed
                        context.push(
                          GoalAmountScreen.path,
                          extra: _selectedGoalType,
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: hasSelection
                      ? Colors.black
                      : Colors.grey.shade300,
                  disabledBackgroundColor: Colors.grey.shade300,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Continue',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'GeneralSans',
                    color: hasSelection ? Colors.white : Colors.grey.shade500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: 'GeneralSans',
            color: Colors.black87,
          ),
        ),
        const Gap(12),
        ...children,
      ],
    );
  }

  Widget _buildGoalOption(
    String title, {
    String? subtitle,
    required IconData icon,
  }) {
    final isSelected = _selectedGoalType == title;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedGoalType = title;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: isSelected ? Colors.black : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Icon(icon, size: 24, color: Colors.black87),
            Image.asset(
              'assets/images/icons/Tree.png',
              width: 24,
              height: 24,
              color: Colors.black87,
             ),
            const Gap(16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'GeneralSans',
                      color: Colors.black,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const Gap(4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'GeneralSans',
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Gap(12),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.black : Colors.grey.shade400,
                  width: 2,
                ),
                color: isSelected ? Colors.black : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
