// lib/features/tools/presentation/providers/filing_providers.dart
//
// Single barrel file for every filing-flow provider.
// Import this instead of the individual old files.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:savvy_bee_mobile/features/auth/presentation/providers/auth_providers.dart';
import 'package:savvy_bee_mobile/features/tools/data/repositories/filing_home_repository.dart';
import 'package:savvy_bee_mobile/features/tools/data/repositories/filing_payment_repository.dart';
import 'package:savvy_bee_mobile/features/tools/domain/models/filing_home_data.dart';

// ── Repository providers ──────────────────────────────────────────────────────

final filingHomeRepositoryProvider = Provider<FilingHomeRepository>((ref) {
  final token = ref.watch(authRepositoryProvider).getAuthToken() ?? '';
  return FilingHomeRepository(bearerToken: token);
});

final filingPaymentRepositoryProvider =
    Provider<FilingPaymentRepository>((ref) {
  final token = ref.watch(authRepositoryProvider).getAuthToken() ?? '';
  return FilingPaymentRepository(bearerToken: token);
});

// ── Filing home data ──────────────────────────────────────────────────────────

final filingHomeProvider =
    AsyncNotifierProvider<FilingHomeNotifier, FilingHomeData>(
  FilingHomeNotifier.new,
);

class FilingHomeNotifier extends AsyncNotifier<FilingHomeData> {
  @override
  Future<FilingHomeData> build() =>
      ref.read(filingHomeRepositoryProvider).fetchHomeData();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(filingHomeRepositoryProvider).fetchHomeData(),
    );
  }
}

// ── TIN provider ──────────────────────────────────────────────────────────────

/// Holds the TIN entered by the user on TIN Validation Screen 1.
/// Step 3 reads this when building the payment/init request.
final filingTinProvider = StateProvider<String>((ref) => '');

// ── Selected plan ─────────────────────────────────────────────────────────────

/// Plan title written by Step 2, read by Steps 3–6.
final selectedFilingPlanProvider =
    StateProvider<String>((ref) => 'Freelancer');

// ── Tax due ───────────────────────────────────────────────────────────────────

/// Written by Step 3 after payment/init succeeds.
/// Steps 4, 5, 6 read this as the authoritative tax liability.
final filingTaxDueProvider = StateProvider<double>((ref) => 0.0);

// ── Filing process state ──────────────────────────────────────────────────────

/// After payment/liabilityfee succeeds, Step 5 writes the result here
/// so Step 6 (and FilingRecord) can read the final status.
final filingLiabilityResultProvider =
    StateProvider<LiabilityFeeResult?>((ref) => null);

// ── Resume routing helper ─────────────────────────────────────────────────────

/// Returns the named route to navigate to when a FillingProcess already exists.
/// Call this inside the Tax Dashboard or TIN Validation screen after data loads.
///
/// Usage:
///   final route = resumeRouteFor(filingData.fillingProcess);
///   if (route != null) context.pushNamed(route);
String? resumeRouteFor(FillingProcess? process) {
  if (process == null) return null;
  switch (process.status) {
    case FillingStatus.pendingPayment:
      return '/filing/step-4'; // Step 4
    case FillingStatus.payedFillingFee:
      return '/filing/step-5'; // Step 5
    case FillingStatus.payedLiabilityFee:
    case FillingStatus.validatingTax:
    case FillingStatus.rejected:
    case FillingStatus.completed:
    case FillingStatus.failed:
      return '/filing/step-6'; // Step 6 (status screen)
    case FillingStatus.unknown:
      return null;
  }
}


// // lib/features/tools/presentation/providers/filing_home_provider.dart

// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:savvy_bee_mobile/features/auth/presentation/providers/auth_providers.dart';
// import 'package:savvy_bee_mobile/features/tools/data/repositories/filing_home_repository.dart';
// import 'package:savvy_bee_mobile/features/tools/domain/models/filing_home_data.dart';

// // ── Repository provider ──────────────────────────────────────────────────────

// /// Exposes the repository. Token is pulled from your existing auth provider.
// /// Replace `authNotifierProvider` / `.token` with whatever your app uses.
// final filingHomeRepositoryProvider = Provider<FilingHomeRepository>((ref) {
//   final token = ref.watch(authRepositoryProvider).getAuthToken() ?? '';
//   return FilingHomeRepository(bearerToken: token);
// });

// // ── Data provider ────────────────────────────────────────────────────────────

// /// Fetches filing home data exactly once and caches the result for the
// /// lifetime of the provider (i.e. the entire filing flow).
// ///
// /// Any step screen can call:
// ///   final dataAsync = ref.watch(filingHomeProvider);
// ///
// /// To force a refresh (e.g. pull-to-refresh):
// ///   ref.invalidate(filingHomeProvider);
// final filingHomeProvider =
//     AsyncNotifierProvider<FilingHomeNotifier, FilingHomeData>(
//       FilingHomeNotifier.new,
//     );

// class FilingHomeNotifier extends AsyncNotifier<FilingHomeData> {
//   @override
//   Future<FilingHomeData> build() async {
//     final repo = ref.read(filingHomeRepositoryProvider);
//     return repo.fetchHomeData();
//   }

//   /// Force-refresh from the network.
//   Future<void> refresh() async {
//     state = const AsyncLoading();
//     state = await AsyncValue.guard(
//       () => ref.read(filingHomeRepositoryProvider).fetchHomeData(),
//     );
//   }
// }
