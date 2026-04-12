import 'package:savvy_bee_mobile/core/network/api_client.dart';
import 'package:savvy_bee_mobile/core/network/api_endpoints.dart';

// ── Models ────────────────────────────────────────────────────────────────────

class NokAddress {
  final String addressLine1;
  final String addressLine2;
  final String city;
  final String state;
  final String postalCode;
  final String country;

  const NokAddress({
    required this.addressLine1,
    required this.addressLine2,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
  });

  factory NokAddress.fromJson(Map<String, dynamic> json) => NokAddress(
    addressLine1: json['addressLine_1'] as String? ?? '',
    addressLine2: json['addressLine_2'] as String? ?? '',
    city: json['city'] as String? ?? '',
    state: json['state'] as String? ?? '',
    postalCode: json['postalCode'] as String? ?? '',
    country: json['country'] as String? ?? '',
  );

  Map<String, dynamic> toJson() => {
    'addressLine_1': addressLine1,
    'addressLine_2': addressLine2,
    'city': city,
    'state': state,
    'postalCode': postalCode,
    'country': country,
  };
}

class NokData {
  final String fullName;
  final String phoneNumber;
  final String relationship;
  final String email;
  final NokAddress? address;

  const NokData({
    required this.fullName,
    required this.phoneNumber,
    required this.relationship,
    required this.email,
    this.address,
  });

  bool get isSet => fullName.isNotEmpty;

  factory NokData.fromJson(Map<String, dynamic> json) => NokData(
    fullName: json['FullName'] as String? ?? '',
    phoneNumber: json['PhoneNumber'] as String? ?? '',
    relationship: json['Relationship'] as String? ?? '',
    email: json['Email'] as String? ?? '',
    address: json['Address'] is Map<String, dynamic>
        ? NokAddress.fromJson(json['Address'] as Map<String, dynamic>)
        : null,
  );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'FullName': fullName,
      'PhoneNumber': phoneNumber,
      'Relationship': relationship,
      'Email': email,
    };
    if (address != null) map['Address'] = address!.toJson();
    return map;
  }
}

class UserAddress {
  final String addressLine1;
  final String addressLine2;
  final String city;
  final String state;
  final String postalCode;
  final String country;

  const UserAddress({
    required this.addressLine1,
    required this.addressLine2,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
  });

  bool get isSet => addressLine1.isNotEmpty;

  factory UserAddress.fromJson(Map<String, dynamic> json) => UserAddress(
    addressLine1: json['addressLine_1'] as String? ?? '',
    addressLine2: json['addressLine_2'] as String? ?? '',
    city: json['city'] as String? ?? '',
    state: json['state'] as String? ?? '',
    postalCode: json['postalCode'] as String? ?? '',
    country: json['country'] as String? ?? '',
  );

  Map<String, dynamic> toJson() => {
    'addressLine_1': addressLine1,
    'addressLine_2': addressLine2,
    'city': city,
    'state': state,
    'postalCode': postalCode,
    'country': country,
  };
}

// ── Repository ────────────────────────────────────────────────────────────────

class NokRepository {
  final ApiClient _apiClient;

  const NokRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  /// GET /auth/update/nextofkin
  Future<NokData?> fetchNok() async {
    final response = await _apiClient.get(ApiEndpoints.fetchNok);
    final body = response.data as Map<String, dynamic>?;
    if (body == null) return null;
    final data = body['data'] ?? body['Data'];
    if (data is! Map<String, dynamic>) return null;
    final nok = NokData.fromJson(data);
    return nok.isSet ? nok : null;
  }

  /// PATCH /auth/update/nextofkin
  Future<void> updateNok(NokData nok) async {
    await _apiClient.patch(ApiEndpoints.updateNok, data: nok.toJson());
  }

  /// POST /auth/kyc/identity-number/address/ng
  Future<UserAddress> setAddress(UserAddress address) async {
    final response = await _apiClient.post(
      ApiEndpoints.setAddress,
      data: address.toJson(),
    );
    final body = response.data as Map<String, dynamic>?;
    final data = body?['data'] ?? body?['Data'];
    if (data is Map<String, dynamic>) return UserAddress.fromJson(data);
    return address;
  }
}
