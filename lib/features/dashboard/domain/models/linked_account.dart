import 'package:savvy_bee_mobile/features/dashboard/domain/models/dashboard_data.dart';

class LinkedAccount {
  final String id;
  final String userId;
  final String monoLinkedAcctId;
  final Institution institution;
  final Details details;
  final Balance balance;
  final DateTime createdAt;
  final DateTime updatedAt;

  LinkedAccount({
    required this.id,
    required this.userId,
    required this.monoLinkedAcctId,
    required this.institution,
    required this.details,
    required this.balance,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LinkedAccount.fromJson(Map<String, dynamic> json) {
    return LinkedAccount(
      id: json['_id'] as String,
      userId: json['UserID'] as String,
      monoLinkedAcctId: json['MonoLinkedAcct_ID'] as String,
      institution: Institution.fromJson(json['Institution']),
      details: Details.fromJson(json['Details']),
      balance: Balance.fromJson(json['Balance']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'UserID': userId,
      'MonoLinkedAcct_ID': monoLinkedAcctId,
      'Institution': institution.toJson(),
      'Details': details.toJson(),
      'Balance': balance.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

// class Institution {
//   final String name;
//   final String code;

//   Institution({required this.name, required this.code});

//   factory Institution.fromJson(Map<String, dynamic> json) {
//     return Institution(
//       name: json['name'] as String,
//       code: json['code'] as String,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'name': name,
//       'code': code,
//     };
//   }
// }

class Details {
  final String name;
  final String accountNumber;
  final String accountType;

  Details({
    required this.name,
    required this.accountNumber,
    required this.accountType,
  });

  factory Details.fromJson(Map<String, dynamic> json) {
    return Details(
      name: json['name'] as String,
      accountNumber: json['account_number'] as String,
      accountType: json['account_type'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'account_number': accountNumber,
      'account_type': accountType,
    };
  }
}

class Balance {
  final int available;
  final String currency;

  Balance({required this.available, required this.currency});

  factory Balance.fromJson(Map<String, dynamic> json) {
    return Balance(
      available: json['available'] as int,
      currency: json['currency'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'available': available,
      'currency': currency,
    };
  }
}
