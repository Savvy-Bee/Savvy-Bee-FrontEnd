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
      data:
          (json['data'] as List<dynamic>?)
              ?.map((item) => Debt.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
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
  final String id;
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
  final int v;

  Debt({
    required this.id,
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

  /// How much has been paid off so far
  double get paid => owed - balance;

  /// Progress as a fraction 0.0 – 1.0
  double get progress => owed > 0 ? (paid / owed).clamp(0.0, 1.0) : 0.0;

  factory Debt.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic value, {double fallback = 0.0}) {
      if (value == null) return fallback;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? fallback;
      return fallback;
    }

    int toInt(dynamic value, {int fallback = 0}) {
      if (value == null) return fallback;
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? fallback;
      return fallback;
    }

    return Debt(
      id: json['id']?.toString() ?? '',
      name: json['Name'] as String? ?? 'Unnamed Debt',
      owed: toDouble(json['Owed']),
      interestRate: toDouble(json['interestRate']),
      balance: toDouble(json['Balance']),
      minPayment: toDouble(json['minPayment']),
      preferrablePayout: json['PreferrablePayout'] as String? ?? 'Monthly',
      day: toInt(json['Day'], fallback: 1),
      expectedPayoffDate: json['expectedPayoffDate'] != null
          ? DateTime.tryParse(json['expectedPayoffDate'] as String? ?? '') ??
              DateTime.now()
          : DateTime.now(),
      status: json['Status'] as String? ?? 'Unknown',
      creationCompletion: json['CreationCompletion'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String? ?? '') ??
              DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
              DateTime.now()
          : DateTime.now(),
      v: toInt(json['__v']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'Name': name,
      'Owed': owed,
      'interestRate': interestRate,
      'Balance': balance,
      'PreferrablePayout': preferrablePayout,
      'Day': day,
      'minPayment': minPayment,
      'expectedPayoffDate': expectedPayoffDate.toIso8601String(),
      'Status': status,
      'CreationCompletion': creationCompletion,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      '__v': v,
    };
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Manual creation (POST /tools/debt/create/manual)
// Fields: Name, Owed, minPayment, expectedPayoffDate, DebtType
// ─────────────────────────────────────────────────────────────────────────────

class ManualDebtRequestModel {
  final String name;
  final num owed;
  final num minPayment;
  final DateTime expectedPayoffDate;
  final String debtType;

  const ManualDebtRequestModel({
    required this.name,
    required this.owed,
    required this.minPayment,
    required this.expectedPayoffDate,
    required this.debtType,
  });

  Map<String, dynamic> toJson() => {
        'Name': name,
        'Owed': owed,
        'minPayment': minPayment,
        'expectedPayoffDate':
            expectedPayoffDate.toIso8601String().split('T')[0],
        'DebtType': debtType,
      };
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared response for both create-manual and list operations
// ─────────────────────────────────────────────────────────────────────────────

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
      debtId: (json['data']?['debtid']?.toString() ?? ''),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Manual repayment (PATCH /tools/debt/update/manual/:id)
// Field: amount
// ─────────────────────────────────────────────────────────────────────────────

// (no additional model needed — amount is passed as a plain String to the
// repository method manualFundDebt(debtId, amount))

// ─────────────────────────────────────────────────────────────────────────────
// Legacy models kept to avoid breaking other parts of the codebase
// ─────────────────────────────────────────────────────────────────────────────

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
      message: data?['message'] as String? ?? 'Payment processing details unavailable',
      customerEmail: data?['customer']?['email'] as String? ?? 'N/A',
    );
  }
}

/// Legacy step-1 request model — kept so existing call sites don't break.
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

  Map<String, dynamic> toJson() => {
        'Name': name,
        'Owed': amountOwed,
        'interestRate': interestRate,
        'PreferrablePayout': paymentFrequency,
        'minPayment': minPayment,
        'expectedPayoffDate': expectedPayoffDate.toIso8601String().split('T')[0],
        'Day': repaymentDay,
      };
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

  Map<String, dynamic> toJson() => {
        'debtid': debtId,
        'code': bankCode,
        'accNumber': accNumber,
      };
}



// class DebtListResponse {
//   final bool success;
//   final String message;
//   final List<Debt> data;

//   DebtListResponse({
//     required this.success,
//     required this.message,
//     required this.data,
//   });

//   factory DebtListResponse.fromJson(Map<String, dynamic> json) {
//     return DebtListResponse(
//       success: json['success'] as bool,
//       message: json['message'] as String,
//       data:
//           (json['data'] as List<dynamic>?)
//               ?.map((item) => Debt.fromJson(item as Map<String, dynamic>))
//               .toList() ??
//           [],
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'success': success,
//       'message': message,
//       'data': data.map((item) => item.toJson()).toList(),
//     };
//   }
// }

// class Debt {
//   final String id;
//   final String name;
//   final double owed;
//   final double interestRate;
//   final double balance;
//   final String preferrablePayout;
//   final int day;
//   final double minPayment;
//   final DateTime expectedPayoffDate;
//   final String status;
//   final bool creationCompletion;
//   final DateTime createdAt;
//   final DateTime updatedAt;
//   final int v;

//   Debt({
//     required this.id,
//     required this.name,
//     required this.owed,
//     required this.interestRate,
//     required this.balance,
//     required this.preferrablePayout,
//     required this.day,
//     required this.minPayment,
//     required this.expectedPayoffDate,
//     required this.status,
//     required this.creationCompletion,
//     required this.createdAt,
//     required this.updatedAt,
//     required this.v,
//   });

//   bool get isActive => status == 'Active';

//   factory Debt.fromJson(Map<String, dynamic> json) {
//     // Helper to safely convert to double (handles num, String, null)
//     double toDouble(dynamic value, {double fallback = 0.0}) {
//       if (value == null) return fallback;
//       if (value is num) return value.toDouble();
//       if (value is String) return double.tryParse(value) ?? fallback;
//       return fallback;
//     }

//     // Helper for int
//     int toInt(dynamic value, {int fallback = 0}) {
//       if (value == null) return fallback;
//       if (value is int) return value;
//       if (value is num) return value.toInt();
//       if (value is String) return int.tryParse(value) ?? fallback;
//       return fallback;
//     }

//     return Debt(
//       id: json['id']?.toString() ?? '', // handles int or string

//       name: json['Name'] as String? ?? 'Unnamed Debt',

//       owed: toDouble(json['Owed']),
//       interestRate: toDouble(json['interestRate']),
//       balance: toDouble(json['Balance']),
//       minPayment: toDouble(json['minPayment']),

//       preferrablePayout: json['PreferrablePayout'] as String? ?? 'Monthly',

//       day: toInt(json['Day'], fallback: 1),

//       expectedPayoffDate: json['expectedPayoffDate'] != null
//           ? DateTime.tryParse(json['expectedPayoffDate'] as String? ?? '') ??
//                 DateTime.now()
//           : DateTime.now(),

//       status: json['Status'] as String? ?? 'Unknown',

//       creationCompletion: json['CreationCompletion'] as bool? ?? false,

//       createdAt: json['createdAt'] != null
//           ? DateTime.tryParse(json['createdAt'] as String? ?? '') ??
//                 DateTime.now()
//           : DateTime.now(),

//       updatedAt: json['updatedAt'] != null
//           ? DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
//                 DateTime.now()
//           : DateTime.now(),

//       v: toInt(json['__v']),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'Name': name,
//       'Owed': owed,
//       'interestRate': interestRate,
//       'Balance': balance,
//       'PreferrablePayout': preferrablePayout,
//       'Day': day,
//       'minPayment': minPayment,
//       'expectedPayoffDate': expectedPayoffDate.toIso8601String(),
//       'Status': status,
//       'CreationCompletion': creationCompletion,
//       'createdAt': createdAt.toIso8601String(),
//       'updatedAt': updatedAt.toIso8601String(),
//       '__v': v,
//     };
//   }
// }

// class DebtCreationResponse {
//   final String debtId;
//   final String message;
//   final bool success;

//   const DebtCreationResponse({
//     required this.debtId,
//     required this.message,
//     required this.success,
//   });

//   factory DebtCreationResponse.fromJson(Map<String, dynamic> json) {
//     return DebtCreationResponse(
//       success: json['success'] as bool? ?? false,
//       message: json['message'] as String? ?? 'Unknown response message',
//       // Fix: Handle both int and String for debtid
//       debtId: (json['data']?['debtid']?.toString() ?? ''),
//     );
//   }
// }

// class DebtPaymentData {
//   final String amount;
//   final String fee;
//   final String currency;
//   final String status;
//   final String reference;
//   final String message;
//   final String customerEmail;

//   const DebtPaymentData({
//     required this.amount,
//     required this.fee,
//     required this.currency,
//     required this.status,
//     required this.reference,
//     required this.message,
//     required this.customerEmail,
//   });

//   factory DebtPaymentData.fromJson(Map<String, dynamic> json) {
//     final data = json['data'] as Map<String, dynamic>?;

//     return DebtPaymentData(
//       amount: data?['amount'] as String? ?? '0.00',
//       fee: data?['fee'] as String? ?? '0.00',
//       currency: data?['currency'] as String? ?? 'N/A',
//       status: data?['status'] as String? ?? 'unknown',
//       reference: data?['reference'] as String? ?? 'N/A',
//       message:
//           data?['message'] as String? ??
//           'Payment processing details unavailable',
//       customerEmail: data?['customer']?['email'] as String? ?? 'N/A',
//     );
//   }
// }

// class DebtRequestModel {
//   final String name;
//   final num amountOwed;
//   final num interestRate;
//   final String paymentFrequency;
//   final num minPayment;
//   final DateTime expectedPayoffDate;
//   final String repaymentDay;

//   DebtRequestModel({
//     required this.name,
//     required this.amountOwed,
//     required this.interestRate,
//     required this.paymentFrequency,
//     required this.minPayment,
//     required this.expectedPayoffDate,
//     required this.repaymentDay,
//   });

//   // Method to convert the instance back to a Map (matching your specific keys)
//   Map<String, dynamic> toJson() {
//     return {
//       "Name": name,
//       "Owed": amountOwed,
//       "interestRate": interestRate,
//       "PreferrablePayout": paymentFrequency,
//       "minPayment": minPayment,
//       "expectedPayoffDate": expectedPayoffDate.toIso8601String().split('T')[0],
//       "Day": repaymentDay,
//     };
//   }
// }

// class DebtCreationStep2Request {
//   final String debtId;
//   final String bankCode;
//   final String accNumber;

//   const DebtCreationStep2Request({
//     required this.debtId,
//     required this.bankCode,
//     required this.accNumber,
//   });

//   Map<String, dynamic> toJson() {
//     return {"debtid": debtId, "code": bankCode, "accNumber": accNumber};
//   }
// }
