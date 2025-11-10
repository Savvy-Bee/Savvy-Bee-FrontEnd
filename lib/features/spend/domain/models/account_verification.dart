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
    return AccountVerificationData(
      bankName: json['bank_name'] as String,
      bankCode: json['bank_code'] as String,
      accountNumber: json['account_number'] as String,
      accountName: json['account_name'] as String,
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