import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_button.dart';

class DeleteAccountDialog extends ConsumerStatefulWidget {
  final String userEmail;
  final VoidCallback onDeleteConfirmed;

  const DeleteAccountDialog({
    super.key,
    required this.userEmail,
    required this.onDeleteConfirmed,
  });

  @override
  ConsumerState<DeleteAccountDialog> createState() =>
      _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends ConsumerState<DeleteAccountDialog> {
  bool _isDeleting = false;

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
              'Delete Account',
              style: TextStyle(
                fontFamily: 'GeneralSans',
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const Gap(12),
            const Text(
              'Are you sure you want to delete your account?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'GeneralSans',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.black87,
              ),
            ),
            const Gap(24),

            // Delete my account button (red outlined)
            CustomOutlinedButton(
              text: 'Delete my account',
              isDestructive: true,
              isLoading: _isDeleting,
              onPressed: _isDeleting
                  ? null
                  : () async {
                      setState(() {
                        _isDeleting = true;
                      });

                      try {
                        widget.onDeleteConfirmed();
                        if (context.mounted) {
                          Navigator.of(context).pop(
                            true,
                          ); // Return true to indicate deletion started
                        }
                      } catch (e) {
                        if (context.mounted) {
                          setState(() {
                            _isDeleting = false;
                          });
                        }
                      }
                    },
            ),
            const Gap(12),

            // Cancel button (black filled)
            CustomElevatedButton(
              text: 'Cancel',
              buttonColor: CustomButtonColor.black,
              onPressed: _isDeleting
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

/// Helper function to show the delete account dialog
Future<bool?> showDeleteAccountDialog(
  BuildContext context, {
  required String userEmail,
  required VoidCallback onDeleteConfirmed,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => DeleteAccountDialog(
      userEmail: userEmail,
      onDeleteConfirmed: onDeleteConfirmed,
    ),
  );
}
