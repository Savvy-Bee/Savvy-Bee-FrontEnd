import 'dart:developer';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:savvy_bee_mobile/core/services/service_locator.dart';
import 'package:savvy_bee_mobile/features/chat/domain/models/chat_models.dart';
import 'package:savvy_bee_mobile/core/network/api_client.dart';
import 'package:savvy_bee_mobile/features/chat/domain/models/personality.dart';

import '../../data/repository/chat_repository.dart';

final aiPersonalityProvider = FutureProvider<List<Personality>>((ref) async {
  final repo = ref.read(chatRepositoryProvider);

  final personalities = await repo.fetchPersonalities();

  return personalities;
});

// Chat repository provider
final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ChatRepository(apiClient: apiClient);
});

/// Chat state for managing chat messages and UI state
class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final bool isSending;
  final String? errorMessage;
  final bool hasError;
  final bool needsReAuth;
  final Persona? persona;

  ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.isSending = false,
    this.errorMessage,
    this.needsReAuth = false,
    this.persona,
  }) : hasError = errorMessage != null;

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    bool? isSending,
    String? errorMessage,
    bool? needsReAuth,
    bool clearError = false,
    Persona? persona,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isSending: isSending ?? this.isSending,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      needsReAuth: needsReAuth ?? this.needsReAuth,
      persona: persona ?? this.persona,
    );
  }

  /// Get only user messages
  List<ChatMessage> get userMessages =>
      messages.where((msg) => msg.isFromUser).toList();

  /// Get only AI messages
  List<ChatMessage> get aiMessages =>
      messages.where((msg) => msg.isFromAI).toList();

  /// Check if chat is empty
  bool get isEmpty => messages.isEmpty;

  /// Get last message
  ChatMessage? get lastMessage => messages.isNotEmpty ? messages.last : null;

  @override
  String toString() {
    return 'ChatState(messages: ${messages.length}, isLoading: $isLoading, '
        'isSending: $isSending, hasError: $hasError, needsReAuth: $needsReAuth)';
  }
}

/// AsyncNotifier for managing chat state with async operations
class ChatNotifier extends AsyncNotifier<ChatState> {
  ChatRepository get _chatRepository => ref.read(chatRepositoryProvider);

  @override
  Future<ChatState> build() async {
    // Initialize by loading chat history
    return await _loadChatHistory();
  }

  /// Load chat history from API
  Future<ChatState> _loadChatHistory() async {
    try {
      log('Loading chat history...');
      final response = await _chatRepository.getChatHistory();

      if (response != null && response.success) {
        log('Chat history loaded: ${response.allChats.length} messages');
        return ChatState(messages: response.allChats, isLoading: false);
      } else {
        log('Failed to load chat history: ${response?.message}');
        return ChatState(
          isLoading: false,
          errorMessage: response?.message ?? 'Failed to load chat history',
        );
      }
    } on ApiException catch (e) {
      log('ApiException loading chat history: ${e.message}');
      // Check if it's an auth error
      if (e.statusCode == 401) {
        return ChatState(
          isLoading: false,
          errorMessage: 'Session expired. Please login again.',
          needsReAuth: true,
        );
      }
      return ChatState(isLoading: false, errorMessage: e.message);
    } catch (e) {
      log('Error loading chat history: $e');
      return ChatState(
        isLoading: false,
        errorMessage: 'Failed to load chat history',
      );
    }
  }

  /// Send a message to the AI with optional image and document attachments
  Future<bool> sendMessage(
    String message, {
    File? image,
    File? document,
  }) async {
    if (message.trim().isEmpty && image == null && document == null) {
      return false;
    }

    final currentState = state.value ?? ChatState();

    // Check if re-authentication is needed
    if (currentState.needsReAuth) {
      log('Cannot send message - re-authentication required');
      return false;
    }

    // Show optimistic user message immediately
    final optimisticUserMessage = ChatMessage(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      userId: 'current_user',
      from: 'user',
      message: message.trim(),
      chatType: ChatType.general, // User messages are always general
      otherData: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Update state to show user message and sending indicator
    state = AsyncValue.data(
      currentState.copyWith(
        messages: [...currentState.messages, optimisticUserMessage],
        isSending: true,
        clearError: true,
      ),
    );

    try {
      final request = SendChatRequest(
        message: message.trim(),
        image: image,
        document: document,
      );
      final response = await _chatRepository.sendMessage(request);

      if (response != null && response.success) {
        log(
          'Message sent successfully. Received ${response.chats.length} messages',
        );

        // Log chat types for debugging
        for (final chat in response.chats) {
          log(
            'Received message: type=${chat.chatType}, hasWidget=${chat.hasWidget}',
          );
        }

        // Replace optimistic message with actual messages from server
        final updatedMessages = [
          ...currentState.messages.where(
            (msg) => msg.id != optimisticUserMessage.id,
          ),
          ...response.chats,
        ];

        state = AsyncValue.data(
          currentState.copyWith(messages: updatedMessages, isSending: false),
        );
        return true;
      } else {
        // Remove optimistic message and show error
        state = AsyncValue.data(
          currentState.copyWith(
            messages: currentState.messages
                .where((msg) => msg.id != optimisticUserMessage.id)
                .toList(),
            isSending: false,
            errorMessage: response?.message ?? 'Failed to send message',
          ),
        );
        return false;
      }
    } on ApiException catch (e) {
      // Check if it's an auth error
      final needsReAuth = e.statusCode == 401;

      // Remove optimistic message and show error
      state = AsyncValue.data(
        currentState.copyWith(
          messages: currentState.messages
              .where((msg) => msg.id != optimisticUserMessage.id)
              .toList(),
          isSending: false,
          errorMessage: needsReAuth
              ? 'Session expired. Please login again.'
              : e.message,
          needsReAuth: needsReAuth,
        ),
      );
      return false;
    } catch (e) {
      log('Error sending message: $e');
      // Remove optimistic message and show error
      state = AsyncValue.data(
        currentState.copyWith(
          messages: currentState.messages
              .where((msg) => msg.id != optimisticUserMessage.id)
              .toList(),
          isSending: false,
          errorMessage: 'Failed to send message',
        ),
      );
      return false;
    }
  }

  /// Refresh chat history
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _loadChatHistory());
  }

  /// Clear error message
  void clearError() {
    final currentState = state.value;
    if (currentState != null) {
      state = AsyncValue.data(currentState.copyWith(clearError: true));
    }
  }

  /// Retry last failed message
  Future<void> retryLastMessage() async {
    final currentState = state.value;
    if (currentState != null && currentState.userMessages.isNotEmpty) {
      final lastUserMessage = currentState.userMessages.last;
      await sendMessage(lastUserMessage.message);
    }
  }
}

// Chat provider
final chatProvider = AsyncNotifierProvider<ChatNotifier, ChatState>(() {
  return ChatNotifier();
});

// Convenience providers
final chatMessagesProvider = Provider<List<ChatMessage>>((ref) {
  return ref.watch(chatProvider).value?.messages ?? [];
});

final isSendingMessageProvider = Provider<bool>((ref) {
  return ref.watch(chatProvider).value?.isSending ?? false;
});

final chatErrorProvider = Provider<String?>((ref) {
  return ref.watch(chatProvider).value?.errorMessage;
});

final chatIsEmptyProvider = Provider<bool>((ref) {
  return ref.watch(chatProvider).value?.isEmpty ?? true;
});

final chatNeedsReAuthProvider = Provider<bool>((ref) {
  return ref.watch(chatProvider).value?.needsReAuth ?? false;
});
