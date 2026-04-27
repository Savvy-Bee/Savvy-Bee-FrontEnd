import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:savvy_bee_mobile/core/services/service_locator.dart';

import '../../domain/models/bills.dart';

// ==================== STATE CLASSES ====================

/// Base state for bill operations
class BillState<T> {
  final T? data;
  final bool isLoading;
  final String? error;
  final String? successMessage;

  const BillState({
    this.data,
    this.isLoading = false,
    this.error,
    this.successMessage,
  });

  BillState<T> copyWith({
    T? data,
    bool? isLoading,
    String? error,
    String? successMessage,
  }) {
    return BillState<T>(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      successMessage: successMessage,
    );
  }
}

//* ==================== AIRTIME NOTIFIER ====================

class AirtimeNotifier extends AutoDisposeAsyncNotifier<BillsResponse?> {
  @override
  Future<BillsResponse?> build() async {
    return null;
  }

  /// Initialize airtime purchase
  Future<void> initializeAirtime({
    required String phoneNo,
    required String provider,
    required String amount,
  }) async {
    state = const AsyncValue.loading();

    final repository = ref.read(billsRepositoryProvider);

    state = await AsyncValue.guard(() async {
      return await repository.initializeAirtime(
        phoneNo: phoneNo,
        provider: provider,
        amount: amount,
      );
    });
  }

  /// Verify airtime transaction
  Future<bool> verifyAirtime({required String pin}) async {
    state = const AsyncValue.loading();

    final repository = ref.read(billsRepositoryProvider);

    state = await AsyncValue.guard(() async {
      return await repository.verifyAirtime(pin: pin);
    });

    return state.value?.success ?? false;
  }

  /// Reset state
  void reset() {
    state = const AsyncValue.data(null);
  }
}

final airtimeProvider =
    AutoDisposeAsyncNotifierProvider<AirtimeNotifier, BillsResponse?>(
      AirtimeNotifier.new,
    );

//* ==================== DATA NOTIFIER ====================

class DataNotifier extends AsyncNotifier<BillsResponse?> {
  @override
  Future<BillsResponse?> build() async {
    return null;
  }

  /// Initialize data purchase
  Future<void> initializeData({
    required String phoneNo,
    required String provider,
    required String code,
  }) async {
    state = const AsyncValue.loading();

    final repository = ref.read(billsRepositoryProvider);

    state = await AsyncValue.guard(() async {
      return await repository.initializeData(
        phoneNo: phoneNo,
        provider: provider,
        code: code,
      );
    });
  }

  /// Verify data transaction
  Future<bool> verifyData({required String pin}) async {
    state = const AsyncValue.loading();

    final repository = ref.read(billsRepositoryProvider);

    state = await AsyncValue.guard(() async {
      return await repository.verifyData(pin: pin);
    });

    return state.value?.success ?? false;
  }

  /// Reset state
  void reset() {
    state = const AsyncValue.data(null);
  }
}

final dataProvider = AsyncNotifierProvider<DataNotifier, BillsResponse?>(
  DataNotifier.new,
);

/// Data plans provider
final dataPlansProvider = FutureProvider.family<List<DataPlan>, String>((
  ref,
  provider,
) async {
  final repository = ref.watch(billsRepositoryProvider);
  return await repository.fetchDataPlans(provider: provider);
});

//* ==================== TV NOTIFIER ====================

class TvNotifier extends AsyncNotifier<BillsResponse?> {
  @override
  Future<BillsResponse?> build() async {
    return null;
  }

  /// Initialize TV subscription
  Future<bool> initializeTv({
    required String phoneNo,
    required String provider,
    required String code,
  }) async {
    state = const AsyncValue.loading();

    final repository = ref.read(billsRepositoryProvider);

    state = await AsyncValue.guard(() async {
      return await repository.initializeTv(
        phoneNo: phoneNo,
        provider: provider,
        code: code,
      );
    });

    return state.value?.success ?? false;
  }

  /// Verify TV transaction
  Future<bool> verifyTv({required String pin}) async {
    state = const AsyncValue.loading();

    final repository = ref.read(billsRepositoryProvider);

    state = await AsyncValue.guard(() async {
      return await repository.verifyTv(pin: pin);
    });

    return state.value?.success ?? false;
  }

  /// Reset state
  void reset() {
    state = const AsyncValue.data(null);
  }
}

final tvProvider = AsyncNotifierProvider<TvNotifier, BillsResponse?>(
  TvNotifier.new,
);

/// TV providers provider
final tvProvidersProvider = FutureProvider<List<TvProvider>>((ref) async {
  final repository = ref.watch(billsRepositoryProvider);
  return await repository.fetchTvProviders();
});

/// TV plans provider
final tvPlansProvider = FutureProvider.family<List<TvPlan>, String>((
  ref,
  provider,
) async {
  final repository = ref.watch(billsRepositoryProvider);
  return await repository.fetchTvPlans(provider: provider.toUpperCase());
});

//* ==================== ELECTRICITY NOTIFIER ====================

class ElectricityNotifier extends AsyncNotifier<BillsResponse?> {
  @override
  Future<BillsResponse?> build() async {
    return null;
  }

  /// Initialize electricity bill payment
  Future<bool> initializeElectricity({
    required String provider,
    required String meterNumber,
    required String amount,
    String meterType = 'prepaid',
  }) async {
    state = const AsyncValue.loading();

    final repository = ref.read(billsRepositoryProvider);

    state = await AsyncValue.guard(() async {
      return await repository.initializeElectricity(
        provider: provider,
        meterNumber: meterNumber,
        amount: amount,
        meterType: meterType.toUpperCase(),
      );
    });

    return state.value?.success ?? false;
  }

  /// Verify electricity transaction
  Future<bool> verifyElectricity({required String pin}) async {
    state = const AsyncValue.loading();

    final repository = ref.read(billsRepositoryProvider);

    state = await AsyncValue.guard(() async {
      return await repository.verifyElectricity(pin: pin);
    });

    return state.value?.success ?? false;
  }

  /// Reset state
  void reset() {
    state = const AsyncValue.data(null);
  }
}

final electricityProvider =
    AsyncNotifierProvider<ElectricityNotifier, BillsResponse?>(
      ElectricityNotifier.new,
    );

/// Electricity providers provider
final electricityProvidersProvider = FutureProvider<List<ElectricityProvider>>((
  ref,
) async {
  final repository = ref.watch(billsRepositoryProvider);
  return await repository.fetchElectricityProviders();
});

// ==================== COMBINED BILLS NOTIFIER ====================

/// A unified notifier for managing all bill types in one place
class BillsNotifier
    extends AutoDisposeAsyncNotifier<Map<String, BillsResponse?>> {
  @override
  Future<Map<String, BillsResponse?>> build() async {
    return {'airtime': null, 'data': null, 'tv': null, 'electricity': null};
  }

  /// Purchase airtime
  ///
  /// Returns true on success, or throws with the API error message on failure.
  Future<bool> purchaseAirtime({
    required String phoneNo,
    required String provider,
    required String amount,
    required String pin,
  }) async {
    state = const AsyncValue.loading();
    final repository = ref.read(billsRepositoryProvider);

    try {
      final verifyResponse = await _runInitializeThenVerify(
        initialize: () => repository.initializeAirtime(
          phoneNo: phoneNo,
          provider: provider,
          amount: amount,
        ),
        verify: () => repository.verifyAirtime(pin: pin),
      );

      state = AsyncValue.data({
        'airtime': verifyResponse,
        'data': null,
        'tv': null,
        'electricity': null,
      });

      if (!verifyResponse.success) throw Exception(verifyResponse.message);
      return true;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  /// Purchase data
  ///
  /// Returns true on success, or throws with the API error message on failure.
  Future<bool> purchaseData({
    required String phoneNo,
    required String provider,
    required String code,
    required String pin,
  }) async {
    state = const AsyncValue.loading();
    final repository = ref.read(billsRepositoryProvider);

    try {
      final verifyResponse = await _runInitializeThenVerify(
        initialize: () => repository.initializeData(
          phoneNo: phoneNo,
          provider: provider,
          code: code,
        ),
        verify: () => repository.verifyData(pin: pin),
      );

      state = AsyncValue.data({
        'airtime': null,
        'data': verifyResponse,
        'tv': null,
        'electricity': null,
      });

      if (!verifyResponse.success) throw Exception(verifyResponse.message);
      return true;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  /// Subscribe to TV
  ///
  /// Returns true on success, or throws with the API error message on failure.
  Future<bool> subscribeTv({
    required String phoneNo,
    required String provider,
    required String code,
    required String pin,
  }) async {
    state = const AsyncValue.loading();
    final repository = ref.read(billsRepositoryProvider);

    try {
      final verifyResponse = await _runInitializeThenVerify(
        initialize: () => repository.initializeTv(
          phoneNo: phoneNo,
          provider: provider,
          code: code,
        ),
        verify: () => repository.verifyTv(pin: pin),
      );

      state = AsyncValue.data({
        'airtime': null,
        'data': null,
        'tv': verifyResponse,
        'electricity': null,
      });

      if (!verifyResponse.success) throw Exception(verifyResponse.message);
      return true;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  /// Pay electricity bill
  ///
  /// Returns true on success, or throws with the API error message on failure.
  Future<bool> payElectricity({
    required String phoneNo,
    required String provider,
    required String meterNumber,
    required String amount,
    required String pin,
    String meterType = 'prepaid',
  }) async {
    state = const AsyncValue.loading();
    final repository = ref.read(billsRepositoryProvider);

    try {
      final verifyResponse = await _runInitializeThenVerify(
        initialize: () => repository.initializeElectricity(
          provider: provider,
          meterNumber: meterNumber,
          amount: amount,
          meterType: meterType.toUpperCase(),
        ),
        verify: () => repository.verifyElectricity(pin: pin),
      );

      state = AsyncValue.data({
        'airtime': null,
        'data': null,
        'tv': null,
        'electricity': verifyResponse,
      });

      if (!verifyResponse.success) throw Exception(verifyResponse.message);
      return true;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  /// Reset all states to initial null values
  void reset() {
    state = AsyncValue.data({
      'airtime': null,
      'data': null,
      'tv': null,
      'electricity': null,
    });
  }

  Future<BillsResponse> _runInitializeThenVerify({
    required Future<BillsResponse> Function() initialize,
    required Future<BillsResponse> Function() verify,
  }) async {
    final initResponse = await initialize();
    if (!initResponse.success) {
      throw Exception(initResponse.message);
    }

    // Enforce strict sequencing: verify only runs after initialize
    // completed and returned a success response.
    final verifyResponse = await verify();
    return verifyResponse;
  }
}

final billsProvider =
    AutoDisposeAsyncNotifierProvider<
      BillsNotifier,
      Map<String, BillsResponse?>
    >(BillsNotifier.new);
