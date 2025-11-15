import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/utils/assets/assets.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';

import '../../../../../../core/utils/constants.dart';

class BankConnectionStatusBottomSheet extends StatelessWidget {
  const BankConnectionStatusBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => BankConnectionStatusBottomSheet(),
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
            'You have successfully connected Kuda Bank to Savvy Bee',
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
            onPressed: () {},
          ),
          const Gap(32),
        ],
      ),
    );
  }
}
