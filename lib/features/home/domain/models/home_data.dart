class InsightAdvice {
  final String budgetInsight;
  final String budgetAdvice;
  final String goalSavingsAdvice;

  InsightAdvice({
    required this.budgetInsight,
    required this.budgetAdvice,
    required this.goalSavingsAdvice,
  });

  factory InsightAdvice.fromJson(Map<String, dynamic> json) {
    return InsightAdvice(
      budgetInsight: json['BudgetInsight'] as String? ?? '',
      budgetAdvice: json['BudgetAdvice'] as String? ?? '',
      goalSavingsAdvice: json['GoalSavingsAdvice'] as String? ?? '',
    );
  }
}

class Kyc {
  final bool nin;
  final bool bvn;

  Kyc({required this.nin, required this.bvn});

  factory Kyc.fromJson(Map<String, dynamic> json) {
    return Kyc(nin: json['NIN'] as bool? ?? false, bvn: json['BVN'] as bool? ?? false);
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
      message: json['message'] as String? ?? '',
      ratings: json['Ratings'] as num? ?? 0,
      status: json['Status'] as String? ?? '',
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
      id: json['id'] as String? ?? '',
      streak: (json['Streak'] as num?)?.toInt() ?? 0,
      flowers: (json['Flowers'] as num?)?.toInt() ?? 0,
      honeyDrop: (json['HoneyDrop'] as num?)?.toInt() ?? 0,
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String? ?? '',
      totalFlower: (json['TotalFlower'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
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
      id: json['id'] as String? ?? '',
      name: json['Name'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
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
      stats: HiveStats.fromJson((json['hive'] as Map<String, dynamic>?) ?? {}),
      achievement: ((json['Achievement'] as List<dynamic>?) ?? [])
          .map((e) => Achievement.fromJson(e as Map<String, dynamic>))
          .toList(),
      league: json['League'] as String? ?? '',
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
  final String email;
  final String country;
  final String currency;
  final String language;
  final String profilePhoto;
  final String aiPersonality;
  // final String dob;
  final String? state;
  final String? phoneNumber;
  final Kyc kyc;
  final AIData aiData;
  final HiveData hive;
  final InsightAdvice? insightAdvice;

  HomeData({
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    required this.country,
    required this.currency,
    required this.language,
    required this.profilePhoto,
    required this.aiPersonality,
    // required this.dob,
    this.state,
    this.phoneNumber,
    required this.kyc,
    required this.aiData,
    required this.hive,
    this.insightAdvice,
  });

  factory HomeData.fromJson(Map<String, dynamic> json) {
    return HomeData(
      firstName: json['FirstName'] as String? ?? '',
      lastName: json['LastName'] as String? ?? '',
      username: json['Username'] as String? ?? '',
      email: json['Email'] as String? ?? '',
      country: json['Country'] as String? ?? '',
      currency: json['Currency'] as String? ?? '',
      language: json['Language'] as String? ?? '',
      profilePhoto: json['ProfilePhoto'] as String? ?? '',
      aiPersonality: json['AIPersonality'] as String? ?? '',
      // dob: json['DOB'] as String,
      state: json['State'] as String?,
      phoneNumber: json['PhoneNumber'] as String?,
      kyc: Kyc.fromJson((json['Kyc'] as Map<String, dynamic>?) ?? {}),
      aiData: AIData.fromJson((json['AIData'] as Map<String, dynamic>?) ?? {}),
      hive: HiveData.fromJson((json['Hive'] as Map<String, dynamic>?) ?? {}),
      insightAdvice: json['Insight_Advice'] != null
          ? InsightAdvice.fromJson(
              json['Insight_Advice'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'FirstName': firstName,
      'LastName': lastName,
      'Username': username,
      'Email': email,
      'Country': country,
      'Currency': currency,
      'Language': language,
      'ProfilePhoto': profilePhoto,
      'AIPersonality': aiPersonality,
      // 'DOB': dob,
      if (state != null) 'State': state,
      if (phoneNumber != null) 'PhoneNumber': phoneNumber,
      'Kyc': kyc.toJson(),
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
