import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';
import 'package:savvy_bee_mobile/core/widgets/intro_text.dart';
import 'package:savvy_bee_mobile/features/profile/presentation/screens/subscription/subscription_downgrade_reason_screen.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/assets/illustrations.dart';
import '../../../../../core/widgets/custom_card.dart';

class DowngradeSubscriptionScreen extends ConsumerStatefulWidget {
  static const String path = '/downgrade-subscription';

  const DowngradeSubscriptionScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DowngradeSubscriptionScreenState();
}

class _DowngradeSubscriptionScreenState
    extends ConsumerState<DowngradeSubscriptionScreen> {
  final cardBorderColor = AppColors.grey.withValues(alpha: 0.5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          IntroText(
            title: "Are you sure, Dany? You'll lose your premium benefits.",
            subtitle: 'Your premium plan will end in 24 hours.',
          ),
          const Gap(24),
          Text(
            'TOP PREMIUM BENEFITS',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
          const Gap(16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              spacing: 16,
              children: [
                _buildBeePlusBenefitItem(
                  context,
                  title: '50 AI conversations/month',
                  subtitle:
                      'Chat with Nahl for personalized financial advice and deep analysis',
                ),
                _buildBeePlusBenefitItem(
                  context,
                  title: 'Unlimited AI conversations',
                  subtitle:
                      'Chat with Nahl for personalized financial advice and deep analysis',
                ),
              ],
            ),
          ),
          const Gap(48),
          Text(
            "You'll lose access to you 23 chats will Nahl. Only your 3 most recent chats will be saved.",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16).copyWith(bottom: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: [
            CustomElevatedButton(
              text: 'Keep my premium plan',
              buttonColor: CustomButtonColor.black,
              onPressed: () => context.pop(),
            ),
            CustomOutlinedButton(
              text: 'Proceed with downgrade',
              onPressed: () =>
                  context.pushNamed(SubscriptionDowngradeReasonScreen.path),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBeePlusBenefitItem(
    BuildContext context, {
    required String title,
    required String subtitle,
  }) {
    final width = MediaQuery.widthOf(context) * 0.8;

    return CustomCard(
      borderColor: cardBorderColor,
      borderRadius: 8,
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(Illustrations.premiumBee, height: 48),
          const Gap(8),
          Text(
            title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const Gap(4),
          Text(
            subtitle,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
