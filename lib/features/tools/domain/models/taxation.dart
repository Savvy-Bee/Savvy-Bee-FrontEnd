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
    return {'success': success, 'message': message, 'data': data.toJson()};
  }
}

class TaxationHomeData {
  final double totalEarnings;
  final TaxData tax;
  final List<TaxHistoryItem> history;

  TaxationHomeData({
    required this.totalEarnings,
    required this.tax,
    required this.history,
  });

  factory TaxationHomeData.fromJson(Map<String, dynamic> json) {
    return TaxationHomeData(
      totalEarnings: (json['TotalEarnings'] as num).toDouble(),
      tax: TaxData.fromJson(json['Tax'] as Map<String, dynamic>),
      history:
          (json['history'] as List<dynamic>?)
              ?.map(
                (item) => TaxHistoryItem.fromJson(item as Map<String, dynamic>),
              )
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
  final double yearly;
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
      yearly: (json['yearly'] as num).toDouble(),
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
  final double amount;
  final String type;
  final String? category;
  final double balance;
  final DateTime date;

  bool get isDebit => type.toLowerCase() == 'debit';
  bool get isCredit => type.toLowerCase() == 'credit';

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
      amount: (json['amount'] as num).toDouble(),
      type: json['type'] as String,
      category: json['category'] as String?,
      balance: (json['balance'] as num).toDouble(),
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
    return {'success': success, 'message': message, 'data': data.toJson()};
  }
}

class TaxCalculatorData {
  final int totalEarnings;
  final TaxData tax;

  TaxCalculatorData({required this.totalEarnings, required this.tax});

  factory TaxCalculatorData.fromJson(Map<String, dynamic> json) {
    return TaxCalculatorData(
      totalEarnings: json['TotalEarnings'] as int,
      tax: TaxData.fromJson(json['Tax'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {'TotalEarnings': totalEarnings, 'Tax': tax.toJson()};
  }
}

class TaxationStrategyResponse {
  final bool success;
  final String message;
  final TaxationStrategyData data;

  TaxationStrategyResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory TaxationStrategyResponse.fromJson(Map<String, dynamic> json) {
    return TaxationStrategyResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: TaxationStrategyData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'message': message, 'data': data.toJson()};
  }
}

class TaxationStrategyData {
  final double gains;
  final double losses;
  final int rate;
  final List<StrategyStatement> statements;
  final StrategyRecommendation recommendation;
  final int exemptions;

  TaxationStrategyData({
    required this.gains,
    required this.losses,
    required this.rate,
    required this.statements,
    required this.recommendation,
    required this.exemptions,
  });

  factory TaxationStrategyData.fromJson(Map<String, dynamic> json) {
    return TaxationStrategyData(
      gains: (json['Gains'] as num).toDouble(),
      losses: (json['Losses'] as num).toDouble(),
      rate: json['Rate'] as int,
      statements:
          (json['Statment'] as List<dynamic>)
              .map((item) => StrategyStatement.fromJson(item as Map<String, dynamic>))
              .toList(),
      recommendation:
          StrategyRecommendation.fromJson(
            json['Recommendation'] as Map<String, dynamic>,
          ),
      exemptions: json['Exemptions'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Gains': gains,
      'Losses': losses,
      'Rate': rate,
      'Statment': statements.map((item) => item.toJson()).toList(),
      'Recommendation': recommendation.toJson(),
      'Exemptions': exemptions,
    };
  }
}

class StrategyStatement {
  final String name;
  final String type;
  final double? cost;
  final double returnValue;
  final double? quantity;
  final String currency;
  final StrategyDetails details;

  StrategyStatement({
    required this.name,
    required this.type,
    this.cost,
    required this.returnValue,
    this.quantity,
    required this.currency,
    required this.details,
  });

  factory StrategyStatement.fromJson(Map<String, dynamic> json) {
    return StrategyStatement(
      name: json['name'] as String,
      type: json['type'] as String,
      cost: json['cost'] != null ? (json['cost'] as num).toDouble() : null,
      returnValue: (json['return'] as num).toDouble(),
      quantity: json['quantity'] != null ? (json['quantity'] as num).toDouble() : null,
      currency: json['currency'] as String,
      details: StrategyDetails.fromJson(json['details'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'cost': cost,
      'return': returnValue,
      'quantity': quantity,
      'currency': currency,
      'details': details.toJson(),
    };
  }
}

class StrategyDetails {
  final String? symbol;
  final double? price;
  final double currentBalance;

  StrategyDetails({
    this.symbol,
    this.price,
    required this.currentBalance,
  });

  factory StrategyDetails.fromJson(Map<String, dynamic> json) {
    return StrategyDetails(
      symbol: json['symbol'] as String?,
      price: json['price'] != null ? (json['price'] as num).toDouble() : null,
      currentBalance: (json['current_balance'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'price': price,
      'current_balance': currentBalance,
    };
  }
}

class StrategyRecommendation {
  final List<StrategyRecommendationItem> data;

  StrategyRecommendation({required this.data});

  factory StrategyRecommendation.fromJson(Map<String, dynamic> json) {
    return StrategyRecommendation(
      data:
          (json['Data'] as List<dynamic>)
              .map((item) => StrategyRecommendationItem.fromJson(item as Map<String, dynamic>))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'Data': data.map((item) => item.toJson()).toList()};
  }
}

class StrategyRecommendationItem {
  final String title;
  final String recommendation;
  final double amount;

  StrategyRecommendationItem({
    required this.title,
    required this.recommendation,
    required this.amount,
  });

  factory StrategyRecommendationItem.fromJson(Map<String, dynamic> json) {
    return StrategyRecommendationItem(
      title: json['Title'] as String,
      recommendation: json['Recommendation'] as String,
      amount: (json['Amount'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'Title': title, 'Recommendation': recommendation, 'Amount': amount};
  }
}
