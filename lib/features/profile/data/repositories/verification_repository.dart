// lib/features/spend/data/repositories/verification_repository.dart

import 'dart:convert';
import 'package:savvy_bee_mobile/core/network/api_client.dart';
import 'package:savvy_bee_mobile/features/profile/data/models/verification_models.dart';
import 'package:savvy_bee_mobile/features/profile/data/services/encryption_service.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

class VerificationRepository {
  final ApiClient apiClient;

  VerificationRepository({required this.apiClient});

  Future<VerificationResponse> verifyNin({
    required String nin,
    required File selfieFile,
  }) async {
    try {
      // Prepare NIN data as JSON string
      final ninData = jsonEncode({'Nin': nin});

      // Encrypt the NIN data
      final encryptedNin = EncryptionService.encryptData(nin);

      print('Original NIN data: $nin');
      print('Encrypted NIN: $encryptedNin');

      final formData = FormData.fromMap({
        'Data': encryptedNin,
        'Profile': await MultipartFile.fromFile(
          selfieFile.path,
          filename: 'selfie.jpg',
          contentType: MediaType('image', 'jpeg'), // or image/jpeg
        ),
      });

      // LOG what you are sending
      print('FormData fields: ${formData.fields}');
      print('FormData files: ${formData.files.map((e) => e.key)}');

      // Make the API call
      final response = await apiClient.post(
        '/auth/kyc/identity-number/nin/ng',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      // Parse and return the response
      return VerificationResponse.fromJson(response.data);
    } catch (e) {
      print('NIN Verification error: $e');
      rethrow;
    }
  }

  Future<VerificationResponse> verifyBvn({
    required String bvn,
    required File selfieFile,
  }) async {
    try {
      final bvnData = jsonEncode({'BVN': bvn});
      final encryptedBvn = EncryptionService.encryptData(bvn);

      print('Original BVN data: $bvn');
      print('Encrypted BVN: $encryptedBvn');

      final formData = FormData.fromMap({
        'Data': encryptedBvn,
        'Profile': await MultipartFile.fromFile(
          selfieFile.path,
          filename: 'selfie.jpg',
          contentType: MediaType('image', 'jpeg'), // or image/jpeg
        ),
      });

      // LOG what you are sending
      print('FormData fields: ${formData.fields}');
      print('FormData files: ${formData.files.map((e) => e.key)}');

      final response = await apiClient.post(
        '/auth/kyc/identity-number/bvn/ng',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      return VerificationResponse.fromJson(response.data);
    } catch (e) {
      print('BVN Verification error: $e');
      rethrow;
    }
  }
}
