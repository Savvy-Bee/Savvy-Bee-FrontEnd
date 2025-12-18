import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:savvy_bee_mobile/core/network/models/api_response_model.dart';
import 'package:savvy_bee_mobile/core/services/service_locator.dart';
import 'package:savvy_bee_mobile/features/spend/domain/models/wallet.dart';

// Create Naira Account Provider
final createNairaAccountProvider = FutureProvider.autoDispose
    .family<ApiResponse<WalletDashboardData>, String>((ref, pin) async {
      final repository = ref.watch(walletRepositoryProvider);
      return await repository.createNairaAccount(pin: pin);
    });

// Dashboard Data Provider
final dashboardDataProvider =
    FutureProvider.autoDispose<ApiResponse<WalletDashboardData>>((ref) async {
      final repository = ref.watch(walletRepositoryProvider);
      return await repository.fetchDashboardData();
    });

// Transactions Provider with Pagination Parameters
class TransactionParams {
  final int page;
  final int limit;

  const TransactionParams({this.page = 1, this.limit = 10});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionParams &&
          runtimeType == other.runtimeType &&
          page == other.page &&
          limit == other.limit;

  @override
  int get hashCode => page.hashCode ^ limit.hashCode;
}

final transactionsProvider = FutureProvider.autoDispose
    .family<ApiResponse<WalletTransactionsResponse>, TransactionParams>((
      ref,
      params,
    ) async {
      final repository = ref.watch(walletRepositoryProvider);
      return await repository.fetchTransactions(
        page: params.page,
        limit: params.limit,
      );
    });

// Convenience provider for default transaction list (first page)
final defaultTransactionsProvider =
    FutureProvider.autoDispose<ApiResponse<WalletTransactionsResponse>>((
      ref,
    ) async {
      return ref.watch(
        transactionsProvider(
          const TransactionParams(page: 1, limit: 10),
        ).future,
      );
    });

// State Notifier for managing transaction pagination
class TransactionListNotifier
    extends StateNotifier<AsyncValue<ApiResponse<WalletTransactionsResponse>>> {
  TransactionListNotifier(this._ref) : super(const AsyncValue.loading()) {
    loadTransactions();
  }

  final Ref _ref;
  int _currentPage = 1;
  final int _limit = 10;

  int get currentPage => _currentPage;

  Future<void> loadTransactions() async {
    if (mounted) {
      state = const AsyncValue.loading();
      state = await AsyncValue.guard(() async {
        final repository = _ref.read(walletRepositoryProvider);
        return await repository.fetchTransactions(
          page: _currentPage,
          limit: _limit,
        );
      });
    }
  }

  Future<void> nextPage() async {
    final currentState = state.value;
    if (currentState?.data?.pagination.hasNextPage ?? false) {
      _currentPage++;
      await loadTransactions();
    }
  }

  Future<void> previousPage() async {
    if (_currentPage > 1) {
      _currentPage--;
      await loadTransactions();
    }
  }

  Future<void> goToPage(int page) async {
    if (page > 0) {
      _currentPage = page;
      await loadTransactions();
    }
  }

  Future<void> refresh() async {
    _currentPage = 1;
    await loadTransactions();
  }
}

final transactionListProvider =
    StateNotifierProvider.autoDispose<
      TransactionListNotifier,
      AsyncValue<ApiResponse<WalletTransactionsResponse>>
    >((ref) => TransactionListNotifier(ref));
