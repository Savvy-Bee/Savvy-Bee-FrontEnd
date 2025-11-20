import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';

import '../../../../../core/utils/assets/assets.dart';
import '../../../../../core/utils/constants.dart';
import '../../../../../core/widgets/custom_button.dart';
// TODO: DELETE FILE
class StatementSentScreen extends StatelessWidget {
  static const String path = '/statement-sent';

  const StatementSentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(Assets.successSvg),
                const Gap(16),
                Text(
                  'Sent!',
                  style: TextStyle(
                    fontFamily: Constants.neulisNeueFontFamily,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Gap(8),
                Text(
                  'Your statement is on its way to your inbox.',
                  style: TextStyle(
                    fontFamily: Constants.neulisNeueFontFamily,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            CustomElevatedButton(text: 'Okay', onPressed: () {}),
          ],
        ),
      ),
    );
  }
}
