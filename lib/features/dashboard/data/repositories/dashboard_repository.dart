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
        (data) =>
            (data as List).map((e) => MonoInstitution.fromJson(e)).toList(),
      );
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
      return data;
    } catch (e) {
      log("Error fetching linked accounts: $e");
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

      print('🌐 API Call: $endpoint');

      final response = await _apiClient.get(endpoint);

      print('🌐 Response received');
      print('🌐 Response data type: ${response.data?.runtimeType}');

      // The ApiClient already wraps the response in ApiResponse structure
      // response.data = {success: true, message: "...", data: {...}}

      final data = ApiResponse.fromJson(response.data, (json) {
        if (json == null) {
          print('⚠️ JSON is null');
          return null;
        }

        print('📦 Parsing dashboard data...');
        print('📦 JSON keys: ${(json as Map).keys.toList()}');

        // Parse the "data" field directly as DashboardData
        // NOT as DashboardDataResponse
        return DashboardData.fromJson(json as Map<String, dynamic>);
      });

      print('✅ Dashboard data parsed');
      print('✅ Has data: ${data.data != null}');
      if (data.data != null) {
        print('✅ Accounts: ${data.data!.accounts.length}');
        if (data.data!.accounts.isNotEmpty) {
          print(
            '✅ First account transactions: ${data.data!.accounts[0].history12Months.length}',
          );
        }
      }

      return data;
    } catch (e, stackTrace) {
      log("Error fetching dashboard data: $e");
      log("Stack trace: $stackTrace");
      rethrow;
    }
  }

  /// Fetch Reauth URL for an account
  Future<ApiResponse<String>> reauthorizeAccount(String accountId) async {
    try {
      final response = await _apiClient.get(
        '${ApiEndpoints.reauthorizeAccount}/$accountId',
      );

      final data = ApiResponse.fromJson(response.data, (json) {
        final innerData =
            (json as Map<String, dynamic>)['data'] as Map<String, dynamic>?;
        return innerData?['mono_url'] as String?;
      });

      return data;
    } catch (e) {
      log("Error fetching reauth URL: $e");
      rethrow;
    }
  }
}
