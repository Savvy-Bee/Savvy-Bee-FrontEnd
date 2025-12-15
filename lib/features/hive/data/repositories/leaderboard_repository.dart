import 'package:savvy_bee_mobile/core/network/api_client.dart';
import 'package:savvy_bee_mobile/core/network/api_endpoints.dart';
import 'package:savvy_bee_mobile/core/network/models/api_response_model.dart';

import '../../domain/models/leaderboard.dart';

class LeaderboardRepository {
  final ApiClient _apiClient;

  LeaderboardRepository({required ApiClient apiClient})
    : _apiClient = apiClient;

  /// Get leaderboard
  /// GET /hive/details/leaderboard
  Future<ApiResponse<LeaderboardData>> getLeaderboard() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.leaderboard);

      final data = ApiResponse.fromJson(
        response.data,
        (data) => LeaderboardData.fromJson(data),
      );

      return data;
    } catch (e) {
      rethrow;
    }
  }
}
