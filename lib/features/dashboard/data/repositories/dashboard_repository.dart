import 'dart:developer';

import 'package:savvy_bee_mobile/core/network/api_client.dart';
import 'package:savvy_bee_mobile/core/network/api_endpoints.dart';
import 'package:savvy_bee_mobile/core/network/models/api_response_model.dart';
import 'package:savvy_bee_mobile/core/services/storage_service.dart';
import 'package:savvy_bee_mobile/features/dashboard/domain/models/dashboard_data.dart';
import 'package:savvy_bee_mobile/features/spend/domain/models/institution.dart';

class DashboardRepository {
  final ApiClient _apiClient;

  DashboardRepository(this._apiClient);

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
      log("Error: $e");
      rethrow;
    }
  }

  /// Fetch Dashboard Data
  Future<ApiResponse<DashboardData>> fetchDashboardData(String bankId) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.dashboardData);

      final data = ApiResponse.fromJson(
        response.data,
        (data) => DashboardData.fromJson(data),
      );
      log('API Response: $response');
      log('Data response: ${data.toString()}');
      return data;
    } catch (e) {
      log("Error: $e");
      rethrow;
    }
  }
}
