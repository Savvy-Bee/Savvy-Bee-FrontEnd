class BillsResponse {
  final bool success;
  final String message;
  final dynamic data;

  BillsResponse({required this.success, required this.message, this.data});

  factory BillsResponse.fromJson(Map<String, dynamic> json) {
    return BillsResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'],
    );
  }
}

class DataPlan {
  final String package;
  final String provider;
  final String amount;
  final String code;

  DataPlan({
    required this.package,
    required this.provider,
    required this.amount,
    required this.code,
  });

  factory DataPlan.fromJson(Map<String, dynamic> json) {
    return DataPlan(
      package: json['package'] ?? '',
      provider: json['provider'] ?? '',
      amount: json['amount'] ?? '',
      code: json['code'] ?? '',
    );
  }
}

class TvProvider {
  final String name;
  final String shortName;
  final String logo;

  TvProvider({required this.name, required this.shortName, required this.logo});

  factory TvProvider.fromJson(Map<String, dynamic> json) {
    return TvProvider(
      name: json['name'] ?? '',
      shortName: json['short_name'] ?? '',
      logo: json['logo'] ?? '',
    );
  }
}

class TvPlan {
  final String package;
  final String name;
  final String provider;
  final String amount;
  final String code;

  TvPlan({
    required this.package,
    required this.name,
    required this.provider,
    required this.amount,
    required this.code,
  });

  factory TvPlan.fromJson(Map<String, dynamic> json) {
    return TvPlan(
      package: json['package'] ?? '',
      name: json['name'] ?? '',
      provider: json['provider'] ?? '',
      amount: json['amount'] ?? '',
      code: json['code'] ?? '',
    );
  }
}

class ElectricityProvider {
  final String disco;
  final String shortName;
  final String logo;

  ElectricityProvider({
    required this.disco,
    required this.shortName,
    required this.logo,
  });

  factory ElectricityProvider.fromJson(Map<String, dynamic> json) {
    return ElectricityProvider(
      disco: json['disco'] ?? '',
      shortName: json['short_name'] ?? '',
      logo: json['logo'] ?? '',
    );
  }
}
