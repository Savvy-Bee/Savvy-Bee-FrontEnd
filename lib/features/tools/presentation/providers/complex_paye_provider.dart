// lib/features/tools/presentation/providers/complex_paye_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:savvy_bee_mobile/features/auth/presentation/providers/auth_providers.dart';
import 'package:savvy_bee_mobile/features/tools/data/repositories/complex_paye_repository.dart';
import 'package:savvy_bee_mobile/features/tools/domain/models/complex_paye_models.dart';

// ── Repository provider ───────────────────────────────────────────────────────

final complexPayeRepositoryProvider = Provider<ComplexPayeRepository>((ref) {
  final token = ref.watch(authRepositoryProvider).getAuthToken() ?? '';
  return ComplexPayeRepository(bearerToken: token);
});

// ── History list ──────────────────────────────────────────────────────────────

class ComplexPayeHistoryNotifier
    extends AsyncNotifier<List<ComplexPayeHistoryItem>> {
  @override
  Future<List<ComplexPayeHistoryItem>> build() =>
      ref.read(complexPayeRepositoryProvider).fetchHistory();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(complexPayeRepositoryProvider).fetchHistory(),
    );
  }
}

final complexPayeHistoryProvider = AsyncNotifierProvider<
    ComplexPayeHistoryNotifier, List<ComplexPayeHistoryItem>>(
  ComplexPayeHistoryNotifier.new,
);

// ── Single detail — family provider ──────────────────────────────────────────

final complexPayeDetailProvider = AsyncNotifierProvider.family<
    ComplexPayeDetailNotifier, ComplexPayeDetailRecord, String>(
  ComplexPayeDetailNotifier.new,
);

class ComplexPayeDetailNotifier
    extends FamilyAsyncNotifier<ComplexPayeDetailRecord, String> {
  @override
  Future<ComplexPayeDetailRecord> build(String arg) =>
      ref.read(complexPayeRepositoryProvider).fetchDetail(arg);

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(complexPayeRepositoryProvider).fetchDetail(arg),
    );
  }

  Future<void> addReview(ComplexPayeReview review) async {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(_copyWith(current, reviews: [review, ...current.reviews]));
    await refresh();
  }

  ComplexPayeDetailRecord _copyWith(
    ComplexPayeDetailRecord r, {
    List<ComplexPayeReview>? reviews,
  }) => ComplexPayeDetailRecord(
    id: r.id,
    businessName: r.businessName,
    tin: r.tin,
    description: r.description,
    classification: r.classification,
    name: r.name,
    cacNumber: r.cacNumber,
    phone: r.phone,
    address: r.address,
    email: r.email,
    revenues: r.revenues,
    noneTaxableRevenues: r.noneTaxableRevenues,
    status: r.status,
    filingFee: r.filingFee,
    taxLiability: r.taxLiability,
    assignedPrice: r.assignedPrice,
    reviews: reviews ?? r.reviews,
    year: r.year,
    createdAt: r.createdAt,
  );
}

// ── Payment state ─────────────────────────────────────────────────────────────

/// ID of the complex PAYE filing currently going through payment.
final complexPayePaymentIdProvider = StateProvider<String>((ref) => '');

/// Filing fee amount from init payment response.
final complexPayeFilingFeeProvider = StateProvider<double>((ref) => 0.0);

/// Tax liability amount from init payment response.
final complexPayeTaxLiabilityProvider = StateProvider<double>((ref) => 0.0);

/// Wallet balance from init payment response.
final complexPayeWalletBalanceProvider = StateProvider<double>((ref) => 0.0);
