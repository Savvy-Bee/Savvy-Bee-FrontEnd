import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';

import '../../../../../core/utils/assets/assets.dart';
import '../../../../../core/utils/constants.dart';

class BillCompletionScreen extends ConsumerStatefulWidget {
  static String path = '/bill-completion';

  const BillCompletionScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _BillCompletionScreenState();
}

class _BillCompletionScreenState extends ConsumerState<BillCompletionScreen> {
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
                  'Recharged!',
                  style: TextStyle(
                    fontFamily: Constants.neulisNeueFontFamily,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Gap(8),
                Text(
                  'Successful',
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
