import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/features/auth/presentation/providers/biometric_provider.dart';

/// Modal bottom sheet that prompts the user to enable biometric login
/// right after a successful password-based login.
///
/// Pops with `true` if the user enabled biometrics, `false`/`null` otherwise.
/// Callers should navigate to home regardless of the result.
class BiometricEnrollmentSheet extends ConsumerWidget {
  final String userEmail;

  const BiometricEnrollmentSheet({super.key, required this.userEmail});

  static Future<bool?> show(BuildContext context, String userEmail) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BiometricEnrollmentSheet(userEmail: userEmail),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final biometric = ref.watch(biometricProvider);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        24 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.greyMid,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Gap(24),

          // Icon
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: AppColors.primaryFaint,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.fingerprint_rounded,
              size: 40,
              color: AppColors.primary,
            ),
          ),
          const Gap(20),

          // Headline
          const Text(
            'Enable Biometric Login',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              fontFamily: 'Excon',
              color: AppColors.textPrimary,
            ),
          ),
          const Gap(8),

          // Body
          const Text(
            'Skip typing your password next time.\nUse your fingerprint or Face ID to log in instantly.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'GeneralSans',
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const Gap(32),

          // Enable button
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: biometric.isAuthenticating
                  ? null
                  : () => _enable(context, ref),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: biometric.isAuthenticating
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.black,
                      ),
                    )
                  : const Icon(Icons.fingerprint_rounded, size: 20),
              label: Text(
                biometric.isAuthenticating ? 'Confirming…' : 'Enable Biometrics',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'GeneralSans',
                ),
              ),
            ),
          ),
          const Gap(12),

          // Not now
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed:
                  biometric.isAuthenticating ? null : () => Navigator.pop(context, false),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                'Not Now',
                style: TextStyle(
                  fontSize: 15,
                  fontFamily: 'GeneralSans',
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _enable(BuildContext context, WidgetRef ref) async {
    final success =
        await ref.read(biometricProvider.notifier).enableBiometrics(userEmail);
    if (context.mounted) {
      Navigator.pop(context, success);
    }
  }
}
