class Bank {
  final String name;
  final String slug;
  final String code;
  final String country;
  final String? nibssBankCode;

  Bank({
    required this.name,
    required this.slug,
    required this.code,
    required this.country,
    this.nibssBankCode,
  });

  bool get isNigerianBank =>
      country.toLowerCase() == 'nigeria' || country.toLowerCase() == 'ng';

  factory Bank.fromJson(Map<String, dynamic> json) {
    return Bank(
      name: json['name'] as String,
      slug: json['slug'] as String,
      code: json['code'] as String,
      country: json['country'] as String,
      nibssBankCode: json['nibss_bank_code'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'slug': slug,
      'code': code,
      'country': country,
      'nibss_bank_code': nibssBankCode,
    };
  }
}

class BanksResponse {
  final bool success;
  final String message;
  final List<Bank> data;

  BanksResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory BanksResponse.fromJson(Map<String, dynamic> json) {
    return BanksResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: (json['data'] as List)
          .map((bank) => Bank.fromJson(bank as Map<String, dynamic>))
          .toList(),
    );
  }
}
