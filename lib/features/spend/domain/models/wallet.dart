// NGN Account Model
class NgnAccount {
  final String accountName;
  final String accountNumber;
  final String bankCode;
  final String bankName;
  final String koraRef;

  NgnAccount({
    required this.accountName,
    required this.accountNumber,
    required this.bankCode,
    required this.bankName,
    required this.koraRef,
  });

  factory NgnAccount.fromJson(Map<String, dynamic> json) {
    return NgnAccount(
      accountName: json['AccountName'] ?? '',
      accountNumber: json['AccountNumber'] ?? '',
      bankCode: json['BankCode'] ?? '',
      bankName: json['BankName'] ?? '',
      koraRef: json['KoraRef'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'AccountName': accountName,
      'AccountNumber': accountNumber,
      'BankCode': bankCode,
      'BankName': bankName,
      'KoraRef': koraRef,
    };
  }

  NgnAccount copyWith({
    String? accountName,
    String? accountNumber,
    String? bankCode,
    String? bankName,
    String? koraRef,
  }) {
    return NgnAccount(
      accountName: accountName ?? this.accountName,
      accountNumber: accountNumber ?? this.accountNumber,
      bankCode: bankCode ?? this.bankCode,
      bankName: bankName ?? this.bankName,
      koraRef: koraRef ?? this.koraRef,
    );
  }
}

// Account Existence Model
class AccountExistence {
  final bool ng;
  final bool us;

  AccountExistence({required this.ng, required this.us});

  factory AccountExistence.fromJson(Map<String, dynamic> json) {
    return AccountExistence(ng: json['Ng'] ?? false, us: json['US'] ?? false);
  }

  Map<String, dynamic> toJson() {
    return {'Ng': ng, 'US': us};
  }

  AccountExistence copyWith({bool? ng, bool? us}) {
    return AccountExistence(ng: ng ?? this.ng, us: us ?? this.us);
  }
}

// Wallet Account Model
class WalletAccount {
  final String id;
  final String userId;
  final double balance;
  final DateTime createdAt;
  final DateTime updatedAt;
  final NgnAccount? ngnAccount;

  WalletAccount({
    required this.id,
    required this.userId,
    required this.balance,
    required this.createdAt,
    required this.updatedAt,
    this.ngnAccount,
  });

  factory WalletAccount.fromJson(Map<String, dynamic> json) {
    return WalletAccount(
      id: json['_id'] ?? '',
      userId: json['UserID'] ?? '',
      balance: (json['Balance'] ?? 0).toDouble(),
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
      ngnAccount: json['NGNAccount'] != null
          ? NgnAccount.fromJson(json['NGNAccount'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'UserID': userId,
      'Balance': balance,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'NGNAccount': ngnAccount?.toJson(),
    };
  }

  WalletAccount copyWith({
    String? id,
    String? userId,
    double? balance,
    DateTime? createdAt,
    DateTime? updatedAt,
    NgnAccount? ngnAccount,
  }) {
    return WalletAccount(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      balance: balance ?? this.balance,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      ngnAccount: ngnAccount ?? this.ngnAccount,
    );
  }
}

// Dashboard Data Model
class WalletDashboardData {
  final AccountExistence accountExistence;
  final WalletAccount accounts;

  WalletDashboardData({required this.accountExistence, required this.accounts});

  factory WalletDashboardData.fromJson(Map<String, dynamic> json) {
    return WalletDashboardData(
      accountExistence: AccountExistence.fromJson(
        json['AccountExistence'] ?? {},
      ),
      accounts: WalletAccount.fromJson(json['Accounts'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'AccountExistence': accountExistence.toJson(),
      'Accounts': accounts.toJson(),
    };
  }

  WalletDashboardData copyWith({
    AccountExistence? accountExistence,
    WalletAccount? accounts,
  }) {
    return WalletDashboardData(
      accountExistence: accountExistence ?? this.accountExistence,
      accounts: accounts ?? this.accounts,
    );
  }
}

// Transaction Type Enum
enum WalletTransactionType {
  credit('Credit'),
  debit('Debit');

  final String value;
  const WalletTransactionType(this.value);

  static WalletTransactionType fromString(String value) {
    return WalletTransactionType.values.firstWhere(
      (e) => e.value.toLowerCase() == value.toLowerCase(),
      orElse: () => WalletTransactionType.credit,
    );
  }
}

// Transaction Status Enum
enum WalletTransactionStatus {
  success('Success'),
  pending('Pending'),
  failed('Failed');

  final String value;
  const WalletTransactionStatus(this.value);

  static WalletTransactionStatus fromString(String value) {
    return WalletTransactionStatus.values.firstWhere(
      (e) => e.value.toLowerCase() == value.toLowerCase(),
      orElse: () => WalletTransactionStatus.pending,
    );
  }
}

// Transaction Model
class WalletTransaction {
  final String id;
  final String userId;
  final double amount;
  final double charges;
  final WalletTransactionType type;
  final WalletTransactionStatus status;
  final String transactionFor;
  final String koraReferenceId;
  final String narration;
  final DateTime createdAt;
  final DateTime updatedAt;

  WalletTransaction({
    required this.id,
    required this.userId,
    required this.amount,
    required this.charges,
    required this.type,
    required this.status,
    required this.transactionFor,
    required this.koraReferenceId,
    required this.narration,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: json['_id'] ?? '',
      userId: json['UserID'] ?? '',
      amount: (json['Amount'] ?? 0).toDouble(),
      charges: (json['Charges'] ?? 0).toDouble(),
      type: WalletTransactionType.fromString(json['Type'] ?? 'Credit'),
      status: WalletTransactionStatus.fromString(json['Status'] ?? 'Pending'),
      transactionFor: json['For'] ?? '',
      koraReferenceId: json['KoraReferenceID'] ?? '',
      narration: json['Narration'] ?? '',
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'UserID': userId,
      'Amount': amount,
      'Charges': charges,
      'Type': type.value,
      'Status': status.value,
      'For': transactionFor,
      'KoraReferenceID': koraReferenceId,
      'Narration': narration,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  WalletTransaction copyWith({
    String? id,
    String? userId,
    double? amount,
    double? charges,
    WalletTransactionType? type,
    WalletTransactionStatus? status,
    String? transactionFor,
    String? koraReferenceId,
    String? narration,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WalletTransaction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      charges: charges ?? this.charges,
      type: type ?? this.type,
      status: status ?? this.status,
      transactionFor: transactionFor ?? this.transactionFor,
      koraReferenceId: koraReferenceId ?? this.koraReferenceId,
      narration: narration ?? this.narration,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper getters
  bool get isCredit => type == WalletTransactionType.credit;
  bool get isDebit => type == WalletTransactionType.debit;
  bool get isSuccess => status == WalletTransactionStatus.success;
  bool get isPending => status == WalletTransactionStatus.pending;
  bool get isFailed => status == WalletTransactionStatus.failed;
  double get totalAmount => amount + charges;
}

// Pagination Model
class Pagination {
  final int total;
  final int page;
  final int limit;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPrevPage;

  Pagination({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPrevPage,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      totalPages: json['totalPages'] ?? 0,
      hasNextPage: json['hasNextPage'] ?? false,
      hasPrevPage: json['hasPrevPage'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'page': page,
      'limit': limit,
      'totalPages': totalPages,
      'hasNextPage': hasNextPage,
      'hasPrevPage': hasPrevPage,
    };
  }

  Pagination copyWith({
    int? total,
    int? page,
    int? limit,
    int? totalPages,
    bool? hasNextPage,
    bool? hasPrevPage,
  }) {
    return Pagination(
      total: total ?? this.total,
      page: page ?? this.page,
      limit: limit ?? this.limit,
      totalPages: totalPages ?? this.totalPages,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      hasPrevPage: hasPrevPage ?? this.hasPrevPage,
    );
  }
}

// Transactions Response Model
class WalletTransactionsResponse {
  final List<WalletTransaction> transactions;
  final Pagination pagination;

  WalletTransactionsResponse({
    required this.transactions,
    required this.pagination,
  });

  factory WalletTransactionsResponse.fromJson(Map<String, dynamic> json) {
    return WalletTransactionsResponse(
      transactions: (json['data'] as List? ?? [])
          .map((e) => WalletTransaction.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination: Pagination.fromJson(json['pagination'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': transactions.map((e) => e.toJson()).toList(),
      'pagination': pagination.toJson(),
    };
  }

  WalletTransactionsResponse copyWith({
    List<WalletTransaction>? transactions,
    Pagination? pagination,
  }) {
    return WalletTransactionsResponse(
      transactions: transactions ?? this.transactions,
      pagination: pagination ?? this.pagination,
    );
  }
}
