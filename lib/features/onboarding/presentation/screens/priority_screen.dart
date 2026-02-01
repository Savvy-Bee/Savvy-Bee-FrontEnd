import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/widgets/onboarding/continue_button.dart';
import 'package:savvy_bee_mobile/core/widgets/onboarding/onboarding_header.dart';
import 'package:savvy_bee_mobile/core/widgets/onboarding/onboarding_scaffold.dart';
import 'package:savvy_bee_mobile/core/widgets/onboarding/selection_card.dart';
import 'package:savvy_bee_mobile/features/onboarding/presentation/screens/satisfaction_screen.dart';

class PriorityScreen extends StatefulWidget {
  static const String path = '/priority';
  const PriorityScreen({super.key});

  @override
  State<PriorityScreen> createState() => _PriorityScreenState();
}

class _PriorityScreenState extends State<PriorityScreen> {
  final List<SavingsGoal> _goals = [
    SavingsGoal(
      id: 'car',
      label: 'A car',
      icon: Icons.directions_car_outlined,
    ),
    SavingsGoal(
      id: 'emergency',
      label: 'An emergency fund',
      icon: Icons.shield_outlined,
    ),
    SavingsGoal(
      id: 'house',
      label: 'A house',
      icon: Icons.home_outlined,
    ),
    SavingsGoal(
      id: 'debt',
      label: 'To pay off debt',
      icon: Icons.credit_card_outlined,
    ),
    SavingsGoal(
      id: 'other',
      label: 'Something else',
      icon: Icons.more_horiz,
    ),
  ];

  final Set<String> _selectedGoals = {};

  bool get _hasSelection => _selectedGoals.isNotEmpty;

  void _toggleGoal(String id) {
    setState(() {
      if (_selectedGoals.contains(id)) {
        _selectedGoals.remove(id);
      } else {
        _selectedGoals.add(id);
      }
    });
  }

  void _handleContinue() {
    if (_hasSelection) {
      // TODO: Navigate to next screen
       context.pushNamed(SatisfactionScreen.path);
      // print('Selected goals: $_selectedGoals');
    }
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      bottomButton: ContinueButton(
        isEnabled: _hasSelection,
        onPressed: _handleContinue,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 8.h),
          const OnboardingHeader(
            title: 'Are you saving for anything specific?',
            subtitle: 'Choose your top savings goals',
          ),
          // Goals list
          ..._goals.map(
            (goal) => Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: SelectionCard(
                icon: goal.icon,
                label: goal.label,
                isSelected: _selectedGoals.contains(goal.id),
                onTap: () => _toggleGoal(goal.id),
              ),
            ),
          ),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }
}

class SavingsGoal {
  final String id;
  final String label;
  final IconData icon;

  SavingsGoal({
    required this.id,
    required this.label,
    required this.icon,
  });
}