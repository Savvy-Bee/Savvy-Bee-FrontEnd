import 'dart:async';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:savvy_bee_mobile/core/services/biometric_service.dart';
import 'package:savvy_bee_mobile/core/services/device_info_service.dart';
import 'package:savvy_bee_mobile/core/services/service_locator.dart';
import 'package:savvy_bee_mobile/core/services/storage_service.dart';
import 'package:savvy_bee_mobile/features/auth/data/repositories/auth_repository.dart';

// ─── Constants ───────────────────────────────────────────────────────────────

const _kMaxFailures = 5;
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
  success,
  cancelled,
  failed,
  permanentlyFailed,
  lockedOut,
  notAvailable,
  tokenExpired,
  passwordLoginRequired,
}

// ─── Notifier ────────────────────────────────────────────────────────────────

class BiometricNotifier extends StateNotifier<BiometricState> {
  final BiometricService _biometricService;
  final StorageService _storageService;
  final AuthRepository _authRepository;

  /// Completes once _initialize() has finished.
  /// All public methods that depend on isAvailable/isEnabled await this first
  /// so there is no race condition between provider creation and first use.
  final Completer<void> _initCompleter = Completer<void>();

  BiometricNotifier(
    this._biometricService,
    this._storageService,
    this._authRepository,
  ) : super(const BiometricState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final availability = await _biometricService.checkAvailability();
      final isAvailable = availability == BiometricAvailability.available;
      final isEnabled =
          isAvailable && await _storageService.getBiometricEnabled();
      state = state.copyWith(isAvailable: isAvailable, isEnabled: isEnabled);
      log('→ BiometricNotifier init: available=$isAvailable, enabled=$isEnabled');
    } finally {
      _initCompleter.complete();
    }
  }

  // ─── Enable / Disable ──────────────────────────────────────────────────────

  Future<bool> enableBiometrics(String userEmail) async {
    // Always await init so isAvailable reflects real device state.
    await _initCompleter.future;

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
    state = state.copyWith(isEnabled: false, clearError: true);
    log('✓ Biometric login disabled');
  }

  // ─── Authenticate ──────────────────────────────────────────────────────────

  Future<BiometricAuthResult> authenticateWithBiometrics() async {
    // Await init so state reflects actual device capabilities.
    await _initCompleter.future;

    if (!state.isAvailable) return BiometricAuthResult.notAvailable;

    // ── 30-day check ─────────────────────────────────────────────────────────
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

      await _storageService.clearBiometricFailureCount();

      // ── Token check ───────────────────────────────────────────────────────
      final token = await _storageService.getAuthToken();
      if (token != null) {
        state = state.copyWith(isAuthenticating: false);
        log('✓ Biometric auth: token still valid');
        return BiometricAuthResult.success;
      }

      // ── Silent re-login ───────────────────────────────────────────────────
      log('→ Token expired – attempting silent re-login');
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
        null,
      );

      if (response != null && response.success) {
        await _storageService.saveBiometricLastFullLoginDate();
        state = state.copyWith(isAuthenticating: false);
        log('✓ Silent re-login succeeded');
        return BiometricAuthResult.success;
      }

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

  // ─── Helpers ──────────────────────────────────────────────────────────────

  Future<void> _forceDisableAndClear() async {
    await _storageService.setBiometricEnabled(false);
    await _storageService.clearBiometricFailureCount();
    state = state.copyWith(isEnabled: false, clearError: true);
    log('✓ Biometrics force-disabled');
  }

  void clearError() => state = state.copyWith(clearError: true);

  /// Expose the init completer so callers can wait for the provider to finish
  /// its async _initialize() before reading state.
  Future<void> waitForInit() => _initCompleter.future;
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
