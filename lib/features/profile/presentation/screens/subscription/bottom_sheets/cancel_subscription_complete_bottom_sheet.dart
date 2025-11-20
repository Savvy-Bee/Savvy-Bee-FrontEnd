import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/utils/assets/assets.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';

class CancelSubscriptionCompleteBottomSheet extends StatelessWidget {
  const CancelSubscriptionCompleteBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => CancelSubscriptionCompleteBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(Assets.successSvg),
          const Gap(16),
          Text(
            'You have cancelled your subscription.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              height: 1.0,
            ),
          ),
          const Gap(4),
          Text(
            'You can keep enjoying your Bee Plus benefits till 19th Dec, 2025.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          const Gap(24),
          CustomElevatedButton(
            text: 'Got it!',
            buttonColor: CustomButtonColor.black,
            onPressed: () => context.pop(),
          ),
        ],
      ),
    );
  }
}
