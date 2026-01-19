import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:savvy_bee_mobile/core/network/api_client.dart';
import 'package:savvy_bee_mobile/core/services/service_locator.dart';
import 'package:savvy_bee_mobile/features/tools/data/repositories/taxation_repository.dart';
import 'package:savvy_bee_mobile/features/tools/domain/models/taxation.dart';

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
    int? transport,
    int? feeding,
    int? utilities,
    int? others,
  }) async {
    state = const AsyncLoading();
    try {
      final response = await _repository.calculateTax(
        earnings: earnings,
        rent: rent,
        transport: transport,
        feeding: feeding,
        utilities: utilities,
        others: others,
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

// Providers
final taxationHomeNotifierProvider =
    AsyncNotifierProvider<TaxationHomeNotifier, TaxationHomeResponse>(
      TaxationHomeNotifier.new,
    );

final taxCalculatorNotifierProvider =
    AsyncNotifierProvider<TaxCalculatorNotifier, TaxCalculatorResponse?>(
      TaxCalculatorNotifier.new,
    );

// Repository provider
final taxationRepositoryProvider = Provider<TaxationRepository>((ref) {
  return TaxationRepository(apiClient: ref.read(apiClientProvider));
});