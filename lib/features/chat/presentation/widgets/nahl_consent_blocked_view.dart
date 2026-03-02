import 'package:flutter/material.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:savvy_bee_mobile/features/chat/data/services/nahl_consent_service.dart';
import 'package:savvy_bee_mobile/features/chat/presentation/widgets/nahl_consent_dialog.dart';

/// Full-screen placeholder shown when the user has declined consent.
/// Provides an "Accept & Continue" path without re-navigating.
class NahlConsentBlockedView extends StatelessWidget {
  /// Called after the user accepts consent inside this view.
  final VoidCallback onConsentGranted;

  const NahlConsentBlockedView({super.key, required this.onConsentGranted});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lock_outline_rounded,
                size: 48,
                color: Colors.orange.shade700,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Nahl Chat is unavailable',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                fontFamily: 'GeneralSans',
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'You declined to share your data with OpenAI. '
              'Nahl Chat requires this to generate AI responses.\n\n'
              'You can change your mind at any time by tapping below.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'GeneralSans',
                color: Colors.grey,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.check_circle_outline),
                label: const Text(
                  'Accept & Continue',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'GeneralSans',
                  ),
                ),
                onPressed: () async {
                  final agreed = await showNahlConsentDialog(context);
                  if (agreed == true) {
                    await NahlConsentService.saveConsent(true);
                    onConsentGranted();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
