// import '../enums/auth_method.dart';

// class Institution {
//   final String id;
//   final String institution;
//   final String type;
//   final String? nipCode;
//   final String? bankCode;
//   final String country;
//   final List<AuthMethod> authMethods;
//   final List<Scope> scope;

//   Institution({
//     required this.id,
//     required this.institution,
//     required this.type,
//     this.nipCode,
//     this.bankCode,
//     required this.country,
//     required this.authMethods,
//     required this.scope,
//   });

//   factory Institution.fromJson(Map<String, dynamic> json) {
//     return Institution(
//       id: json['id'] ?? '',
//       institution: json['institution'] ?? '',
//       type: json['type'] ?? '',
//       nipCode: json['nip_code'],
//       bankCode: json['bank_code'],
//       country: json['country'] ?? '',
//       authMethods: json['auth_methods'] != null
//           ? (json['auth_methods'] as List)
//                 .map((i) => AuthMethod.fromJson(i))
//                 .toList()
//           : [],
//       scope: json['scope'] != null
//           ? (json['scope'] as List).map((i) => Scope.fromJson(i)).toList()
//           : [],
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'institution': institution,
//       'type': type,
//       'nip_code': nipCode,
//       'bank_code': bankCode,
//       'country': country,
//       'auth_methods': authMethods.map((v) => v.toJson()).toList(),
//       'scope': scope.map((v) => v.toJson()).toList(),
//     };
//   }

//   // Helper method to filter auth methods by type
//   List<AuthMethod> getAuthMethodsByType(AuthMethodType type) {
//     return authMethods.where((method) => method.authType == type).toList();
//   }

//   // Helper method to check if institution supports a specific auth method
//   bool supportsAuthMethod(AuthMethodType type) {
//     return authMethods.any((method) => method.authType == type);
//   }
// }

// class AuthMethod {
//   final String id;
//   final AuthMethodType authType;
//   final String typeRaw; // Keep original string value
//   final String name;
//   final String identifier;

//   AuthMethod({
//     required this.id,
//     required this.authType,
//     required this.typeRaw,
//     required this.name,
//     required this.identifier,
//   });

//   factory AuthMethod.fromJson(Map<String, dynamic> json) {
//     final typeString = json['type'] ?? '';
//     return AuthMethod(
//       id: json['_id'] ?? '',
//       authType: AuthMethodType.fromString(typeString),
//       typeRaw: typeString,
//       name: json['name'] ?? '',
//       identifier: json['identifier'] ?? '',
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {'_id': id, 'type': typeRaw, 'name': name, 'identifier': identifier};
//   }

//   // Helper methods for common checks
//   bool get isInternetBanking => authType == AuthMethodType.internetBanking;
//   bool get isMobileBanking => authType == AuthMethodType.mobileBanking;
//   bool get isAccountNumber => authType == AuthMethodType.accountNumber;
//   bool get isWhatsApp => authType == AuthMethodType.whatsapp;
// }

// class Scope {
//   final String? name;
//   final String? type;

//   Scope({this.name, this.type});

//   factory Scope.fromJson(Map<String, dynamic> json) {
//     return Scope(name: json['name'], type: json['type']);
//   }

//   Map<String, dynamic> toJson() {
//     return {'name': name, 'type': type};
//   }
// }

// // Input data response
// class MonoInputData {
//   final String name;
//   final String email;
//   final String? monoCustomerId;
//   final String identity;

//   MonoInputData({
//     required this.name,
//     required this.email,
//     this.monoCustomerId,
//     required this.identity,
//   });

//   factory MonoInputData.fromJson(Map<String, dynamic> json) {
//     return MonoInputData(
//       name: json['name'] ?? '',
//       email: json['email'] ?? '',
//       monoCustomerId: json['monoCustomerId'],
//       identity: json['identity'] ?? '',
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'name': name,
//       'email': email,
//       'monoCustomerId': monoCustomerId,
//       'identity': identity,
//     };
//   }
// }
