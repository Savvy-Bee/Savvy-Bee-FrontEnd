// Main Response Model
import '../../../../core/widgets/charts/custom_line_chart.dart';

class DashboardDataResponse {
  final bool success;
  final String message;
  final DashboardData data;

  DashboardDataResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory DashboardDataResponse.fromJson(Map<String, dynamic> json) {
    return DashboardDataResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: DashboardData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'message': message, 'data': data.toJson()};
  }
}

// Financial Data Model
class DashboardData {
  final bool isMultiAccount;
  final List<BankAccount> accounts;
  final NetAnalysis netAnalysis;
  final Widgets widgets;
  final List<SavingsGoal> savings;
  final List<Debt> debts;

  // Get aggregated account data (amount, timestamp) for chart usage
  List<ChartDataPoint> getAggregatedAccountData() {
    final List<ChartDataPoint> data = [];

    for (final account in accounts) {
      for (final transaction in account.history12Months) {
        data.add(ChartDataPoint(
          value: transaction.amount,
          timestamp: transaction.date,
        ));
      }
    }

    // Sort by timestamp ascending
    data.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    return data;
  }

  DashboardData({
    required this.isMultiAccount,
    required this.accounts,
    required this.netAnalysis,
    required this.widgets,
    required this.savings,
    required this.debts,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      isMultiAccount: json['isMultiAccount'] ?? false,
      accounts:
          (json['accounts'] as List?)
              ?.map((account) => BankAccount.fromJson(account))
              .toList() ??
          [],
      netAnalysis: NetAnalysis.fromJson(json['netAnalysis'] ?? {}),
      widgets: Widgets.fromJson(json['Widgets'] ?? {}),
      savings:
          (json['savings'] as List?)
              ?.map((saving) => SavingsGoal.fromJson(saving))
              .toList() ??
          [],
      debts:
          (json['Debt'] as List?)
              ?.map((debt) => Debt.fromJson(debt))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isMultiAccount': isMultiAccount,
      'accounts': accounts.map((account) => account.toJson()).toList(),
      'netAnalysis': netAnalysis.toJson(),
      'Widgets': widgets.toJson(),
      'savings': savings.map((saving) => saving.toJson()).toList(),
      'Debt': debts.map((debt) => debt.toJson()).toList(),
    };
  }
}

// Bank Account Model
class BankAccount {
  final String accountId;
  final String monoId;
  final AccountDetails details;
  final List<String> availableData;
  final List<Transaction> history12Months;
  final String? statementPDF;

  BankAccount({
    required this.accountId,
    required this.monoId,
    required this.details,
    required this.availableData,
    required this.history12Months,
    this.statementPDF,
  });

  factory BankAccount.fromJson(Map<String, dynamic> json) {
    return BankAccount(
      accountId: json['accountId'] ?? '',
      monoId: json['monoId'] ?? '',
      details: AccountDetails.fromJson(json['details'] ?? {}),
      availableData: (json['availableData'] as List?)?.cast<String>() ?? [],
      history12Months:
          (json['history12Months'] as List?)
              ?.map((transaction) => Transaction.fromJson(transaction))
              .toList() ??
          [],
      statementPDF: json['statementPDF'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accountId': accountId,
      'monoId': monoId,
      'details': details.toJson(),
      'availableData': availableData,
      'history12Months': history12Months
          .map((transaction) => transaction.toJson())
          .toList(),
      'statementPDF': statementPDF,
    };
  }
}

// Account Details Model
class AccountDetails {
  final String id;
  final String name;
  final String accountNumber;
  final String currency;
  final double balance;
  final String type;
  final String bvn;
  final Institution institution;

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

  factory AccountDetails.fromJson(Map<String, dynamic> json) {
    return AccountDetails(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      accountNumber: json['account_number'] ?? '',
      currency: json['currency'] ?? '',
      balance: (json['balance'] ?? 0).toDouble(),
      type: json['type'] ?? '',
      bvn: json['bvn'] ?? '',
      institution: Institution.fromJson(json['institution'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
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
}

// Institution Model
class Institution {
  final String name;
  final String bankCode;
  final String type;

  Institution({required this.name, required this.bankCode, required this.type});

  factory Institution.fromJson(Map<String, dynamic> json) {
    return Institution(
      name: json['name'] ?? '',
      bankCode: json['bank_code'] ?? '',
      type: json['type'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'bank_code': bankCode, 'type': type};
  }
}

// Transaction Model
class Transaction {
  final String id;
  final String narration;
  final double amount;
  final String type;
  final String? category;
  final double balance;
  final DateTime date;

  Transaction({
    required this.id,
    required this.narration,
    required this.amount,
    required this.type,
    this.category,
    required this.balance,
    required this.date,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] ?? '',
      narration: json['narration'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      type: json['type'] ?? '',
      category: json['category'],
      balance: (json['balance'] ?? 0).toDouble(),
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
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

// Net Analysis Model
class NetAnalysis {
  final double totalBalance;
  final int accountCount;
  final double totalIncome;
  final double totalExpenses;

  NetAnalysis({
    required this.totalBalance,
    required this.accountCount,
    required this.totalIncome,
    required this.totalExpenses,
  });

  factory NetAnalysis.fromJson(Map<String, dynamic> json) {
    return NetAnalysis(
      totalBalance: (json['totalBalance'] ?? 0).toDouble(),
      accountCount: json['accountCount'] ?? 0,
      totalIncome: (json['totalIncome'] ?? 0).toDouble(),
      totalExpenses: (json['totalExpenses'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalBalance': totalBalance,
      'accountCount': accountCount,
      'totalIncome': totalIncome,
      'totalExpenses': totalExpenses,
    };
  }
}

// Widgets Model
class Widgets {
  final SpendCategoryBreakdown spendCategoryBreakdown;
  final FinancialHealth financialHealth;
  final String savingTargetInsight;

  Widgets({
    required this.spendCategoryBreakdown,
    required this.financialHealth,
    required this.savingTargetInsight,
  });

  factory Widgets.fromJson(Map<String, dynamic> json) {
    return Widgets(
      spendCategoryBreakdown: SpendCategoryBreakdown.fromJson(
        json['SpendCategoryBreakdown'] ?? {},
      ),
      financialHealth: FinancialHealth.fromJson(json['FinancialHealth'] ?? {}),
      savingTargetInsight: json['SavingTargetInsight'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'SpendCategoryBreakdown': spendCategoryBreakdown.toJson(),
      'FinancialHealth': financialHealth.toJson(),
      'SavingTargetInsight': savingTargetInsight,
    };
  }
}

// Spend Category Breakdown Model
class SpendCategoryBreakdown {
  final List<CategoryAmount> categories;
  final String insight;
  final String nextAction;
  final String alerts;

  SpendCategoryBreakdown({
    required this.categories,
    required this.insight,
    required this.nextAction,
    required this.alerts,
  });

  factory SpendCategoryBreakdown.fromJson(Map<String, dynamic> json) {
    return SpendCategoryBreakdown(
      categories:
          (json['categories'] as List?)
              ?.map((category) => CategoryAmount.fromJson(category))
              .toList() ??
          [],
      insight: json['insight'] ?? '',
      nextAction: json['nextAction'] ?? '',
      alerts: json['alerts'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categories': categories.map((category) => category.toJson()).toList(),
      'insight': insight,
      'nextAction': nextAction,
      'alerts': alerts,
    };
  }
}

// Category Amount Model
class CategoryAmount {
  final String name;
  final double amount;

  CategoryAmount({required this.name, required this.amount});

  factory CategoryAmount.fromJson(Map<String, dynamic> json) {
    return CategoryAmount(
      name: json['name'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'amount': amount};
  }
}

// Financial Health Model
class FinancialHealth {
  final int rate;
  final String insight;

  FinancialHealth({required this.rate, required this.insight});

  factory FinancialHealth.fromJson(Map<String, dynamic> json) {
    return FinancialHealth(
      rate: json['rate'] ?? 0,
      insight: json['insight'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'rate': rate, 'insight': insight};
  }
}

// Savings Goal Model
class SavingsGoal {
  final String id;
  final String userId;
  final String goalName;
  final String goalType;
  final double balance;
  final double targetAmount;
  final DateTime endDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  SavingsGoal({
    required this.id,
    required this.userId,
    required this.goalName,
    required this.goalType,
    required this.balance,
    required this.targetAmount,
    required this.endDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SavingsGoal.fromJson(Map<String, dynamic> json) {
    return SavingsGoal(
      id: json['_id'] ?? '',
      userId: json['UserID'] ?? '',
      goalName: json['GoalName'] ?? '',
      goalType: json['GoalType'] ?? '',
      balance: (json['Balance'] ?? 0).toDouble(),
      targetAmount: (json['TargetAmount'] ?? 0).toDouble(),
      endDate: DateTime.parse(
        json['EndDate'] ?? DateTime.now().toIso8601String(),
      ),
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'UserID': userId,
      'GoalName': goalName,
      'GoalType': goalType,
      'Balance': balance,
      'TargetAmount': targetAmount,
      'EndDate': endDate.toIso8601String().split('T')[0],
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Calculate progress percentage
  double get progressPercentage {
    if (targetAmount == 0) return 0;
    return (balance / targetAmount * 100).clamp(0, 100);
  }

  // Check if goal is completed
  bool get isCompleted => balance >= targetAmount;
}

// Debt Model
class Debt {
  final String id;
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
  });

  factory Debt.fromJson(Map<String, dynamic> json) {
    return Debt(
      id: json['_id'] ?? '',
      userId: json['UserID'] ?? '',
      name: json['Name'] ?? '',
      owed: (json['Owed'] ?? 0).toDouble(),
      interestRate: (json['interestRate'] ?? 0).toDouble(),
      balance: (json['Balance'] ?? 0).toDouble(),
      preferrablePayout: json['PreferrablePayout'] ?? '',
      day: json['Day'] ?? 0,
      minPayment: (json['minPayment'] ?? 0).toDouble(),
      expectedPayoffDate: DateTime.parse(
        json['expectedPayoffDate'] ?? DateTime.now().toIso8601String(),
      ),
      status: json['Status'] ?? '',
      creationCompletion: json['CreationCompletion'] ?? false,
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'UserID': userId,
      'Name': name,
      'Owed': owed,
      'interestRate': interestRate,
      'Balance': balance,
      'PreferrablePayout': preferrablePayout,
      'Day': day,
      'minPayment': minPayment,
      'expectedPayoffDate': expectedPayoffDate.toIso8601String().split('T')[0],
      'Status': status,
      'CreationCompletion': creationCompletion,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Calculate remaining debt
  double get remainingDebt => owed - balance;

  // Check if debt is paid off
  bool get isPaidOff => balance >= owed;

  // Calculate payoff progress percentage
  double get payoffPercentage {
    if (owed == 0) return 0;
    return (balance / owed * 100).clamp(0, 100);
  }
}
