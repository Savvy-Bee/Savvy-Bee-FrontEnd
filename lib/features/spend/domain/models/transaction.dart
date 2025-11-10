class CustomerInfo {
  final String email;

  CustomerInfo({required this.email});

  factory CustomerInfo.fromJson(Map<String, dynamic> json) {
    return CustomerInfo(
      email: json['email'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
    };
  }
}

class TransactionData {
  final String amount;
  final String fee;
  final String currency;
  final String status;
  final String reference;
  final String message;
  final CustomerInfo customer;

  TransactionData({
    required this.amount,
    required this.fee,
    required this.currency,
    required this.status,
    required this.reference,
    required this.message,
    required this.customer,
  });

  factory TransactionData.fromJson(Map<String, dynamic> json) {
    return TransactionData(
      amount: json['amount'] as String,
      fee: json['fee'] as String,
      currency: json['currency'] as String,
      status: json['status'] as String,
      reference: json['reference'] as String,
      message: json['message'] as String,
      customer: CustomerInfo.fromJson(json['customer'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'fee': fee,
      'currency': currency,
      'status': status,
      'reference': reference,
      'message': message,
      'customer': customer.toJson(),
    };
  }
}

class TransactionResponse {
  final bool success;
  final String message;
  final TransactionData data;

  TransactionResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory TransactionResponse.fromJson(Map<String, dynamic> json) {
    return TransactionResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: TransactionData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}