import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/service_locator.dart';
import '../../data/repositories/taxation_repository.dart';
import '../../domain/models/taxation.dart';

class TaxationHomeNotifier extends AsyncNotifier<TaxationHomeResponse> {
  TaxationRepository get _repository => ref.read(taxationRepositoryProvider);

  @override
  Future<TaxationHomeResponse> build() async {
    return _repository.getTaxationHomeData();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    try {
      final data = await _repository.getTaxationHomeData();
      state = AsyncData(data);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

class TaxCalculatorNotifier extends AsyncNotifier<TaxCalculatorResponse?> {
  TaxationRepository get _repository => ref.read(taxationRepositoryProvider);

  @override
  Future<TaxCalculatorResponse?> build() async {
    return null; // Start with no calculation
  }

  Future<void> calculateTax({
    required int earnings,
    int? rent,
  }) async {
    state = const AsyncLoading();
    try {
      final response = await _repository.calculateTax(
        earnings: earnings,
        rent: rent,
      );
      state = AsyncData(response);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  void resetCalculation() {
    state = const AsyncData(null);
  }
}

class TaxationStrategyNotifier extends AsyncNotifier<TaxationStrategyResponse> {
  TaxationRepository get _repository => ref.read(taxationRepositoryProvider);

  @override
  Future<TaxationStrategyResponse> build() async {
    return _repository.getTaxationStrategies();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    try {
      final data = await _repository.getTaxationStrategies();
      state = AsyncData(data);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

// Providers
final taxationHomeNotifierProvider =
    AsyncNotifierProvider<TaxationHomeNotifier, TaxationHomeResponse>(
      TaxationHomeNotifier.new,
    );

final taxCalculatorNotifierProvider =
    AsyncNotifierProvider<TaxCalculatorNotifier, TaxCalculatorResponse?>(
      TaxCalculatorNotifier.new,
    );

final taxationStrategyNotifierProvider =
    AsyncNotifierProvider<TaxationStrategyNotifier, TaxationStrategyResponse>(
      TaxationStrategyNotifier.new,
    );

// Repository provider
final taxationRepositoryProvider = Provider<TaxationRepository>((ref) {
  return TaxationRepository(apiClient: ref.read(apiClientProvider));
});