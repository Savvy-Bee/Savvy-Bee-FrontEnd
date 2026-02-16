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
  final int totalFlowers;
  final int streak;
  final int flowers;
  final int honeyDrop;
  final DateTime createdAt;
  final DateTime updatedAt;

  const HiveData({
    required this.id,
    required this.totalFlowers,
    required this.streak,
    required this.flowers,
    required this.honeyDrop,
    required this.createdAt,
    required this.updatedAt,
  });

  factory HiveData.fromJson(Map<String, dynamic> json) {
    return HiveData(
      // Use 'id' instead of '_id' - the API returns 'id'
      id: json['id']?.toString() ?? '',

      // Safe parsing with fallback to 0
      totalFlowers: (json['TotalFlower'] as num?)?.toInt() ?? 0,
      streak: (json['Streak'] as num?)?.toInt() ?? 0,
      flowers: (json['Flowers'] as num?)?.toInt() ?? 0,
      honeyDrop: (json['HoneyDrop'] as num?)?.toInt() ?? 0,

      // Safe date parsing
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'TotalFlower': totalFlowers,
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
      // Use 'id' instead of '_id'
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      userId: json['UserID']?.toString() ?? '',
      name: json['Name']?.toString() ?? '',
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'UserID': userId,
      'Name': name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
