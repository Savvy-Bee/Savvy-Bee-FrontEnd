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

  /// Helper to safely parse numbers and filter out NaN
  static num _parseNum(dynamic value) {
    if (value == null) return 0;
    
    // Handle numeric types directly
    if (value is num) {
      // CRITICAL: Check for NaN and Infinity
      if (value.isNaN || value.isInfinite) return 0;
      return value;
    }
    
    // Handle string values
    if (value is String) {
      // CRITICAL: Check for "NaN" string before parsing
      if (value.toUpperCase() == 'NAN' || 
          value.toUpperCase() == 'INFINITY' || 
          value.toUpperCase() == '-INFINITY') {
        return 0;
      }
      
      final parsed = num.tryParse(value);
      if (parsed == null) return 0;
      
      // Double-check parsed value isn't NaN
      if (parsed.isNaN || parsed.isInfinite) return 0;
      
      return parsed;
    }
    
    return 0;
  }

  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      // ✅ API returns 'id' as number, convert to string
      id: (map['id'] ?? map['_id'] ?? '').toString(),

      // ✅ UserID might be missing
      userId: (map['UserID'] ?? '').toString(),

      budgetName: map['BudgetName']?.toString() ?? '',

      // ✅ Handle both int and double AND filter NaN
      balance: _parseNum(map['Balance']),
      targetAmountMonthly: _parseNum(map['TargetAmountMonthly']),

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

  /// Helper to safely parse numbers and filter out NaN
  static num _parseNum(dynamic value) {
    if (value == null) return 0;
    
    if (value is num) {
      if (value.isNaN || value.isInfinite) return 0;
      return value;
    }
    
    if (value is String) {
      if (value.toUpperCase() == 'NAN' || 
          value.toUpperCase() == 'INFINITY' || 
          value.toUpperCase() == '-INFINITY') {
        return 0;
      }
      
      final parsed = num.tryParse(value);
      if (parsed == null) return 0;
      if (parsed.isNaN || parsed.isInfinite) return 0;
      return parsed;
    }
    
    return 0;
  }

  factory BudgetHomeData.fromMap(Map<String, dynamic> map) {
    return BudgetHomeData(
      totalEarnings: _parseNum(map['TotalEarnings']),

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



// import 'dart:convert';

// class Budget {
//   final String id;
//   final String userId;
//   final String budgetName;
//   final num balance;
//   final num targetAmountMonthly;
//   final DateTime createdAt;
//   final DateTime updatedAt;

//   Budget({
//     required this.id,
//     required this.userId,
//     required this.budgetName,
//     required this.balance,
//     required this.targetAmountMonthly,
//     required this.createdAt,
//     required this.updatedAt,
//   });

//   factory Budget.fromMap(Map<String, dynamic> map) {
//     return Budget(
//       // ✅ API returns 'id' as number, convert to string
//       id: (map['id'] ?? map['_id'] ?? '').toString(),

//       // ✅ UserID might be missing
//       userId: (map['UserID'] ?? '').toString(),

//       budgetName: map['BudgetName']?.toString() ?? '',

//       // ✅ Handle both int and double
//       balance: num.tryParse(map['Balance']?.toString() ?? '0') ?? 0,
//       targetAmountMonthly:
//           num.tryParse(map['TargetAmountMonthly']?.toString() ?? '0') ?? 0,

//       // ✅ Safe date parsing
//       createdAt:
//           DateTime.tryParse(map['createdAt']?.toString() ?? '') ??
//           DateTime.now(),
//       updatedAt:
//           DateTime.tryParse(map['updatedAt']?.toString() ?? '') ??
//           DateTime.now(),
//     );
//   }

//   factory Budget.fromJson(String source) => Budget.fromMap(json.decode(source));

//   @override
//   String toString() {
//     return 'Budget(id: $id, budgetName: $budgetName, balance: $balance, targetAmountMonthly: $targetAmountMonthly)';
//   }
// }

// class BudgetHomeData {
//   final num totalEarnings;
//   final List<Budget> budgets;

//   BudgetHomeData({required this.totalEarnings, required this.budgets});

//   factory BudgetHomeData.fromMap(Map<String, dynamic> map) {
//     return BudgetHomeData(
//       totalEarnings: num.tryParse(map['TotalEarnings']?.toString() ?? '0') ?? 0,

//       budgets: (map['Budgets'] as List? ?? [])
//           .map((x) {
//             try {
//               return Budget.fromMap(x as Map<String, dynamic>);
//             } catch (e) {
//               print('⚠️ Error parsing budget item: $e');
//               return null;
//             }
//           })
//           .whereType<Budget>() // Filter out nulls
//           .toList(),
//     );
//   }

//   factory BudgetHomeData.fromJson(String source) =>
//       BudgetHomeData.fromMap(json.decode(source));

//   @override
//   String toString() =>
//       'BudgetHomeData(totalEarnings: $totalEarnings, budgets: ${budgets.length} items)';
// }
