import 'package:dio/dio.dart';
import 'package:savvy_bee_mobile/core/network/api_client.dart';
import 'package:savvy_bee_mobile/core/network/models/api_response_model.dart';

/// Repository for account deletion operations
class DeleteAccountRepository {
  final ApiClient apiClient;

  DeleteAccountRepository({required this.apiClient});

  /// Step 1: Request account deletion (sends OTP to email)
  /// GET /auth/deleteaccount/request?email=user@example.com
  ///
  /// Success response: { Access: true, Error: false, Sent: true, Email: "..." }
  /// Error response: { Access: true, Error: "Email wasnt sent please click resend." }
  Future<ApiResponse<void>> requestAccountDeletion({
    required String email,
  }) async {
    try {
      print('📤 Requesting account deletion for: $email');

      final response = await apiClient.get(
        '/auth/deleteaccount/request',
        queryParameters: {'email': email},
      );

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response data: ${response.data}');

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;

        // Check for error field (can be boolean false or string error message)
        final errorField = responseData['Error'];

        if (errorField != null && errorField != false) {
          // Error is a string message
          throw ApiException(
            message: errorField.toString(),
            statusCode: response.statusCode,
          );
        }

        // Check if email was sent successfully
        final sent = responseData['Sent'] as bool? ?? false;

        if (!sent) {
          throw ApiException(
            message: 'Failed to send verification email',
            statusCode: response.statusCode,
          );
        }

        return ApiResponse(
          success: true,
          message: 'Verification code sent to your email',
          data: null,
        );
      } else {
        throw ApiException(
          message: 'Failed to request account deletion',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      print('❌ DioException: ${e.type}');
      print('❌ Response: ${e.response?.data}');

      // Handle connection errors but data was received
      if (e.type == DioExceptionType.connectionError &&
          e.response?.data != null) {
        try {
          final responseData = e.response!.data as Map<String, dynamic>;

          // Check for error field
          final errorField = responseData['Error'];

          if (errorField != null && errorField != false) {
            throw ApiException(message: errorField.toString(), statusCode: 0);
          }

          // Check if email was sent
          final sent = responseData['Sent'] as bool? ?? false;

          if (!sent) {
            throw ApiException(
              message: 'Failed to send verification email',
              statusCode: 0,
            );
          }

          return ApiResponse(
            success: true,
            message: 'Verification code sent to your email',
            data: null,
          );
        } catch (parseError) {
          print('❌ Parse error: $parseError');
          if (parseError is ApiException) rethrow;
          throw ApiException(
            message: 'Network error: Connection reset while reading response',
            statusCode: 0,
          );
        }
      }

      if (e.type == DioExceptionType.connectionError) {
        throw ApiException(
          message: 'Network connection error. Please try again.',
          statusCode: 0,
        );
      }

      if (e.response?.data != null) {
        final errorData = e.response!.data as Map<String, dynamic>;
        final errorField = errorData['Error'];

        throw ApiException(
          message:
              errorField?.toString() ?? 'Failed to request account deletion',
          statusCode: e.response?.statusCode,
        );
      }

      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      print('❌ Unexpected error: $e');
      throw ApiException(message: 'Failed to request account deletion: $e');
    }
  }

  /// Step 2: Verify OTP and delete account
  /// DELETE /auth/deleteaccount/verify?email=user@example.com
  /// Body: formdata with Otp=123456
  ///
  /// Success response: { Access: true, Error: false, Verified: true, Email: "..." }
  /// Error response: { Access: true, Error: "No user with this email" }
  Future<ApiResponse<void>> verifyAndDeleteAccount({
    required String email,
    required String otp,
  }) async {
    try {
      print('📤 Verifying account deletion for: $email with OTP: $otp');

      final formData = FormData.fromMap({'Otp': otp});

      final response = await apiClient.delete(
        '/auth/deleteaccount/verify',
        queryParameters: {'email': email},
        data: formData,
      );

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        // Handle 204 No Content
        if (response.statusCode == 204 || response.data == null) {
          return ApiResponse(
            success: true,
            message: 'Account deleted successfully',
            data: null,
          );
        }

        final responseData = response.data as Map<String, dynamic>;

        // Check for error field (can be boolean false or string error message)
        final errorField = responseData['Error'];

        if (errorField != null && errorField != false) {
          // Error is a string message
          throw ApiException(
            message: errorField.toString(),
            statusCode: response.statusCode,
          );
        }

        // Check if verification was successful
        final verified = responseData['Verified'] as bool? ?? false;

        if (!verified) {
          throw ApiException(
            message: 'Failed to verify OTP',
            statusCode: response.statusCode,
          );
        }

        return ApiResponse(
          success: true,
          message: 'Account deleted successfully',
          data: null,
        );
      } else {
        throw ApiException(
          message: 'Failed to delete account',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      print('❌ DioException: ${e.type}');
      print('❌ Response: ${e.response?.data}');

      // Handle connection errors but data was received
      if (e.type == DioExceptionType.connectionError &&
          e.response?.data != null) {
        try {
          final responseData = e.response!.data as Map<String, dynamic>;

          // Check for error field
          final errorField = responseData['Error'];

          if (errorField != null && errorField != false) {
            throw ApiException(message: errorField.toString(), statusCode: 0);
          }

          // Check if verified
          final verified = responseData['Verified'] as bool? ?? false;

          if (!verified) {
            throw ApiException(message: 'Failed to verify OTP', statusCode: 0);
          }

          return ApiResponse(
            success: true,
            message: 'Account deleted successfully',
            data: null,
          );
        } catch (parseError) {
          print('❌ Parse error: $parseError');
          if (parseError is ApiException) rethrow;
          throw ApiException(
            message: 'Network error: Connection reset while reading response',
            statusCode: 0,
          );
        }
      }

      if (e.type == DioExceptionType.connectionError) {
        throw ApiException(
          message: 'Network connection error. Please try again.',
          statusCode: 0,
        );
      }

      if (e.response?.data != null) {
        final errorData = e.response!.data as Map<String, dynamic>;
        final errorField = errorData['Error'];

        throw ApiException(
          message:
              errorField?.toString() ??
              'Invalid OTP or failed to delete account',
          statusCode: e.response?.statusCode,
        );
      }

      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      print('❌ Unexpected error: $e');
      throw ApiException(message: 'Failed to delete account: $e');
    }
  }
}
