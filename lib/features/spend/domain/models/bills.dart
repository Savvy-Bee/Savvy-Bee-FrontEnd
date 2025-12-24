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
  final int amount;
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
      amount: json['amount'] ?? 0,
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

class ElectricityCustomer {
  final String name;
  final String address;
  final String district;

  ElectricityCustomer({
    required this.name,
    required this.address,
    required this.district,
  });

  factory ElectricityCustomer.fromJson(Map<String, dynamic> json) {
    return ElectricityCustomer(
      name: _sanitizeString(json['customer_name']),
      address: _sanitizeString(json['customer_address']),
      district: _sanitizeString(json['customer_district']),
    );
  }

  static String _sanitizeString(dynamic value) {
    if (value == null) return 'N/A';

    String str = value.toString().trim();

    // Remove multiple consecutive commas and spaces
    str = str.replaceAll(RegExp(r',\s*,+'), ',');

    // Remove trailing commas
    str = str.replaceAll(RegExp(r',+\s*$'), '');

    // Remove leading commas
    str = str.replaceAll(RegExp(r'^\s*,+'), '');

    // Replace multiple spaces with single space
    str = str.replaceAll(RegExp(r'\s+'), ' ');

    return str.trim().isEmpty ? 'N/A' : str.trim();
  }
}
