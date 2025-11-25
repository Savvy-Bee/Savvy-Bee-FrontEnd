import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:savvy_bee_mobile/core/network/api_client.dart';
import 'package:savvy_bee_mobile/core/services/service_locator.dart';
import 'package:savvy_bee_mobile/features/tools/data/repositories/debt_repository.dart';
import 'package:savvy_bee_mobile/features/tools/domain/models/debt.dart';

class DebtListNotifier extends AsyncNotifier<DebtListResponse> {
  DebtRepository get _repository => ref.read(debtRepositoryProvider);

  @override
  Future<DebtListResponse> build() async {
    return _repository.getDebtHomeData();
  }

  // Returns dynamic (the response) so UI can get the ID
  Future<DebtCreationResponse> createDebt(DebtRequestModel debtData) async {
    state = const AsyncLoading();

    try {
      final response = await _repository.createDebtStep1(debtData);

      // We don't invalidate yet if we want to keep the loading state
      // logic clean between steps, but usually, we invalidate to refresh the list
      // in the background.
      ref.invalidateSelf();

      return response;
    } catch (e, st) {
      state =
          AsyncError(e, st).copyWithPrevious(state)
              as AsyncValue<DebtListResponse>;

      if (e is ApiException) {
        rethrow;
      }
      throw ApiException(message: 'Failed to create debt: $e');
    }
  }

  Future<void> createDebtStep2({
    required DebtCreationStep2Request reqBody,
  }) async {
    state = const AsyncLoading(); // Set loading state
    try {
      await _repository.createDebtStep2(reqBody: reqBody);
      ref.invalidateSelf();
    } catch (e, st) {
      state =
          AsyncError(e, st).copyWithPrevious(state)
              as AsyncValue<DebtListResponse>;
      rethrow;
    }
  }

  Future<void> manualFundDebt(String debtId, String amount) async {
    try {
      await _repository.manualFundDebt(debtId, amount);
      ref.invalidateSelf();
    } catch (e) {
      rethrow;
    }
  }

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

final debtListNotifierProvider =
    AsyncNotifierProvider<DebtListNotifier, DebtListResponse>(
      DebtListNotifier.new,
    );
