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

// Register request model
class RegisterRequest {
  final String firstName;
  final String lastName;
  final String email;
  final String password;

  RegisterRequest({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'FirstName': firstName,
      'LastName': lastName,
      'Email': email,
      'Password': password,
    };
  }
}

// Register response data model
class RegisterResponse {
  final bool success;
  final String message;
  final User? data;

  RegisterResponse({required this.success, required this.message, this.data});

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? User.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'message': message, 'data': data?.toJson()};
  }
}

// Verify email request model
class VerifyEmailRequest {
  final String email;
  final String otp;

  VerifyEmailRequest({required this.email, required this.otp});

  Map<String, dynamic> toJson() {
    return {'Email': email, 'OTP': otp};
  }
}

// Register other details request model
class RegisterOtherDetailsRequest {
  final String email;
  final String dob; // Date of Birth (e.g., '1988-04-04')
  final String country;

  RegisterOtherDetailsRequest({
    required this.email,
    required this.dob,
    required this.country,
  });

  Map<String, dynamic> toJson() {
    return {'Email': email, 'DOB': dob, 'Country': country};
  }
}

// Login response data model
class LoginResponse {
  final bool success;
  final String message;
  final LoginData? data;

  LoginResponse({required this.success, required this.message, this.data});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? LoginData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'message': message, 'data': data?.toJson()};
  }
}

class LoginData {
  final String token;
  final Verification verification;

  LoginData({required this.token, required this.verification});

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      token: json['token'] ?? '',
      verification: Verification.fromJson(json['verification'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {'token': token, 'verification': verification.toJson()};
  }
}

class Verification {
  final bool emailVerification;
  final bool otherDetails;

  Verification({required this.emailVerification, required this.otherDetails});

  factory Verification.fromJson(Map<String, dynamic> json) {
    return Verification(
      emailVerification: json['EmailVerification'] ?? false,
      otherDetails: json['OtherDetails'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'EmailVerification': emailVerification,
      'OtherDetails': otherDetails,
    };
  }
}
