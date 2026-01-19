class DebtListResponse {
  final bool success;
  final String message;
  final List<Debt> data;

  DebtListResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory DebtListResponse.fromJson(Map<String, dynamic> json) {
    return DebtListResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      // Handle the list parsing safely
      data:
          (json['data'] as List<dynamic>?)
              ?.map((item) => Debt.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [], // Returns empty list if data is null
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data.map((item) => item.toJson()).toList(),
    };
  }
}

class Debt {
  final String id; // Mapped from '_id'
  final String userId;
  final String name;
  final double owed;
  final double interestRate;
  final double balance;
  final String preferrablePayout;
  final int day;
  final double minPayment;
  final DateTime expectedPayoffDate;
  final String status;
  final bool creationCompletion;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int v; // Mapped from '__v' (Mongoose version key)

  Debt({
    required this.id,
    required this.userId,
    required this.name,
    required this.owed,
    required this.interestRate,
    required this.balance,
    required this.preferrablePayout,
    required this.day,
    required this.minPayment,
    required this.expectedPayoffDate,
    required this.status,
    required this.creationCompletion,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  bool get isActive => status == 'Active';

  factory Debt.fromJson(Map<String, dynamic> json) {
    return Debt(
      id: json['_id'] as String,
      userId: json['UserId'] as String,
      name: json['Name'] as String,
      // Using (json['x'] as num).toDouble() is safer for API numbers
      // because 1000 usually comes as int, but 1000.50 comes as double.
      owed: (json['Owed'] as num).toDouble(),
      interestRate: (json['interestRate'] as num).toDouble(),
      balance: (json['Balance'] as num).toDouble(),
      preferrablePayout: json['PreferrablePayout'] as String,
      day: json['Day'] as int,
      minPayment: (json['minPayment'] as num).toDouble(),
      // Parsing the date strings to DateTime objects
      expectedPayoffDate: DateTime.parse(json['expectedPayoffDate']),
      status: json['Status'] as String,
      creationCompletion: json['CreationCompletion'] as bool,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      v: json['__v'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'UserId': userId,
      'Name': name,
      'Owed': owed,
      'interestRate': interestRate,
      'Balance': balance,
      'PreferrablePayout': preferrablePayout,
      'Day': day,
      'minPayment': minPayment,
      // Formatting dates back to string for the API
      'expectedPayoffDate': expectedPayoffDate.toIso8601String(),
      'Status': status,
      'CreationCompletion': creationCompletion,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      '__v': v,
    };
  }
}

class DebtCreationResponse {
  final String debtId;
  final String message;
  final bool success;

  const DebtCreationResponse({
    required this.debtId,
    required this.message,
    required this.success,
  });

  factory DebtCreationResponse.fromJson(Map<String, dynamic> json) {
    return DebtCreationResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? 'Unknown response message',
      debtId: json['data']?['debtid'] as String? ?? '',
    );
  }
}

class DebtPaymentData {
  final String amount;
  final String fee;
  final String currency;
  final String status;
  final String reference;
  final String message;
  final String customerEmail;

  const DebtPaymentData({
    required this.amount,
    required this.fee,
    required this.currency,
    required this.status,
    required this.reference,
    required this.message,
    required this.customerEmail,
  });

  factory DebtPaymentData.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;

    return DebtPaymentData(
      amount: data?['amount'] as String? ?? '0.00',
      fee: data?['fee'] as String? ?? '0.00',
      currency: data?['currency'] as String? ?? 'N/A',
      status: data?['status'] as String? ?? 'unknown',
      reference: data?['reference'] as String? ?? 'N/A',
      message:
          data?['message'] as String? ??
          'Payment processing details unavailable',
      customerEmail: data?['customer']?['email'] as String? ?? 'N/A',
    );
  }
}

class DebtRequestModel {
  final String name;
  final num amountOwed;
  final num interestRate;
  final String paymentFrequency;
  final num minPayment;
  final DateTime expectedPayoffDate;
  final String repaymentDay;

  DebtRequestModel({
    required this.name,
    required this.amountOwed,
    required this.interestRate,
    required this.paymentFrequency,
    required this.minPayment,
    required this.expectedPayoffDate,
    required this.repaymentDay,
  });

  // Method to convert the instance back to a Map (matching your specific keys)
  Map<String, dynamic> toJson() {
    return {
      "Name": name,
      "Owed": amountOwed,
      "interestRate": interestRate,
      "PreferrablePayout": paymentFrequency,
      "minPayment": minPayment,
      "expectedPayoffDate": expectedPayoffDate.toIso8601String().split('T')[0],
      "Day": repaymentDay,
    };
  }
}

class DebtCreationStep2Request {
  final String debtId;
  final String bankCode;
  final String accNumber;

  const DebtCreationStep2Request({
    required this.debtId,
    required this.bankCode,
    required this.accNumber,
  });

  Map<String, dynamic> toJson() {
    return {"debtid": debtId, "code": bankCode, "accNumber": accNumber};
  }
}
