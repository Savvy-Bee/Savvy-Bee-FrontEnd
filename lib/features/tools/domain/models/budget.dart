import 'dart:convert';

class Budget {
  final String id;
  final String userId;
  final String budgetName;
  final num balance;
  final num targetAmountMonthly;
  final DateTime createdAt;
  final DateTime updatedAt;

  Budget({
    required this.id,
    required this.userId,
    required this.budgetName,
    required this.balance,
    required this.targetAmountMonthly,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['_id'] ?? '',
      userId: map['UserID'] ?? '',
      budgetName: map['BudgetName'] ?? '',
      balance: map['Balance'] ?? 0,
      targetAmountMonthly: map['TargetAmountMonthly'] ?? 0,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  factory Budget.fromJson(String source) =>
      Budget.fromMap(json.decode(source));

  @override
  String toString() {
    return 'BudgetModel(id: $id, budgetName: $budgetName, balance: $balance, targetAmountMonthly: $targetAmountMonthly)';
  }
}

class BudgetHomeData {
  final num totalEarnings;
  final List<Budget> budgets;

  BudgetHomeData({required this.totalEarnings, required this.budgets});

  factory BudgetHomeData.fromMap(Map<String, dynamic> map) {
    return BudgetHomeData(
      totalEarnings: map['TotalEarnings'] ?? 0,
      budgets: List<Budget>.from(
        (map['Budgets'] as List? ?? []).map((x) => Budget.fromMap(x)),
      ),
    );
  }

  factory BudgetHomeData.fromJson(String source) =>
      BudgetHomeData.fromMap(json.decode(source));

  @override
  String toString() =>
      'BudgetHomeDataModel(totalEarnings: $totalEarnings, budgets: $budgets)';
}
