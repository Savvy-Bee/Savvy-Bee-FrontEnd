// lib/features/tools/presentation/providers/filing_history_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:savvy_bee_mobile/features/auth/presentation/providers/auth_providers.dart';
import 'package:savvy_bee_mobile/features/tools/data/repositories/filing_history_repository.dart';

// ── Repository provider ───────────────────────────────────────────────────────

final filingHistoryRepositoryProvider = Provider<FilingHistoryRepository>((
  ref,
) {
  final token = ref.watch(authRepositoryProvider).getAuthToken() ?? '';
  return FilingHistoryRepository(bearerToken: token);
});

// ── History list ──────────────────────────────────────────────────────────────

class FilingHistoryNotifier extends AsyncNotifier<List<FilingHistoryItem>> {
  @override
  Future<List<FilingHistoryItem>> build() =>
      ref.read(filingHistoryRepositoryProvider).fetchHistory();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(filingHistoryRepositoryProvider).fetchHistory(),
    );
  }
}

final filingHistoryProvider =
    AsyncNotifierProvider<FilingHistoryNotifier, List<FilingHistoryItem>>(
      FilingHistoryNotifier.new,
    );

// ── Single detail — family provider (keyed by filing ID) ─────────────────────
//
// Riverpod 2.x family pattern: AsyncNotifier + .family modifier.
// Usage:
//   ref.watch(filingDetailProvider('some-id'))
//   ref.read(filingDetailProvider('some-id').notifier).refresh()

final filingDetailProvider =
    AsyncNotifierProvider.family<
      FilingDetailNotifier,
      FilingDetailRecord,
      String
    >(FilingDetailNotifier.new);

class FilingDetailNotifier
    extends FamilyAsyncNotifier<FilingDetailRecord, String> {
  @override
  Future<FilingDetailRecord> build(String arg) =>
      ref.read(filingHistoryRepositoryProvider).fetchDetail(arg);

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(filingHistoryRepositoryProvider).fetchDetail(arg),
    );
  }

  /// Optimistically prepend a new review, then re-fetch from server to sync.
  Future<void> addReview(FilingReview review) async {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(
      _copyWith(current, reviews: [review, ...current.reviews]),
    );
    await refresh();
  }

  FilingDetailRecord _copyWith(
    FilingDetailRecord r, {
    List<FilingReview>? reviews,
  }) => FilingDetailRecord(
    id: r.id,
    plan: r.plan,
    status: r.status,
    withdrawn: r.withdrawn,
    classification: r.classification,
    acctsDetails: r.acctsDetails,
    revenues: r.revenues,
    annualRevenue: r.annualRevenue,
    noneTaxableRevenues: r.noneTaxableRevenues,
    noneTaxableIncome: r.noneTaxableIncome,
    taxableIncome: r.taxableIncome,
    effectiveTaxRate: r.effectiveTaxRate,
    taxAmount: r.taxAmount,
    year: r.year,
    tin: r.tin,
    createdAt: r.createdAt,
    updatedAt: r.updatedAt,
    filingUploadLink: r.filingUploadLink,
    reviews: reviews ?? r.reviews,
  );
}
