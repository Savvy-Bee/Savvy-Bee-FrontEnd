/// Represents the Kyc status data structure.
class Kyc {
  final bool nin;
  final bool bvn;

  Kyc({required this.nin, required this.bvn});

  /// Factory constructor to create a Kyc instance from a JSON map.
  factory Kyc.fromJson(Map<String, dynamic> json) {
    return Kyc(nin: json['NIN'] as bool, bvn: json['BVN'] as bool);
  }

  /// Converts the Kyc instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {'NIN': nin, 'BVN': bvn};
  }
}

/// Represents the AIData structure.
class AIData {
  final String message;
  final num ratings;
  final String status;

  AIData({required this.message, required this.ratings, required this.status});

  /// Factory constructor to create an AIData instance from a JSON map.
  factory AIData.fromJson(Map<String, dynamic> json) {
    return AIData(
      message: json['message'] as String,
      ratings: json['Ratings'] as num,
      status: json['Status'] as String,
    );
  }

  /// Converts the AIData instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {'message': message, 'Ratings': ratings, 'Status': status};
  }
}

/// Represents the main 'data' structure containing user and AI information.
class HomeData {
  final String firstName;
  final String lastName;
  final String username;
  final Kyc kyc;
  final String profilePhoto;
  final AIData aiData;

  HomeData({
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.kyc,
    required this.profilePhoto,
    required this.aiData,
  });

  /// Factory constructor to create a HomeData instance from a JSON map.
  factory HomeData.fromJson(Map<String, dynamic> json) {
    return HomeData(
      firstName: json['FirstName'] as String,
      lastName: json['LastName'] as String,
      username: json['Username'] as String,
      // Nested objects require calling their respective fromJson methods
      kyc: Kyc.fromJson(json['Kyc'] as Map<String, dynamic>),
      profilePhoto: json['ProfilePhoto'] as String,
      aiData: AIData.fromJson(json['AIData'] as Map<String, dynamic>),
    );
  }

  /// Converts the HomeData instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'FirstName': firstName,
      'LastName': lastName,
      'Username': username,
      'Kyc': kyc.toJson(),
      'ProfilePhoto': profilePhoto,
      'AIData': aiData.toJson(),
    };
  }
}

/// Represents the overall API response structure.
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
