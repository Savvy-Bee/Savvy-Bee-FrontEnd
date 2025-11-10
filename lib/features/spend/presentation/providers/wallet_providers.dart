// import 'package:flutter_riverpod/flutter_riverpod.dart';

// import '../../../../core/network/api_client.dart';
// import '../../../../core/services/service_locator.dart';
// import '../../domain/models/institution.dart';
// import '../data/repository/wallet_repository.dart';

// /// Wallet Repository provider
// final walletRepositoryProvider = Provider<WalletRepository>((ref) {
//   final apiClient = ref.watch(apiClientProvider);
//   final storageService = ref.watch(storageServiceProvider);

//   return WalletRepository(apiClient: apiClient, storageService: storageService);
// });

// // ============================================================================
// // State Providers for API Calls
// // ============================================================================

// /// Fetch institutions state
// final institutionsProvider = FutureProvider<List<Institution>>((ref) async {
//   final repository = ref.watch(walletRepositoryProvider);
//   final response = await repository.fetchInstitutions();

//   if (response.success && response.data != null) {
//     return response.data!;
//   } else {
//     throw ApiException(message: response.message);
//   }
// });

// /// Fetch Mono input data state
// final monoInputDataProvider = FutureProvider<MonoInputData>((ref) async {
//   final repository = ref.watch(walletRepositoryProvider);
//   final response = await repository.fetchMonoInputData();

//   if (response.success && response.data != null) {
//     return response.data!;
//   } else {
//     throw ApiException(message: response.message);
//   }
// });

// /// Fetch linked accounts state
// final linkedAccountsProvider = FutureProvider.autoDispose<List<LinkedAccount>>((
//   ref,
// ) async {
//   final repository = ref.watch(walletRepositoryProvider);
//   final response = await repository.fetchAllLinkedAccounts();

//   if (response.success && response.data != null) {
//     return response.data!;
//   } else {
//     throw ApiException(message: response.message);
//   }
// });

// // ============================================================================
// // Notifier for Account Linking
// // ============================================================================

// class LinkAccountNotifier extends StateNotifier<AsyncValue<String?>> {
//   final WalletRepository _repository;

//   LinkAccountNotifier(this._repository) : super(const AsyncValue.data(null));

//   Future<void> linkAccount({
//     required String code,
//     required String accountName,
//   }) async {
//     state = const AsyncValue.loading();

//     try {
//       final response = await _repository.linkAccount(
//         code: code,
//         accountName: accountName,
//       );

//       if (response.success) {
//         state = AsyncValue.data(response.message);
//       } else {
//         state = AsyncValue.error(
//           ApiException(message: response.message),
//           StackTrace.current,
//         );
//       }
//     } on ApiException catch (e, stack) {
//       state = AsyncValue.error(e, stack);
//     } catch (e, stack) {
//       state = AsyncValue.error(
//         ApiException(message: 'Unexpected error: $e'),
//         stack,
//       );
//     }
//   }

//   void reset() {
//     state = const AsyncValue.data(null);
//   }
// }

// final linkAccountProvider =
//     StateNotifierProvider.autoDispose<LinkAccountNotifier, AsyncValue<String?>>(
//       (ref) {
//         final repository = ref.watch(walletRepositoryProvider);
//         return LinkAccountNotifier(repository);
//       },
//     );

// // ============================================================================
// // Notifier for Account Creation
// // ============================================================================

// class CreateAccountNotifier extends StateNotifier<AsyncValue<dynamic>> {
//   final WalletRepository _repository;

//   CreateAccountNotifier(this._repository) : super(const AsyncValue.data(null));

//   Future<void> createNairaAccount() async {
//     state = const AsyncValue.loading();

//     try {
//       final response = await _repository.createNairaAccount();

//       if (response.success) {
//         state = AsyncValue.data(response.data);
//       } else {
//         state = AsyncValue.error(
//           ApiException(message: response.message),
//           StackTrace.current,
//         );
//       }
//     } on ApiException catch (e, stack) {
//       state = AsyncValue.error(e, stack);
//     } catch (e, stack) {
//       state = AsyncValue.error(
//         ApiException(message: 'Unexpected error: $e'),
//         stack,
//       );
//     }
//   }

//   void reset() {
//     state = const AsyncValue.data(null);
//   }
// }

// final createAccountProvider =
//     StateNotifierProvider.autoDispose<
//       CreateAccountNotifier,
//       AsyncValue<dynamic>
//     >((ref) {
//       final repository = ref.watch(walletRepositoryProvider);
//       return CreateAccountNotifier(repository);
//     });
