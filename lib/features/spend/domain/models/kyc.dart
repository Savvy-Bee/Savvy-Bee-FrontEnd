class KycAddress {
  final String town;
  final String lga;
  final String state;
  final String street;

  KycAddress({
    required this.town,
    required this.lga,
    required this.state,
    required this.street,
  });

  factory KycAddress.fromJson(Map<String, dynamic> json) {
    return KycAddress(
      town: json['town'] as String,
      lga: json['lga'] as String,
      state: json['state'] as String,
      street: json['street'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'town': town, 'lga': lga, 'state': state, 'street': street};
  }
}

class KycValidationField {
  final String value;
  final bool match;
  final int? confidenceRating;

  KycValidationField({
    required this.value,
    required this.match,
    this.confidenceRating,
  });

  factory KycValidationField.fromJson(Map<String, dynamic> json) {
    return KycValidationField(
      value: json['value'] as String,
      match: json['match'] as bool,
      confidenceRating: json['confidence_rating'] as int?,
    );
  }
}

class KycValidation {
  final KycValidationField firstName;
  final KycValidationField lastName;
  final KycValidationField dateOfBirth;
  final KycValidationField selfie;

  KycValidation({
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.selfie,
  });

  factory KycValidation.fromJson(Map<String, dynamic> json) {
    return KycValidation(
      firstName: KycValidationField.fromJson(
        json['first_name'] as Map<String, dynamic>,
      ),
      lastName: KycValidationField.fromJson(
        json['last_name'] as Map<String, dynamic>,
      ),
      dateOfBirth: KycValidationField.fromJson(
        json['date_of_birth'] as Map<String, dynamic>,
      ),
      selfie: KycValidationField.fromJson(
        json['selfie'] as Map<String, dynamic>,
      ),
    );
  }
}

class KycData {
  final String reference;
  final String id;
  final String idType;
  final String firstName;
  final String lastName;
  final String? middleName;
  final String dateOfBirth;
  final String phoneNumber;
  final KycAddress address;
  final String? email;
  final String? birthState;
  final String? birthLga;
  final String? birthCountry;
  final String? nextOfKinState;
  final String? religion;
  final String? gender;
  final KycValidation validation;
  final String requestedBy;

  KycData({
    required this.reference,
    required this.id,
    required this.idType,
    required this.firstName,
    required this.lastName,
    this.middleName,
    required this.dateOfBirth,
    required this.phoneNumber,
    required this.address,
    this.email,
    this.birthState,
    this.birthLga,
    this.birthCountry,
    this.nextOfKinState,
    this.religion,
    this.gender,
    required this.validation,
    required this.requestedBy,
  });

  factory KycData.fromJson(Map<String, dynamic> json) {
    return KycData(
      reference: json['reference'] as String,
      id: json['id'] as String,
      idType: json['id_type'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      middleName: json['middle_name'] as String?,
      dateOfBirth: json['date_of_birth'] as String,
      phoneNumber: json['phone_number'] as String,
      address: KycAddress.fromJson(json['address'] as Map<String, dynamic>),
      email: json['email'] as String?,
      birthState: json['birth_state'] as String?,
      birthLga: json['birth_lga'] as String?,
      birthCountry: json['birth_country'] as String?,
      nextOfKinState: json['next_of_kin_state'] as String?,
      religion: json['religion'] as String?,
      gender: json['gender'] as String?,
      validation: KycValidation.fromJson(
        json['validation'] as Map<String, dynamic>,
      ),
      requestedBy: json['requested_by'] as String,
    );
  }
}

class KycVerificationResponse {
  final bool success;
  final String message;
  final KycData? data;

  KycVerificationResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory KycVerificationResponse.fromJson(Map<String, dynamic> json) {
    return KycVerificationResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: json['data'] != null
          ? KycData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}
