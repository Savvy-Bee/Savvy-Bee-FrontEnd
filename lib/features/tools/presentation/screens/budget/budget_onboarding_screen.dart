import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/num_extensions.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/providers/budget_provider.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/screens/budget/edit_budget_screen.dart';

// ============================================================================
// BUDGET ONBOARDING INTRO SCREEN
// ============================================================================

/// Budget Onboarding Intro - First screen user sees
/// Shows bee mascot with lollipop and "easy-beezy" message
class BudgetOnboardingIntroScreen extends StatelessWidget {
  static const String path = '/budget-onboarding';

  const BudgetOnboardingIntroScreen({super.key});

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
          TextButton(
            onPressed: () {
              // Skip to budget screen
              context.goNamed('/budget-screen');
            },
            child: const Text(
              'Skip',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontFamily: 'GeneralSans',
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),

            // Bee Mascot Image (placeholder - replace with actual asset)
            Container(
              width: 200,
              height: 200,
              decoration: const BoxDecoration(
                color: Color(0xFFA8DADC),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text('🐝🍭', style: TextStyle(fontSize: 80)),
              ),
            ),
            const Gap(40),

            // Title
            const Text(
              'Setting up your budget is easy-beezy.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w500,
                fontFamily: 'GeneralSans',
                height: 1.2,
                color: Colors.black,
              ),
            ),
            const Gap(16),

            // Subtitle
            const Text(
              "Your budget is the foundation for planning your spending and reaching your goals. Don't worry, we'll guide you along the way.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'GeneralSans',
                height: 1.4,
                color: Colors.black87,
              ),
            ),

            const Spacer(),

            // Start Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.pushNamed('/set-income');
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
                  'Start my budget',
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
    );
  }
}
