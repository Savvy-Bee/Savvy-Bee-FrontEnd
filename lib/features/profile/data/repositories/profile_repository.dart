import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/models/api_response_model.dart';

class ProfileRepository {
  final ApiClient _apiClient;

  ProfileRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<ApiResponse> updateProfileAvatar(String avatarName) async {
    try {
      final response = await _apiClient.patch(
        ApiEndpoints.updateProfileAvatar,
        data: {'Name': avatarName},
      );

      final data = ApiResponse.fromJson(response.data, (_) => null);

      return data;
    } catch (e) {
      rethrow;
    }
  }
}
