import 'dashboard_data.dart';

class LinkedAccount {
  final String id;
  final String userId;
  final String monoLinkedAcctId;
  final AccountInstitution institution;
  final Details details;
  final AccountBalance balance;
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
      institution: AccountInstitution.fromJson(json['Institution']),
      details: Details.fromJson(json['Details']),
      balance: AccountBalance.fromJson(json['Balance']),
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

class AccountInstitution {
  final String name;
  final String code;

  AccountInstitution({required this.name, required this.code});

  factory AccountInstitution.fromJson(Map<String, dynamic> json) {
    return AccountInstitution(
      name: json['name'] as String,
      code: json['code'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'code': code};
  }
}

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

class AccountBalance {
  final int available;
  final String currency;

  AccountBalance({required this.available, required this.currency});

  factory AccountBalance.fromJson(Map<String, dynamic> json) {
    return AccountBalance(
      available: json['available'] as int,
      currency: json['currency'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'available': available, 'currency': currency};
  }
}

// ============================================================================
// LINK ACCOUNT RESPONSE MODELS
// ============================================================================

class LinkAccountResponse {
  final String status;
  final String message;
  final DateTime timestamp;
  final LinkAccountData data;

  LinkAccountResponse({
    required this.status,
    required this.message,
    required this.timestamp,
    required this.data,
  });

  factory LinkAccountResponse.fromJson(Map<String, dynamic> json) {
    return LinkAccountResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      timestamp: DateTime.parse(json['timestamp']),
      data: LinkAccountData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'data': data.toJson(),
    };
  }
}

class LinkAccountData {
  final LinkedAccountInfo account;
  final CustomerInfo customer;
  final MetaInfo meta;

  LinkAccountData({
    required this.account,
    required this.customer,
    required this.meta,
  });

  factory LinkAccountData.fromJson(Map<String, dynamic> json) {
    return LinkAccountData(
      account: LinkedAccountInfo.fromJson(json['account'] ?? {}),
      customer: CustomerInfo.fromJson(json['customer'] ?? {}),
      meta: MetaInfo.fromJson(json['meta'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'account': account.toJson(),
      'customer': customer.toJson(),
      'meta': meta.toJson(),
    };
  }
}

class LinkedAccountInfo {
  final String id;
  final String name;
  final String accountNumber;
  final String currency;
  final int balance;
  final String type;
  final String bvn;
  final InstitutionInfo institution;

  LinkedAccountInfo({
    required this.id,
    required this.name,
    required this.accountNumber,
    required this.currency,
    required this.balance,
    required this.type,
    required this.bvn,
    required this.institution,
  });

  factory LinkedAccountInfo.fromJson(Map<String, dynamic> json) {
    return LinkedAccountInfo(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      accountNumber: json['account_number'] ?? '',
      currency: json['currency'] ?? 'NGN',
      balance: json['balance'] ?? 0,
      type: json['type'] ?? '',
      bvn: json['bvn'] ?? '',
      institution: InstitutionInfo.fromJson(json['institution'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'account_number': accountNumber,
      'currency': currency,
      'balance': balance,
      'type': type,
      'bvn': bvn,
      'institution': institution.toJson(),
    };
  }
}

class CustomerInfo {
  final String id;

  CustomerInfo({required this.id});

  factory CustomerInfo.fromJson(Map<String, dynamic> json) {
    return CustomerInfo(id: json['id'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'id': id};
  }
}

class MetaInfo {
  final String dataStatus;
  final String authMethod;
  final List<String> retrievedData;

  MetaInfo({
    required this.dataStatus,
    required this.authMethod,
    required this.retrievedData,
  });

  factory MetaInfo.fromJson(Map<String, dynamic> json) {
    return MetaInfo(
      dataStatus: json['data_status'] ?? '',
      authMethod: json['auth_method'] ?? '',
      retrievedData:
          (json['retrieved_data'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data_status': dataStatus,
      'auth_method': authMethod,
      'retrieved_data': retrievedData,
    };
  }
}
