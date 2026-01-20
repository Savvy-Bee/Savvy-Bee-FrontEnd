import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:savvy_bee_mobile/core/network/api_client.dart';
import 'package:savvy_bee_mobile/core/services/service_locator.dart';
import 'package:savvy_bee_mobile/features/spend/data/repositories/kyc_repository.dart';
import 'package:savvy_bee_mobile/features/spend/domain/models/kyc.dart';

class KycNotifier extends AsyncNotifier<KycData?> {
  // Initial state is null, as we don't fetch anything at startup
  @override
  Future<KycData?> build() async {
    return null; // The initial state is empty KYC data.
  }

  /// Handles identity verification using the combined NIN->BVN fallback method.
  /// First attempts NIN verification, then BVN verification if NIN returns 409 conflict.
  Future<void> verifyIdentity({
    required String encryptedNin,
    required String encryptedBvn,
    required File profileImageFile,
  }) async {
    // Set state to loading
    state = const AsyncLoading<KycData?>().copyWithPrevious(state);

    // Get the repository from the service locator (ref)
    final KycRepository kycRepository = ref.read(kycRepositoryProvider);

    try {
      // Use the new combined verification method
      final response = await kycRepository.verifyIdentity(
        encryptedNin: encryptedNin,
        encryptedBvn: encryptedBvn,
        profileImageFile: profileImageFile,
      );

      // Set state to data with the successful KYC result
      if (response.success) {
        // Success case: use the data if available, or null if both 409
        state = AsyncData(response.data);
      } else {
        // Should not happen with the provided API logic, but good for safety
        state = AsyncError(response.message, StackTrace.current);
      }
    } on ApiException catch (e, st) {
      // Set state to error on API exception
      state = AsyncError(e, st);
    } catch (e, st) {
      // Set state to error on any other exception
      state = AsyncError(e, st);
    }
  }

  /// Function to manually reset the verification state
  void resetState() {
    state = const AsyncData(null);
  }
}

// Define the Identity Type Enum
// enum KycIdentityType { nin, bvn }

// Define the AsyncNotifierProvider
final kycNotifierProvider = AsyncNotifierProvider<KycNotifier, KycData?>(
  KycNotifier.new,
);
