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
  Future<void> initializeTv({
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

class ElectricityNotifier extends AutoDisposeAsyncNotifier<BillsResponse?> {
  @override
  Future<BillsResponse?> build() async {
    return null;
  }

  /// Initialize electricity bill payment
  Future<void> initializeElectricity({
    required String phoneNo,
    required String provider,
    required String code,
    required String amount,
    String meterType = 'prepaid',
  }) async {
    state = const AsyncValue.loading();

    final repository = ref.read(billsRepositoryProvider);

    state = await AsyncValue.guard(() async {
      return await repository.initializeElectricity(
        phoneNo: phoneNo,
        provider: provider,
        code: code,
        amount: amount,
        meterType: meterType,
      );
    });
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
    AutoDisposeAsyncNotifierProvider<ElectricityNotifier, BillsResponse?>(
      ElectricityNotifier.new,
    );

/// Electricity providers provider
final electricityProvidersProvider =
    FutureProvider.autoDispose<List<ElectricityProvider>>((ref) async {
      final repository = ref.watch(billsRepositoryProvider);
      return await repository.fetchElectricityProviders();
    });

// ==================== COMBINED BILLS NOTIFIER (OPTIONAL) ====================

/// A unified notifier for managing all bill types in one place
class BillsNotifier
    extends AutoDisposeAsyncNotifier<Map<String, BillsResponse?>> {
  @override
  Future<Map<String, BillsResponse?>> build() async {
    return {'airtime': null, 'data': null, 'tv': null, 'electricity': null};
  }

  /// Purchase airtime
  ///
  /// Returns a boolean indicating whether the purchase was successful.
  /// The response is stored locally to avoid race conditions when reading
  /// from the state immediately after setting it (state updates are async).
  Future<bool> purchaseAirtime({
    required String phoneNo,
    required String provider,
    required String amount,
    required String pin,
  }) async {
    state = const AsyncValue.loading();
    final repository = ref.read(billsRepositoryProvider);

    // Store response locally instead of reading from state later
    // This prevents race conditions since state updates are asynchronous
    BillsResponse? airtimeResponse;

    state = await AsyncValue.guard(() async {
      // Initialize the airtime purchase
      await repository.initializeAirtime(
        phoneNo: phoneNo,
        provider: provider,
        amount: amount,
      );

      // Verify with PIN and store response locally
      airtimeResponse = await repository.verifyAirtime(pin: pin);

      // Update state with the response
      return {
        'airtime': airtimeResponse,
        'data': null,
        'tv': null,
        'electricity': null,
      };
    });

    // Return success status from local variable, not from state
    // Reading from state here would be unreliable due to async updates
    return airtimeResponse?.success ?? false;
  }

  /// Purchase data
  ///
  /// Returns a boolean indicating whether the purchase was successful.
  /// The response is stored locally to avoid race conditions when reading
  /// from the state immediately after setting it (state updates are async).
  Future<bool> purchaseData({
    required String phoneNo,
    required String provider,
    required String code,
    required String pin,
  }) async {
    state = const AsyncValue.loading();
    final repository = ref.read(billsRepositoryProvider);

    // Store response locally instead of reading from state later
    // This prevents race conditions since state updates are asynchronous
    BillsResponse? dataResponse;

    state = await AsyncValue.guard(() async {
      // Initialize the data purchase
      await repository.initializeData(
        phoneNo: phoneNo,
        provider: provider,
        code: code,
      );

      // Verify with PIN and store response locally
      dataResponse = await repository.verifyData(pin: pin);

      // Update state with the response
      return {
        'airtime': null,
        'data': dataResponse,
        'tv': null,
        'electricity': null,
      };
    });

    // Return success status from local variable, not from state
    // Reading from state here would be unreliable due to async updates
    return dataResponse?.success ?? false;
  }

  /// Subscribe to TV
  ///
  /// Returns a boolean indicating whether the subscription was successful.
  /// The response is stored locally to avoid race conditions when reading
  /// from the state immediately after setting it (state updates are async).
  Future<bool> subscribeTv({
    required String phoneNo,
    required String provider,
    required String code,
    required String pin,
  }) async {
    state = const AsyncValue.loading();
    final repository = ref.read(billsRepositoryProvider);

    // Store response locally instead of reading from state later
    // This prevents race conditions since state updates are asynchronous
    BillsResponse? tvResponse;

    state = await AsyncValue.guard(() async {
      // Initialize the TV subscription
      await repository.initializeTv(
        phoneNo: phoneNo,
        provider: provider,
        code: code,
      );

      // Verify with PIN and store response locally
      tvResponse = await repository.verifyTv(pin: pin);

      // Update state with the response
      return {
        'airtime': null,
        'data': null,
        'tv': tvResponse,
        'electricity': null,
      };
    });

    // Return success status from local variable, not from state
    // Reading from state here would be unreliable due to async updates
    return tvResponse?.success ?? false;
  }

  /// Pay electricity bill
  ///
  /// Returns a boolean indicating whether the payment was successful.
  /// The response is stored locally to avoid race conditions when reading
  /// from the state immediately after setting it (state updates are async).
  Future<bool> payElectricity({
    required String phoneNo,
    required String provider,
    required String code,
    required String amount,
    required String pin,
    String meterType = 'prepaid',
  }) async {
    state = const AsyncValue.loading();
    final repository = ref.read(billsRepositoryProvider);

    // Store response locally instead of reading from state later
    // This prevents race conditions since state updates are asynchronous
    BillsResponse? electricityResponse;

    state = await AsyncValue.guard(() async {
      // Initialize the electricity payment
      await repository.initializeElectricity(
        phoneNo: phoneNo,
        provider: provider,
        code: code,
        amount: amount,
        meterType: meterType,
      );

      // Verify with PIN and store response locally
      electricityResponse = await repository.verifyElectricity(pin: pin);

      // Update state with the response
      return {
        'airtime': null,
        'data': null,
        'tv': null,
        'electricity': electricityResponse,
      };
    });

    // Return success status from local variable, not from state
    // Reading from state here would be unreliable due to async updates
    return electricityResponse?.success ?? false;
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
}

final billsProvider =
    AutoDisposeAsyncNotifierProvider<
      BillsNotifier,
      Map<String, BillsResponse?>
    >(BillsNotifier.new);
