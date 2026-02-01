import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_input_field.dart';
import 'package:savvy_bee_mobile/features/profile/presentation/screens/subscription/subscription_cancelled_screen.dart';

import '../../../../../core/widgets/custom_button.dart';
import '../../../../../core/widgets/intro_text.dart';

class SubscriptionFeedbackScreen extends ConsumerStatefulWidget {
  static const String path = '/subscription-feedback';

  const SubscriptionFeedbackScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SubscriptionFeedbackScreenState();
}

class _SubscriptionFeedbackScreenState
    extends ConsumerState<SubscriptionFeedbackScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          IntroText(
            title: "Speak your mind",
            subtitle:
                "We're so sad to see you go. If there's anything we can do to win you back in the future, please let us know.",
          ),
          const Gap(24),
          CustomTextFormField(
            label: 'Feedback',
            hint: "Tell us what's up",
            maxLines: 5,
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16).copyWith(bottom: 32),
        child: CustomElevatedButton(
          text: 'Continue',
          buttonColor: CustomButtonColor.black,
          onPressed: () {
            context.pushNamed(SubscriptionCancelledScreen.path);
          },
        ),
      ),
    );
  }
}
