import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/utils/assets/assets.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';
import 'package:savvy_bee_mobile/core/widgets/info_widget.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/screens/wallet/nin_verification_screen.dart';

class CreateWalletScreen extends ConsumerWidget {
  static String path = '/wallet';

  const CreateWalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Wallet')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InfoWidget(
              title: 'Verify your identity to create your wallet',
              subtitle:
                  'To keep your wallet secure and comply with regulations, we need to verify your identity using your NIN, BVN, and a quick live photo.',
              icon: SvgPicture.asset(Assets.verifySvg),
            ),
            CustomElevatedButton(
              text: 'Get Started',
              onPressed: () => context.pushNamed(NinVerificationScreen.path),
              buttonColor: CustomButtonColor.black,
              showArrow: true,
            ),
          ],
        ),
      ),
    );
  }
}
