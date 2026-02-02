import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_card.dart';
import 'package:savvy_bee_mobile/core/widgets/intro_text.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/assets/illustrations.dart';
import 'subscription/downgrade_subscription_screen.dart';

class ManageSubscriptionScreen extends ConsumerStatefulWidget {
  static const String path = '/manage-subscription';

  const ManageSubscriptionScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ManageSubscriptionScreenState();
}

class _ManageSubscriptionScreenState
    extends ConsumerState<ManageSubscriptionScreen> {
  bool isFreePlan = false;

  final cardBorderColor = AppColors.grey.withValues(alpha: 0.5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          IntroText(
            title: isFreePlan ? 'Free Plan' : 'Bee+',
            subtitle: isFreePlan
                ? 'Upgrade to get access to premium benefits'
                : 'Free Trial • Next payment on 18th Jan 2026',
          ),
          const Gap(24),
          _buildPlanStatsCard(isFreePlan: isFreePlan),
          const Gap(24),
          if (isFreePlan)
            _buildBeePlusBenefitCard(context), // Show only for free plan
          if (!isFreePlan) _buildPlanDetailsCard(), // Show only for Bee+ plan
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16).copyWith(bottom: 32),
        child: CustomElevatedButton(
          text: isFreePlan ? 'Upgrade to Bee+' : 'Downgrade to Free',
          buttonColor: CustomButtonColor.black,
          onPressed: isFreePlan
              ? () {}
              : () {
                  context.pushNamed(DowngradeSubscriptionScreen.path);
                },
        ),
      ),
    );
  }

  Widget _buildPlanDetailsCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 16,
      children: [
        Text(
          'PLAN DETAILS',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
        CustomCard(
          hasShadow: true,
          borderColor: cardBorderColor,
          borderRadius: 8,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            spacing: 24,
            children: [
              _buildRowItem('Plan', 'Bee+ | Monthly'),
              _buildRowItem('Billing', '1 month free, then ₦5,000/month'),
              _buildRowItem('First payment', '20th Nov, 2025'),
              _buildRowItem('Stamp Duty Fee', '₦50.00'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBeePlusBenefitCard(BuildContext context) {
    return CustomCard(
      borderColor: cardBorderColor,
      hasShadow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Everything you need in Bee+',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const Gap(4),
          Text(
            'Intelligence, automation, and zero financial anxiety',
            style: TextStyle(fontSize: 16),
          ),
          const Gap(16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              spacing: 8,
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
        ],
      ),
    );
  }

  Widget _buildPlanStatsCard({required bool isFreePlan}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 16,
      children: [
        Text(
          isFreePlan ? 'PLAN DETAILS' : 'NAHL USAGE',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
        CustomCard(
          borderColor: cardBorderColor,
          borderRadius: 8,
          hasShadow: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isFreePlan) ...[
                Text(
                  'Chats',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
                ),
                const Gap(8),
                Text(
                  '5/50',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
                ),
                const Gap(16),
                LinearProgressIndicator(
                  value: 0.1,
                  color: AppColors.success,
                  backgroundColor: AppColors.success.withValues(alpha: 0.34),
                  borderRadius: BorderRadius.circular(10),
                  minHeight: 10,
                ),
              ],
              if (isFreePlan) ...[
                _buildRowItem('Plan', 'Free'),
                const Gap(24),
                _buildRowItem('Next payment', 'No next payment'),
              ],
            ],
          ),
        ),
      ],
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

  Widget _buildRowItem(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
        Text(value, style: TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }
}
