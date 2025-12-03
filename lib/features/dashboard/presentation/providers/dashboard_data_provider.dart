import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:savvy_bee_mobile/core/services/service_locator.dart';
import 'package:savvy_bee_mobile/features/dashboard/domain/models/dashboard_data.dart';
import 'package:savvy_bee_mobile/features/spend/domain/models/institution.dart';



// Dashboard Data Notifier
class DashboardDataNotifier
    extends AutoDisposeFamilyAsyncNotifier<DashboardData?, String> {
  @override
  Future<DashboardData?> build(String bankId) async {
    final repository = ref.read(dashboardRepositoryProvider);
    final response = await repository.fetchDashboardData(bankId);

    // if (response.data == null) {
    //   throw Exception(response.message);
    // }

    return response.data;
  }

  Future<void> refresh() async {
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
class InstitutionsNotifier extends AutoDisposeAsyncNotifier<List<Institution>> {
  @override
  Future<List<Institution>> build() async {
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
    AutoDisposeAsyncNotifierProvider<InstitutionsNotifier, List<Institution>>(
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

  Future<bool> linkAccount(String code) async {
    try {
      final repository = ref.read(dashboardRepositoryProvider);
      final response = await repository.linkAccount(code: code);

      if (response.success) {
        await refresh();
        return true;
      }
      return false;
    } catch (e) {
      return false;
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
      return false;
    }
  }
}

final linkedAccountsProvider =
    AutoDisposeAsyncNotifierProvider<
      LinkedAccountsNotifier,
      List<LinkedAccount>
    >(LinkedAccountsNotifier.new);
