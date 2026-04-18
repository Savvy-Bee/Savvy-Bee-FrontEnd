class Beneficiary {
  final String id;
  final String name;
  final String? username;
  final String? accountNumber;
  final String? bankName;
  final String? bankCode;

  Beneficiary({
    required this.id,
    required this.name,
    this.username,
    this.accountNumber,
    this.bankName,
    this.bankCode,
  });

  bool get isSavvyBee => username != null;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'username': username,
        'accountNumber': accountNumber,
        'bankName': bankName,
        'bankCode': bankCode,
      };

  factory Beneficiary.fromJson(Map<String, dynamic> json) => Beneficiary(
        id: json['id'] as String,
        name: json['name'] as String,
        username: json['username'] as String?,
        accountNumber: json['accountNumber'] as String?,
        bankName: json['bankName'] as String?,
        bankCode: json['bankCode'] as String?,
      );
}
