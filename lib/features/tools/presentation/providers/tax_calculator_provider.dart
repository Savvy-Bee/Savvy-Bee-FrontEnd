// lib/features/tools/presentation/providers/tax_calculator_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:savvy_bee_mobile/features/auth/presentation/providers/auth_providers.dart';
import 'package:savvy_bee_mobile/features/tools/data/repositories/tax_calculator_repository.dart';
import 'package:savvy_bee_mobile/features/tools/domain/models/tax_calculator_result.dart';

// ── Repository provider ───────────────────────────────────────────────────────

final taxCalculatorRepositoryProvider = Provider<TaxCalculatorRepository>((
  ref,
) {
  final token = ref.watch(authRepositoryProvider).getAuthToken() ?? '';
  return TaxCalculatorRepository(bearerToken: token);
});

// ── State ─────────────────────────────────────────────────────────────────────

class TaxCalculatorState {
  final TaxCalculatorResult? result;
  final bool isLoading;
  final String? error;

  const TaxCalculatorState({this.result, this.isLoading = false, this.error});

  TaxCalculatorState copyWith({
    TaxCalculatorResult? result,
    bool? isLoading,
    String? error,
  }) {
    return TaxCalculatorState(
      result: result ?? this.result,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class TaxCalculatorNotifier extends StateNotifier<TaxCalculatorState> {
  final TaxCalculatorRepository _repo;

  TaxCalculatorNotifier(this._repo) : super(const TaxCalculatorState());

  Future<void> calculate({
    required double earnings,
    double rent = 0,
    double nhf = 0,
    double nhis = 0,
    double pension = 0,
    double loanInterest = 0,
    double lifeInsurance = 0,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _repo.calculate(
        earnings: earnings / 12,
        rent: rent,
        nhf: nhf,
        nhis: nhis,
        pension: pension,
        loanInterest: loanInterest,
        lifeInsurance: lifeInsurance,
      );
      state = TaxCalculatorState(result: result);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void reset() => state = const TaxCalculatorState();
}

// ── Provider ──────────────────────────────────────────────────────────────────

final taxCalculatorProvider =
    StateNotifierProvider<TaxCalculatorNotifier, TaxCalculatorState>((ref) {
      final repo = ref.read(taxCalculatorRepositoryProvider);
      return TaxCalculatorNotifier(repo);
    });
