import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart'; // XFile

import 'package:savvy_bee_mobile/core/network/api_client.dart';
import 'package:savvy_bee_mobile/core/network/api_endpoints.dart';
import 'package:savvy_bee_mobile/features/spend/domain/models/kyc.dart';

class KycRepository {
  final ApiClient _apiClient;

  KycRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Verifies a National Identity Number (NIN).
  /// [profileImageFile] is an [XFile] — works on both mobile and web.
  Future<KycVerificationResponse> verifyNin({
    required String encryptedData,
    required XFile profileImageFile,
  }) async {
    try {
      final FormData formData = FormData.fromMap({
        'Data': encryptedData,
        'Profile': MultipartFile.fromBytes(
          await profileImageFile.readAsBytes(),
          filename: profileImageFile.name,
        ),
      });

      final response = await _apiClient.post(
        ApiEndpoints.verifyNin,
        data: formData,
      );

      return KycVerificationResponse.fromJson(response.data);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Failed to verify NIN: $e');
    }
  }

  /// Verifies a Bank Verification Number (BVN).
  /// [profileImageFile] is an [XFile] — works on both mobile and web.
  Future<KycVerificationResponse> verifyBvn({
    required String encryptedData,
    required XFile profileImageFile,
  }) async {
    try {
      final FormData formData = FormData.fromMap({
        'Data': encryptedData,
        'Profile': MultipartFile.fromBytes(
          await profileImageFile.readAsBytes(),
          filename: profileImageFile.name,
        ),
      });

      final response = await _apiClient.post(
        ApiEndpoints.verifyBvn,
        data: formData,
      );

      return KycVerificationResponse.fromJson(response.data);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Failed to verify BVN: $e');
    }
  }

  /// Combined identity verification — tries NIN first, then BVN on 409.
  Future<KycVerificationResponse> verifyIdentity({
    required String encryptedNin,
    required String encryptedBvn,
    required XFile profileImageFile,
  }) async {
    try {
      final ninResponse = await verifyNin(
        encryptedData: encryptedNin,
        profileImageFile: profileImageFile,
      );

      try {
        await verifyBvn(
          encryptedData: encryptedBvn,
          profileImageFile: profileImageFile,
        );
      } catch (e) {
        log('BVN verification failed after successful NIN: $e');
      }

      return ninResponse;
    } on ApiException catch (e) {
      if (e.statusCode == 409) {
        try {
          return await verifyBvn(
            encryptedData: encryptedBvn,
            profileImageFile: profileImageFile,
          );
        } on ApiException catch (bvnException) {
          if (bvnException.statusCode == 409) {
            return KycVerificationResponse(
              success: true,
              message: 'Both NIN and BVN are already verified',
              data: null,
            );
          }
          rethrow;
        } catch (e) {
          throw ApiException(
            message: 'Failed to verify BVN after NIN conflict: $e',
          );
        }
      }
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Failed to verify identity: $e');
    }
  }
}
