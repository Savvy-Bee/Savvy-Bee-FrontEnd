import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/utils/assets/app_icons.dart';
import 'package:savvy_bee_mobile/core/utils/assets/logos.dart';
import 'package:savvy_bee_mobile/core/utils/constants.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_card.dart';

class ProcessingConnectionBottomSheet extends ConsumerStatefulWidget {
  const ProcessingConnectionBottomSheet({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ProcessingConnectionBottomSheetState();

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => ProcessingConnectionBottomSheet(),
    );
  }
}

class _ProcessingConnectionBottomSheetState
    extends ConsumerState<ProcessingConnectionBottomSheet> {
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
                style: Constants.collapsedButtonStyle,
                icon: Icon(Icons.close),
              ),
            ],
          ),
          const Gap(32),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomCard(
                padding: const EdgeInsets.all(20),
                borderRadius: 8,
                child: Image.asset(Logos.logo),
              ),
              SizedBox(width: 37, child: const Divider()),
              CustomCard(
                padding: const EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: 16,
                ),
                borderRadius: 8,
                child: Text(
                  'Bank',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const Gap(32),
          Text(
            'Connecting to Kuda Bank',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              fontFamily: Constants.neulisNeueFontFamily,
            ),
          ),
          const Gap(32),
          AppIcon(AppIcons.progressIcon, color: AppColors.primary),
          const Gap(32),
          Text(
            'Syncing your information.',
            style: TextStyle(fontFamily: Constants.neulisNeueFontFamily),
          ),
          const Gap(32),
        ],
      ),
    );
  }
}
