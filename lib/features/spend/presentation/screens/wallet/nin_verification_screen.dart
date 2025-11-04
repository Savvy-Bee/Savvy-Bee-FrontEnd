import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_input_field.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/screens/wallet/photo_verification_screen.dart';

import '../../../../../core/widgets/custom_button.dart';
import '../../../../../core/widgets/info_widget.dart';

class NinVerificationScreen extends ConsumerStatefulWidget {
  static String path = '/nin-verification';

  const NinVerificationScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _NinVerificationScreenState();
}

class _NinVerificationScreenState extends ConsumerState<NinVerificationScreen> {
  final _ninController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('NIN Verification')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                InfoWidget(
                  title: 'Enter your National Identification Number (NIN)',
                  subtitle:
                      'Your NIN helps us confirm your identity with the National Identity Database.',
                  textAlignment: InfoWidgetTextAlignment.left,
                ),
                const Gap(16.0),
                CustomTextFormField(
                  controller: _ninController,
                  hint: 'Enter your 11-digit NIN',
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
              onPressed: () {
                context.pushNamed(PhotoVerificationScreen.path);
              },
              // onPressed: _ninController.text.trim().isEmpty ? null : () {},
              buttonColor: CustomButtonColor.black,
            ),
          ],
        ),
      ),
    );
  }
}
