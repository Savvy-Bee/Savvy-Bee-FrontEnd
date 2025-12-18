import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:savvy_bee_mobile/features/hive/data/repositories/hive_repository.dart';
import 'package:savvy_bee_mobile/features/home/data/repositories/home_repository.dart';
import 'package:savvy_bee_mobile/features/spend/data/repositories/kyc_repository.dart';
import 'package:savvy_bee_mobile/features/spend/data/repositories/transfer_repository.dart.dart';
import 'package:savvy_bee_mobile/features/tools/data/repositories/budget_repository.dart';
import 'package:savvy_bee_mobile/features/tools/data/repositories/goals_repository.dart';

import '../../features/auth/data/repositories/auth_repository.dart';
import '../../features/dashboard/data/repositories/dashboard_repository.dart';
import '../../features/hive/data/repositories/leaderboard_repository.dart';
import '../../features/profile/data/repositories/profile_repository.dart';
import '../../features/spend/data/repositories/bills_repository.dart';
import '../../features/spend/data/repositories/wallet_repository.dart';
import '../../features/tools/data/repositories/debt_repository.dart';
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

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return HomeRepository(apiClient: apiClient);
});

final debtRepositoryProvider = Provider<DebtRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return DebtRepository(apiClient: apiClient);
});

final hiveRepositoryProvider = Provider<HiveRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return HiveRepository(apiClient: apiClient);
});

final billsRepositoryProvider = Provider<BillsRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return BillsRepository(apiClient: apiClient);
});

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  var apiClient = ref.read(apiClientProvider);

  return DashboardRepository(apiClient);
});

final leaderboardRepositoryProvider = Provider<LeaderboardRepository>((ref) {
  var apiClient = ref.read(apiClientProvider);
  return LeaderboardRepository(apiClient: apiClient);
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  var apiClient = ref.read(apiClientProvider);
  return ProfileRepository(apiClient: apiClient);
});
