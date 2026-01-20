import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/utils/assets/assets.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';

import '../../../../../../core/utils/constants.dart';
import '../../../../../dashboard/presentation/providers/dashboard_data_provider.dart';

class BankConnectionStatusBottomSheet extends ConsumerWidget {
  final String bankName;

  const BankConnectionStatusBottomSheet({super.key, required this.bankName});

  static void show(BuildContext context, {required String bankName}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => BankConnectionStatusBottomSheet(bankName: bankName),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          SvgPicture.asset(Assets.successGreenSvg),
          const Gap(32),
          Text(
            'Success',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              fontFamily: Constants.neulisNeueFontFamily,
            ),
          ),
          Text(
            'You have successfully connected $bankName to Savvy Bee',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontFamily: Constants.neulisNeueFontFamily,
            ),
          ),
          const Gap(32),
          CustomElevatedButton(
            text: 'Done',
            buttonColor: CustomButtonColor.black,
            onPressed: () {
              context.pop();
              ref.invalidate(dashboardDataProvider('all'));
              ref.invalidate(linkedAccountsProvider);
            },
          ),
          const Gap(32),
        ],
      ),
    );
  }
}
