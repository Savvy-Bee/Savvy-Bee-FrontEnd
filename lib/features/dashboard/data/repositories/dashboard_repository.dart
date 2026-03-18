import 'dart:developer';

import 'package:savvy_bee_mobile/core/network/api_client.dart';
import 'package:savvy_bee_mobile/core/network/api_endpoints.dart';
import 'package:savvy_bee_mobile/core/network/models/api_response_model.dart';
import 'package:savvy_bee_mobile/features/dashboard/domain/models/dashboard_data.dart';
import 'package:savvy_bee_mobile/features/spend/domain/models/mono_institution.dart';

import '../../domain/models/linked_account.dart';

class DashboardRepository {
  final ApiClient _apiClient;

  DashboardRepository(this._apiClient);

  /// Fetch Institutions/Banks
  Future<ApiResponse<List<MonoInstitution>>> fetchInstitutions() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.fetchInstitutions);
      log("[Dashboard] fetchInstitutions SUCCESS\nEndpoint: ${ApiEndpoints.fetchInstitutions}\nResponse: ${response.data}");

      final data = ApiResponse.fromJson(
        response.data,
        (data) =>
            (data as List).map((e) => MonoInstitution.fromJson(e)).toList(),
      );
      return data;
    } catch (e) {
      log("[Dashboard] fetchInstitutions ERROR\nEndpoint: ${ApiEndpoints.fetchInstitutions}\nError: $e");
      rethrow;
    }
  }

  /// Fetch Mono Input Data
  Future<ApiResponse<MonoInputData>> fetchMonoInputData() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.fetchMonoInputData);
      log("[Dashboard] fetchMonoInputData SUCCESS\nEndpoint: ${ApiEndpoints.fetchMonoInputData}\nResponse: ${response.data}");

      final data = ApiResponse.fromJson(
        response.data,
        (data) => MonoInputData.fromJson(data),
      );
      return data;
    } catch (e) {
      log("[Dashboard] fetchMonoInputData ERROR\nEndpoint: ${ApiEndpoints.fetchMonoInputData}\nError: $e");
      rethrow;
    }
  }

  /// Link Account
  Future<ApiResponse<Map<String, dynamic>>> linkAccount({
    required String code,
  }) async {
    try {
      final formData = {'code': code};

      final response = await _apiClient.post(
        ApiEndpoints.linkAccount,
        data: formData,
      );
      log("[Dashboard] linkAccount SUCCESS\nEndpoint: ${ApiEndpoints.linkAccount}\nResponse: ${response.data}");

      final data = ApiResponse.fromJson(
        response.data,
        (data) => data as Map<String, dynamic>,
      );
      return data;
    } catch (e) {
      log("[Dashboard] linkAccount ERROR\nEndpoint: ${ApiEndpoints.linkAccount}\nError: $e");
      rethrow;
    }
  }

  /// Unlink Account
  Future<ApiResponse<void>> unlinkAccount({
    required String accountId,
    required String code,
    required String accountName,
  }) async {
    try {
      final formData = {'code': code, 'AcountName': accountName};

      final response = await _apiClient.delete(
        '${ApiEndpoints.unlinkAccount}/$accountId',
        data: formData,
      );
      log("[Dashboard] unlinkAccount SUCCESS\nEndpoint: ${ApiEndpoints.unlinkAccount}/$accountId\nResponse: ${response.data}");

      final data = ApiResponse.fromJson(response.data, (data) => null);
      return data;
    } catch (e) {
      log("[Dashboard] unlinkAccount ERROR\nEndpoint: ${ApiEndpoints.unlinkAccount}/$accountId\nError: $e");
      rethrow;
    }
  }

  /// Fetch Linked Accounts
  Future<ApiResponse<List<LinkedAccount>>> fetchLinkedAccounts() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.linkedAccounts);
      log("[Dashboard] fetchLinkedAccounts SUCCESS\nEndpoint: ${ApiEndpoints.linkedAccounts}\nResponse: ${response.data}");

      final data = ApiResponse.fromJson(
        response.data,
        (data) => (data as List).map((e) => LinkedAccount.fromJson(e)).toList(),
      );
      return data;
    } catch (e) {
      log("[Dashboard] fetchLinkedAccounts ERROR\nEndpoint: ${ApiEndpoints.linkedAccounts}\nError: $e");
      rethrow;
    }
  }

  /// Fetch Dashboard Data
  /// Pass empty string or 'all' for all banks, or specific bankId for single bank
  ///
  /// FIXED: The API response structure is:
  /// {
  ///   "success": true,
  ///   "message": "Data fetched successfully",
  ///   "data": {
  ///     "isMultiAccount": false,
  ///     "accounts": [...],
  ///     "netAnalysis": {...},
  ///     ...
  ///   }
  /// }
  ///
  /// But the "data" object itself doesn't have "success" field,
  /// so we need to parse it as DashboardData directly, not DashboardDataResponse
  Future<ApiResponse<DashboardData?>> fetchDashboardData(String bankId) async {
    try {
      final endpoint = bankId.isEmpty || bankId == 'all'
          ? '${ApiEndpoints.dashboardData}/id'
          : '${ApiEndpoints.dashboardData}/$bankId';

      log("[Dashboard] fetchDashboardData calling\nEndpoint: $endpoint");

      final response = await _apiClient.get(endpoint);
      log("[Dashboard] fetchDashboardData SUCCESS\nEndpoint: $endpoint\nResponse: ${response.data}");

      final data = ApiResponse.fromJson(response.data, (json) {
        if (json == null) return null;
        return DashboardData.fromJson(json as Map<String, dynamic>);
      });

      return data;
    } catch (e, stackTrace) {
      log("[Dashboard] fetchDashboardData ERROR\nError: $e\nStack trace: $stackTrace");
      rethrow;
    }
  }

  /// Fetch Reauth URL for an account
  Future<ApiResponse<String>> reauthorizeAccount(String accountId) async {
    final endpoint = '${ApiEndpoints.reauthorizeAccount}/$accountId';
    try {
      final response = await _apiClient.get(endpoint);
      log("[Dashboard] reauthorizeAccount SUCCESS\nEndpoint: $endpoint\nResponse: ${response.data}");

      final data = ApiResponse.fromJson(response.data, (json) {
        final innerData =
            (json as Map<String, dynamic>)['data'] as Map<String, dynamic>?;
        return innerData?['mono_url'] as String?;
      });

      return data;
    } catch (e) {
      log("[Dashboard] reauthorizeAccount ERROR\nEndpoint: $endpoint\nError: $e");
      rethrow;
    }
  }
}
