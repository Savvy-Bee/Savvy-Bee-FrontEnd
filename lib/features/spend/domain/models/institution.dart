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
          .map((e) => AuthMethod.fromJson(e))
          .toList(),
      scope: (json['scope'] as List).map((e) => Scope.fromJson(e)).toList(),
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
    return {'_id': id, 'type': type, 'name': name, 'identifier': identifier};
  }
}

class Scope {
  final String name;
  final String type;

  Scope({required this.name, required this.type});

  factory Scope.fromJson(Map<String, dynamic> json) {
    return Scope(name: json['name'] as String, type: json['type'] as String);
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'type': type};
  }
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
      'monoCustomerId': monoCustomerId,
      'identity': identity,
    };
  }
}

class LinkedAccount {
  final String id;
  final String userId;
  final String monoLinkedAcctId;
  final String accountName;
  final DateTime createdAt;
  final DateTime updatedAt;

  LinkedAccount({
    required this.id,
    required this.userId,
    required this.monoLinkedAcctId,
    required this.accountName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LinkedAccount.fromJson(Map<String, dynamic> json) {
    return LinkedAccount(
      id: json['_id'] as String,
      userId: json['UserID'] as String,
      monoLinkedAcctId: json['MonoLinkedAcct_ID'] as String,
      accountName: json['AccountName'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'UserID': userId,
      'MonoLinkedAcct_ID': monoLinkedAcctId,
      'AccountName': accountName,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;

  ApiResponse({required this.success, required this.message, this.data});

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'] as T?,
    );
  }
}
