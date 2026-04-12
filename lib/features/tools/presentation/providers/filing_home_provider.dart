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

final filingPaymentRepositoryProvider = Provider<FilingPaymentRepository>((
  ref,
) {
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

// ── Filing country provider ───────────────────────────────────────────────────

/// The country code the user selected for filing.
/// 'ng' = Nigeria (default, uses standard flow).
/// Other supported values: 'uk', 'us', 'fr', 'ci', 'sn', 'cd', 'cm'.
final filingCountryProvider = StateProvider<String>((ref) => 'ng');

// ── TIN provider ──────────────────────────────────────────────────────────────

/// Holds the TIN entered by the user on TIN Validation Screen 1.
/// Step 3 reads this when building the payment/init request.
final filingTinProvider = StateProvider<String>((ref) => '');

// ── Taxpayer identity providers (new — set during TIN reg / validation) ────────

/// "Individual" or "Coperate" — matches API enum exactly.
/// Written by the TIN Registration flow (Screen 1 classification choice)
/// or by TIN Validation screen when the validated result comes back.
final filingClassificationProvider = StateProvider<String>(
  (ref) => 'Individual',
);

/// Full legal name of the taxpayer or registered business name.
final filingNameProvider = StateProvider<String>((ref) => '');

/// CAC registration number — only relevant for Corporate filers.
/// Leave empty ('') for Individual filers.
final filingCacNumberProvider = StateProvider<String>((ref) => '');

/// Contact details collected during TIN registration (Screen 3).
/// Stored as a simple record so it can be passed directly to payment/init.
final filingContactProvider = StateProvider<FilingContactRecord>(
  (ref) => const FilingContactRecord(phoneNo: '', address: '', email: ''),
);

/// Lightweight value object for contact info (no dependency on repository).
class FilingContactRecord {
  final String phoneNo;
  final String address;
  final String email;

  const FilingContactRecord({
    required this.phoneNo,
    required this.address,
    required this.email,
  });
}

// ── Selected plan ─────────────────────────────────────────────────────────────

/// Plan title written by Step 2, read by Steps 3–6.
final selectedFilingPlanProvider = StateProvider<String>((ref) => 'Freelancer');

// ── Tax due ───────────────────────────────────────────────────────────────────

/// Written by Step 3 after payment/init succeeds.
/// Steps 4, 5, 6 read this as the authoritative tax liability.
final filingTaxDueProvider = StateProvider<double>((ref) => 0.0);

/// Written by Step 3 after payment/init succeeds.
/// Passed to payFillingFee and payLiabilityFee as the filing process ID.
final filingIDProvider = StateProvider<String>((ref) => '');

/// Wallet balance returned by the payment/init response (field: "Wallet").
/// Written by Step 3, read by Steps 4 and 5 to show the user's spendable
/// balance without needing a separate wallet API call on those screens.
final filingWalletBalanceProvider = StateProvider<double>((ref) => 0.0);

// ── Filing process state ──────────────────────────────────────────────────────

/// After payment/liabilityfee succeeds, Step 5 writes the result here
/// so Step 6 (and FilingRecord) can read the final status.
final filingLiabilityResultProvider = StateProvider<LiabilityFeeResult?>(
  (ref) => null,
);

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



// // lib/features/tools/presentation/providers/filing_home_providers.dart
// //
// // Single barrel file for every filing-flow provider.
// // Import this instead of the individual old files.

// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:savvy_bee_mobile/features/auth/presentation/providers/auth_providers.dart';
// import 'package:savvy_bee_mobile/features/tools/data/repositories/filing_home_repository.dart';
// import 'package:savvy_bee_mobile/features/tools/data/repositories/filing_payment_repository.dart';
// import 'package:savvy_bee_mobile/features/tools/domain/models/filing_home_data.dart';

// // ── Repository providers ──────────────────────────────────────────────────────

// final filingHomeRepositoryProvider = Provider<FilingHomeRepository>((ref) {
//   final token = ref.watch(authRepositoryProvider).getAuthToken() ?? '';
//   return FilingHomeRepository(bearerToken: token);
// });

// final filingPaymentRepositoryProvider = Provider<FilingPaymentRepository>((
//   ref,
// ) {
//   final token = ref.watch(authRepositoryProvider).getAuthToken() ?? '';
//   return FilingPaymentRepository(bearerToken: token);
// });

// // ── Filing home data ──────────────────────────────────────────────────────────

// final filingHomeProvider =
//     AsyncNotifierProvider<FilingHomeNotifier, FilingHomeData>(
//       FilingHomeNotifier.new,
//     );

// class FilingHomeNotifier extends AsyncNotifier<FilingHomeData> {
//   @override
//   Future<FilingHomeData> build() =>
//       ref.read(filingHomeRepositoryProvider).fetchHomeData();

//   Future<void> refresh() async {
//     state = const AsyncLoading();
//     state = await AsyncValue.guard(
//       () => ref.read(filingHomeRepositoryProvider).fetchHomeData(),
//     );
//   }
// }

// // ── TIN provider ──────────────────────────────────────────────────────────────

// /// Holds the TIN entered by the user on TIN Validation Screen 1.
// /// Step 3 reads this when building the payment/init request.
// final filingTinProvider = StateProvider<String>((ref) => '');

// // ── Taxpayer identity providers (new — set during TIN reg / validation) ────────

// /// "Individual" or "Coperate" — matches API enum exactly.
// /// Written by the TIN Registration flow (Screen 1 classification choice)
// /// or by TIN Validation screen when the validated result comes back.
// final filingClassificationProvider = StateProvider<String>(
//   (ref) => 'Individual',
// );

// /// Full legal name of the taxpayer or registered business name.
// final filingNameProvider = StateProvider<String>((ref) => '');

// /// CAC registration number — only relevant for Corporate filers.
// /// Leave empty ('') for Individual filers.
// final filingCacNumberProvider = StateProvider<String>((ref) => '');

// /// Contact details collected during TIN registration (Screen 3).
// /// Stored as a simple record so it can be passed directly to payment/init.
// final filingContactProvider = StateProvider<FilingContactRecord>(
//   (ref) => const FilingContactRecord(phoneNo: '', address: '', email: ''),
// );

// /// Lightweight value object for contact info (no dependency on repository).
// class FilingContactRecord {
//   final String phoneNo;
//   final String address;
//   final String email;

//   const FilingContactRecord({
//     required this.phoneNo,
//     required this.address,
//     required this.email,
//   });
// }

// // ── Selected plan ─────────────────────────────────────────────────────────────

// /// Plan title written by Step 2, read by Steps 3–6.
// final selectedFilingPlanProvider = StateProvider<String>((ref) => 'Freelancer');

// // ── Tax due ───────────────────────────────────────────────────────────────────

// /// Written by Step 3 after payment/init succeeds.
// /// Steps 4, 5, 6 read this as the authoritative tax liability.
// final filingTaxDueProvider = StateProvider<double>((ref) => 0.0);


// final filingIDProvider = StateProvider<String>((ref) => '');

// // ── Filing process state ──────────────────────────────────────────────────────

// /// After payment/liabilityfee succeeds, Step 5 writes the result here
// /// so Step 6 (and FilingRecord) can read the final status.
// final filingLiabilityResultProvider = StateProvider<LiabilityFeeResult?>(
//   (ref) => null,
// );

// // ── Resume routing helper ─────────────────────────────────────────────────────

// /// Returns the named route to navigate to when a FillingProcess already exists.
// /// Call this inside the Tax Dashboard or TIN Validation screen after data loads.
// ///
// /// Usage:
// ///   final route = resumeRouteFor(filingData.fillingProcess);
// ///   if (route != null) context.pushNamed(route);
// String? resumeRouteFor(FillingProcess? process) {
//   if (process == null) return null;
//   switch (process.status) {
//     case FillingStatus.pendingPayment:
//       return '/filing/step-4'; // Step 4
//     case FillingStatus.payedFillingFee:
//       return '/filing/step-5'; // Step 5
//     case FillingStatus.payedLiabilityFee:
//     case FillingStatus.validatingTax:
//     case FillingStatus.rejected:
//     case FillingStatus.completed:
//     case FillingStatus.failed:
//       return '/filing/step-6'; // Step 6 (status screen)
//     case FillingStatus.unknown:
//       return null;
//   }
// }
