class AccountVerificationData {
  final String bankName;
  final String bankCode;
  final String accountNumber;
  final String accountName;

  AccountVerificationData({
    required this.bankName,
    required this.bankCode,
    required this.accountNumber,
    required this.accountName,
  });

  factory AccountVerificationData.fromJson(Map<String, dynamic> json) {
    // Response shape: { id, type, attributes: { bank: { name, nipCode }, accountName, accountNumber } }
    final attrs = json['attributes'] as Map<String, dynamic>? ?? json;
    final bank = attrs['bank'] as Map<String, dynamic>? ?? {};
    return AccountVerificationData(
      bankName: bank['name'] as String? ?? json['bank_name'] as String? ?? '',
      bankCode: (bank['nipCode'] ?? bank['id'] ?? json['bank_code'] ?? '').toString(),
      accountNumber: (attrs['accountNumber'] ?? json['account_number'] ?? '').toString(),
      accountName: (attrs['accountName'] ?? json['account_name'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bank_name': bankName,
      'bank_code': bankCode,
      'account_number': accountNumber,
      'account_name': accountName,
    };
  }
}

class AccountVerificationResponse {
  final bool success;
  final String message;
  final AccountVerificationData data;

  AccountVerificationResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory AccountVerificationResponse.fromJson(Map<String, dynamic> json) {
    return AccountVerificationResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: AccountVerificationData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}