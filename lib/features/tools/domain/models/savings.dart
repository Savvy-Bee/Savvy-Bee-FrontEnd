class SavingsGoal {
  final String id;
  final String userId;
  final String goalName;
  final String goalType;
  final double balance;
  final double targetAmount;
  final String endDate;
  final String createdAt;
  final String updatedAt;

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
      // ✅ FIX 1: API returns 'id' not '_id'
      id: (json['id'] ?? json['_id'] ?? '').toString(),

      // ✅ FIX 2: API returns 'UserID' not 'UserId'
      userId: (json['UserID'] ?? json['UserId'] ?? '').toString(),

      goalName: json['GoalName']?.toString() ?? '',
      goalType: json['GoalType']?.toString() ?? '',

      // ✅ FIX 3: Safe parsing for numeric values
      balance:
          num.tryParse(json['Balance']?.toString() ?? '0')?.toDouble() ?? 0.0,
      targetAmount:
          num.tryParse(json['TargetAmount']?.toString() ?? '0')?.toDouble() ??
          0.0,

      endDate: json['EndDate']?.toString() ?? '',
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'UserID': userId,
      'GoalName': goalName,
      'GoalType': goalType,
      'Balance': balance,
      'TargetAmount': targetAmount,
      'EndDate': endDate,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  double get progress => targetAmount > 0 ? (balance / targetAmount) * 100 : 0;

  bool get isCompleted => balance >= targetAmount;

  @override
  String toString() {
    return 'SavingsGoal(id: $id, goalName: $goalName, balance: $balance, targetAmount: $targetAmount)';
  }
}
