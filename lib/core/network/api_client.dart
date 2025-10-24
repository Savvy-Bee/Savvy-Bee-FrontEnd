import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Custom exception for API errors
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException({required this.message, this.statusCode, this.data});

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

/// Enhanced API Client with better error handling, logging, and interceptors
class ApiClient {
  final Dio _dio;
  final String baseUrl;

  ApiClient({required this.baseUrl})
    : _dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(minutes: 10), // TODO: Change timeout
          receiveTimeout: const Duration(minutes: 10), // TODO: Change timeout
          sendTimeout: const Duration(minutes: 10), // TODO: Change timeout
          responseType: ResponseType.json,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      ) {
    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          _logRequest(options);
          return handler.next(options);
        },
        onResponse: (response, handler) {
          _logResponse(response);
          return handler.next(response);
        },
        onError: (DioException error, handler) {
          _logError(error);
          return handler.next(error);
        },
      ),
    );
  }

  /// Enhanced request logging
  void _logRequest(RequestOptions options) {
    if (!kDebugMode) return;

    log('╔════════════════════════════════════════════════════════════════');
    log('║ REQUEST');
    log('╠════════════════════════════════════════════════════════════════');
    log('║ Method: ${options.method}');
    log('║ Path: ${options.path}');
    log('║ Base URL: ${options.baseUrl}');

    if (options.queryParameters.isNotEmpty) {
      log('║ Query Parameters: ${options.queryParameters}');
    }

    if (options.headers.isNotEmpty) {
      log('║ Headers:');
      options.headers.forEach((key, value) {
        // Mask sensitive headers
        if (key.toLowerCase() == 'authorization') {
          log('║   $key: ${_maskToken(value.toString())}');
        } else {
          log('║   $key: $value');
        }
      });
    }

    if (options.data != null) {
      if (options.data is FormData) {
        log('║ Body: [FormData]');
        final formData = options.data as FormData;
        for (var field in formData.fields) {
          // Mask sensitive fields
          if (_isSensitiveField(field.key)) {
            log('║   ${field.key}: ${_maskValue(field.value)}');
          } else {
            log('║   ${field.key}: ${field.value}');
          }
        }
      } else {
        log('║ Body: ${options.data}');
      }
    }

    log('╚════════════════════════════════════════════════════════════════');
  }

  /// Enhanced response logging
  void _logResponse(Response response) {
    if (!kDebugMode) return;

    log('╔════════════════════════════════════════════════════════════════');
    log('║ RESPONSE');
    log('╠════════════════════════════════════════════════════════════════');
    log('║ Status Code: ${response.statusCode}');
    log('║ Status Message: ${response.statusMessage}');
    log('║ Path: ${response.requestOptions.path}');

    if (response.headers.map.isNotEmpty) {
      log('║ Headers: ${response.headers.map}');
    }

    log('║ Data: ${response.data}');
    log('╚════════════════════════════════════════════════════════════════');
  }

  /// Enhanced error logging
  void _logError(DioException error) {
    if (!kDebugMode) return;

    log('╔════════════════════════════════════════════════════════════════');
    log('║ ERROR');
    log('╠════════════════════════════════════════════════════════════════');
    log('║ Type: ${error.type}');
    log('║ Message: ${error.message}');
    log('║ Path: ${error.requestOptions.path}');

    if (error.response != null) {
      log('║ Status Code: ${error.response?.statusCode}');
      log('║ Response Data: ${error.response?.data}');
    }

    // log('║ Stack Trace: ${error.stackTrace}');

    log('╚════════════════════════════════════════════════════════════════');
  }

  /// Mask sensitive token for logging
  String _maskToken(String token) {
    if (token.length <= 10) return '***';
    return '${token.substring(0, 10)}...${token.substring(token.length - 4)}';
  }

  /// Mask sensitive field values
  String _maskValue(String value) {
    if (value.length <= 4) return '***';
    return '${value.substring(0, 2)}***${value.substring(value.length - 2)}';
  }

  /// Check if field is sensitive
  bool _isSensitiveField(String fieldName) {
    final sensitiveFields = [
      'password',
      'token',
      'secret',
      'api_key',
      'apikey',
      'authorization',
    ];
    return sensitiveFields.any(
      (field) => fieldName.toLowerCase().contains(field),
    );
  }

  /// Handle Dio errors and convert to ApiException
  ApiException _handleError(DioException error) {
    String message;
    int? statusCode = error.response?.statusCode;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        message = 'Connection timeout. Please check your internet connection.';
        break;
      case DioExceptionType.sendTimeout:
        message = 'Request timeout. Please try again.';
        break;
      case DioExceptionType.receiveTimeout:
        message = 'Response timeout. Please try again.';
        break;
      case DioExceptionType.badResponse:
        message =
            _extractErrorMessage(error.response?.data) ??
            'Server error occurred.';
        break;
      case DioExceptionType.cancel:
        message = 'Request was cancelled.';
        break;
      case DioExceptionType.connectionError:
        message = 'No internet connection. Please check your network.';
        break;
      case DioExceptionType.badCertificate:
        message = 'Certificate verification failed.';
        break;
      case DioExceptionType.unknown:
        if (error.error is SocketException) {
          message = 'No internet connection.';
        } else {
          message = 'An unexpected error occurred.';
        }
        break;
    }

    return ApiException(
      message: message,
      statusCode: statusCode,
      data: error.response?.data,
    );
  }

  /// Extract error message from response data
  String? _extractErrorMessage(dynamic data) {
    if (data == null) return null;

    if (data is Map<String, dynamic>) {
      // Try common error message keys
      return data['message'] ?? data['error'] ?? data['msg'] ?? data['detail'];
    }

    if (data is String) {
      return data;
    }

    return null;
  }

  /// GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      log('Unexpected error in GET request: $e');
      throw ApiException(message: 'An unexpected error occurred: $e');
    }
  }

  /// POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      log('Unexpected error in POST request: $e');
      throw ApiException(message: 'An unexpected error occurred: $e');
    }
  }

  /// PUT request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      log('Unexpected error in PUT request: $e');
      throw ApiException(message: 'An unexpected error occurred: $e');
    }
  }

  /// PATCH request
  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      log('Unexpected error in PATCH request: $e');
      throw ApiException(message: 'An unexpected error occurred: $e');
    }
  }

  /// DELETE request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      log('Unexpected error in DELETE request: $e');
      throw ApiException(message: 'An unexpected error occurred: $e');
    }
  }

  /// Set auth token in request headers
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
    if (kDebugMode) {
      log('Auth token set: ${_maskToken(token)}');
    }
  }

  /// Clear auth token from headers
  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
    if (kDebugMode) {
      log('Auth token cleared');
    }
  }

  /// Get current auth token
  String? getAuthToken() {
    return _dio.options.headers['Authorization']?.toString().replaceFirst(
      'Bearer ',
      '',
    );
  }

  /// Update base URL
  void updateBaseUrl(String newBaseUrl) {
    _dio.options.baseUrl = newBaseUrl;
    if (kDebugMode) {
      log('Base URL updated to: $newBaseUrl');
    }
  }

  /// Add custom header
  void addHeader(String key, String value) {
    _dio.options.headers[key] = value;
  }

  /// Remove custom header
  void removeHeader(String key) {
    _dio.options.headers.remove(key);
  }

  /// Get Dio instance for advanced usage
  Dio get dio => _dio;
}
