// lib/features/tools/presentation/providers/filing_home_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:savvy_bee_mobile/features/auth/presentation/providers/auth_providers.dart';
import 'package:savvy_bee_mobile/features/tools/data/repositories/filing_home_repository.dart';
import 'package:savvy_bee_mobile/features/tools/domain/models/filing_home_data.dart';

// ── Repository provider ──────────────────────────────────────────────────────

/// Exposes the repository. Token is pulled from your existing auth provider.
/// Replace `authNotifierProvider` / `.token` with whatever your app uses.
final filingHomeRepositoryProvider = Provider<FilingHomeRepository>((ref) {
  final token = ref.watch(authRepositoryProvider).getAuthToken() ?? '';
  return FilingHomeRepository(bearerToken: token);
});

// ── Data provider ────────────────────────────────────────────────────────────

/// Fetches filing home data exactly once and caches the result for the
/// lifetime of the provider (i.e. the entire filing flow).
///
/// Any step screen can call:
///   final dataAsync = ref.watch(filingHomeProvider);
///
/// To force a refresh (e.g. pull-to-refresh):
///   ref.invalidate(filingHomeProvider);
final filingHomeProvider =
    AsyncNotifierProvider<FilingHomeNotifier, FilingHomeData>(
      FilingHomeNotifier.new,
    );

class FilingHomeNotifier extends AsyncNotifier<FilingHomeData> {
  @override
  Future<FilingHomeData> build() async {
    final repo = ref.read(filingHomeRepositoryProvider);
    return repo.fetchHomeData();
  }

  /// Force-refresh from the network.
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(filingHomeRepositoryProvider).fetchHomeData(),
    );
  }
}
