// lib/features/home/data/repositories/home_repository.dart

import 'package:savvy_bee_mobile/features/home/domain/models/home_data.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';

/// Repository class for handling home screen data fetching.
class HomeRepository {
  final ApiClient apiClient;

  HomeRepository({required this.apiClient});

  /// Fetches the user's dashboard data from the API.
  Future<HomeDataResponse> fetchHomeData() async {
    try {
      final response = await apiClient.get(ApiEndpoints.homeDashboard);

      // The response.data contains the raw JSON map which we pass to the model.
      return HomeDataResponse.fromJson(response.data);
    } catch (e) {
      // Re-throw the handled ApiException or catch other errors
      // and translate them into domain-specific exceptions if necessary.
      rethrow;
    }
  }
}