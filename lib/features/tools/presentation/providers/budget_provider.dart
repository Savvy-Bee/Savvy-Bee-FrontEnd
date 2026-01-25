import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:savvy_bee_mobile/core/services/service_locator.dart';
import 'package:savvy_bee_mobile/features/tools/data/repositories/budget_repository.dart';
import 'package:savvy_bee_mobile/features/tools/domain/models/budget.dart';

/// Predefined budget categories
const List<String> predefinedBudgetCategories = [
  'Auto & transport',
  'Childcare & education',
  'Drinks & dining',
  'Entertainment',
  'Financial',
  'Groceries',
  'Healthcare',
  'Household',
  'Other',
  'Personal care',
  'Shopping',
];

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

  BudgetHomeNotifier(this._toolsRepository)
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

  /// Creates a new budget category with default values
  Future<String> createBudgetCategory(String categoryName) async {
    // Set state to loading
    state = const AsyncValue.loading();

    try {
      // Create budget with default values (0 spent, 0 total budget initially)
      final message = await _toolsRepository.createBudget(
        budgetName: categoryName,
        totalBudget: 0,
        amountSpent: 0,
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
}

/// Provider to get available budget categories (not yet created by user)
final availableBudgetCategoriesProvider = Provider<List<String>>((ref) {
  final budgetState = ref.watch(budgetHomeNotifierProvider);

  return budgetState.when(
    data: (data) {
      final existingCategories = data.budgets.map((b) => b.budgetName).toSet();
      return predefinedBudgetCategories
          .where((category) => !existingCategories.contains(category))
          .toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Provider to get existing budget categories (already created by user)
final existingBudgetCategoriesProvider = Provider<List<Budget>>((ref) {
  final budgetState = ref.watch(budgetHomeNotifierProvider);

  return budgetState.when(
    data: (data) => data.budgets,
    loading: () => [],
    error: (_, __) => [],
  );
});

/// The provider that exposes the [BudgetHomeNotifier] and its state.
final budgetHomeNotifierProvider =
    StateNotifierProvider<BudgetHomeNotifier, AsyncValue<BudgetHomeData>>((
      ref,
    ) {
      final toolsRepository = ref.watch(toolsRepositoryProvider);
      return BudgetHomeNotifier(toolsRepository);
    });
