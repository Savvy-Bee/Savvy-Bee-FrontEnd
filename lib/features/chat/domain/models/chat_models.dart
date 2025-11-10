import 'dart:io';

/// Chat message model with widget support
class ChatMessage {
  final String id;
  final String userId;
  final String from; // 'user' or 'ai'
  final String? gif;
  final String message;
  final ChatType chatType;
  final dynamic otherData; // Can be Map, List, or null
  final DateTime createdAt;
  final DateTime updatedAt;

  ChatMessage({
    required this.id,
    required this.userId,
    required this.from,
    this.gif,
    required this.message,
    required this.chatType,
    this.otherData,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Check if message is from user
  bool get isFromUser => from.toLowerCase() == 'user';

  /// Check if message is from AI
  bool get isFromAI => from.toLowerCase() == 'ai';

  /// Check if message has widget data
  bool get hasWidget => chatType != ChatType.general && otherData != null;

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['_id'] ?? '',
      userId: json['UserId'] ?? '',
      from: json['From'] ?? '',
      gif: json['Gif'],
      message: json['Message'] ?? '',
      chatType: ChatType.fromString(json['ChatType'] ?? 'general'),
      otherData: json['otherdata'],
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
      'ChatType': chatType.value,
      'otherdata': otherData,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'ChatMessage(id: $id, from: $from, chatType: $chatType, message: $message)';
  }
}

/// AI Persona
class Persona {
  final String id;
  final String name;
  final String description;
  final String characteristics;
  final List<String> tone;
  final String dashboardBias;

  const Persona({
    required this.id,
    required this.name,
    required this.description,
    required this.characteristics,
    required this.tone,
    required this.dashboardBias,
  });

  /// Deserialize from JSON.
  factory Persona.fromJson(Map<String, dynamic> json) {
    return Persona(
      id: json['ID'] as String,
      name: json['Name'] as String,
      description: json['Description'] as String,
      characteristics: json['Characteristics'] as String,
      tone: (json['Tone'] as List<dynamic>).cast<String>(),
      dashboardBias: json['Dashboard_Bias'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'ID': id,
    'Name': name,
    'Description': description,
    'Characteristics': characteristics,
    'Tone': tone,
    'Dashboard_Bias': dashboardBias,
  };
}

/// Enum for different chat types
enum ChatType {
  general('general'),
  budget('budget'),
  goal('goal');

  final String value;
  const ChatType(this.value);

  static ChatType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'budget':
        return ChatType.budget;
      case 'goal':
        return ChatType.goal;
      case 'general':
      default:
        return ChatType.general;
    }
  }
}

/// Budget widget data model
class BudgetData {
  final String id;
  final String budgetName;
  final double balance;
  final double targetAmountMonthly;

  BudgetData({
    required this.id,
    required this.budgetName,
    required this.balance,
    required this.targetAmountMonthly,
  });

  double get progress => targetAmountMonthly > 0
      ? (balance / targetAmountMonthly * 100).clamp(0, 100)
      : 0;

  double get remaining => targetAmountMonthly - balance;

  factory BudgetData.fromJson(Map<String, dynamic> json) {
    return BudgetData(
      id: json['_id'] ?? '',
      budgetName: json['BudgetName'] ?? '',
      balance: (json['Balance'] as num?)?.toDouble() ?? 0.0,
      targetAmountMonthly:
          (json['TargetAmountMonthly'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'BudgetName': budgetName,
    'Balance': balance,
    'TargetAmountMonthly': targetAmountMonthly,
  };
}

/// Goal widget data model
class GoalData {
  final String goalName;
  final double goalAmount;

  GoalData({required this.goalName, required this.goalAmount});

  factory GoalData.fromJson(Map<String, dynamic> json) {
    return GoalData(
      goalName: json['GoalName'] ?? '',
      goalAmount: (json['GoalAmount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'GoalName': goalName,
    'GoalAmount': goalAmount,
  };
}

/// Helper to parse otherdata based on chat type
class ChatWidgetDataParser {
  /// Parse budget data from otherdata
  static List<BudgetData>? parseBudgetData(dynamic otherData) {
    if (otherData == null) return null;

    try {
      if (otherData is List) {
        return otherData
            .map((item) => BudgetData.fromJson(item as Map<String, dynamic>))
            .toList();
      } else if (otherData is Map<String, dynamic>) {
        return [BudgetData.fromJson(otherData)];
      }
    } catch (e) {
      print('Error parsing budget data: $e');
    }
    return null;
  }

  /// Parse goal data from otherdata
  static GoalData? parseGoalData(dynamic otherData) {
    if (otherData == null) return null;

    try {
      if (otherData is Map<String, dynamic>) {
        return GoalData.fromJson(otherData);
      }
    } catch (e) {
      print('Error parsing goal data: $e');
    }
    return null;
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
  final Persona persona;

  ChatHistoryResponse({
    required this.success,
    required this.message,
    required this.allChats,
    required this.persona,
  });

  factory ChatHistoryResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    final chatsList = data?['allchat'] as List<dynamic>? ?? [];

    return ChatHistoryResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      persona: Persona.fromJson(data!['Persona']),
      allChats: chatsList.map((chat) => ChatMessage.fromJson(chat)).toList(),
    );
  }
}
