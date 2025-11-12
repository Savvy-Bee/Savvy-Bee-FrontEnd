import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:savvy_bee_mobile/core/services/service_locator.dart';
import 'package:savvy_bee_mobile/features/tools/data/repositories/goals_repository.dart';
import 'package:savvy_bee_mobile/features/tools/domain/models/savings.dart';

// ============================================================================
// Repository Provider
// ============================================================================

final goalsRepositoryProvider = Provider<GoalsRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return GoalsRepository(apiClient: apiClient);
});

// ============================================================================
// Data Providers
// ============================================================================

/// Provider to fetch all savings goals
final savingsGoalsProvider = FutureProvider<List<SavingsGoal>>((ref) async {
  final repository = ref.watch(goalsRepositoryProvider);
  final response = await repository.getHomeData();

  if (response.success && response.data != null) {
    return response.data!;
  } else {
    throw Exception(response.message);
  }
});

/// Provider to fetch a specific savings goal by ID
final savingsGoalByIdProvider = Provider.family<SavingsGoal?, String>((
  ref,
  goalId,
) {
  final goalsAsync = ref.watch(savingsGoalsProvider);

  return goalsAsync.maybeWhen(
    data: (goals) => goals.firstWhere(
      (goal) => goal.id == goalId,
      orElse: () => throw Exception('Goal not found'),
    ),
    orElse: () => null,
  );
});

// ============================================================================
// Action Providers (StateNotifierProvider for mutable state)
// ============================================================================

/// State for savings goal operations
class SavingsGoalState {
  final bool isLoading;
  final String? error;
  final SavingsGoal? updatedGoal;

  SavingsGoalState({this.isLoading = false, this.error, this.updatedGoal});

  SavingsGoalState copyWith({
    bool? isLoading,
    String? error,
    SavingsGoal? updatedGoal,
  }) {
    return SavingsGoalState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      updatedGoal: updatedGoal ?? this.updatedGoal,
    );
  }
}

/// Notifier for savings goal operations
class SavingsGoalNotifier extends StateNotifier<SavingsGoalState> {
  final GoalsRepository repository;
  final Ref ref;

  SavingsGoalNotifier({required this.repository, required this.ref})
    : super(SavingsGoalState());

  /// Create a new savings goal
  Future<void> createGoal({
    required String name,
    required double totalSavings,
    required double amountSaved,
    required String endDate,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await repository.createSavings(
        name: name,
        totalSavings: totalSavings,
        amountSaved: amountSaved,
        endDate: endDate,
      );

      if (response.success && response.data != null) {
        state = state.copyWith(isLoading: false, updatedGoal: response.data);

        // Refresh the goals list
        ref.invalidate(savingsGoalsProvider);
      } else {
        state = state.copyWith(isLoading: false, error: response.message);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Add funds to a savings goal
  Future<void> addFunds({
    required String goalId,
    required double amount,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await repository.addFunds(
        goalId: goalId,
        amount: amount,
      );

      if (response.success && response.data != null) {
        state = state.copyWith(isLoading: false, updatedGoal: response.data);

        // Refresh the goals list
        ref.invalidate(savingsGoalsProvider);
      } else {
        state = state.copyWith(isLoading: false, error: response.message);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Withdraw funds from a savings goal
  Future<void> withdrawFunds({
    required String goalId,
    required double amount,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await repository.withdrawFunds(
        goalId: goalId,
        amount: amount,
      );

      if (response.success && response.data != null) {
        state = state.copyWith(isLoading: false, updatedGoal: response.data);

        // Refresh the goals list
        ref.invalidate(savingsGoalsProvider);
      } else {
        state = state.copyWith(isLoading: false, error: response.message);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Reset state
  void reset() {
    state = SavingsGoalState();
  }
}

/// Provider for savings goal operations
final savingsGoalNotifierProvider =
    StateNotifierProvider<SavingsGoalNotifier, SavingsGoalState>((ref) {
      final repository = ref.watch(goalsRepositoryProvider);
      return SavingsGoalNotifier(repository: repository, ref: ref);
    });

// ============================================================================
// Utility Providers
// ============================================================================

/// Provider to calculate total savings across all goals
final totalSavingsProvider = Provider<double>((ref) {
  final goalsAsync = ref.watch(savingsGoalsProvider);

  return goalsAsync.maybeWhen(
    data: (goals) => goals.fold(0.0, (sum, goal) => sum + goal.balance),
    orElse: () => 0.0,
  );
});

/// Provider to calculate total target amount across all goals
final totalTargetProvider = Provider<double>((ref) {
  final goalsAsync = ref.watch(savingsGoalsProvider);

  return goalsAsync.maybeWhen(
    data: (goals) => goals.fold(0.0, (sum, goal) => sum + goal.targetAmount),
    orElse: () => 0.0,
  );
});

/// Provider to get completed goals
final completedGoalsProvider = Provider<List<SavingsGoal>>((ref) {
  final goalsAsync = ref.watch(savingsGoalsProvider);

  return goalsAsync.maybeWhen(
    data: (goals) => goals.where((goal) => goal.isCompleted).toList(),
    orElse: () => [],
  );
});

/// Provider to get active (incomplete) goals
final activeGoalsProvider = Provider<List<SavingsGoal>>((ref) {
  final goalsAsync = ref.watch(savingsGoalsProvider);

  return goalsAsync.maybeWhen(
    data: (goals) => goals.where((goal) => !goal.isCompleted).toList(),
    orElse: () => [],
  );
});
