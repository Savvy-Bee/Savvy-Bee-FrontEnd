import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/enums/financial_archetype_enums.dart';

final userArchetypeProvider = StateProvider<UserArchetype?>((ref) => null);
final financialPriorityProvider = StateProvider<FinancialPriority?>((ref) => null);
final financeManagementProvider = StateProvider<FinanceManagement?>((ref) => null);
final confusingTopicProvider = StateProvider<ConfusingTopic?>((ref) => null);
final financialChallengeProvider = StateProvider<FinancialChallenge?>((ref) => null);
final financialMotivationProvider = StateProvider<FinancialMotivation?>((ref) => null);