import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/data/repositories/auth_repository.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import 'storage_service.dart';

// Service locator providers
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(baseUrl: ApiEndpoints.baseUrl);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final storageService = ref.watch(storageServiceProvider);

  return AuthRepository(apiClient: apiClient, storageService: storageService);
});
