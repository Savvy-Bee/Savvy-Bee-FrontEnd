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

// ==================== AIRTIME NOTIFIER ====================

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
  Future<void> verifyAirtime({required String pin}) async {
    state = const AsyncValue.loading();
    
    final repository = ref.read(billsRepositoryProvider);
    
    state = await AsyncValue.guard(() async {
      return await repository.verifyAirtime(pin: pin);
    });
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

class DataNotifier extends AutoDisposeAsyncNotifier<BillsResponse?> {
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
  Future<void> verifyData({required String pin}) async {
    state = const AsyncValue.loading();
    
    final repository = ref.read(billsRepositoryProvider);
    
    state = await AsyncValue.guard(() async {
      return await repository.verifyData(pin: pin);
    });
  }

  /// Reset state
  void reset() {
    state = const AsyncValue.data(null);
  }
}

final dataProvider = 
    AutoDisposeAsyncNotifierProvider<DataNotifier, BillsResponse?>(
  DataNotifier.new,
);

/// Data plans provider
final dataPlansProvider = FutureProvider.autoDispose
    .family<List<DataPlan>, String>((ref, provider) async {
  final repository = ref.watch(billsRepositoryProvider);
  return await repository.fetchDataPlans(provider: provider);
});

//* ==================== TV NOTIFIER ====================

class TvNotifier extends AutoDisposeAsyncNotifier<BillsResponse?> {
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
  Future<void> verifyTv({required String pin}) async {
    state = const AsyncValue.loading();
    
    final repository = ref.read(billsRepositoryProvider);
    
    state = await AsyncValue.guard(() async {
      return await repository.verifyTv(pin: pin);
    });
  }

  /// Reset state
  void reset() {
    state = const AsyncValue.data(null);
  }
}

final tvProvider = 
    AutoDisposeAsyncNotifierProvider<TvNotifier, BillsResponse?>(
  TvNotifier.new,
);

/// TV providers provider
final tvProvidersProvider = 
    FutureProvider.autoDispose<List<TvProvider>>((ref) async {
  final repository = ref.watch(billsRepositoryProvider);
  return await repository.fetchTvProviders();
});

/// TV plans provider
final tvPlansProvider = FutureProvider.autoDispose
    .family<List<TvPlan>, String>((ref, provider) async {
  final repository = ref.watch(billsRepositoryProvider);
  return await repository.fetchTvPlans(provider: provider);
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
  Future<void> verifyElectricity({required String pin}) async {
    state = const AsyncValue.loading();
    
    final repository = ref.read(billsRepositoryProvider);
    
    state = await AsyncValue.guard(() async {
      return await repository.verifyElectricity(pin: pin);
    });
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
class BillsNotifier extends AutoDisposeAsyncNotifier<Map<String, BillsResponse?>> {
  @override
  Future<Map<String, BillsResponse?>> build() async {
    return {
      'airtime': null,
      'data': null,
      'tv': null,
      'electricity': null,
    };
  }

  /// Purchase airtime
  Future<void> purchaseAirtime({
    required String phoneNo,
    required String provider,
    required String amount,
    required String pin,
  }) async {
    state = const AsyncValue.loading();
    
    final repository = ref.read(billsRepositoryProvider);
    
    state = await AsyncValue.guard(() async {
      // Initialize
      await repository.initializeAirtime(
        phoneNo: phoneNo,
        provider: provider,
        amount: amount,
      );
      
      // Verify
      final response = await repository.verifyAirtime(pin: pin);
      
      return {
        'airtime': response,
        'data': null,
        'tv': null,
        'electricity': null,
      };
    });
  }

  /// Purchase data
  Future<void> purchaseData({
    required String phoneNo,
    required String provider,
    required String code,
    required String pin,
  }) async {
    state = const AsyncValue.loading();
    
    final repository = ref.read(billsRepositoryProvider);
    
    state = await AsyncValue.guard(() async {
      // Initialize
      await repository.initializeData(
        phoneNo: phoneNo,
        provider: provider,
        code: code,
      );
      
      // Verify
      final response = await repository.verifyData(pin: pin);
      
      return {
        'airtime': null,
        'data': response,
        'tv': null,
        'electricity': null,
      };
    });
  }

  /// Subscribe to TV
  Future<void> subscribeTv({
    required String phoneNo,
    required String provider,
    required String code,
    required String pin,
  }) async {
    state = const AsyncValue.loading();
    
    final repository = ref.read(billsRepositoryProvider);
    
    state = await AsyncValue.guard(() async {
      // Initialize
      await repository.initializeTv(
        phoneNo: phoneNo,
        provider: provider,
        code: code,
      );
      
      // Verify
      final response = await repository.verifyTv(pin: pin);
      
      return {
        'airtime': null,
        'data': null,
        'tv': response,
        'electricity': null,
      };
    });
  }

  /// Pay electricity bill
  Future<void> payElectricity({
    required String phoneNo,
    required String provider,
    required String code,
    required String amount,
    required String pin,
    String meterType = 'prepaid',
  }) async {
    state = const AsyncValue.loading();
    
    final repository = ref.read(billsRepositoryProvider);
    
    state = await AsyncValue.guard(() async {
      // Initialize
      await repository.initializeElectricity(
        phoneNo: phoneNo,
        provider: provider,
        code: code,
        amount: amount,
        meterType: meterType,
      );
      
      // Verify
      final response = await repository.verifyElectricity(pin: pin);
      
      return {
        'airtime': null,
        'data': null,
        'tv': null,
        'electricity': response,
      };
    });
  }

  /// Reset all states
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
    AutoDisposeAsyncNotifierProvider<BillsNotifier, Map<String, BillsResponse?>>(
  BillsNotifier.new,
);