import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/core/widgets/custom_snackbar.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/providers/kyc_provider.dart';

import '../../../../../core/widgets/custom_button.dart';

import 'nin_verification_screen.dart'; // Import keys
import 'package:savvy_bee_mobile/features/spend/presentation/screens/wallet/wallet_creation_complete_screen.dart';

class LivePhotoScreen extends ConsumerStatefulWidget {
  static String path = '/live-photo';

  // NIN and BVN are passed via the GoRouter 'extra' property
  final Map<String, dynamic> data;

  const LivePhotoScreen({super.key, required this.data});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _LivePhotoScreenState();
}

class _LivePhotoScreenState extends ConsumerState<LivePhotoScreen> {
  // Mock image file for demonstration. In a real app, this would be captured by a camera plugin.
  File? _profileImageFile;

  @override
  void initState() {
    super.initState();
    // Simulate photo capture on init for demonstration
    // In a real app, this would be triggered by a button press and camera integration.
    _profileImageFile = File('mock_profile_image.jpg');
  }

  void _submitVerification() {
    final nin = widget.data[kKycNinKey] as String?;
    final bvn = widget.data[kKycBvnKey] as String?;

    // Check for required data
    if (nin == null || bvn == null || _profileImageFile == null) {
      CustomSnackbar.show(
        context,
        'Missing verification data (NIN, BVN, or Photo). Please restart the flow.',
        type: SnackbarType.error,
      );
      return;
    }

    // Use NIN as the encrypted data and KycIdentityType.nin as the identifier for the flow
    // This assumes the API accepts either NIN or BVN for the final verification step.
    // Given the sequential flow and the combined verification method, we use the primary identifier (NIN).
    ref
        .read(kycNotifierProvider.notifier)
        .verifyIdentity(
          // NOTE: In a real app, 'nin' would need to be encrypted before being passed as 'encryptedData'
          encryptedData: nin,
          profileImageFile: _profileImageFile!,
          type: KycIdentityType.nin,
        );
  }

  @override
  Widget build(BuildContext context) {
    final kycState = ref.watch(kycNotifierProvider);
    final isVerifying = kycState.isLoading;

    // Listener for API outcome
    ref.listen<AsyncValue<dynamic>>(kycNotifierProvider, (previous, next) {
      // We only care when loading is completed
      if (previous?.isLoading == true && !next.isLoading) {
        if (next.hasError) {
          // Handle Error: Show the custom snackbar
          final error = next.error.toString();
          CustomSnackbar.show(
            context,
            error.startsWith('Exception:')
                ? error.substring(10)
                : 'Identity verification failed. Please try again.',
            type: SnackbarType.error,
          );
          // Reset the state to allow a new attempt
          ref.read(kycNotifierProvider.notifier).resetState();
        } else if (next.hasValue && next.value != null) {
          // Handle Success: Navigate to completion screen
          context.goNamed(WalletCreationCompletionScreen.path);
        }
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Live Photo')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Placeholder for camera view or preview
            const Expanded(
              child: Center(
                child: Text(
                  "Camera View / Live Photo Capture Area",
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ),
            ),
            CustomElevatedButton(
              text: isVerifying ? 'Verifying...' : 'Submit Verification',
              onPressed: isVerifying || _profileImageFile == null
                  ? null
                  : _submitVerification,
              showArrow: false,
              isLoading: isVerifying,
              buttonColor: CustomButtonColor.black,
            ),
          ],
        ),
      ),
    );
  }
}
