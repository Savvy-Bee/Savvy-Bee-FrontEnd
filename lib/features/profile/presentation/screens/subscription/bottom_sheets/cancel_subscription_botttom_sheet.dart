import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/utils/assets/assets.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';
import 'package:savvy_bee_mobile/features/profile/presentation/screens/subscription/bottom_sheets/cancel_subscription_reason_bottom_sheet.dart';

import '../../../../../../core/widgets/custom_button.dart';

class CancelSubscriptionBottomSheet extends StatelessWidget {
  const CancelSubscriptionBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => CancelSubscriptionBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () => context.pop(),
                icon: Icon(Icons.close),
              ),
            ],
          ),
          Image.asset(Assets.happyBees),
          const Gap(24),
          Text(
            "Are you sure, Dany?\nYou'll lose your\npremium benefits.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              fontFamily: Constants.neulisNeueFontFamily,
              height: 1.0,
            ),
          ),
          const Gap(16),
          Text(
            "You'll lose access to your orem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: Constants.neulisNeueFontFamily),
          ),
          const Gap(48),
          Column(
            spacing: 8,
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomElevatedButton(
                text: 'No, Keep Plus',
                onPressed: () => context.pop(),
              ),
              CustomElevatedButton(
                text: 'Cancel Subscription',
                onPressed: () =>
                    CancelSubscriptionReasonBottomSheet.show(context),
                buttonColor: CustomButtonColor.black,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
