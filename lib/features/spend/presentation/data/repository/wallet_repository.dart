// class WalletRepository {
import 'package:dio/dio.dart';
import 'package:savvy_bee_mobile/core/network/api_endpoints.dart';
import 'package:savvy_bee_mobile/core/network/models/api_response_model.dart';
import 'package:savvy_bee_mobile/features/spend/domain/models/institution.dart';

import '../../../../../core/network/api_client.dart';
import '../../../../../core/services/storage_service.dart';

class WalletRepository {
  final ApiClient _apiClient;
  final StorageService _storageService;

  WalletRepository({
    required ApiClient apiClient,
    required StorageService storageService,
  }) : _apiClient = apiClient,
       _storageService = storageService;

  /// Initialize auth token from storage
  Future<void> initializeAuth() async {
    final token = await _storageService.getAuthToken();
    if (token != null && token.isNotEmpty) {
      _apiClient.setAuthToken(token);
    }
  }

  // ========================================================================
  // Mono Link Account APIs
  // ========================================================================

  /// Fetch available institutions/banks
  Future<ApiResponse<List<Institution>>> fetchInstitutions() async {
    try {
      await initializeAuth();

      final response = await _apiClient.get(ApiEndpoints.fetchInstitutions);

      final List<Institution> institutions = (response.data['data'] as List)
          .map((json) => Institution.fromJson(json))
          .toList();

      return ApiResponse(
        success: response.data['success'] as bool,
        message: response.data['message'] as String,
        data: institutions,
      );
    } on ApiException catch (e) {
      throw ApiException(
        message: e.message,
        statusCode: e.statusCode,
        data: e.data,
      );
    } catch (e) {
      throw ApiException(message: 'Failed to fetch institutions: $e');
    }
  }

  /// Fetch Mono input data for current user
  Future<ApiResponse<MonoInputData>> fetchMonoInputData() async {
    try {
      await initializeAuth();

      final response = await _apiClient.get(ApiEndpoints.fetchMonoInputData);

      final inputData = MonoInputData.fromJson(response.data['data']);

      return ApiResponse(
        success: response.data['success'] as bool,
        message: response.data['message'] as String,
        data: inputData,
      );
    } on ApiException catch (e) {
      throw ApiException(
        message: e.message,
        statusCode: e.statusCode,
        data: e.data,
      );
    } catch (e) {
      throw ApiException(message: 'Failed to fetch Mono input data: $e');
    }
  }

  /// Link a bank account using Mono code
  Future<ApiResponse<dynamic>> linkAccount({
    required String code,
    required String accountName,
  }) async {
    try {
      await initializeAuth();

      final formData = FormData.fromMap({
        'code': code,
        'AcountName': accountName, // Note: API has typo "Account"
      });

      final response = await _apiClient.post(
        ApiEndpoints.linkAccount,
        data: formData,
      );

      return ApiResponse(
        success: response.data['success'] as bool,
        message: response.data['message'] as String,
        data: response.data['data'],
      );
    } on ApiException catch (e) {
      throw ApiException(
        message: e.message,
        statusCode: e.statusCode,
        data: e.data,
      );
    } catch (e) {
      throw ApiException(message: 'Failed to link account: $e');
    }
  }

  /// Fetch all linked accounts for current user
  Future<ApiResponse<List<LinkedAccount>>> fetchAllLinkedAccounts() async {
    try {
      await initializeAuth();

      final response = await _apiClient.get(ApiEndpoints.allLinkedAccounts);

      final List<LinkedAccount> accounts = (response.data['data'] as List)
          .map((json) => LinkedAccount.fromJson(json))
          .toList();

      return ApiResponse(
        success: response.data['success'] as bool,
        message: response.data['message'] as String,
        data: accounts,
      );
    } on ApiException catch (e) {
      throw ApiException(
        message: e.message,
        statusCode: e.statusCode,
        data: e.data,
      );
    } catch (e) {
      throw ApiException(message: 'Failed to fetch linked accounts: $e');
    }
  }

  // ========================================================================
  // Account Creation
  // ========================================================================

  /// Create Naira account
  Future<ApiResponse<dynamic>> createNairaAccount() async {
    try {
      await initializeAuth();

      final response = await _apiClient.get(ApiEndpoints.createNairaAccount);

      return ApiResponse(
        success: response.data['success'] as bool,
        message: response.data['message'] as String,
        data: response.data['data'],
      );
    } on ApiException catch (e) {
      throw ApiException(
        message: e.message,
        statusCode: e.statusCode,
        data: e.data,
      );
    } catch (e) {
      throw ApiException(message: 'Failed to create Naira account: $e');
    }
  }
}
