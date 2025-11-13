import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/utils/assets/app_icons.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_card.dart';
import 'package:savvy_bee_mobile/features/auth/presentation/screens/signup/presentation/screens/bottom_sheets/bank_connection_status_bottom_sheet.dart';
import 'package:savvy_bee_mobile/features/auth/presentation/screens/signup/presentation/screens/bottom_sheets/processing_connection_bottom_sheet.dart';

import '../../../../../../../../core/utils/constants.dart';

class SelectedBankLoginBottomSheet extends ConsumerStatefulWidget {
  const SelectedBankLoginBottomSheet({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SelectedBankLoginBottomSheetState();
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SelectedBankLoginBottomSheet(),
    );
  }
}

class _SelectedBankLoginBottomSheetState
    extends ConsumerState<SelectedBankLoginBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
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
          CustomCard(
            borderRadius: 8,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Text(
              'Bank',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const Gap(32),
          Text(
            'Login at Kuda Bank',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              fontFamily: Constants.neulisNeueFontFamily,
            ),
          ),
          const Gap(32),
          _buildInfo('1', "You'll be sent to Kuda Bank to securely log in."),
          const Gap(24),
          _buildInfo('2', "Then you'll return here to finish connecting"),
          const Gap(32),
          CustomElevatedButton(
            text: 'Go to log in',
            buttonColor: CustomButtonColor.black,
            icon: AppIcon(AppIcons.externalLinkIcon),
            onPressed: () => BankConnectionStatusBottomSheet.show(context),
          ),
        ],
      ),
    );
  }

  Widget _buildInfo(String number, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(),
          ),
          child: Text(
            number,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        const Gap(16),
        Expanded(child: Text(text, style: TextStyle(fontSize: 16))),
      ],
    );
  }
}
