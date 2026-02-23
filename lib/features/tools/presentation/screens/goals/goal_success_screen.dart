import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/tracking/minxpanel_tracking.dart';
import 'package:savvy_bee_mobile/core/utils/num_extensions.dart';
import 'package:savvy_bee_mobile/features/tools/presentation/providers/goals_provider.dart';

// ============================================================================
// Step 5: Success / Milestone Screen
// ============================================================================

class GoalSuccessScreen extends StatefulWidget {
  static const String path = '/goal-success';

  const GoalSuccessScreen({super.key});

  @override
  State<GoalSuccessScreen> createState() => _GoalSuccessScreenState();
}

class _GoalSuccessScreenState extends State<GoalSuccessScreen> {
  @override
  void initState() {
    super.initState();
    MixpanelService.trackFirstFeatureUsed('Tools-Goals');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Two chat bubbles illustration (placeholder)
              // Container(
              //   width: 200,
              //   height: 200,
              //   decoration: const BoxDecoration(color: Colors.transparent),
              //   child: Stack(
              //     children: [
              //       Positioned(
              //         top: 40,
              //         left: 20,
              //         child: _buildChatBubble(Colors.black, 80),
              //       ),
              //       Positioned(
              //         bottom: 40,
              //         right: 20,
              //         child: _buildChatBubble(AppColors.yellow, 120),
              //       ),
              //     ],
              //   ),
              // ),
              Image.asset(
                'assets/images/icons/Milestone.png',
                width: 200,
                height: 200,
              ),
              const Gap(40),

              const Text(
                'New milestone unlocked!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'GeneralSans',
                ),
              ),
              const Gap(16),

              const Text(
                "Congratulations on taking a step toward your goal! You've hit a milestone!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'GeneralSans',
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
              const Gap(60),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.go('/goals'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.yellow,
                    foregroundColor: Colors.black,
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
    );
  }

  Widget _buildChatBubble(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size / 2),
      ),
      child: Center(
        child: Container(
          width: size * 0.3,
          height: size * 0.15,
          decoration: BoxDecoration(
            color: color.computeLuminance() > 0.5 ? Colors.black : Colors.white,
            borderRadius: BorderRadius.circular(size * 0.1),
          ),
        ),
      ),
    );
  }
}
