class DashboardData {
  final AccountDetails details;
  final List<String> availabledata;
  final dynamic history12Months;
  final DashboardWidgets widgets;
  final List<dynamic> savings;
  final List<dynamic> debt;

  DashboardData({
    required this.details,
    required this.availabledata,
    this.history12Months,
    required this.widgets,
    required this.savings,
    required this.debt,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) => DashboardData(
    details: AccountDetails.fromJson(json['details']),
    availabledata: List<String>.from(json['availabledata']),
    history12Months: json['history12Months'],
    widgets: DashboardWidgets.fromJson(json['Widgets']),
    savings: List<dynamic>.from(json['savings']),
    debt: List<dynamic>.from(json['Debt']),
  );

  Map<String, dynamic> toJson() => {
    'details': details.toJson(),
    'availabledata': availabledata,
    'history12Months': history12Months,
    'Widgets': widgets.toJson(),
    'savings': savings,
    'Debt': debt,
  };
}

class AccountDetails {
  final String id;
  final String name;
  final String accountNumber;
  final String currency;
  final int balance;
  final String type;
  final String bvn;
  final InstitutionInfo institution;

  AccountDetails({
    required this.id,
    required this.name,
    required this.accountNumber,
    required this.currency,
    required this.balance,
    required this.type,
    required this.bvn,
    required this.institution,
  });

  factory AccountDetails.fromJson(Map<String, dynamic> json) => AccountDetails(
    id: json['id'],
    name: json['name'],
    accountNumber: json['account_number'],
    currency: json['currency'],
    balance: json['balance'],
    type: json['type'],
    bvn: json['bvn'],
    institution: InstitutionInfo.fromJson(json['institution']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'account_number': accountNumber,
    'currency': currency,
    'balance': balance,
    'type': type,
    'bvn': bvn,
    'institution': institution.toJson(),
  };
}

class InstitutionInfo {
  final String? name;
  final String? type;
  final String? bankCode;

  InstitutionInfo({this.name, this.type, this.bankCode});

  factory InstitutionInfo.fromJson(Map<String, dynamic> json) => InstitutionInfo(
    name: json['name'],
    type: json['type'],
    bankCode: json['code'] ?? json['bank_code'],
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'type': type,
    'bank_code': bankCode,
  };
}

class DashboardWidgets {
  final SpendCategoryBreakdown spendCategoryBreakdown;
  final FinancialHealth financialHealth;
  final String savingTargetInsight;

  DashboardWidgets({
    required this.spendCategoryBreakdown,
    required this.financialHealth,
    required this.savingTargetInsight,
  });

  factory DashboardWidgets.fromJson(Map<String, dynamic> json) => DashboardWidgets(
    spendCategoryBreakdown: SpendCategoryBreakdown.fromJson(
      json['SpendCategoryBreakdown'],
    ),
    financialHealth: FinancialHealth.fromJson(json['FinancialHealth']),
    savingTargetInsight: json['SavingTargetInsight'],
  );

  Map<String, dynamic> toJson() => {
    'SpendCategoryBreakdown': spendCategoryBreakdown.toJson(),
    'FinancialHealth': financialHealth.toJson(),
    'SavingTargetInsight': savingTargetInsight,
  };
}

class SpendCategoryBreakdown {
  final List<Category> categories;
  final String insight;
  final String nextAction;
  final String alerts;

  SpendCategoryBreakdown({
    required this.categories,
    required this.insight,
    required this.nextAction,
    required this.alerts,
  });

  factory SpendCategoryBreakdown.fromJson(Map<String, dynamic> json) =>
      SpendCategoryBreakdown(
        categories: List<Category>.from(
          json['categories'].map((x) => Category.fromJson(x)),
        ),
        insight: json['insight'],
        nextAction: json['nextAction'],
        alerts: json['alerts'],
      );

  Map<String, dynamic> toJson() => {
    'categories': List<dynamic>.from(categories.map((x) => x.toJson())),
    'insight': insight,
    'nextAction': nextAction,
    'alerts': alerts,
  };
}

class Category {
  final String name;
  final double amount;

  Category({required this.name, required this.amount});

  factory Category.fromJson(Map<String, dynamic> json) =>
      Category(name: json['name'], amount: json['amount'].toDouble());

  Map<String, dynamic> toJson() => {'name': name, 'amount': amount};
}

class FinancialHealth {
  final int rate;
  final String insight;

  FinancialHealth({required this.rate, required this.insight});

  factory FinancialHealth.fromJson(Map<String, dynamic> json) =>
      FinancialHealth(rate: json['rate'], insight: json['insight']);

  Map<String, dynamic> toJson() => {'rate': rate, 'insight': insight};
}
