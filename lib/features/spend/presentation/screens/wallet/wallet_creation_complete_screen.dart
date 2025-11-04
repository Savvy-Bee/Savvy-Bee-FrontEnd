import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:savvy_bee_mobile/core/utils/assets/assets.dart';

import '../../../../../core/widgets/custom_button.dart';
import '../../../../../core/widgets/info_widget.dart';

class WalletCreationCompletionScreen extends ConsumerWidget {
  static String path = '/wallet-creation-complete';

  const WalletCreationCompletionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InfoWidget(
              title: 'Wallet Created',
              subtitle: 'Your wallet has been created successfully.',
              icon: SvgPicture.asset(Assets.verifyFilledSvg),
            ),
            CustomElevatedButton(
              text: 'Okay',
              showArrow: false,
              onPressed: () {},
              buttonColor: CustomButtonColor.yellow,
            ),
          ],
        ),
      ),
    );
  }
}
