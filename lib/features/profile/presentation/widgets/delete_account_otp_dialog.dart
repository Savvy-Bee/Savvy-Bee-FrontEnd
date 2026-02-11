import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';

class DeleteAccountOtpDialog extends ConsumerStatefulWidget {
  final String userEmail;
  final Function(String otp) onVerifyOtp;

  const DeleteAccountOtpDialog({
    super.key,
    required this.userEmail,
    required this.onVerifyOtp,
  });

  @override
  ConsumerState<DeleteAccountOtpDialog> createState() =>
      _DeleteAccountOtpDialogState();
}

class _DeleteAccountOtpDialogState
    extends ConsumerState<DeleteAccountOtpDialog> {
  final _otpController = TextEditingController();
  bool _isVerifying = false;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Verify Account Deletion',
              style: TextStyle(
                fontFamily: 'GeneralSans',
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const Gap(12),
            Text(
              'We\'ve sent a verification code to ${widget.userEmail}. Please enter it below to confirm account deletion.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'GeneralSans',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.black87,
              ),
            ),
            const Gap(24),

            // OTP Input
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 6,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                fontFamily: 'GeneralSans',
                letterSpacing: 8,
              ),
              decoration: InputDecoration(
                counterText: '',
                hintText: '000000',
                hintStyle: TextStyle(
                  color: Colors.grey.shade300,
                  letterSpacing: 8,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
            const Gap(24),

            // Verify button
            CustomElevatedButton(
              text: 'Verify and Delete',
              buttonColor: CustomButtonColor.red,
              isLoading: _isVerifying,
              onPressed: _otpController.text.length == 6 && !_isVerifying
                  ? () async {
                      setState(() {
                        _isVerifying = true;
                      });

                      try {
                        await widget.onVerifyOtp(_otpController.text);
                        if (context.mounted) {
                          Navigator.of(context).pop(true);
                        }
                      } catch (e) {
                        if (context.mounted) {
                          setState(() {
                            _isVerifying = false;
                          });
                        }
                      }
                    }
                  : null,
            ),
            const Gap(12),

            // Cancel button
            CustomOutlinedButton(
              text: 'Cancel',
              onPressed: _isVerifying
                  ? null
                  : () {
                      Navigator.of(context).pop(false);
                    },
            ),
          ],
        ),
      ),
    );
  }
}

/// Helper function to show the OTP verification dialog
Future<bool?> showDeleteAccountOtpDialog(
  BuildContext context, {
  required String userEmail,
  required Function(String otp) onVerifyOtp,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) =>
        DeleteAccountOtpDialog(userEmail: userEmail, onVerifyOtp: onVerifyOtp),
  );
}
