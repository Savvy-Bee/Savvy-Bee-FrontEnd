import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../domain/models/chat_models.dart';
import '../../domain/models/personality.dart';

class ChatRepository {
  final ApiClient _apiClient;

  ChatRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Helper method to handle API exceptions
  T _handleError<T>(dynamic error, String operation, T Function() fallback) {
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

    return fallback();
  }

  /// Verify auth token exists before making requests
  bool _hasAuthToken() {
    final token = _apiClient.getAuthToken();
    if (token == null || token.isEmpty) {
      if (kDebugMode) {
        log('No auth token found - user may need to login again');
      }
      return false;
    }
    return true;
  }

  /// Send a chat message to the AI
  /// Requires authentication (Bearer token)
  /// Supports optional image and document file uploads
  Future<ChatResponse?> sendMessage(SendChatRequest request) async {
    try {
      // Verify token exists
      if (!_hasAuthToken()) {
        throw ApiException(
          message: 'Authentication required. Please login again.',
          statusCode: 401,
        );
      }

      // Determine if we need to use FormData (for file uploads) or JSON
      dynamic data;
      Options? options;

      if (request.hasFiles) {
        // Create FormData for file uploads
        final formData = FormData.fromMap({'chat': request.message});

        // Add image file if provided
        if (request.image != null) {
          formData.files.add(
            MapEntry(
              'image',
              await MultipartFile.fromFile(
                request.image!.path,
                filename: request.image!.path.split('/').last,
              ),
            ),
          );
        }

        // Add document file if provided
        if (request.document != null) {
          formData.files.add(
            MapEntry(
              'document',
              await MultipartFile.fromFile(
                request.document!.path,
                filename: request.document!.path.split('/').last,
              ),
            ),
          );
        }

        data = formData;
        // No need to set Content-Type as Dio will set it automatically with boundary
      } else {
        // Use JSON for text-only messages
        data = request.toJson();
        options = Options(headers: {'Content-Type': 'application/json'});
      }

      final response = await _apiClient.post(
        ApiEndpoints.chatSend,
        data: data,
        options: options,
      );

      return ChatResponse.fromJson(response.data);
    } catch (e) {
      // If 401, suggest re-authentication
      if (e is ApiException && e.statusCode == 401) {
        if (kDebugMode) {
          log('Authentication failed - token may be expired or invalid');
        }
      }
      return _handleError(e, 'Send chat message', () => null);
    }
  }

  /// Get chat history for the authenticated user
  /// Requires authentication (Bearer token)
  Future<ChatHistoryResponse?> getChatHistory() async {
    try {
      // Verify token exists
      if (!_hasAuthToken()) {
        throw ApiException(
          message: 'Authentication required. Please login again.',
          statusCode: 401,
        );
      }

      final response = await _apiClient.get(ApiEndpoints.chatHistory);

      return ChatHistoryResponse.fromJson(response.data);
    } catch (e) {
      return _handleError(e, 'Get chat history', () => null);
    }
  }

  /// Update user data (personality, strictness, language, country)
  /// Requires authentication (Bearer token)
  Future<bool> updateUserData(UpdateUserDataRequest request) async {
    try {
      // Verify token exists
      if (!_hasAuthToken()) {
        throw ApiException(
          message: 'Authentication required. Please login again.',
          statusCode: 401,
        );
      }

      final formData = FormData.fromMap(request.toJson());

      final response = await _apiClient.post(
        ApiEndpoints.updateUserData,
        data: formData,
      );
      log('Update user data response: $response');

      final data = response.data as Map<String, dynamic>?;
      final success = data?['success'] ?? false;

      if (success) {
        log('User data updated successfully');
      }

      return success;
    } catch (e) {
      return _handleError(e, 'Update user data', () => false);
    }
  }

  /// Update only AI personality
  Future<bool> updatePersonality(String personalityId) async {
    return updateUserData(UpdateUserDataRequest(aiPersonality: personalityId));
  }

  /// Update only AI strictness
  Future<bool> updateStrictness(AIStrictness strictness) async {
    return updateUserData(
      UpdateUserDataRequest(aiStrictness: strictness.value),
    );
  }

  /// Update only language
  Future<bool> updateLanguage(String language) async {
    return updateUserData(UpdateUserDataRequest(language: language));
  }

  /// Clear chat history (if endpoint exists)
  // Future<bool> clearChatHistory() async {
  //   try {
  //     final response = await _apiClient.delete(ApiEndpoints.chatClear);
  //
  //     final data = response.data as Map<String, dynamic>?;
  //     return data?['success'] ?? false;
  //   } catch (e) {
  //     return _handleError(e, 'Clear chat history', () => false);
  //   }
  // }
}
