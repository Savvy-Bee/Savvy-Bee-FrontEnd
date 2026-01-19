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

      final data = ApiResponse.fromJson(
        response.data,
        (data) => (data as List).map((e) => MonoInstitution.fromJson(e)).toList(),
      );
      log('API Response: $response');
      log('Data response: ${data.toString()}');
      return data;
    } catch (e) {
      log("Error fetching institutions: $e");
      rethrow;
    }
  }

  /// Fetch Mono Input Data
  Future<ApiResponse<MonoInputData>> fetchMonoInputData() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.fetchMonoInputData);

      final data = ApiResponse.fromJson(
        response.data,
        (data) => MonoInputData.fromJson(data),
      );
      log('API Response: $response');
      log('Data response: ${data.toString()}');
      return data;
    } catch (e) {
      log("Error fetching mono input data: $e");
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

      final data = ApiResponse.fromJson(
        response.data,
        (data) => data as Map<String, dynamic>,
      );
      log('API Response: $response');
      log('Data response: ${data.toString()}');
      return data;
    } catch (e) {
      log("Error linking account: $e");
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

      final data = ApiResponse.fromJson(response.data, (data) => null);
      log('API Response: $response');
      log('Data response: ${data.toString()}');
      return data;
    } catch (e) {
      log("Error unlinking account: $e");
      rethrow;
    }
  }

  /// Fetch Linked Accounts
  Future<ApiResponse<List<LinkedAccount>>> fetchLinkedAccounts() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.linkedAccounts);

      final data = ApiResponse.fromJson(
        response.data,
        (data) => (data as List).map((e) => LinkedAccount.fromJson(e)).toList(),
      );
      log('API Response: $response');
      log('Data response: ${data.toString()}');
      return data;
    } catch (e) {
      log("Error fetching linked accounts: $e");
      rethrow;
    }
  }

  /// Fetch Dashboard Data
  /// Pass empty string or 'all' for all banks, or specific bankId for single bank
  Future<ApiResponse<DashboardDataResponse?>> fetchDashboardData(
    String bankId,
  ) async {
    try {
      final endpoint = bankId.isEmpty || bankId == 'all'
          ? '${ApiEndpoints.dashboardData}/id'
          : '${ApiEndpoints.dashboardData}/$bankId';

      final response = await _apiClient.get(endpoint);

      final data = ApiResponse.fromJson(
        response.data,
        (data) => data != null ? DashboardDataResponse.fromJson(data) : null,
      );
      log('API Response: $response');
      log('Data response: ${data.toString()}');
      return data;
    } catch (e) {
      log("Error fetching dashboard data: $e");
      rethrow;
    }
  }
}
