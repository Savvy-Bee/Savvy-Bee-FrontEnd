import 'package:dio/dio.dart';
import 'package:savvy_bee_mobile/core/network/api_client.dart';
import 'package:savvy_bee_mobile/core/network/api_endpoints.dart';

class DebtRepository {
  final ApiClient _apiClient;

  DebtRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<List<dynamic>> getDebtHomeData() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.debtHome);

      if (response.data['success'] == true && response.data['data'] is List) {
        return response.data['data'] as List<dynamic>;
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

  Future<Map<String, dynamic>> createDebtStep1(
    Map<String, dynamic> debtData,
  ) async {
    try {
      final formData = FormData.fromMap(debtData);

      final response = await _apiClient.post(
        ApiEndpoints.createDebtStep('1'),
        data: formData,
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        return response.data['data'] as Map<String, dynamic>;
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
    required String debtId,
    required String bankCode,
    required String accountNumber,
  }) async {
    try {
      final formData = FormData.fromMap({
        'debtid': debtId,
        'code': bankCode,
        'acctNumber': accountNumber,
      });

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
