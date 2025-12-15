import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/assets/app_icons.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_card.dart';
import 'package:savvy_bee_mobile/core/widgets/icon_text_row_widget.dart';
import 'package:savvy_bee_mobile/features/auth/presentation/widgets/toggleable_list_tile.dart';
import 'package:savvy_bee_mobile/features/profile/presentation/screens/subscription/bottom_sheets/cancel_subscription_details_botttom_sheet.dart';

import '../../../../../../core/widgets/custom_button.dart';

class CancelSubscriptionReasonBottomSheet extends ConsumerStatefulWidget {
  const CancelSubscriptionReasonBottomSheet({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CancelSubscriptionReasonBottomSheetState();

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => CancelSubscriptionReasonBottomSheet(),
    );
  }
}

class _CancelSubscriptionReasonBottomSheetState
    extends ConsumerState<CancelSubscriptionReasonBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              BackButton(style: Constants.collapsedButtonStyle),
              IconTextRowWidget(
                'Cancel',
                textStyle: TextStyle(
                  color: AppColors.error,
                  fontWeight: FontWeight.bold,
                ),
                AppIcon(AppIcons.arrowRightIcon, color: AppColors.error),
                reverse: true,
                onTap: () => context.pop(),
              ),
            ],
          ),
          const Gap(20),
          Text(
            "Why are you leaving?",
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
            "Tell us why you're cancelling your plan and we'll do our best to fix it.",
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: Constants.neulisNeueFontFamily),
          ),
          const Gap(24),
          _buildTile('I have an issue with my account or plan'),
          ToggleableListTile(
            text: 'I have an issue with my account or plan',
            leading: Text('●', style: TextStyle(fontSize: 32)),
          ),
          const Gap(48),
          CustomElevatedButton(
            text: 'Cancel Subscription',
            onPressed: () => CancelSubscriptionDetailsBottomSheet.show(context),
          ),
        ],
      ),
    );
  }

  Widget _buildTile(
    String title, {
    bool isSelected = false,
    VoidCallback? onTap,
  }) {
    return CustomCard(
      borderRadius: 8,
      onTap: onTap,
      bgColor: isSelected ? AppColors.primaryFaint : null,
      borderColor: isSelected ? null : AppColors.grey,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
