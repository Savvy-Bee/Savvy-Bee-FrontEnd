import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_input_field.dart';

import '../../../../../core/widgets/custom_button.dart';
import '../../../../../core/widgets/info_widget.dart';

class BvnVerificationScreen extends ConsumerStatefulWidget {
  static String path = '/bvn-verification';

  const BvnVerificationScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _BvnVerificationScreenState();
}

class _BvnVerificationScreenState extends ConsumerState<BvnVerificationScreen> {
  final _bvnController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('BVN Verification')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                InfoWidget(
                  title: 'Enter your Bank Verification Number (BVN)',
                  subtitle:
                      'This helps us link your wallet to your financial identity for secure transactions.',
                  textAlignment: InfoWidgetTextAlignment.left,
                ),
                const Gap(16.0),
                CustomTextFormField(
                  controller: _bvnController,
                  hint: 'Enter your 11-digit BVN',
                  subText: "We'll use this only for identity verification.",
                  isRounded: true,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(11),
                  ],
                ),
              ],
            ),
            CustomElevatedButton(
              text: 'Continue',
              onPressed: _bvnController.text.trim().isEmpty ? null : () {},
              buttonColor: CustomButtonColor.black,
              showArrow: true,
            ),
          ],
        ),
      ),
    );
  }
}
