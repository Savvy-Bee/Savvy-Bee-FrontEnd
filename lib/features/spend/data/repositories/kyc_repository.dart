import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';

import 'package:savvy_bee_mobile/core/network/api_client.dart';
import 'package:savvy_bee_mobile/core/network/api_endpoints.dart';
import 'package:savvy_bee_mobile/features/spend/domain/models/kyc.dart';

class KycRepository {
  final ApiClient _apiClient;

  KycRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Verifies a National Identity Number (NIN)
  /// [encryptedData]: The encrypted stringified JSON containing the NIN.
  /// [profileImageFile]: The File object for the profile image.
  /// Returns [KycVerificationResponse] on success.
  Future<KycVerificationResponse> verifyNin({
    required String encryptedData,
    required File profileImageFile,
  }) async {
    try {
      final String fileName = profileImageFile.path.split('/').last;

      // Create FormData object for the multipart request
      final FormData formData = FormData.fromMap({
        'Data': encryptedData,
        'Profile': await MultipartFile.fromFile(
          profileImageFile.path,
          filename: fileName,
        ),
      });

      final response = await _apiClient.post(
        ApiEndpoints.verifyNin,
        data: formData,
      );

      // The response.data will be a Map<String, dynamic>
      return KycVerificationResponse.fromJson(response.data);
    } on ApiException {
      rethrow;
    } catch (e) {
      // Handle non-ApiException errors, if any, or rethrow
      throw ApiException(message: 'Failed to verify NIN: $e');
    }
  }

  /// Verifies a Bank Verification Number (BVN)
  /// [encryptedData]: The encrypted stringified JSON containing the BVN.
  /// [profileImageFile]: The File object for the profile image.
  /// Returns [KycVerificationResponse] on success.
  Future<KycVerificationResponse> verifyBvn({
    required String encryptedData,
    required File profileImageFile,
  }) async {
    try {
      final String fileName = profileImageFile.path.split('/').last;

      // Create FormData object for the multipart request
      final FormData formData = FormData.fromMap({
        'Data': encryptedData,
        'Profile': await MultipartFile.fromFile(
          profileImageFile.path,
          filename: fileName,
        ),
      });

      final response = await _apiClient.post(
        ApiEndpoints.verifyBvn,
        data: formData,
      );

      // The response.data will be a Map<String, dynamic>
      return KycVerificationResponse.fromJson(response.data);
    } on ApiException {
      rethrow;
    } catch (e) {
      // Handle non-ApiException errors, if any, or rethrow
      throw ApiException(message: 'Failed to verify BVN: $e');
    }
  }

  /// Combined identity verification that tries NIN first, then BVN on 409 conflict
  /// [encryptedNin]: The encrypted stringified JSON containing the NIN.
  /// [encryptedBvn]: The encrypted stringified JSON containing the BVN.
  /// [profileImageFile]: The File object for the profile image.
  /// Returns [KycVerificationResponse] on success.
  ///
  /// Note: BVN verification will always be attempted after successful NIN verification
  /// or when NIN returns 409 conflict. If both NIN and BVN return 409, returns success
  /// indicating both are already verified. If both succeed, returns NIN response.
  Future<KycVerificationResponse> verifyIdentity({
    required String encryptedNin,
    required String encryptedBvn,
    required File profileImageFile,
  }) async {
    try {
      // First attempt: Verify NIN
      final ninResponse = await verifyNin(
        encryptedData: encryptedNin,
        profileImageFile: profileImageFile,
      );

      // If NIN is successful, also verify BVN
      try {
        await verifyBvn(
          encryptedData: encryptedBvn,
          profileImageFile: profileImageFile,
        );
      } catch (e) {
        // Log BVN verification failure but don't fail the entire process
        // since NIN verification was successful
        log('BVN verification failed after successful NIN: $e');
      }

      return ninResponse;
    } on ApiException catch (e) {
      // If NIN verification returns 409 (Conflict), try BVN verification
      if (e.statusCode == 409) {
        try {
          final bvnResponse = await verifyBvn(
            encryptedData: encryptedBvn,
            profileImageFile: profileImageFile,
          );
          return bvnResponse;
        } on ApiException catch (bvnException) {
          // If BVN also returns 409, return success (both are already verified)
          if (bvnException.statusCode == 409) {
            return KycVerificationResponse(
              success: true,
              message: 'Both NIN and BVN are already verified',
              data: null,
            );
          }
          // Re-throw BVN exceptions that are not 409
          rethrow;
        } catch (e) {
          throw ApiException(
            message: 'Failed to verify BVN after NIN conflict: $e',
          );
        }
      }
      // Re-throw any other API exceptions
      rethrow;
    } catch (e) {
      // Handle non-ApiException errors
      throw ApiException(message: 'Failed to verify identity: $e');
    }
  }
}
