import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:savvy_bee_mobile/core/network/api_client.dart';
import 'package:savvy_bee_mobile/core/services/service_locator.dart';
import 'package:savvy_bee_mobile/features/tools/data/repositories/debt_repository.dart';

class DebtListNotifier extends AsyncNotifier<List<dynamic>> {
  DebtRepository get _repository => ref.read(debtRepositoryProvider);

  @override
  Future<List<dynamic>> build() async {
    return _repository.getDebtHomeData();
  }

  Future<void> createDebt(Map<String, dynamic> debtData) async {
    state = const AsyncLoading();

    try {
      await _repository.createDebtStep1(debtData);

      ref.invalidateSelf();
    } catch (e, st) {
      state =
          AsyncError(e, st).copyWithPrevious(state)
              as AsyncValue<List<dynamic>>;

      if (e is ApiException) {
        rethrow;
      }
      throw ApiException(message: 'Failed to create debt: $e');
    }
  }

  Future<void> createDebtStep2({
    required String debtId,
    required String bankCode,
    required String accountNumber,
  }) async {
    try {
      await _repository.createDebtStep2(
        debtId: debtId,
        bankCode: bankCode,
        accountNumber: accountNumber,
      );
      ref.invalidateSelf();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> manualFundDebt(String debtId, String amount) async {
    try {
      // Renamed to match repository and endpoint
      await _repository.manualFundDebt(debtId, amount);
      ref.invalidateSelf();
    } catch (e) {
      rethrow;
    }
  }

  /// Method to manually refresh the debt list
  Future<void> refresh() async {
    state = const AsyncLoading();
    try {
      final data = await _repository.getDebtHomeData();
      state = AsyncData(data);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

/// The provider for the DebtListNotifier
final debtListNotifierProvider =
    AsyncNotifierProvider<DebtListNotifier, List<dynamic>>(
      DebtListNotifier.new,
    );
