import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:savvy_bee_mobile/core/services/service_locator.dart';
import 'package:savvy_bee_mobile/features/dashboard/domain/models/dashboard_data.dart';
import 'package:savvy_bee_mobile/features/spend/domain/models/mono_institution.dart';

import '../../domain/models/linked_account.dart';

// Dashboard Data Notifier - FIXED
class DashboardDataNotifier
    extends AutoDisposeFamilyAsyncNotifier<DashboardData?, String> {
  @override
  Future<DashboardData?> build(String bankId) async {
    print('🔄 DashboardDataNotifier.build called with bankId: $bankId');

    final repository = ref.read(dashboardRepositoryProvider);
    final response = await repository.fetchDashboardData(bankId);

    print('🔄 Response success: ${response.success}');
    print('🔄 Response message: ${response.message}');
    print('🔄 Response data null: ${response.data == null}');

    if (response.data != null) {
      print('✅ Dashboard data exists');
      print('✅ Accounts: ${response.data!.accounts.length}');
      print('✅ Savings: ${response.data!.savings.length}');

      if (response.data!.accounts.isNotEmpty) {
        print(
          '✅ First account balance: ${response.data!.accounts[0].details.balance}',
        );
        print(
          '✅ First account transactions: ${response.data!.accounts[0].history12Months.length}',
        );
      }
    } else {
      print('⚠️ Dashboard data is null');
    }

    // Return the data directly (it's already DashboardData, not wrapped)
    return response.data;
  }

  Future<void> refresh() async {
    print('🔄 Refreshing dashboard data...');
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(dashboardRepositoryProvider);
      final response = await repository.fetchDashboardData(arg);

      if (response.data == null) {
        throw Exception(response.message);
      }

      return response.data!;
    });
  }
}

final dashboardDataProvider =
    AutoDisposeAsyncNotifierProvider.family<
      DashboardDataNotifier,
      DashboardData?,
      String
    >(DashboardDataNotifier.new);

// Institutions Notifier
class InstitutionsNotifier extends AsyncNotifier<List<MonoInstitution>> {
  @override
  Future<List<MonoInstitution>> build() async {
    final repository = ref.read(dashboardRepositoryProvider);
    final response = await repository.fetchInstitutions();

    if (response.data == null) {
      throw Exception(response.message);
    }

    return response.data!;
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(dashboardRepositoryProvider);
      final response = await repository.fetchInstitutions();

      if (response.data == null) {
        throw Exception(response.message);
      }

      return response.data!;
    });
  }
}

final institutionsProvider =
    AsyncNotifierProvider<InstitutionsNotifier, List<MonoInstitution>>(
      InstitutionsNotifier.new,
    );

// Mono Input Data Notifier
class MonoInputDataNotifier extends AutoDisposeAsyncNotifier<MonoInputData> {
  @override
  Future<MonoInputData> build() async {
    final repository = ref.read(dashboardRepositoryProvider);
    final response = await repository.fetchMonoInputData();

    if (response.data == null) {
      throw Exception(response.message);
    }

    return response.data!;
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(dashboardRepositoryProvider);
      final response = await repository.fetchMonoInputData();

      if (response.data == null) {
        throw Exception(response.message);
      }

      return response.data!;
    });
  }
}

final monoInputDataProvider =
    AutoDisposeAsyncNotifierProvider<MonoInputDataNotifier, MonoInputData>(
      MonoInputDataNotifier.new,
    );

// Linked Accounts Notifier
class LinkedAccountsNotifier
    extends AutoDisposeAsyncNotifier<List<LinkedAccount>> {
  @override
  Future<List<LinkedAccount>> build() async {
    final repository = ref.read(dashboardRepositoryProvider);
    final response = await repository.fetchLinkedAccounts();

    if (response.data == null) {
      throw Exception(response.message);
    }

    return response.data!;
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(dashboardRepositoryProvider);
      final response = await repository.fetchLinkedAccounts();

      if (response.data == null) {
        throw Exception(response.message);
      }

      return response.data!;
    });
  }

  /// Link account with improved error handling
  Future<bool> linkAccount(String code) async {
    try {
      final repository = ref.read(dashboardRepositoryProvider);
      final response = await repository.linkAccount(code: code);

      // ✅ Check for success flag
      if (response.success) {
        log('✅ Link account API successful');
        await refresh();
        return true;
      } else {
        // ❌ Backend returned success: false
        log('❌ Link account failed: ${response.message}');
        throw Exception(response.message ?? 'Failed to link account');
      }
    } on DioException catch (e) {
      // ❌ Network/HTTP errors
      log('❌ DioException in linkAccount: ${e.message}');
      log('   Status Code: ${e.response?.statusCode}');
      log('   Response Data: ${e.response?.data}');

      // Extract error message from response
      final errorMessage =
          e.response?.data?['message'] ?? 'Network error. Please try again.';
      throw Exception(errorMessage);
    } catch (e) {
      // ❌ Other errors
      log('❌ Unexpected error in linkAccount: $e');
      throw Exception('Issue on our end. Please try again.');
    }
  }

  Future<bool> unlinkAccount({
    required String accountId,
    required String code,
    required String accountName,
  }) async {
    try {
      final repository = ref.read(dashboardRepositoryProvider);
      final response = await repository.unlinkAccount(
        accountId: accountId,
        code: code,
        accountName: accountName,
      );

      if (response.success) {
        await refresh();
        ref.invalidate(dashboardDataProvider);
        return true;
      }
      return false;
    } catch (e) {
      log('Error unlinking account: $e');
      return false;
    }
  }
}

final linkedAccountsProvider =
    AutoDisposeAsyncNotifierProvider<
      LinkedAccountsNotifier,
      List<LinkedAccount>
    >(LinkedAccountsNotifier.new);

// import 'dart:developer';

// import 'package:dio/dio.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:savvy_bee_mobile/core/services/service_locator.dart';
// import 'package:savvy_bee_mobile/features/dashboard/domain/models/dashboard_data.dart';
// import 'package:savvy_bee_mobile/features/spend/domain/models/mono_institution.dart';

// import '../../domain/models/linked_account.dart';

// // Dashboard Data Notifier
// class DashboardDataNotifier
//     extends AutoDisposeFamilyAsyncNotifier<DashboardData?, String> {
//   @override
//   Future<DashboardData?> build(String bankId) async {
//     final repository = ref.read(dashboardRepositoryProvider);
//     final response = await repository.fetchDashboardData(bankId);

//     // if (response.data == null) {
//     //   throw Exception(response.message);
//     // }

//     return response.data?.data;
//   }

//   Future<void> refresh() async {
//     state = const AsyncValue.loading();
//     state = await AsyncValue.guard(() async {
//       final repository = ref.read(dashboardRepositoryProvider);
//       final response = await repository.fetchDashboardData(arg);

//       if (response.data?.data == null) {
//         throw Exception(response.message);
//       }

//       return response.data!.data;
//     });
//   }
// }

// final dashboardDataProvider =
//     AutoDisposeAsyncNotifierProvider.family<
//       DashboardDataNotifier,
//       DashboardData?,
//       String
//     >(DashboardDataNotifier.new);

// // Institutions Notifier
// class InstitutionsNotifier extends AsyncNotifier<List<MonoInstitution>> {
//   @override
//   Future<List<MonoInstitution>> build() async {
//     final repository = ref.read(dashboardRepositoryProvider);
//     final response = await repository.fetchInstitutions();

//     if (response.data == null) {
//       throw Exception(response.message);
//     }

//     return response.data!;
//   }

//   Future<void> refresh() async {
//     state = const AsyncValue.loading();
//     state = await AsyncValue.guard(() async {
//       final repository = ref.read(dashboardRepositoryProvider);
//       final response = await repository.fetchInstitutions();

//       if (response.data == null) {
//         throw Exception(response.message);
//       }

//       return response.data!;
//     });
//   }
// }

// final institutionsProvider =
//     AsyncNotifierProvider<InstitutionsNotifier, List<MonoInstitution>>(
//       InstitutionsNotifier.new,
//     );

// // Mono Input Data Notifier
// class MonoInputDataNotifier extends AutoDisposeAsyncNotifier<MonoInputData> {
//   @override
//   Future<MonoInputData> build() async {
//     final repository = ref.read(dashboardRepositoryProvider);
//     final response = await repository.fetchMonoInputData();

//     if (response.data == null) {
//       throw Exception(response.message);
//     }

//     return response.data!;
//   }

//   Future<void> refresh() async {
//     state = const AsyncValue.loading();
//     state = await AsyncValue.guard(() async {
//       final repository = ref.read(dashboardRepositoryProvider);
//       final response = await repository.fetchMonoInputData();

//       if (response.data == null) {
//         throw Exception(response.message);
//       }

//       return response.data!;
//     });
//   }
// }

// final monoInputDataProvider =
//     AutoDisposeAsyncNotifierProvider<MonoInputDataNotifier, MonoInputData>(
//       MonoInputDataNotifier.new,
//     );

// // Linked Accounts Notifier

// // Updated LinkedAccountsNotifier with better error handling

// class LinkedAccountsNotifier
//     extends AutoDisposeAsyncNotifier<List<LinkedAccount>> {
//   @override
//   Future<List<LinkedAccount>> build() async {
//     final repository = ref.read(dashboardRepositoryProvider);
//     final response = await repository.fetchLinkedAccounts();

//     if (response.data == null) {
//       throw Exception(response.message);
//     }

//     return response.data!;
//   }

//   Future<void> refresh() async {
//     state = const AsyncValue.loading();
//     state = await AsyncValue.guard(() async {
//       final repository = ref.read(dashboardRepositoryProvider);
//       final response = await repository.fetchLinkedAccounts();

//       if (response.data == null) {
//         throw Exception(response.message);
//       }

//       return response.data!;
//     });
//   }

//   /// Link account with improved error handling
//   Future<bool> linkAccount(String code) async {
//     try {
//       final repository = ref.read(dashboardRepositoryProvider);
//       final response = await repository.linkAccount(code: code);

//       // ✅ Check for success flag
//       if (response.success) {
//         log('✅ Link account API successful');
//         await refresh();
//         return true;
//       } else {
//         // ❌ Backend returned success: false
//         log('❌ Link account failed: ${response.message}');
//         throw Exception(response.message ?? 'Failed to link account');
//       }
//     } on DioException catch (e) {
//       // ❌ Network/HTTP errors
//       log('❌ DioException in linkAccount: ${e.message}');
//       log('   Status Code: ${e.response?.statusCode}');
//       log('   Response Data: ${e.response?.data}');

//       // Extract error message from response
//       final errorMessage =
//           e.response?.data?['message'] ?? 'Network error. Please try again.';
//       throw Exception(errorMessage);
//     } catch (e) {
//       // ❌ Other errors
//       log('❌ Unexpected error in linkAccount: $e');
//       throw Exception('Issue on our end. Please try again.');
//     }
//   }

//   Future<bool> unlinkAccount({
//     required String accountId,
//     required String code,
//     required String accountName,
//   }) async {
//     try {
//       final repository = ref.read(dashboardRepositoryProvider);
//       final response = await repository.unlinkAccount(
//         accountId: accountId,
//         code: code,
//         accountName: accountName,
//       );

//       if (response.success) {
//         await refresh();
//         ref.invalidate(dashboardDataProvider);
//         return true;
//       }
//       return false;
//     } catch (e) {
//       log('Error unlinking account: $e');
//       return false;
//     }
//   }
// }

// final linkedAccountsProvider =
//     AutoDisposeAsyncNotifierProvider<
//       LinkedAccountsNotifier,
//       List<LinkedAccount>
//     >(LinkedAccountsNotifier.new);
