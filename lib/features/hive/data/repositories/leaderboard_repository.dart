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
  Future<ApiResponse<List<LeaderboardEntry>>> getLeaderboard() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.leaderboard);

      final data = ApiResponse.fromJson(response.data, (data) {
        // Handle case where data might be the whole response object
        if (data is Map<String, dynamic> && data.containsKey('data')) {
          final list = data['data'] as List;
          return list
              .map((e) => LeaderboardEntry.fromJson(e as Map<String, dynamic>))
              .toList();
        }

        // Handle case where data is already the list
        if (data is List) {
          return data
              .map((e) => LeaderboardEntry.fromJson(e as Map<String, dynamic>))
              .toList();
        }

        return <LeaderboardEntry>[];
      });

      return data;
    } catch (e) {
      rethrow;
    }
  }
}
