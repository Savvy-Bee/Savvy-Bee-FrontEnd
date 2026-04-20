class Bank {
  final String name;
  final String code;
  final String? id;
  final String? slug;
  final String? country;
  final String? nibssBankCode;

  Bank({
    required this.name,
    required this.code,
    this.id,
    this.slug,
    this.country,
    this.nibssBankCode,
  });

  // Treat null country as Nigerian since the banks endpoint only returns Nigerian banks
  bool get isNigerianBank =>
      country == null ||
      country!.toLowerCase() == 'nigeria' ||
      country!.toLowerCase() == 'ng';

  factory Bank.fromJson(Map<String, dynamic> json) {
    return Bank(
      name: json['name'] as String,
      code: json['code'] as String,
      id: json['id'] as String?,
      slug: json['slug'] as String?,
      country: json['country'] as String?,
      nibssBankCode: json['nibss_bank_code'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'code': code,
      if (id != null) 'id': id,
      if (slug != null) 'slug': slug,
      if (country != null) 'country': country,
      if (nibssBankCode != null) 'nibss_bank_code': nibssBankCode,
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
