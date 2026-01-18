class Institution {
  final String id;
  final String institution;
  final String type;
  final String? nipCode;
  final String? bankCode;
  final String country;
  final List<AuthMethod> authMethods;
  final List<Scope> scope;

  Institution({
    required this.id,
    required this.institution,
    required this.type,
    this.nipCode,
    this.bankCode,
    required this.country,
    required this.authMethods,
    required this.scope,
  });

  factory Institution.fromJson(Map<String, dynamic> json) {
    return Institution(
      id: json['id'] as String,
      institution: json['institution'] as String,
      type: json['type'] as String,
      nipCode: json['nip_code'] as String?,
      bankCode: json['bank_code'] as String?,
      country: json['country'] as String,
      authMethods: (json['auth_methods'] as List)
          .map((e) => AuthMethod.fromJson(e as Map<String, dynamic>))
          .toList(),
      // Filter out invalid scope objects
      scope: (json['scope'] as List)
          .where((e) => e is Map<String, dynamic> && 
                       e.containsKey('name') && 
                       e.containsKey('type') &&
                       e['name'] != null && 
                       e['type'] != null)
          .map((e) => Scope.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'institution': institution,
      'type': type,
      'nip_code': nipCode,
      'bank_code': bankCode,
      'country': country,
      'auth_methods': authMethods.map((e) => e.toJson()).toList(),
      'scope': scope.map((e) => e.toJson()).toList(),
    };
  }

  // Helper method to get display name
  String get displayName => institution;

  // Helper method to check if institution supports specific auth method
  bool supportsAuthMethod(String methodType) {
    return authMethods.any((method) => method.type == methodType);
  }

  // Helper method to get specific auth method
  AuthMethod? getAuthMethod(String methodType) {
    try {
      return authMethods.firstWhere((method) => method.type == methodType);
    } catch (e) {
      return null;
    }
  }
}

class AuthMethod {
  final String id;
  final String type;
  final String name;
  final String identifier;

  AuthMethod({
    required this.id,
    required this.type,
    required this.name,
    required this.identifier,
  });

  factory AuthMethod.fromJson(Map<String, dynamic> json) {
    return AuthMethod(
      id: json['_id'] as String,
      type: json['type'] as String,
      name: json['name'] as String,
      identifier: json['identifier'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'type': type,
      'name': name,
      'identifier': identifier,
    };
  }

  // Helper method for display
  String get displayName => name;
}

class Scope {
  final String name;
  final String type;

  Scope({required this.name, required this.type});

  factory Scope.fromJson(Map<String, dynamic> json) {
    // Add null checks and default values
    return Scope(
      name: json['name'] as String? ?? '',
      type: json['type'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
    };
  }

  // Helper method to check if scope is valid
  bool get isValid => name.isNotEmpty && type.isNotEmpty;
}

class MonoInputData {
  final String name;
  final String email;
  final String? monoCustomerId;
  final String identity;

  MonoInputData({
    required this.name,
    required this.email,
    this.monoCustomerId,
    required this.identity,
  });

  factory MonoInputData.fromJson(Map<String, dynamic> json) {
    return MonoInputData(
      name: json['name'] as String,
      email: json['email'] as String,
      monoCustomerId: json['monoCustomerId'] as String?,
      identity: json['identity'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      if (monoCustomerId != null) 'monoCustomerId': monoCustomerId,
      'identity': identity,
    };
  }
}

// class LinkedAccount {
//   final String id;
//   final String userId;
//   final String monoLinkedAcctId;
//   final String accountName;
//   final DateTime createdAt;
//   final DateTime updatedAt;

//   LinkedAccount({
//     required this.id,
//     required this.userId,
//     required this.monoLinkedAcctId,
//     required this.accountName,
//     required this.createdAt,
//     required this.updatedAt,
//   });

//   factory LinkedAccount.fromJson(Map<String, dynamic> json) {
//     return LinkedAccount(
//       id: json['_id'] as String,
//       userId: json['UserID'] as String,
//       monoLinkedAcctId: json['MonoLinkedAcct_ID'] as String,
//       accountName: json['AccountName'] as String,
//       createdAt: DateTime.parse(json['createdAt'] as String),
//       updatedAt: DateTime.parse(json['updatedAt'] as String),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       '_id': id,
//       'UserID': userId,
//       'MonoLinkedAcct_ID': monoLinkedAcctId,
//       'AccountName': accountName,
//       'createdAt': createdAt.toIso8601String(),
//       'updatedAt': updatedAt.toIso8601String(),
//     };
//   }

//   // Helper method for display
//   String get displayName => accountName;
// }

// Response wrapper for API calls
class InstitutionsResponse {
  final bool success;
  final String message;
  final List<Institution> data;

  InstitutionsResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory InstitutionsResponse.fromJson(Map<String, dynamic> json) {
    return InstitutionsResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: (json['data'] as List?)
              ?.map((e) => Institution.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data.map((e) => e.toJson()).toList(),
    };
  }
}

// Helper extensions for filtering institutions
extension InstitutionListExtensions on List<Institution> {
  /// Filter by institution type (PERSONAL_BANKING, BUSINESS_BANKING)
  List<Institution> filterByType(String type) {
    return where((inst) => inst.type == type).toList();
  }

  /// Filter by auth method support
  List<Institution> filterByAuthMethod(String methodType) {
    return where((inst) => inst.supportsAuthMethod(methodType)).toList();
  }

  /// Sort alphabetically by institution name
  List<Institution> sortedByName() {
    final sorted = List<Institution>.from(this);
    sorted.sort((a, b) => a.institution.compareTo(b.institution));
    return sorted;
  }

  /// Get personal banking institutions only
  List<Institution> get personalBanking {
    return filterByType('PERSONAL_BANKING');
  }

  /// Get business banking institutions only
  List<Institution> get businessBanking {
    return filterByType('BUSINESS_BANKING');
  }

  /// Filter institutions that support mobile banking
  List<Institution> get withMobileBanking {
    return filterByAuthMethod('mobile_banking');
  }

  /// Filter institutions that support internet banking
  List<Institution> get withInternetBanking {
    return filterByAuthMethod('internet_banking');
  }

  /// Filter institutions that support account number auth
  List<Institution> get withAccountNumber {
    return filterByAuthMethod('account_number');
  }
}