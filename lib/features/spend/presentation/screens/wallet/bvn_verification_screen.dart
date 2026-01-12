import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/utils/encryption_service.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_input_field.dart';

import '../../../../../core/widgets/custom_button.dart';
import '../../../../../core/widgets/info_widget.dart';
import 'nin_verification_screen.dart'; // Import keys
import 'live_photo_screen.dart';

class BvnVerificationScreen extends ConsumerStatefulWidget {
  static const String path = '/bvn-verification';

  // NIN is passed via the GoRouter 'extra' property, but defining a property is helpful
  final Map<String, dynamic> data;

  const BvnVerificationScreen({super.key, required this.data});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _BvnVerificationScreenState();
}

class _BvnVerificationScreenState extends ConsumerState<BvnVerificationScreen> {
  final _bvnController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _bvnController.dispose();
    super.dispose();
  }

  // Helper to check if the input meets the required length (11 digits for BVN)
  bool get _isBvnValid => _bvnController.text.trim().length == 11;

  void _navigateToLivePhoto() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Retrieve encrypted NIN passed from the previous screen
      final encryptedNin = widget.data[kKycNinKey] as String;

      final plainBvn = _bvnController.text.trim();

      // Encrypt the BVN
      final encryptedBvn = await EncryptionService.encryptText(plainBvn);

      if (encryptedBvn == null) {
        // Handle encryption error
        // You might want to show a snackbar or error message
        return;
      }

      print(encryptedBvn); // Base64 string with IV prepended

      // Navigate to the LivePhotoScreen, passing both encrypted NIN and BVN
      if (mounted) {
        context.pushNamed(
          LivePhotoScreen.path,
          extra: {
            kKycNinKey: encryptedNin, // Already encrypted from previous screen
            kKycBvnKey: encryptedBvn, // Newly encrypted BVN
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BVN Verification')),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 24.0,
        ).copyWith(bottom: 32),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const InfoWidget(
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
                    validator: (value) {
                      if (value == null || value.length != 11) {
                        return 'BVN must be exactly 11 digits.';
                      }
                      return null;
                    },
                    onChanged: (_) {
                      setState(() {});
                    },
                  ),
                ],
              ),
              CustomElevatedButton(
                text: 'Continue',
                onPressed: _isBvnValid ? _navigateToLivePhoto : null,
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
