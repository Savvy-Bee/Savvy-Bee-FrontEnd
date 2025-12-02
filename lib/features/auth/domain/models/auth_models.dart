// Register request model
import 'user.dart';

class RegisterRequest {
  final String firstName;
  final String lastName;
  final String email;
  final String username;
  final String password;

  RegisterRequest({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.username,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'FirstName': firstName,
      'LastName': lastName,
      'Email': email,
      'Username': username,
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
  final String currency;
  final String language;

  RegisterOtherDetailsRequest({
    required this.email,
    required this.dob,
    required this.country,
    required this.currency,
    required this.language,
  });

  Map<String, dynamic> toJson() {
    return {
      'Email': email,
      'DOB': dob,
      'Country': country,
      'currency': currency,
      'language': language,
    };
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

class PostOnboardRequest {
  final String whatMatters;
  final String userArchetype;
  final String financePriorities;
  final String howFinanceManaged;
  final String confusingTopics;
  final String challengesWithYou;
  final String motivatesyou;

  PostOnboardRequest({
    required this.whatMatters,
    required this.userArchetype,
    required this.financePriorities,
    required this.howFinanceManaged,
    required this.confusingTopics,
    required this.challengesWithYou,
    required this.motivatesyou,
  });

  Map<String, dynamic> toJson() {
    return {
      'WhatMatters': whatMatters,
      'UserArchetype': userArchetype,
      'FinancePriorities': financePriorities,
      'HowFinanceManaged': howFinanceManaged,
      'ConfusingTopics': confusingTopics,
      'ChallengesWithYou': challengesWithYou,
      'Motivatesyou': motivatesyou,
    };
  }
}
