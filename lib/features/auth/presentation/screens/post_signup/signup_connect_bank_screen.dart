import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:savvy_bee_mobile/core/widgets/bottom_sheets/notification_prompt_bottom_sheet.dart';
import 'package:savvy_bee_mobile/features/auth/presentation/screens/post_signup/bottom_sheets/connect_bank_security_bottom_sheet.dart';

import '../../../../../core/utils/assets/illustrations.dart';
import '../../../../../core/utils/assets/logos.dart';
import '../../../../../core/utils/constants.dart';
import '../../../../../core/widgets/custom_button.dart';

class SignupConnectBankScreen extends StatefulWidget {
  static String path = '/signup-connect-bank';

  const SignupConnectBankScreen({super.key});

  @override
  State<SignupConnectBankScreen> createState() =>
      _SignupConnectBankScreenState();
}

class _SignupConnectBankScreenState extends State<SignupConnectBankScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Image.asset(Logos.logo),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Start tracking\nyour money',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 38,
                    height: 0.9,
                    fontWeight: FontWeight.bold,
                    fontFamily: Constants.neulisNeueFontFamily,
                  ),
                ),
                const Gap(16),
                Text(
                  'Find out where your money is going. Link your bank accounts',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    height: 1.1,
                    fontFamily: Constants.neulisNeueFontFamily,
                  ),
                ),
              ],
            ),
            Image.asset(Illustrations.scammerBee),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomElevatedButton(
                  text: 'Connect bank account',
                  showArrow: true,
                  buttonColor: CustomButtonColor.black,
                  onPressed: () => ConnectBankSecurityBottomSheet.show(context),
                ),
                const Gap(8),
                CustomOutlinedButton(
                  text: 'Next',
                  showArrow: true,
                  onPressed: () => NotificationPromptBottomSheet.show(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
