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

  /// Handles both NIN and BVN verification since the logic is similar.
  /// The specific API call is delegated to the repository.
  Future<void> verifyIdentity({
    required String encryptedData,
    required File profileImageFile,
    // required KycIdentityType type, // Use a clear enum for identity type
  }) async {
    // Set state to loading
    state = const AsyncLoading<KycData?>().copyWithPrevious(state);

    // Get the repository from the service locator (ref)
    final KycRepository kycRepository = ref.read(kycRepositoryProvider);

    try {
      KycVerificationResponse response;

      // if (type == KycIdentityType.nin) {
      response = await kycRepository
          .verifyNin(
            encryptedData: encryptedData,
            profileImageFile: profileImageFile,
          )
          .then((value) async {
            response = await kycRepository.verifyBvn(
              encryptedData: encryptedData,
              profileImageFile: profileImageFile,
            );
            return value;
          });
      // } else if (type == KycIdentityType.bvn) {
      // response = await kycRepository.verifyBvn(
      //   encryptedData: encryptedData,
      //   profileImageFile: profileImageFile,
      // );
      // } else {
      // Handle unexpected type
      // throw Exception('Unsupported KYC identity type.');
      // }

      // Set state to data with the successful KYC result
      if (response.data != null) {
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
