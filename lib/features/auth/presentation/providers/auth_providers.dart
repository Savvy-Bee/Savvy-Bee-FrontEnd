import 'dart:convert';
import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:savvy_bee_mobile/core/services/service_locator.dart';
import 'package:savvy_bee_mobile/core/services/storage_service.dart';
import 'package:savvy_bee_mobile/features/auth/data/repositories/auth_repository.dart';
import 'package:savvy_bee_mobile/features/auth/domain/models/auth_models.dart';

import '../../../../core/network/models/api_response_model.dart';
import '../../domain/models/user.dart';

// Auth repository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final storageService = ref.watch(storageServiceProvider);
  return AuthRepository(apiClient: apiClient, storageService: storageService);
});

/// Auth state for managing authentication status
class AuthState {
  final User? user;
  final bool isLoading;
  final String? errorMessage;
  final bool isAuthenticated;
  final bool isInitialized; // ADD THIS

  AuthState({
    this.user,
    this.isLoading = false,
    this.errorMessage,
    this.isInitialized = false, // ADD THIS
  }) : isAuthenticated = user != null;

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? errorMessage,
    bool? isInitialized, // ADD THIS
    bool clearError = false,
    bool clearUser = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isInitialized: isInitialized ?? this.isInitialized, // ADD THIS
    );
  }

  factory AuthState.initial() => AuthState();

  @override
  String toString() {
    return 'AuthState(user: ${user?.email}, isLoading: $isLoading, '
        'isAuthenticated: $isAuthenticated, isInitialized: $isInitialized)';
  }
}

/// Auth notifier for managing authentication logic
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;
  final StorageService _storageService;

  AuthNotifier(this._authRepository, this._storageService)
    : super(AuthState.initial()) {
    _initialize();
  }

  /// Initialize authentication state from storage
  Future<void> _initialize() async {
    try {
      log('→ Initializing auth state...');

      // CRITICAL: Load token from storage and set in API client
      await _authRepository.loadAndSetToken();

      // Load user data
      await _loadUserFromStorage();

      // Mark as initialized
      state = state.copyWith(isInitialized: true);

      log('✓ Auth initialized - Authenticated: ${state.isAuthenticated}');
    } catch (e) {
      log('✗ Auth initialization error: $e');
      state = AuthState.initial().copyWith(isInitialized: true);
    }
  }

  /// Load user data from local storage
  Future<void> _loadUserFromStorage() async {
    try {
      final userData = await _storageService.getData(
        StorageService.userDataKey,
      );

      if (userData != null) {
        final userMap = jsonDecode(userData);
        final user = User.fromJson(userMap);

        final token = await _storageService.getAuthToken();
        if (token != null) {
          state = state.copyWith(user: user);
          log('✓ User loaded: ${user.email}');
        } else {
          log('⚠ No token found - clearing storage');
          await _clearStorage();
        }
      }
    } catch (e) {
      log('✗ Error loading user: $e');
      await _clearStorage();
    }
  }

  /// Save user data to local storage
  Future<void> _saveUserToStorage(User user) async {
    try {
      final userData = jsonEncode(user.toJson());
      await _storageService.saveData(StorageService.userDataKey, userData);
      log('User saved to storage: ${user.email}');
    } catch (e) {
      log('Error saving user to storage: $e');
    }
  }

  /// Clear all stored authentication data
  Future<void> _clearStorage() async {
    try {
      await _storageService.deleteAuthToken();
      await _storageService.deleteData(StorageService.userDataKey);
      _authRepository.clearAuthToken();
      log('Storage cleared');
    } catch (e) {
      log('Error clearing storage: $e');
    }
  }

  /// Register a new user
  Future<bool> register(RegisterRequest request) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await _authRepository.register(request);

      if (response.success && response.data != null) {
        final user = response.data!;
        state = state.copyWith(user: user, isLoading: false);
        await _saveUserToStorage(user);
        log('User registered successfully: ${user.email}');
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: response.message,
        );
        return false;
      }
    } catch (e) {
      log('Register error: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'An unexpected error occurred during registration',
      );
      return false;
    }
  }

  /// Resend OTP to user's email
  Future<bool> resendOtp(String email) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await _authRepository.resendOtp(email);

      state = state.copyWith(
        isLoading: false,
        errorMessage: response.success ? null : response.message,
      );

      if (response.success) {
        log('OTP resent successfully to: $email');
      }

      return response.success;
    } catch (e) {
      log('Resend OTP error: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to resend OTP',
      );
      return false;
    }
  }

  /// Verify email with OTP code
  Future<bool> verifyEmail(VerifyEmailRequest request) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await _authRepository.verifyEmail(request);

      if (response.success) {
        // Update user verification status
        if (state.user != null) {
          final updatedUser = User(
            id: state.user!.id,
            firstName: state.user!.firstName,
            lastName: state.user!.lastName,
            email: state.user!.email,
            verified: true,
          );

          state = state.copyWith(user: updatedUser, isLoading: false);
          await _saveUserToStorage(updatedUser);
          log('Email verified successfully: ${updatedUser.email}');
        } else {
          state = state.copyWith(isLoading: false);
        }
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: response.message,
        );
        return false;
      }
    } catch (e) {
      log('Verify email error: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Email verification failed',
      );
      return false;
    }
  }

  /// Register additional user details (DOB and Country)
  Future<bool> registerOtherDetails(RegisterOtherDetailsRequest request) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await _authRepository.registerOtherDetails(request);

      if (response.success) {
        state = state.copyWith(isLoading: false);
        log('Other details registered successfully');
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: response.message,
        );
        return false;
      }
    } catch (e) {
      log('Register other details error: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to register other details',
      );
      return false;
    }
  }

  /// Login with email and password
  Future<ApiResponse<LoginData>?> login(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await _authRepository.login(email, password);

      if (response != null && response.success && response.data != null) {
        state = state.copyWith(isLoading: false);

        return response;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: response?.message,
        );
        return response;
      }
    } catch (e) {
      log('Login error: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Login failed. Please try again.',
      );
      return null;
    }
  }

  /// Request password reset
  Future<bool> requestPasswordReset(String email) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await _authRepository.requestPasswordReset(email);

      state = state.copyWith(
        isLoading: false,
        errorMessage: response.success ? null : response.message,
      );

      if (response.success) {
        log('Password reset requested for: $email');
      }

      return response.success;
    } catch (e) {
      log('Request password reset error: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to request password reset',
      );
      return false;
    }
  }

  /// Reset password with OTP
  Future<bool> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await _authRepository.resetPassword(
        email: email,
        otp: otp,
        newPassword: newPassword,
      );

      state = state.copyWith(
        isLoading: false,
        errorMessage: response.success ? null : response.message,
      );

      if (response.success) {
        log('Password reset successfully for: $email');
      }

      return response.success;
    } catch (e) {
      log('Reset password error: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to reset password',
      );
      return false;
    }
  }

  /// Set user onboarding data (WhatMatters, Archetype, etc.)
  Future<bool> postOnboardData(PostOnboardRequest request) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await _authRepository.postOnboardData(request);

      if (response.success) {
        state = state.copyWith(isLoading: false);
        log('Post-onboard data saved successfully');
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: response.message,
        );
        return false;
      }
    } catch (e) {
      log('Post-onboard data error: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to save post-onboard data',
      );
      return false;
    }
  }

  /// Update user data (AI Settings, Language, Country)
  Future<bool> updateUserData(UpdateUserDataRequest request) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await _authRepository.updateUserData(request);

      if (response.success) {
        // If the update is successful, we should theoretically
        // refresh the user profile to reflect the changes locally.
        // Since you don't have a dedicated 'getUserProfile' endpoint
        // implemented yet, we'll just stop loading for now.
        state = state.copyWith(isLoading: false);
        log('User data updated successfully');
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: response.message,
        );
        return false;
      }
    } catch (e) {
      log('Update user data error: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to update user data',
      );
      return false;
    }
  }

  /// Logout and clear all user data
  Future<void> logout() async {
    try {
      await _clearStorage();
      state = AuthState.initial();
      log('User logged out successfully');
    } catch (e) {
      log('Logout error: $e');
      // Still reset state even if clearing storage fails
      state = AuthState.initial();
    }
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

// Auth provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final storageService = ref.watch(storageServiceProvider);
  return AuthNotifier(authRepository, storageService);
});

// Convenience providers for common auth checks
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authProvider).user;
});

final isLoadingProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isLoading;
});

final authIsInitializedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isInitialized;
});
