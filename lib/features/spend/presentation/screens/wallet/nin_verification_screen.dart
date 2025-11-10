import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_input_field.dart';

import '../../../../../core/widgets/custom_button.dart';
import '../../../../../core/widgets/info_widget.dart';

import 'bvn_verification_screen.dart';

// Keys for passing data between screens
const String kKycNinKey = 'kyc_nin_key';
const String kKycBvnKey = 'kyc_bvn_key';

class NinVerificationScreen extends ConsumerStatefulWidget {
  static String path = '/nin-verification';

  const NinVerificationScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _NinVerificationScreenState();
}

class _NinVerificationScreenState extends ConsumerState<NinVerificationScreen> {
  final _ninController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _ninController.dispose();
    super.dispose();
  }

  // Helper to check if the input meets the required length (11 digits for NIN)
  bool get _isNinValid => _ninController.text.trim().length == 11;

  void _navigateToBvnVerification() {
    if (_formKey.currentState?.validate() ?? false) {
      // Navigate to the next screen, passing the captured NIN
      context.pushNamed(
        BvnVerificationScreen.path,
        extra: {kKycNinKey: _ninController.text.trim()},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Note: We don't watch the kycNotifierProvider here, as the verification API call happens on the final screen.

    return Scaffold(
      appBar: AppBar(title: const Text('NIN Verification')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const InfoWidget(
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
                    validator: (value) {
                      if (value == null || value.length != 11) {
                        return 'NIN must be exactly 11 digits.';
                      }
                      return null;
                    },
                    onChanged: (_) {
                      // Trigger a rebuild to update the button state
                      setState(() {});
                    },
                  ),
                ],
              ),
              CustomElevatedButton(
                text: 'Continue',
                onPressed: _isNinValid ? _navigateToBvnVerification : null,
                buttonColor: CustomButtonColor.black,
                showArrow: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
