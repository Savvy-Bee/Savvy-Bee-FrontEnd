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
      id: json['_id'] as String,
      userId: json['UserId'] as String,
      goalName: json['GoalName'] as String,
      goalType: json['GoalType'] as String,
      balance: (json['Balance'] as num).toDouble(),
      targetAmount: (json['TargetAmount'] as num).toDouble(),
      endDate: json['EndDate'] as String,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'UserId': userId,
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
}
