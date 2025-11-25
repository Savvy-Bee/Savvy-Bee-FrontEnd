class HiveHomeResponse {
  final bool success;
  final String message;
  final HiveHomeData data;

  const HiveHomeResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory HiveHomeResponse.fromJson(Map<String, dynamic> json) {
    return HiveHomeResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: HiveHomeData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'message': message, 'data': data.toJson()};
  }
}

class HiveHomeData {
  final HiveData hive; // Maps to the 'hive' object
  final List<Achievement> achievement; // Maps to the 'Achievement' array

  const HiveHomeData({required this.hive, required this.achievement});

  factory HiveHomeData.fromJson(Map<String, dynamic> json) {
    return HiveHomeData(
      // Parsing the single nested 'hive' object
      hive: HiveData.fromJson(json['hive'] as Map<String, dynamic>),
      // Parsing the array of 'Achievement' objects
      achievement: (json['Achievement'] as List<dynamic>)
          .map((item) => Achievement.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hive': hive.toJson(),
      'Achievement': achievement.map((a) => a.toJson()).toList(),
    };
  }
}

class HiveData {
  final String id;
  final String userId;
  final int streak;
  final int flowers;
  final int honeyDrop;
  final DateTime createdAt;
  final DateTime updatedAt;

  const HiveData({
    required this.id,
    required this.userId,
    required this.streak,
    required this.flowers,
    required this.honeyDrop,
    required this.createdAt,
    required this.updatedAt,
  });

  factory HiveData.fromJson(Map<String, dynamic> json) {
    return HiveData(
      id: json['_id'] as String,
      userId: json['UserID'] as String,
      streak: json['Streak'] as int,
      flowers: json['Flowers'] as int,
      honeyDrop: json['HoneyDrop'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'UserID': userId,
      'Streak': streak,
      'Flowers': flowers,
      'HoneyDrop': honeyDrop,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class Achievement {
  final String id;
  final String userId;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Achievement({
    required this.id,
    required this.userId,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['_id'] as String,
      userId: json['UserID'] as String,
      name: json['Name'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'UserID': userId,
      'Name': name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
