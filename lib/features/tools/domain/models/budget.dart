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
      // ✅ API returns 'id' as number, convert to string
      id: (map['id'] ?? map['_id'] ?? '').toString(),

      // ✅ UserID might be missing
      userId: (map['UserID'] ?? '').toString(),

      budgetName: map['BudgetName']?.toString() ?? '',

      // ✅ Handle both int and double
      balance: num.tryParse(map['Balance']?.toString() ?? '0') ?? 0,
      targetAmountMonthly:
          num.tryParse(map['TargetAmountMonthly']?.toString() ?? '0') ?? 0,

      // ✅ Safe date parsing
      createdAt:
          DateTime.tryParse(map['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(map['updatedAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  factory Budget.fromJson(String source) => Budget.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Budget(id: $id, budgetName: $budgetName, balance: $balance, targetAmountMonthly: $targetAmountMonthly)';
  }
}

class BudgetHomeData {
  final num totalEarnings;
  final List<Budget> budgets;

  BudgetHomeData({required this.totalEarnings, required this.budgets});

  factory BudgetHomeData.fromMap(Map<String, dynamic> map) {
    return BudgetHomeData(
      totalEarnings: num.tryParse(map['TotalEarnings']?.toString() ?? '0') ?? 0,

      budgets: (map['Budgets'] as List? ?? [])
          .map((x) {
            try {
              return Budget.fromMap(x as Map<String, dynamic>);
            } catch (e) {
              print('⚠️ Error parsing budget item: $e');
              return null;
            }
          })
          .whereType<Budget>() // Filter out nulls
          .toList(),
    );
  }

  factory BudgetHomeData.fromJson(String source) =>
      BudgetHomeData.fromMap(json.decode(source));

  @override
  String toString() =>
      'BudgetHomeData(totalEarnings: $totalEarnings, budgets: ${budgets.length} items)';
}
