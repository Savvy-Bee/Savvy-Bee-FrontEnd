import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/assets/illustrations.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';
import 'package:savvy_bee_mobile/features/profile/presentation/screens/subscription/bottom_sheets/cancel_subscription_botttom_sheet.dart';

import '../../../../core/widgets/game_card.dart';

class ManageSubscriptionScreen extends ConsumerStatefulWidget {
  static const String path = '/manage-subscription';

  const ManageSubscriptionScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ManageSubscriptionScreenState();
}

class _ManageSubscriptionScreenState
    extends ConsumerState<ManageSubscriptionScreen> {
  bool isFreeTrial = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage subscription')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(Illustrations.premiumBee),
                const Gap(16),
                if (isFreeTrial)
                  Text(
                    "You're currently on a free trial which will convert on 19/12/2025. Cancel 24 hours before renewal if you don't want to continue.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: Constants.neulisNeueFontFamily,
                    ),
                  ),
                const Gap(16),
                GameCard(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildRowItem('Plan', 'Plus | Monthly'),
                      const Divider(height: 0),
                      _buildRowItem(
                        'Billing',
                        '1 month free, then ₦5,000/month',
                      ),
                      const Divider(height: 0),
                      _buildRowItem('First payment', '20th Nov, 2025'),
                      const Divider(height: 0),
                      _buildRowItem('Next payment', '20th Dec, 2025'),
                    ],
                  ),
                ),
              ],
            ),
            Column(
              spacing: 8,
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomElevatedButton(text: 'Upgrade plan', onPressed: () {}),
                CustomElevatedButton(
                  text: 'Cancel Subscription',
                  onPressed: () => CancelSubscriptionBottomSheet.show(context),
                  buttonColor: CustomButtonColor.black,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRowItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppColors.grey,
              fontFamily: Constants.neulisNeueFontFamily,
            ),
          ),
          Text(
            value,
            style: TextStyle(fontFamily: Constants.neulisNeueFontFamily),
          ),
        ],
      ),
    );
  }
}
