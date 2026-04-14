import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/enums/financial_archetype_enums.dart';

// ─── Single-select providers (pages 1 & 3) ───────────────────────────────────

final userArchetypeProvider = StateProvider<UserArchetype?>((ref) => null);
final financeManagementProvider = StateProvider<FinanceManagement?>((ref) => null);

// ─── Multi-select providers (pages 2, 4, 5, 6) ───────────────────────────────

final financialPrioritiesProvider =
    StateProvider<List<FinancialPriority>>((ref) => const []);

final confusingTopicsProvider =
    StateProvider<List<ConfusingTopic>>((ref) => const []);

final financialChallengesProvider =
    StateProvider<List<FinancialChallenge>>((ref) => const []);

final financialMotivationsProvider =
    StateProvider<List<FinancialMotivation>>((ref) => const []);
