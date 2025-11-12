import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:savvy_bee_mobile/features/spend/data/repositories/kyc_repository.dart';
import 'package:savvy_bee_mobile/features/spend/data/repositories/transfer_repository.dart.dart';
import 'package:savvy_bee_mobile/features/tools/data/repositories/budget_repository.dart';
import 'package:savvy_bee_mobile/features/tools/data/repositories/goals_repository.dart';

import '../../features/auth/data/repositories/auth_repository.dart';
import '../../features/spend/data/repositories/wallet_repository.dart';
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

final transferRepositoryProvider = Provider<TransferRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return TransferRepository(apiClient: apiClient);
});

final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return WalletRepository(apiClient: apiClient);
});

final toolsRepositoryProvider = Provider<BudgetRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return BudgetRepository(apiClient: apiClient);
});

final kycRepositoryProvider = Provider<KycRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return KycRepository(apiClient: apiClient);
});

final goalsRepositoryProvider = Provider<GoalsRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return GoalsRepository(apiClient: apiClient);
});
