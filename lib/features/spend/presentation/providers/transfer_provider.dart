import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:savvy_bee_mobile/core/services/service_locator.dart';
import 'package:savvy_bee_mobile/features/spend/data/repositories/transfer_repository.dart.dart';
import 'package:savvy_bee_mobile/features/spend/domain/models/account_verification.dart';
import 'package:savvy_bee_mobile/features/spend/domain/models/bank.dart';
import 'package:savvy_bee_mobile/features/spend/domain/models/internal_transfer.dart';
import 'package:savvy_bee_mobile/features/spend/domain/models/transaction.dart';

// Provider for TransferRepository
final transferRepositoryProvider = Provider<TransferRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return TransferRepository(apiClient: apiClient);
});

// Provider to fetch all banks
final banksProvider = FutureProvider<List<Bank>>((ref) async {
  final repository = ref.watch(transferRepositoryProvider);
  final response = await repository.getBanks();
  return response.data;
});

// Provider to verify account (family provider for parameters)
final verifyAccountProvider =
    FutureProvider.family<
      AccountVerificationData,
      ({String accountNumber, String bankName})
    >((ref, params) async {
      final repository = ref.watch(transferRepositoryProvider);
      final response = await repository.verifyAccount(
        accountNumber: params.accountNumber,
        bankName: params.bankName,
      );
      return response.data;
    });

// State class for transfer operations
class TransferState {
  final bool isLoading;
  final String? error;
  final AccountVerificationData? verifiedAccount;
  final TransactionData? transaction;
  final InternalTransferData? internalTransfer;

  const TransferState({
    this.isLoading = false,
    this.error,
    this.verifiedAccount,
    this.transaction,
    this.internalTransfer,
  });

  TransferState copyWith({
    bool? isLoading,
    String? error,
    AccountVerificationData? verifiedAccount,
    TransactionData? transaction,
    InternalTransferData? internalTransfer,
    bool clearError = false,
  }) {
    return TransferState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      verifiedAccount: verifiedAccount ?? this.verifiedAccount,
      transaction: transaction ?? this.transaction,
      internalTransfer: internalTransfer ?? this.internalTransfer,
    );
  }
}

// State notifier for managing transfer flow with loading states
class TransferNotifier extends StateNotifier<TransferState> {
  final TransferRepository _repository;

  TransferNotifier(this._repository) : super(const TransferState());

  /// Verify account before transfer
  Future<void> verifyAccount({
    required String accountNumber,
    required String bankName,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _repository.verifyAccount(
        accountNumber: accountNumber,
        bankName: bankName,
      );
      state = state.copyWith(isLoading: false, verifiedAccount: response.data);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  /// Initialize and complete external bank transfer
  Future<void> initiateExternalTransfer({
    required String accountNumber,
    required String bankCode,
    required double amount,
    required String pin,
    required String transferFor,
    required String narration,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      // Step 1: Initialize transaction
      await _repository.initializeTransaction(
        accountNumber: accountNumber,
        bankCode: bankCode,
        amount: amount,
      );

      // Step 2: Verify transaction with PIN
      final response = await _repository.verifyTransaction(
        pin: pin,
        transferFor: transferFor,
        narration: narration,
      );

      state = state.copyWith(isLoading: false, transaction: response.data);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  /// Send money to another user within the app
  Future<void> sendMoneyInternally({
    required String pin,
    required String transferFor,
    required String narration,
    required String username,
    required double amount,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _repository.sendMoneyInternally(
        pin: pin,
        transferFor: transferFor,
        narration: narration,
        username: username,
        amount: amount,
      );

      state = state.copyWith(isLoading: false, internalTransfer: response.data);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  /// Clear verified account data
  void clearVerifiedAccount() {
    state = const TransferState();
  }

  /// Reset entire state
  void reset() {
    state = const TransferState();
  }
}

// Provider for TransferNotifier
final transferNotifierProvider =
    StateNotifierProvider<TransferNotifier, TransferState>((ref) {
      final repository = ref.watch(transferRepositoryProvider);
      return TransferNotifier(repository);
    });

// Additional convenience providers for individual operations

/// Initialize external transfer
final initializeTransferProvider =
    FutureProvider.family<
      Map<String, dynamic>,
      ({String accountNumber, String bankCode, double amount})
    >((ref, params) async {
      final repository = ref.watch(transferRepositoryProvider);
      return await repository.initializeTransaction(
        accountNumber: params.accountNumber,
        bankCode: params.bankCode,
        amount: params.amount,
      );
    });

/// Verify and complete external transfer
final verifyTransferProvider =
    FutureProvider.family<
      TransactionData,
      ({String pin, String transferFor, String narration})
    >((ref, params) async {
      final repository = ref.watch(transferRepositoryProvider);
      final response = await repository.verifyTransaction(
        pin: params.pin,
        transferFor: params.transferFor,
        narration: params.narration,
      );
      return response.data;
    });

/// Internal transfer to another user
final internalTransferProvider =
    FutureProvider.family<
      InternalTransferData,
      ({
        String pin,
        String transferFor,
        String narration,
        String username,
        double amount,
      })
    >((ref, params) async {
      final repository = ref.watch(transferRepositoryProvider);
      final response = await repository.sendMoneyInternally(
        pin: params.pin,
        transferFor: params.transferFor,
        narration: params.narration,
        username: params.username,
        amount: params.amount,
      );
      return response.data;
    });
