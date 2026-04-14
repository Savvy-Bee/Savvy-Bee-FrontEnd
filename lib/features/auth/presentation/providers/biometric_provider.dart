import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:savvy_bee_mobile/core/services/biometric_service.dart';
import 'package:savvy_bee_mobile/core/services/device_info_service.dart';
import 'package:savvy_bee_mobile/core/services/service_locator.dart';
import 'package:savvy_bee_mobile/core/services/storage_service.dart';
import 'package:savvy_bee_mobile/features/auth/data/repositories/auth_repository.dart';

// ─── Constants ───────────────────────────────────────────────────────────────

/// Number of consecutive biometric failures before the lock is permanently
/// removed and the user is forced back to password login.
const _kMaxFailures = 5;

/// Days since the last full (email + password) login before the user must
/// authenticate with credentials again regardless of biometric state.
const _kPasswordRefreshDays = 30;

// ─── State ───────────────────────────────────────────────────────────────────

class BiometricState {
  final bool isEnabled;
  final bool isAvailable;
  final bool isAuthenticating;
  final String? errorMessage;

  const BiometricState({
    this.isEnabled = false,
    this.isAvailable = false,
    this.isAuthenticating = false,
    this.errorMessage,
  });

  BiometricState copyWith({
    bool? isEnabled,
    bool? isAvailable,
    bool? isAuthenticating,
    String? errorMessage,
    bool clearError = false,
  }) {
    return BiometricState(
      isEnabled: isEnabled ?? this.isEnabled,
      isAvailable: isAvailable ?? this.isAvailable,
      isAuthenticating: isAuthenticating ?? this.isAuthenticating,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

// ─── Result enum ─────────────────────────────────────────────────────────────

enum BiometricAuthResult {
  /// OS prompt passed and a valid session is now active.
  success,

  /// User dismissed the OS prompt without authenticating.
  cancelled,

  /// OS prompt failed (non-lockout error).
  failed,

  /// Too many consecutive failures – biometrics have been disabled automatically.
  permanentlyFailed,

  /// Device is locked out temporarily or permanently.
  lockedOut,

  /// Biometrics not available / not enabled.
  notAvailable,

  /// Token expired AND silent re-login via stored credentials also failed.
  /// Caller should redirect to the login screen.
  tokenExpired,

  /// 30 days have passed since the last email+password login.
  /// Caller must redirect to the login screen.
  passwordLoginRequired,
}

// ─── Notifier ────────────────────────────────────────────────────────────────

class BiometricNotifier extends StateNotifier<BiometricState> {
  final BiometricService _biometricService;
  final StorageService _storageService;
  final AuthRepository _authRepository;

  BiometricNotifier(
    this._biometricService,
    this._storageService,
    this._authRepository,
  ) : super(const BiometricState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    final availability = await _biometricService.checkAvailability();
    final isAvailable = availability == BiometricAvailability.available;
    final isEnabled =
        isAvailable && await _storageService.getBiometricEnabled();

    state = state.copyWith(isAvailable: isAvailable, isEnabled: isEnabled);
    log('→ BiometricNotifier init: available=$isAvailable, enabled=$isEnabled');
  }

  // ─── Enable / Disable ──────────────────────────────────────────────────────

  /// Called from Security / Profile toggle.
  /// [userEmail] is the currently logged-in email (credentials were already
  /// saved to secure storage on login, so no password needed here).
  Future<bool> enableBiometrics(String userEmail) async {
    if (!state.isAvailable) {
      state = state.copyWith(
        errorMessage: 'Biometrics not available on this device.',
      );
      return false;
    }

    state = state.copyWith(isAuthenticating: true, clearError: true);

    try {
      final authenticated = await _biometricService.authenticate(
        reason: 'Confirm your identity to enable biometric login',
      );

      if (!authenticated) {
        state = state.copyWith(
          isAuthenticating: false,
          errorMessage: 'Authentication cancelled.',
        );
        return false;
      }

      await _storageService.setBiometricEnabled(true);
      await _storageService.saveBiometricEmail(userEmail);
      await _storageService.clearBiometricFailureCount();
      state = state.copyWith(isAuthenticating: false, isEnabled: true);
      log('✓ Biometric login enabled for $userEmail');
      return true;
    } on BiometricLockoutException catch (e) {
      state = state.copyWith(
        isAuthenticating: false,
        errorMessage: e.isPermanent
            ? 'Too many failed attempts. Use your password.'
            : 'Temporarily locked out. Try again later.',
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isAuthenticating: false,
        errorMessage: 'An error occurred. Try again.',
      );
      return false;
    }
  }

  Future<void> disableBiometrics() async {
    await _storageService.setBiometricEnabled(false);
    // Keep stored credentials so re-enabling later still works until logout.
    // Full credential wipe only happens on logout (clearAll).
    state = state.copyWith(isEnabled: false, clearError: true);
    log('✓ Biometric login disabled');
  }

  // ─── Authenticate ──────────────────────────────────────────────────────────

  /// Called on the lock screen and login screen biometric button.
  ///
  /// Flow:
  ///  1. Enforce 30-day password-refresh rule.
  ///  2. Check consecutive failure count (auto-disable at [_kMaxFailures]).
  ///  3. Show OS biometric prompt.
  ///  4. On success, ensure a valid JWT exists — if expired, silently re-login
  ///     using credentials stored at last password login.
  Future<BiometricAuthResult> authenticateWithBiometrics() async {
    if (!state.isEnabled || !state.isAvailable) {
      return BiometricAuthResult.notAvailable;
    }

    // ── 30-day check ──────────────────────────────────────────────────────────
    final lastFullLogin = await _storageService.getBiometricLastFullLoginDate();
    if (lastFullLogin == null ||
        DateTime.now().difference(lastFullLogin).inDays >= _kPasswordRefreshDays) {
      log('⚠ Biometric: 30-day password refresh required');
      return BiometricAuthResult.passwordLoginRequired;
    }

    // ── Failure count guard ───────────────────────────────────────────────────
    final failures = await _storageService.getBiometricFailureCount();
    if (failures >= _kMaxFailures) {
      log('⚠ Biometric: max failures reached – disabling');
      await _forceDisableAndClear();
      return BiometricAuthResult.permanentlyFailed;
    }

    state = state.copyWith(isAuthenticating: true, clearError: true);

    try {
      // ── OS prompt ─────────────────────────────────────────────────────────
      final authenticated = await _biometricService.authenticate(
        reason: 'Unlock Savvy Bee',
      );

      if (!authenticated) {
        await _storageService.incrementBiometricFailureCount();
        final newCount = failures + 1;
        if (newCount >= _kMaxFailures) {
          await _forceDisableAndClear();
          state = state.copyWith(
            isAuthenticating: false,
            errorMessage:
                'Too many failed attempts. Biometric login has been disabled.',
          );
          return BiometricAuthResult.permanentlyFailed;
        }
        state = state.copyWith(isAuthenticating: false);
        return BiometricAuthResult.cancelled;
      }

      // Success – reset failure count
      await _storageService.clearBiometricFailureCount();

      // ── Token check ───────────────────────────────────────────────────────
      final token = await _storageService.getAuthToken();
      if (token != null) {
        state = state.copyWith(isAuthenticating: false);
        log('✓ Biometric auth: token still valid');
        return BiometricAuthResult.success;
      }

      // ── Silent re-login ──────────────────────────────────────────────────
      log('→ Token expired – attempting silent re-login with stored credentials');
      final creds = await _storageService.getBiometricCredentials();
      if (creds == null) {
        state = state.copyWith(isAuthenticating: false);
        return BiometricAuthResult.tokenExpired;
      }

      final deviceId = await DeviceInfoService.getDeviceId();
      final response = await _authRepository.login(
        creds.email,
        creds.password,
        deviceId,
        null, // FCM token not needed for silent re-login
      );

      if (response != null && response.success) {
        // Token renewed – also reset the 30-day clock
        await _storageService.saveBiometricLastFullLoginDate();
        state = state.copyWith(isAuthenticating: false);
        log('✓ Silent re-login succeeded');
        return BiometricAuthResult.success;
      }

      // Stored credentials rejected (password changed server-side, etc.)
      log('✗ Silent re-login failed – forcing password login');
      await _forceDisableAndClear();
      state = state.copyWith(isAuthenticating: false);
      return BiometricAuthResult.tokenExpired;
    } on BiometricLockoutException catch (e) {
      state = state.copyWith(
        isAuthenticating: false,
        errorMessage: e.isPermanent
            ? 'Too many failed attempts. Use your password.'
            : 'Temporarily locked out. Try again later.',
      );
      return BiometricAuthResult.lockedOut;
    } catch (e) {
      log('✗ BiometricNotifier.authenticateWithBiometrics error: $e');
      state = state.copyWith(
        isAuthenticating: false,
        errorMessage: 'Authentication failed. Try again.',
      );
      return BiometricAuthResult.failed;
    }
  }

  // ─── Internal helpers ─────────────────────────────────────────────────────

  Future<void> _forceDisableAndClear() async {
    await _storageService.setBiometricEnabled(false);
    await _storageService.clearBiometricFailureCount();
    state = state.copyWith(isEnabled: false, clearError: true);
    log('✓ Biometrics force-disabled');
  }

  void clearError() => state = state.copyWith(clearError: true);
}

// ─── Provider ────────────────────────────────────────────────────────────────

final biometricProvider =
    StateNotifierProvider<BiometricNotifier, BiometricState>((ref) {
  return BiometricNotifier(
    ref.watch(biometricServiceProvider),
    ref.watch(storageServiceProvider),
    ref.watch(authRepositoryProvider),
  );
});
