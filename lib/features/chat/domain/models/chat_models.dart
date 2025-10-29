import 'dart:io';

/// Chat message model
  class ChatMessage {
    final String id;
    final String userId;
    final String from; // 'user' or 'ai'
    final String? gif;
    final String message;
    final DateTime createdAt;
    final DateTime updatedAt;

    ChatMessage({
      required this.id,
      required this.userId,
      required this.from,
      this.gif,
      required this.message,
      required this.createdAt,
      required this.updatedAt,
    });

    /// Check if message is from user
    bool get isFromUser => from.toLowerCase() == 'user';

    /// Check if message is from AI
    bool get isFromAI => from.toLowerCase() == 'ai';

    factory ChatMessage.fromJson(Map<String, dynamic> json) {
      return ChatMessage(
        id: json['_id'] ?? '',
        userId: json['UserId'] ?? '',
        from: json['From'] ?? '',
        gif: json['Gif'] ?? '',
        message: json['Message'] ?? '',
        createdAt: DateTime.parse(
          json['createdAt'] ?? DateTime.now().toIso8601String(),
        ),
        updatedAt: DateTime.parse(
          json['updatedAt'] ?? DateTime.now().toIso8601String(),
        ),
      );
    }

    Map<String, dynamic> toJson() {
      return {
        '_id': id,
        'UserId': userId,
        'From': from,
        'Gif': gif,
        'Message': message,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };
    }

    @override
    String toString() {
      return 'ChatMessage(id: $id, from: $from, gif: $gif, message: $message)';
    }
  }

/// Send chat request model
class SendChatRequest {
  final String message;
  final File? image;
  final File? document;

  SendChatRequest({required this.message, this.image, this.document});

  /// Convert to JSON for API request
  /// Note: For file uploads, this is used to create FormData
  Map<String, dynamic> toJson() {
    return {'chat': message};
  }

  /// Check if this request contains files
  bool get hasFiles => image != null || document != null;
}

/// Chat response model (for send chat)
class ChatResponse {
  final bool success;
  final String message;
  final List<ChatMessage> chats;

  ChatResponse({
    required this.success,
    required this.message,
    required this.chats,
  });

  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    final chatsList = data?['chats'] as List<dynamic>? ?? [];

    return ChatResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      chats: chatsList.map((chat) => ChatMessage.fromJson(chat)).toList(),
    );
  }
}

/// Update user data request
class UpdateUserDataRequest {
  final String? aiPersonality;
  final String? aiStrictness; // "Strict", "Moderate", "Lenient"
  final String? language;
  final String? country;

  UpdateUserDataRequest({
    this.aiPersonality,
    this.aiStrictness,
    this.language,
    this.country,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    if (aiPersonality != null) data['AIPersonality'] = aiPersonality;
    if (aiStrictness != null) data['AIStrictness'] = aiStrictness;
    if (language != null) data['Language'] = language;
    if (country != null) data['Country'] = country;

    return data;
  }
}

/// Chat history response model
class ChatHistoryResponse {
  final bool success;
  final String message;
  final List<ChatMessage> allChats;

  ChatHistoryResponse({
    required this.success,
    required this.message,
    required this.allChats,
  });

  factory ChatHistoryResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    final chatsList = data?['allchat'] as List<dynamic>? ?? [];

    return ChatHistoryResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      allChats: chatsList.map((chat) => ChatMessage.fromJson(chat)).toList(),
    );
  }
}
