import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:savvy_bee_mobile/core/network/api_client.dart';
import 'package:savvy_bee_mobile/core/services/service_locator.dart';
import 'package:savvy_bee_mobile/features/profile/data/repositories/nok_repository.dart';

final nokRepositoryProvider = Provider<NokRepository>((ref) {
  return NokRepository(apiClient: ref.watch(apiClientProvider));
});

/// Fetches current NOK data. Returns null if no NOK has been set yet.
final fetchNokProvider = FutureProvider<NokData?>((ref) async {
  try {
    return await ref.watch(nokRepositoryProvider).fetchNok();
  } on ApiException catch (_) {
    return null;
  } catch (_) {
    return null;
  }
});
