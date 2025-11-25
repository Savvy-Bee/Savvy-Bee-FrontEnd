class StreakResponse {
  final bool success;
  final String message;
  final StreakPayload data;

  const StreakResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory StreakResponse.fromJson(Map<String, dynamic> json) {
    return StreakResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: StreakPayload.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data.toJson(),
    };
  }
}

class StreakPayload {
  final int currentStreak; // Mapped from 'Streak'
  final List<StreakData> streakHistory; // Mapped from 'Streakdata'

  const StreakPayload({
    required this.currentStreak,
    required this.streakHistory,
  });

  factory StreakPayload.fromJson(Map<String, dynamic> json) {
    return StreakPayload(
      currentStreak: json['Streak'] as int,
      // Parsing the array of StreakData objects
      streakHistory: (json['Streakdata'] as List<dynamic>)
          .map((item) => StreakData.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Streak': currentStreak,
      'Streakdata': streakHistory.map((s) => s.toJson()).toList(),
    };
  }
}

class StreakData {
  final String id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;

  const StreakData({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StreakData.fromJson(Map<String, dynamic> json) {
    return StreakData(
      id: json['_id'] as String,
      name: json['Name'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'Name': name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
