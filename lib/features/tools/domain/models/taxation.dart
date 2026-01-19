class TaxationHomeResponse {
  final bool success;
  final String message;
  final TaxationHomeData data;

  TaxationHomeResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory TaxationHomeResponse.fromJson(Map<String, dynamic> json) {
    return TaxationHomeResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: TaxationHomeData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data.toJson(),
    };
  }
}

class TaxationHomeData {
  final int totalEarnings;
  final TaxData tax;
  final List<TaxHistoryItem> history;

  TaxationHomeData({
    required this.totalEarnings,
    required this.tax,
    required this.history,
  });

  factory TaxationHomeData.fromJson(Map<String, dynamic> json) {
    return TaxationHomeData(
      totalEarnings: json['TotalEarnings'] as int,
      tax: TaxData.fromJson(json['Tax'] as Map<String, dynamic>),
      history:
          (json['history'] as List<dynamic>?)
              ?.map((item) => TaxHistoryItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'TotalEarnings': totalEarnings,
      'Tax': tax.toJson(),
      'history': history.map((item) => item.toJson()).toList(),
    };
  }
}

class TaxData {
  final int yearly;
  final double monthly;
  final int rate;
  final int? exemption;

  TaxData({
    required this.yearly,
    required this.monthly,
    required this.rate,
    this.exemption,
  });

  factory TaxData.fromJson(Map<String, dynamic> json) {
    return TaxData(
      yearly: json['yearly'] as int,
      monthly: (json['monthly'] as num).toDouble(),
      rate: json['Rate'] as int,
      exemption: json['Exemption'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'yearly': yearly,
      'monthly': monthly,
      'Rate': rate,
      if (exemption != null) 'Exemption': exemption,
    };
  }
}

class TaxHistoryItem {
  final String id;
  final String narration;
  final int amount;
  final String type;
  final String? category;
  final int balance;
  final DateTime date;

  TaxHistoryItem({
    required this.id,
    required this.narration,
    required this.amount,
    required this.type,
    this.category,
    required this.balance,
    required this.date,
  });

  factory TaxHistoryItem.fromJson(Map<String, dynamic> json) {
    return TaxHistoryItem(
      id: json['id'] as String,
      narration: json['narration'] as String,
      amount: json['amount'] as int,
      type: json['type'] as String,
      category: json['category'] as String?,
      balance: json['balance'] as int,
      date: DateTime.parse(json['date'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'narration': narration,
      'amount': amount,
      'type': type,
      'category': category,
      'balance': balance,
      'date': date.toIso8601String(),
    };
  }
}

class TaxCalculatorResponse {
  final bool success;
  final String message;
  final TaxCalculatorData data;

  TaxCalculatorResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory TaxCalculatorResponse.fromJson(Map<String, dynamic> json) {
    return TaxCalculatorResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: TaxCalculatorData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data.toJson(),
    };
  }
}

class TaxCalculatorData {
  final int totalEarnings;
  final TaxData tax;

  TaxCalculatorData({
    required this.totalEarnings,
    required this.tax,
  });

  factory TaxCalculatorData.fromJson(Map<String, dynamic> json) {
    return TaxCalculatorData(
      totalEarnings: json['TotalEarnings'] as int,
      tax: TaxData.fromJson(json['Tax'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'TotalEarnings': totalEarnings,
      'Tax': tax.toJson(),
    };
  }
}