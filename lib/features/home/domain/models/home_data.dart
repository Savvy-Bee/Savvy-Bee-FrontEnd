class Kyc {
  final bool nin;
  final bool bvn;

  Kyc({required this.nin, required this.bvn});

  factory Kyc.fromJson(Map<String, dynamic> json) {
    return Kyc(nin: json['NIN'] as bool, bvn: json['BVN'] as bool);
  }

  Map<String, dynamic> toJson() {
    return {'NIN': nin, 'BVN': bvn};
  }
}

class AIData {
  final String message;
  final num ratings;
  final String status;

  AIData({required this.message, required this.ratings, required this.status});

  factory AIData.fromJson(Map<String, dynamic> json) {
    return AIData(
      message: json['message'] as String,
      ratings: json['Ratings'] as num,
      status: json['Status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'message': message, 'Ratings': ratings, 'Status': status};
  }
}

class HiveStats {
  final String id;
  final int streak;
  final int flowers;
  final int honeyDrop;
  final String createdAt;
  final String updatedAt;
  final int totalFlower;

  HiveStats({
    required this.id,
    required this.streak,
    required this.flowers,
    required this.honeyDrop,
    required this.createdAt,
    required this.updatedAt,
    required this.totalFlower,
  });

  factory HiveStats.fromJson(Map<String, dynamic> json) {
    return HiveStats(
      id: json['_id'] as String,
      streak: json['Streak'] as int,
      flowers: json['Flowers'] as int,
      honeyDrop: json['HoneyDrop'] as int,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
      totalFlower: json['TotalFlower'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'Streak': streak,
      'Flowers': flowers,
      'HoneyDrop': honeyDrop,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'TotalFlower': totalFlower,
    };
  }
}

class Achievement {
  final String id;
  final String name;
  final String createdAt;
  final String updatedAt;

  Achievement({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['_id'] as String,
      name: json['Name'] as String,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'Name': name,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

class HiveData {
  final HiveStats stats;
  final List<Achievement> achievement;
  final String league;

  HiveData({
    required this.stats,
    required this.achievement,
    required this.league,
  });

  factory HiveData.fromJson(Map<String, dynamic> json) {
    return HiveData(
      stats: HiveStats.fromJson(json['hive'] as Map<String, dynamic>),
      achievement: (json['Achievement'] as List<dynamic>)
          .map((e) => Achievement.fromJson(e as Map<String, dynamic>))
          .toList(),
      league: json['League'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hive': stats.toJson(),
      'Achievement': achievement.map((e) => e.toJson()).toList(),
      'League': league,
    };
  }
}

class HomeData {
  final String firstName;
  final String lastName;
  final String username;
  final Kyc kyc;
  final String profilePhoto;
  final AIData aiData;
  final HiveData hive;

  HomeData({
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.kyc,
    required this.profilePhoto,
    required this.aiData,
    required this.hive,
  });

  factory HomeData.fromJson(Map<String, dynamic> json) {
    return HomeData(
      firstName: json['FirstName'] as String,
      lastName: json['LastName'] as String,
      username: json['Username'] as String,
      kyc: Kyc.fromJson(json['Kyc'] as Map<String, dynamic>),
      profilePhoto: json['ProfilePhoto'] as String,
      aiData: AIData.fromJson(json['AIData'] as Map<String, dynamic>),
      hive: HiveData.fromJson(json['Hive'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'FirstName': firstName,
      'LastName': lastName,
      'Username': username,
      'Kyc': kyc.toJson(),
      'ProfilePhoto': profilePhoto,
      'AIData': aiData.toJson(),
      'Hive': hive.toJson(),
    };
  }
}

class HomeDataResponse {
  final bool success;
  final String message;
  final HomeData data;

  HomeDataResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  /// Factory constructor to create a HomeDataResponse instance from a JSON map.
  factory HomeDataResponse.fromJson(Map<String, dynamic> json) {
    return HomeDataResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      // Nested objects require calling their respective fromJson methods
      data: HomeData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  /// Converts the HomeDataResponse instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {'success': success, 'message': message, 'data': data.toJson()};
  }
}
