// lib/features/tools/presentation/providers/tin_validation_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:savvy_bee_mobile/features/auth/presentation/providers/auth_providers.dart';
import 'package:savvy_bee_mobile/features/tools/data/repositories/tin_validation_repository.dart';

// ── Repository provider ───────────────────────────────────────────────────────

final tinValidationRepositoryProvider =
    Provider<TinValidationRepository>((ref) {
  final token = ref.watch(authRepositoryProvider).getAuthToken() ?? '';
  return TinValidationRepository(bearerToken: token);
});

// ── Result provider ───────────────────────────────────────────────────────────

/// Written by Screen 1 after a successful API call.
/// Read by Screen 2 to populate the taxpayer detail fields.
final tinValidationResultProvider =
    StateProvider<TinValidationResult?>((ref) => null);