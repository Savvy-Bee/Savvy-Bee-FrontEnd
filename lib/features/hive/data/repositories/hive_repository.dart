import 'package:dio/dio.dart';
import 'package:savvy_bee_mobile/core/network/api_client.dart';
import 'package:savvy_bee_mobile/core/network/api_endpoints.dart';
import 'package:savvy_bee_mobile/features/hive/domain/models/hive.dart';
import 'package:savvy_bee_mobile/features/hive/domain/models/streak.dart';

class HiveRepository {
  final ApiClient apiClient;

  HiveRepository({required this.apiClient});

  /// Get streak details
  /// GET /hive/streak/details
  Future<StreakResponse> getStreakDetails() async {
    try {
      final response = await apiClient.get(ApiEndpoints.streakDetails);
      return StreakResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Top up streak
  /// PUT /hive/streak/topup
  Future<bool> topUpStreak() async {
    try {
      final response = await apiClient.put(ApiEndpoints.streaktopUp);
      return response.statusCode == 200;
    } catch (e) {
      rethrow;
    }
  }

  /// Get hive details (includes achievements)
  /// GET /hive/details
  Future<HiveHomeResponse> getHiveDetails() async {
    try {
      final response = await apiClient.get(ApiEndpoints.hiveDetails);
      return HiveHomeResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Top up flowers or honey drops
  /// PUT /hive/operations/:id
  /// @param type - either "flower" or "honeydrop"
  /// @param amount - the amount to top up
  Future<bool> topUpResource({
    required String type,
    required int amount,
  }) async {
    try {
      final formData = FormData.fromMap({'Amount': amount.toString()});

      final response = await apiClient.put(
        ApiEndpoints.resourceTopUp(type),
        data: formData,
      );
      return response.statusCode == 200;
    } catch (e) {
      rethrow;
    }
  }

  /// Add achievement
  /// PUT /hive/operations/add/achievement
  /// @param name - Achievement name: "Bumble", "Honey", "Mason", "Orchid", "QueenBee", "QueensGaurd", "Royal"
  Future<Map<String, dynamic>> addAchievement({required String name}) async {
    try {
      final formData = FormData.fromMap({'Name': name});

      final response = await apiClient.put(
        ApiEndpoints.addAchievement,
        data: formData,
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}
