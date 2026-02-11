import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:savvy_bee_mobile/core/services/service_locator.dart';
import 'package:savvy_bee_mobile/features/profile/data/repositories/delete_account_repository.dart';

// ============================================================================
// Repository Provider
// ============================================================================

final deleteAccountRepositoryProvider = Provider<DeleteAccountRepository>((
  ref,
) {
  final apiClient = ref.watch(apiClientProvider);
  return DeleteAccountRepository(apiClient: apiClient);
});

// ============================================================================
// State for delete account operations
// ============================================================================

class DeleteAccountState {
  final bool isLoading;
  final String? error;
  final bool isOtpSent;
  final bool isDeleted;

  DeleteAccountState({
    this.isLoading = false,
    this.error,
    this.isOtpSent = false,
    this.isDeleted = false,
  });

  DeleteAccountState copyWith({
    bool? isLoading,
    String? error,
    bool? isOtpSent,
    bool? isDeleted,
  }) {
    return DeleteAccountState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isOtpSent: isOtpSent ?? this.isOtpSent,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}

// ============================================================================
// Notifier for delete account operations
// ============================================================================

class DeleteAccountNotifier extends StateNotifier<DeleteAccountState> {
  final DeleteAccountRepository repository;

  DeleteAccountNotifier({required this.repository})
    : super(DeleteAccountState());

  /// Step 1: Request account deletion (sends OTP)
  Future<void> requestDeletion(String email) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await repository.requestAccountDeletion(email: email);

      if (response.success) {
        state = state.copyWith(isLoading: false, isOtpSent: true, error: null);
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.message ?? 'Failed to send OTP',
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Step 2: Verify OTP and delete account
  Future<void> verifyAndDelete(String email, String otp) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await repository.verifyAndDeleteAccount(
        email: email,
        otp: otp,
      );

      if (response.success) {
        state = state.copyWith(isLoading: false, isDeleted: true, error: null);
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.message ?? 'Failed to delete account',
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Reset state
  void reset() {
    state = DeleteAccountState();
  }
}

// ============================================================================
// Provider
// ============================================================================

final deleteAccountNotifierProvider =
    StateNotifierProvider<DeleteAccountNotifier, DeleteAccountState>((ref) {
      final repository = ref.watch(deleteAccountRepositoryProvider);
      return DeleteAccountNotifier(repository: repository);
    });
