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
}
