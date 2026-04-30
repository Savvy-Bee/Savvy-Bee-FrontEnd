class TransactionData {
  final String amount;
  final String fee;
  final String currency;
  final String status;
  final String reference;
  final String message;

  TransactionData({
    required this.amount,
    required this.fee,
    required this.currency,
    required this.status,
    required this.reference,
    required this.message,
  });

  factory TransactionData.fromJson(Map<String, dynamic> json) {
    // API returns: { data: { id, type, attributes: { amount, currency, status, reference, ... } } }
    final inner = json['data'] as Map<String, dynamic>?;
    final attributes =
        (inner?['attributes'] as Map<String, dynamic>?) ?? json;

    return TransactionData(
      amount: ((double.tryParse((attributes['amount'] ?? 0).toString()) ?? 0) / 100).toString(),
      fee: ((double.tryParse((attributes['fee'] ?? 0).toString()) ?? 0) / 100).toString(),
      currency: attributes['currency'] as String? ?? '',
      status: attributes['status'] as String? ?? '',
      reference: attributes['reference'] as String? ?? '',
      message: attributes['message'] as String? ??
          json['message'] as String? ??
          '',
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
    };
  }
}

class TransactionResponse {
  final bool success;
  final String message;
  final TransactionData? data;

  TransactionResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory TransactionResponse.fromJson(Map<String, dynamic> json) {
    return TransactionResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: json['data'] != null
          ? TransactionData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}