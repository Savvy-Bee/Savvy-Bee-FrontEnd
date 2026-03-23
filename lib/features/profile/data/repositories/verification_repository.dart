// lib/features/profile/data/repositories/verification_repository.dart

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart'; // XFile
import 'package:savvy_bee_mobile/core/network/api_client.dart';
import 'package:savvy_bee_mobile/features/profile/data/models/verification_models.dart';
import 'package:savvy_bee_mobile/features/profile/data/services/encryption_service.dart';

class VerificationRepository {
  final ApiClient apiClient;

  VerificationRepository({required this.apiClient});

  Future<VerificationResponse> verifyNin({
    required String nin,
    required XFile selfieFile,
  }) async {
    try {
      // ignore: unused_local_variable
      final ninData = jsonEncode({'Nin': nin});
      final encryptedNin = EncryptionService.encryptData(nin);

      final formData = FormData.fromMap({
        'Data': encryptedNin,
        'Profile': MultipartFile.fromBytes(
          await selfieFile.readAsBytes(),
          filename: selfieFile.name.isNotEmpty ? selfieFile.name : 'selfie.jpg',
          contentType: MediaType('image', 'jpeg'),
        ),
      });

      final response = await apiClient.post(
        '/auth/kyc/identity-number/nin/ng',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      final responseData = response.data;
      if (responseData is! Map<String, dynamic>) {
        throw Exception('Unexpected NIN response format');
      }
      return VerificationResponse.fromJson(responseData);
    } catch (e) {
      debugPrintVerificationError('NIN', e);
      rethrow;
    }
  }

  Future<VerificationResponse> verifyBvn({
    required String bvn,
    required XFile selfieFile,
  }) async {
    try {
      // ignore: unused_local_variable
      final bvnData = jsonEncode({'BVN': bvn});
      final encryptedBvn = EncryptionService.encryptData(bvn);

      final formData = FormData.fromMap({
        'Data': encryptedBvn,
        'Profile': MultipartFile.fromBytes(
          await selfieFile.readAsBytes(),
          filename: selfieFile.name.isNotEmpty ? selfieFile.name : 'selfie.jpg',
          contentType: MediaType('image', 'jpeg'),
        ),
      });

      final response = await apiClient.post(
        '/auth/kyc/identity-number/bvn/ng',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      final responseData = response.data;
      if (responseData is! Map<String, dynamic>) {
        throw Exception('Unexpected BVN response format');
      }
      return VerificationResponse.fromJson(responseData);
    } catch (e) {
      debugPrintVerificationError('BVN', e);
      rethrow;
    }
  }

  void debugPrintVerificationError(String type, Object e) {
    // Using debugPrint keeps logs out of production; avoids dart:developer import
    // ignore: avoid_print
    print('$type Verification error: $e');
  }
}
