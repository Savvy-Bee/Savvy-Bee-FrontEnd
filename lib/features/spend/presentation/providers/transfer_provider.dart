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
  final bool isInitialized;
  final Map<String, dynamic>? initializeResult;

  const TransferState({
    this.isLoading = false,
    this.error,
    this.verifiedAccount,
    this.transaction,
    this.internalTransfer,
    this.isInitialized = false,
    this.initializeResult,
  });

  TransferState copyWith({
    bool? isLoading,
    String? error,
    AccountVerificationData? verifiedAccount,
    TransactionData? transaction,
    InternalTransferData? internalTransfer,
    bool? isInitialized,
    Map<String, dynamic>? initializeResult,
    bool clearError = false,
  }) {
    return TransferState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      verifiedAccount: verifiedAccount ?? this.verifiedAccount,
      transaction: transaction ?? this.transaction,
      internalTransfer: internalTransfer ?? this.internalTransfer,
      isInitialized: isInitialized ?? this.isInitialized,
      initializeResult: initializeResult ?? this.initializeResult,
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

  /// Step 1 — Initialize external bank transfer (NIP).
  /// Call this first; only call [verifyExternalTransfer] after this succeeds.
  Future<void> initializeExternalTransfer({
    required String accountNumber,
    required String bankCode,
    required double amount,
    required String accountName,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true, isInitialized: false);
    try {
      final result = await _repository.initializeTransaction(
        accountNumber: accountNumber,
        bankCode: bankCode,
        amount: amount,
        accountName: accountName,
      );
      if (result['success'] != true) {
        throw Exception(
          result['message']?.toString() ?? 'Failed to initialize transaction',
        );
      }
      state = state.copyWith(
        isLoading: false,
        isInitialized: true,
        initializeResult: result,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  /// Step 2 — Verify external bank transfer with PIN.
  /// Must only be called after [initializeExternalTransfer] succeeds.
  Future<void> verifyExternalTransfer({
    required String pin,
    required String transferFor,
    required String narration,
  }) async {
    if (!state.isInitialized) {
      throw Exception('Transaction not initialized. Please retry.');
    }
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _repository.verifyTransaction(
        pin: pin,
        transferFor: transferFor,
        narration: narration,
      );
      state = state.copyWith(
        isLoading: false,
        transaction: response.data,
        isInitialized: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  /// Combined Initialize + Verify for flows that don't pre-initialize.
  Future<void> initiateExternalTransfer({
    required String accountNumber,
    required String bankCode,
    required double amount,
    required String accountName,
    required String pin,
    required String transferFor,
    required String narration,
  }) async {
    await initializeExternalTransfer(
      accountNumber: accountNumber,
      bankCode: bankCode,
      amount: amount,
      accountName: accountName,
    );
    await verifyExternalTransfer(
      pin: pin,
      transferFor: transferFor,
      narration: narration,
    );
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
      ({String accountNumber, String bankCode, double amount, String accountName})
    >((ref, params) async {
      final repository = ref.watch(transferRepositoryProvider);
      return await repository.initializeTransaction(
        accountNumber: params.accountNumber,
        bankCode: params.bankCode,
        amount: params.amount,
        accountName: params.accountName,
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
      return response.data!;
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
      return response.data!;
    });
