import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:savvy_bee_mobile/core/services/service_locator.dart';
import 'package:savvy_bee_mobile/features/tools/data/repositories/budget_repository.dart';
import 'package:savvy_bee_mobile/features/tools/domain/models/budget.dart';

/// A simple FutureProvider to fetch the budget home data.
///
/// This is read-only. To refetch, you would call `ref.invalidate(budgetHomeDataProvider)`.
final budgetHomeDataProvider = FutureProvider<BudgetHomeData>((ref) {
  final toolsRepository = ref.watch(toolsRepositoryProvider);
  return toolsRepository.getBudgetHomeData();
});

/// Manages the state for the budget home screen, handling fetching
/// and mutations.
class BudgetHomeNotifier extends StateNotifier<AsyncValue<BudgetHomeData>> {
  final BudgetRepository _toolsRepository;
  final Ref _ref; // Store Ref to read other providers

  BudgetHomeNotifier(this._toolsRepository, this._ref)
    : super(const AsyncValue.loading()) {
    // Fetch data when the notifier is first created
    fetchBudgetHomeData();
  }

  /// Fetches the initial data.
  Future<void> fetchBudgetHomeData() async {
    try {
      state = const AsyncValue.loading();
      final data = await _toolsRepository.getBudgetHomeData();
      state = AsyncValue.data(data);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Updates the user's monthly earnings.
  Future<String> updateMonthlyEarnings(num monthlyEarning) async {
    // Set state to loading
    state = const AsyncValue.loading();

    try {
      final message = await _toolsRepository.updateMonthlyEarnings(
        monthlyEarning,
      );

      // On success, refetch the data to show the update
      await fetchBudgetHomeData();

      return message; // Return success message
    } catch (e, st) {
      // On error, update the state and rethrow
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Creates a new budget.
  Future<String> createBudget({
    required String budgetName,
    required num totalBudget,
    required num amountSpent,
  }) async {
    // Set state to loading
    state = const AsyncValue.loading();

    try {
      final message = await _toolsRepository.createBudget(
        budgetName: budgetName,
        totalBudget: totalBudget,
        amountSpent: amountSpent,
      );

      // On success, refetch the data
      await fetchBudgetHomeData();

      return message; // Return success message
    } catch (e, st) {
      // On error, update the state and rethrow
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Updates an existing budget using BudgetName, TotalBudget, and amountSpent.
  Future<String> updateBudget({
    required String budgetName,
    required num newTargetAmount,
    required num amountSpent,
  }) async {
    try {
      final message = await _toolsRepository.updateBudget(
        budgetName: budgetName,
        newTargetAmount: newTargetAmount,
        amountSpent: amountSpent,
      );

      // On success, refetch the data to show the update
      await fetchBudgetHomeData();

      return message; // Return success message
    } catch (e) {
      // On error, rethrow to be caught by the button's try/catch.
      rethrow;
    }
  }
}

/// The provider that exposes the [BudgetHomeNotifier] and its state.
final budgetHomeNotifierProvider =
    StateNotifierProvider<BudgetHomeNotifier, AsyncValue<BudgetHomeData>>((
      ref,
    ) {
      final toolsRepository = ref.watch(toolsRepositoryProvider);
      return BudgetHomeNotifier(toolsRepository, ref);
    });
