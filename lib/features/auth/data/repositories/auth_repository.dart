import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:savvy_bee_mobile/core/network/api_client.dart';
import 'package:savvy_bee_mobile/core/network/api_endpoints.dart';
import 'package:savvy_bee_mobile/core/network/models/api_response_model.dart';
import 'package:savvy_bee_mobile/core/services/storage_service.dart';
import 'package:savvy_bee_mobile/features/auth/domain/models/auth_models.dart';

import '../../domain/models/user.dart';

class AuthRepository {
  final ApiClient _apiClient;
  final StorageService _storageService;

  AuthRepository({
    required ApiClient apiClient,
    required StorageService storageService,
  }) : _apiClient = apiClient,
       _storageService = storageService;

  /// Set auth token in BOTH storage and API client
  Future<void> setAuthToken(String token) async {
    await _storageService.saveAuthToken(token);
    _apiClient.setAuthToken(token);

    if (kDebugMode) {
      log('Auth token saved and set: ${token.substring(0, 20)}...');
    }
  }

  /// Load token from storage and set in API client
  Future<void> loadAndSetToken() async {
    final token = await _storageService.getAuthToken();

    if (token != null && token.isNotEmpty) {
      _apiClient.setAuthToken(token);

      if (kDebugMode) {
        log('Token loaded from storage: ${token.substring(0, 20)}...');
      }
    } else {
      if (kDebugMode) {
        log('No token found in storage');
      }
    }
  }

  /// Clear auth token from BOTH storage and API client
  Future<void> clearAuthToken() async {
    await _storageService.deleteAuthToken();
    _apiClient.clearAuthToken();

    if (kDebugMode) {
      log('Auth token cleared');
    }
  }

  /// Get current token from API client
  String? getAuthToken() {
    return _apiClient.getAuthToken();
  }

  /// Helper method to handle API exceptions
  ApiResponse<T> _handleError<T>(dynamic error, String operation) {
    String message;

    if (error is ApiException) {
      message = error.message;
    } else if (error is DioException) {
      message =
          error.response?.data?['message'] ??
          error.message ??
          '$operation failed';
    } else {
      message = '$operation failed';
    }

    if (kDebugMode) {
      log('$operation error: $error');
    }

    return ApiResponse<T>(success: false, message: message);
  }

  /// Register a new user
  Future<ApiResponse<User>> register(RegisterRequest request) async {
    try {
      final formData = FormData.fromMap(request.toJson());

      final response = await _apiClient.post(
        ApiEndpoints.register,
        data: formData,
      );

      // Parse as LoginResponse to get token
      final registerResponse = RegisterResponse.fromJson(response.data);

      if (registerResponse.success && registerResponse.data != null) {
        return ApiResponse<User>(
          success: true,
          message: registerResponse.message,
          data: registerResponse.data!,
        );
      }

      return ApiResponse<User>(
        success: registerResponse.success,
        message: registerResponse.message,
        data: registerResponse.data!,
      );
    } catch (e) {
      return _handleError(e, 'Registration');
    }
  }

  /// Resend OTP to user's email
  Future<ApiResponse<void>> resendOtp(String email) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.resendOtp,
        queryParameters: {'Email': email},
      );

      return ApiResponse.fromJson(response.data, null);
    } catch (e) {
      return _handleError(e, 'Resend OTP');
    }
  }

  /// Verify email with OTP code
  Future<ApiResponse<void>> verifyEmail(VerifyEmailRequest request) async {
    try {
      final formData = FormData.fromMap(request.toJson());

      final response = await _apiClient.post(
        ApiEndpoints.verifyEmail,
        data: formData,
      );

      return ApiResponse.fromJson(response.data, null);
    } catch (e) {
      return _handleError(e, 'Email verification');
    }
  }

  /// Login with email and password
  Future<ApiResponse<bool>> login(String email, String password) async {
    try {
      if (kDebugMode) {
        log('Attempting login for: $email');
      }

      final response = await _apiClient.post(
        ApiEndpoints.login,
        data: {'email': email, 'password': password},
      );

      if (kDebugMode) {
        log('Login response received');
      }

      // Parse the login response with nested token structure
      final loginResponse = LoginResponse.fromJson(response.data);

      if (loginResponse.success) {
        // Save and set token
        await setAuthToken(loginResponse.data!.token);

        if (kDebugMode) {
          log(
            'Login successful - Token: ${loginResponse.data!.token.substring(0, 20)}...',
          );

          // Verify token was set in API client
          final apiToken = _apiClient.getAuthToken();
          if (apiToken != null) {
            log('✓ Token verified in API client');
          } else {
            log('✗ WARNING: Token NOT in API client!');
          }
        }

        return ApiResponse<bool>(success: true, message: loginResponse.message);
      } else if (loginResponse.success) {
        if (kDebugMode) {
          log('✗ WARNING: Login successful but NO TOKEN in response!');
        }

        return ApiResponse<bool>(
          success: false,
          message: 'Login failed: No authentication token received',
        );
      } else {
        return ApiResponse<bool>(
          success: false,
          message: loginResponse.message,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        log('Login exception: $e');
      }
      return _handleError(e, 'Login');
    }
  }

  /// Register additional user details (DOB and Country)
  Future<ApiResponse<void>> registerOtherDetails(
    RegisterOtherDetailsRequest request,
  ) async {
    try {
      final formData = FormData.fromMap(request.toJson());

      final response = await _apiClient.post(
        ApiEndpoints.setOtherDetails,
        data: formData,
      );

      return ApiResponse.fromJson(response.data, null);
    } catch (e) {
      return _handleError(e, 'Register other details');
    }
  }

  /// Request password reset OTP
  Future<ApiResponse<void>> requestPasswordReset(String email) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.sendResetOtp,
        queryParameters: {'Email': email},
      );

      return ApiResponse.fromJson(response.data, null);
    } catch (e) {
      return _handleError(e, 'Request password reset');
    }
  }

  /// Reset password with new password
  Future<ApiResponse<void>> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      final formData = FormData.fromMap({
        'Email': email,
        'OTP': otp,
        'NewPassword': newPassword,
      });

      final response = await _apiClient.post(
        ApiEndpoints.verifyResetOtp,
        data: formData,
      );

      return ApiResponse.fromJson(response.data, null);
    } catch (e) {
      return _handleError(e, 'Reset password');
    }
  }

  /// Set user onboarding data (WhatMatters, Archetype, etc.)
  Future<ApiResponse<void>> postOnboardData(PostOnboardRequest request) async {
    try {
      final formData = FormData.fromMap(request.toJson());

      final response = await _apiClient.post(
        ApiEndpoints
            .postOnboard, // Assuming you define this endpoint: /auth/register/postonboard
        data: formData,
      );

      return ApiResponse.fromJson(response.data, null);
    } catch (e) {
      return _handleError(e, 'Post Onboard Data');
    }
  }

  /// Update user data (AI Settings, Language, Country)
  /// This endpoint typically requires a Bearer Token for authorization.
  Future<ApiResponse<void>> updateUserData(
    UpdateUserDataRequest request,
  ) async {
    try {
      final formData = FormData.fromMap(request.toJson());

      final response = await _apiClient.post(
        ApiEndpoints
            .updateUserData, // Assuming you define this endpoint: /auth/update/userdata
        data: formData,
      );

      return ApiResponse.fromJson(response.data, null);
    } catch (e) {
      return _handleError(e, 'Update User Data');
    }
  }

  /// Logout
  Future<void> logout() async {
    await clearAuthToken();
    if (kDebugMode) {
      log('User logged out');
    }
  }
}
