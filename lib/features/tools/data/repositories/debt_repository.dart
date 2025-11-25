import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:savvy_bee_mobile/core/network/api_client.dart';
import 'package:savvy_bee_mobile/core/network/api_endpoints.dart';
import 'package:savvy_bee_mobile/features/tools/domain/models/debt.dart';

class DebtRepository {
  final ApiClient _apiClient;

  DebtRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<DebtListResponse> getDebtHomeData() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.debtHome);

      if (response.data['success'] == true && response.data['data'] is List) {
        return DebtListResponse.fromJson(response.data);
      } else {
        throw ApiException(
          message: response.data['message'] ?? 'Failed to load debt data',
          statusCode: response.statusCode,
        );
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'An unexpected error occurred: $e');
    }
  }

  Future<DebtCreationResponse> createDebtStep1(
    DebtRequestModel debtData,
  ) async {
    try {
      final formData = FormData.fromMap(debtData.toJson());

      final response = await _apiClient.post(
        ApiEndpoints.createDebtStep('1'),
        data: formData,
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        log(response.toString());
        return DebtCreationResponse.fromJson(response.data);
      } else {
        throw ApiException(
          message: response.data['message'] ?? 'Failed to create debt',
          statusCode: response.statusCode,
        );
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'An unexpected error occurred: $e');
    }
  }

  Future<Map<String, dynamic>> createDebtStep2({
    required DebtCreationStep2Request reqBody,
  }) async {
    try {
      final formData = FormData.fromMap(reqBody.toJson());

      final response = await _apiClient.post(
        ApiEndpoints.createDebtStep('2'),
        data: formData,
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        return response.data['data'] as Map<String, dynamic>;
      } else {
        throw ApiException(
          message: response.data['message'] ?? 'Failed to complete debt step 2',
          statusCode: response.statusCode,
        );
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'An unexpected error occurred: $e');
    }
  }

  Future<Map<String, dynamic>> manualFundDebt(
    String debtId,
    String amount,
  ) async {
    try {
      final formData = FormData.fromMap({'Amount': amount});

      final response = await _apiClient.patch(
        ApiEndpoints.manualFundDebt(debtId),
        data: formData,
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        return response.data['data'] as Map<String, dynamic>;
      } else {
        throw ApiException(
          message: response.data['message'] ?? 'Failed to make payment',
          statusCode: response.statusCode,
        );
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'An unexpected error occurred: $e');
    }
  }
}
