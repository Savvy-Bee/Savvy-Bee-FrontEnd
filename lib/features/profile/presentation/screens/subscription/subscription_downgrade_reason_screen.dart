import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/dot.dart';
import '../../../../../core/widgets/custom_button.dart';
import '../../../../../core/widgets/intro_text.dart';
import 'subscription_feedback_screen.dart';

class SubscriptionDowngradeReasonScreen extends ConsumerStatefulWidget {
  static const String path = '/subscription-downgrade-reason';

  const SubscriptionDowngradeReasonScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SubscriptionDowngradeReasonScreenState();
}

class _SubscriptionDowngradeReasonScreenState
    extends ConsumerState<SubscriptionDowngradeReasonScreen> {
  final List<String> reasons = [
    'I have an issue with my account or plan',
    "I'm not getting value for my money",
    "I don't need the benefits anymore",
    'I upgraded by accident',
    "I'm unhappy with customer support",
    'Other',
  ];

  String? selectedReason;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          IntroText(
            title: "Why are you leaving?",
            subtitle:
                "Tell us why you're cancelling your plan and we'll do our best to fix it.",
          ),
          const Gap(24),
          ...reasons.expand(
            (reason) => [
              _buildListTile(
                title: reason,
                isSelected: reason == selectedReason,
                onTap: () => setState(() => selectedReason = reason),
              ),
              const Gap(8),
            ],
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16).copyWith(bottom: 32),
        child: CustomElevatedButton(
          text: 'Continue',
          buttonColor: CustomButtonColor.black,
          onPressed: selectedReason == null
              ? null
              : () {
                  context.pushNamed(SubscriptionFeedbackScreen.path);
                },
        ),
      ),
    );
  }

  Widget _buildListTile({
    required String title,
    bool isSelected = false,
    VoidCallback? onTap,
  }) {
    Color borderColor = isSelected
        ? AppColors.black
        : AppColors.grey.withValues(alpha: 0.5);

    var dotColor = isSelected ? AppColors.black : Colors.transparent;

    return ListTile(
      leading: Dot(
        size: 16,
        color: dotColor,
        border: Border.all(color: AppColors.black),
      ),
      horizontalTitleGap: 0,
      title: Text(
        title,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: borderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      onTap: onTap,
    );
  }
}
