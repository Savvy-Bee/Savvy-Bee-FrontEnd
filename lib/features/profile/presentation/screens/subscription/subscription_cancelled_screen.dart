import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/widgets/custom_button.dart';

class SubscriptionCancelledScreen extends ConsumerWidget {
  static const String path = '/subscription-cancelled';

  const SubscriptionCancelledScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 16,
            children: [
              Text(
                'You have cancelled your subscription.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  height: 1,
                ),
              ),
              Text(
                'You can keep enjoying your Bee Plus benefits till 20th January, 2026.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16).copyWith(bottom: 32),
        child: CustomElevatedButton(
          text: 'Got It!',
          buttonColor: CustomButtonColor.black,
          onPressed: () {},
        ),
      ),
    );
  }
}
