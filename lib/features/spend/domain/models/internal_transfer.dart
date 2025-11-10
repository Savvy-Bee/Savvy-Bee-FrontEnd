class InternalTransferData {
  final String userId;
  final double amount;
  final double charges;
  final String type;
  final String status;
  final String transferFor;
  final String narration;
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;

  InternalTransferData({
    required this.userId,
    required this.amount,
    required this.charges,
    required this.type,
    required this.status,
    required this.transferFor,
    required this.narration,
    required this.id,
    required this.createdAt,
    required this.updatedAt,
  });

  factory InternalTransferData.fromJson(Map<String, dynamic> json) {
    return InternalTransferData(
      userId: json['UserID'] as String,
      amount: (json['Amount'] as num).toDouble(),
      charges: (json['Charges'] as num).toDouble(),
      type: json['Type'] as String,
      status: json['Status'] as String,
      transferFor: json['For'] as String,
      narration: json['Narration'] as String,
      id: json['_id'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'UserID': userId,
      'Amount': amount,
      'Charges': charges,
      'Type': type,
      'Status': status,
      'For': transferFor,
      'Narration': narration,
      '_id': id,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class InternalTransferResponse {
  final bool success;
  final String message;
  final InternalTransferData data;

  InternalTransferResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory InternalTransferResponse.fromJson(Map<String, dynamic> json) {
    return InternalTransferResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: InternalTransferData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}