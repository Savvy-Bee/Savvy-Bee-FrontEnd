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

// User model
class User {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final bool verified;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.verified,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      firstName: json['FirstName'] ?? '',
      lastName: json['LastName'] ?? '',
      email: json['Email'] ?? '',
      verified: json['Verified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'FirstName': firstName,
      'LastName': lastName,
      'Email': email,
      'Verified': verified,
    };
  }
}
