import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_input_field.dart';
import 'package:savvy_bee_mobile/core/widgets/icon_text_row_widget.dart';
import 'package:savvy_bee_mobile/features/profile/presentation/screens/subscription/bottom_sheets/cancel_subscription_complete_bottom_sheet.dart';

import '../../../../../../core/utils/assets/app_icons.dart';
import '../../../../../../core/utils/constants.dart';

class CancelSubscriptionDetailsBottomSheet extends ConsumerStatefulWidget {
  const CancelSubscriptionDetailsBottomSheet({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CancelSubscriptionDetailsBottomSheetState();

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => CancelSubscriptionDetailsBottomSheet(),
    );
  }
}

class _CancelSubscriptionDetailsBottomSheetState
    extends ConsumerState<CancelSubscriptionDetailsBottomSheet> {
  final feedbackController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
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
                "Speak your mind",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,

                  height: 1.0,
                ),
              ),
              const Gap(16),
              Text(
                "We're so sad to see you go. If there's anything we can do to win you back in the future, please let us know.",
                textAlign: TextAlign.center,
              ),
              const Gap(16),
              CustomTextFormField(
                label: 'Feedback',
                controller: feedbackController,
                minLines: 1,
                maxLines: 3,
              ),
            ],
          ),
          CustomElevatedButton(
            text: 'Cancel Subscription',
            onPressed: () =>
                CancelSubscriptionCompleteBottomSheet.show(context),
          ),
        ],
      ),
    );
  }
}
