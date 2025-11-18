class Debt {
  final String id;
  final String name;
  final double owedAmount;
  final double balance; // Amount paid/remaining balance from API
  final String expectedPayoffDate;
  final double interestRate;
  final String preferredPayout;
  final int payoutDay;
  final double minimumPayment;
  final String? status; // Added for filtering 'active' vs 'paid_off'

  const Debt({
    required this.id,
    required this.name,
    required this.owedAmount,
    required this.balance,
    required this.expectedPayoffDate,
    required this.interestRate,
    required this.preferredPayout,
    required this.payoutDay,
    required this.minimumPayment,
    this.status,
  });

  factory Debt.fromJson(Map<String, dynamic> json) {
    // Note: The field names below are derived from a mix of your Step 1 request
    // fields and the data structure implied by the "Home Data" response.
    return Debt(
      id: json['_id'] as String? ?? json['debtid'] as String,
      name:
          json['GoalName'] as String? ??
          json['Name'] as String? ??
          'Unnamed Debt',

      // TargetAmount/Owed are usually the total debt amount
      owedAmount: (json['TargetAmount'] as num? ?? json['Owed'] as num? ?? 0.0)
          .toDouble(),

      // Balance is usually the current amount paid or balance remaining
      balance:
          (json['Balance'] as num? ?? json['amountRemaining'] as num? ?? 0.0)
              .toDouble(),

      expectedPayoffDate:
          json['EndDate'] as String? ??
          json['expectedPayoffDate'] as String? ??
          'N/A',
      interestRate: (json['interestRate'] as num? ?? 0.0).toDouble(),
      preferredPayout: json['PreferrablePayout'] as String? ?? 'N/A',
      payoutDay: (json['Day'] as int? ?? 1),
      minimumPayment: (json['minPayment'] as num? ?? 0.0).toDouble(),
      status:
          json['status'] as String? ??
          'active', // Default to active if status is missing
    );
  }

  // Helper function to calculate days left (requires proper Date parsing, kept simple here)
  int get daysLeft {
    try {
      final targetDate = DateTime.parse(expectedPayoffDate);
      return targetDate.difference(DateTime.now()).inDays.clamp(0, 9999);
    } catch (e) {
      return 0;
    }
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
