import 'dart:developer';

import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:flutter/services.dart';

enum BiometricAvailability {
  /// Device supports biometrics and at least one is enrolled
  available,

  /// Device hardware supports it but no biometrics are enrolled
  notEnrolled,

  /// Device has no biometric hardware
  notSupported,

  /// Biometrics are temporarily locked out (too many failed attempts)
  lockedOut,
}

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  /// Returns the current hardware + enrollment status.
  Future<BiometricAvailability> checkAvailability() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isDeviceSupported = await _auth.isDeviceSupported();

      if (!isDeviceSupported || !canCheck) {
        return BiometricAvailability.notSupported;
      }

      final enrolled = await _auth.getAvailableBiometrics();
      if (enrolled.isEmpty) {
        return BiometricAvailability.notEnrolled;
      }

      return BiometricAvailability.available;
    } on PlatformException catch (e) {
      log('✗ BiometricService.checkAvailability error: $e');
      return BiometricAvailability.notSupported;
    }
  }

  /// Returns true if at least one biometric type is available and enrolled.
  Future<bool> get isAvailable async {
    final status = await checkAvailability();
    return status == BiometricAvailability.available;
  }

  /// Triggers the OS biometric prompt.
  ///
  /// [reason] is the string shown to the user in the system dialog.
  /// Returns true on success, false on cancellation or failure.
  /// Throws [BiometricLockoutException] if permanently locked out.
  Future<bool> authenticate({
    required String reason,
    bool useErrorDialogs = true,
    bool stickyAuth = true,
  }) async {
    try {
      final authenticated = await _auth.authenticate(
        localizedReason: reason,
        options: AuthenticationOptions(
          useErrorDialogs: useErrorDialogs,
          stickyAuth: stickyAuth,
          biometricOnly: false, // allow device PIN/pattern as fallback
        ),
      );
      log(authenticated
          ? '✓ Biometric authentication succeeded'
          : '⚠ Biometric authentication cancelled/failed');
      return authenticated;
    } on PlatformException catch (e) {
      log('✗ BiometricService.authenticate PlatformException: ${e.code} – ${e.message}');

      if (e.code == auth_error.lockedOut ||
          e.code == auth_error.permanentlyLockedOut) {
        throw BiometricLockoutException(isPermanent:
            e.code == auth_error.permanentlyLockedOut);
      }

      if (e.code == auth_error.notAvailable ||
          e.code == auth_error.notEnrolled) {
        return false;
      }

      // passcodeNotSet, otherOperatingSystem, etc.
      return false;
    } catch (e) {
      log('✗ BiometricService.authenticate unexpected error: $e');
      return false;
    }
  }
}

class BiometricLockoutException implements Exception {
  final bool isPermanent;
  const BiometricLockoutException({required this.isPermanent});

  @override
  String toString() => isPermanent
      ? 'Biometric permanently locked out. Use device credentials.'
      : 'Biometric temporarily locked out. Try again later.';
}
