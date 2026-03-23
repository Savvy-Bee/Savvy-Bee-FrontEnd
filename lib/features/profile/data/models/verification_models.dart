// lib/features/spend/domain/models/verification_models.dart

class ProfileImage {
  final String uri;
  final String type;
  final String name;

  ProfileImage({
    required this.uri,
    this.type = 'image/jpeg',
    this.name = 'selfie.jpg',
  });

  Map<String, dynamic> toJson() {
    return {'uri': uri, 'type': type, 'name': name};
  }
}

class VerificationRequest {
  final String data; // Encrypted NIN or BVN
  final ProfileImage profile;

  VerificationRequest({required this.data, required this.profile});

  Map<String, dynamic> toJson() {
    return {'Data': data, 'Profile': profile.toJson()};
  }
}

class Address {
  final String town;
  final String lga;
  final String state;
  final String street;

  Address({
    required this.town,
    required this.lga,
    required this.state,
    required this.street,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      town: json['town'] as String? ?? '',
      lga: json['lga'] as String? ?? '',
      state: json['state'] as String? ?? '',
      street: json['street'] as String? ?? '',
    );
  }
}

class ValidationField {
  final String value;
  final bool match;

  ValidationField({required this.value, required this.match});

  factory ValidationField.fromJson(Map<String, dynamic> json) {
    return ValidationField(
      value: json['value'] as String? ?? '',
      match: json['match'] as bool? ?? false,
    );
  }
}

class SelfieValidation extends ValidationField {
  final double confidenceRating;

  SelfieValidation({
    required super.value,
    required super.match,
    required this.confidenceRating,
  });

  factory SelfieValidation.fromJson(Map<String, dynamic> json) {
    return SelfieValidation(
      value: json['value'] as String? ?? '',
      match: json['match'] as bool? ?? false,
      confidenceRating: (json['confidence_rating'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class Validation {
  final ValidationField firstName;
  final ValidationField lastName;
  final ValidationField dateOfBirth;
  final SelfieValidation selfie;

  Validation({
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.selfie,
  });

  factory Validation.fromJson(Map<String, dynamic> json) {
    return Validation(
      firstName: json['first_name'] is Map<String, dynamic>
          ? ValidationField.fromJson(json['first_name'] as Map<String, dynamic>)
          : ValidationField(value: '', match: false),
      lastName: json['last_name'] is Map<String, dynamic>
          ? ValidationField.fromJson(json['last_name'] as Map<String, dynamic>)
          : ValidationField(value: '', match: false),
      dateOfBirth: json['date_of_birth'] is Map<String, dynamic>
          ? ValidationField.fromJson(json['date_of_birth'] as Map<String, dynamic>)
          : ValidationField(value: '', match: false),
      selfie: json['selfie'] is Map<String, dynamic>
          ? SelfieValidation.fromJson(json['selfie'] as Map<String, dynamic>)
          : SelfieValidation(value: '', match: false, confidenceRating: 0.0),
    );
  }
}

class VerificationData {
  final String reference;
  final String id;
  final String idType;
  final String firstName;
  final String lastName;
  final String middleName;
  final String dateOfBirth;
  final String phoneNumber;
  final Address address;
  final String email;
  final String birthState;
  final String birthLga;
  final String birthCountry;
  final String nextOfKinState;
  final String religion;
  final String gender;
  final Validation validation;
  final String requestedBy;

  VerificationData({
    required this.reference,
    required this.id,
    required this.idType,
    required this.firstName,
    required this.lastName,
    required this.middleName,
    required this.dateOfBirth,
    required this.phoneNumber,
    required this.address,
    required this.email,
    required this.birthState,
    required this.birthLga,
    required this.birthCountry,
    required this.nextOfKinState,
    required this.religion,
    required this.gender,
    required this.validation,
    required this.requestedBy,
  });

  factory VerificationData.fromJson(Map<String, dynamic> json) {
    return VerificationData(
      reference: json['reference'] as String? ?? '',
      id: json['id'] as String? ?? '',
      idType: json['id_type'] as String? ?? '',
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      middleName: json['middle_name'] as String? ?? '',
      dateOfBirth: json['date_of_birth'] as String? ?? '',
      phoneNumber: json['phone_number'] as String? ?? '',
      address: json['address'] is Map<String, dynamic>
          ? Address.fromJson(json['address'] as Map<String, dynamic>)
          : Address(town: '', lga: '', state: '', street: ''),
      email: json['email'] as String? ?? '',
      birthState: json['birth_state'] as String? ?? '',
      birthLga: json['birth_lga'] as String? ?? '',
      birthCountry: json['birth_country'] as String? ?? '',
      nextOfKinState: json['next_of_kin_state'] as String? ?? '',
      religion: json['religion'] as String? ?? '',
      gender: json['gender'] as String? ?? '',
      validation: json['validation'] is Map<String, dynamic>
          ? Validation.fromJson(json['validation'] as Map<String, dynamic>)
          : Validation(
              firstName: ValidationField(value: '', match: false),
              lastName: ValidationField(value: '', match: false),
              dateOfBirth: ValidationField(value: '', match: false),
              selfie: SelfieValidation(value: '', match: false, confidenceRating: 0.0),
            ),
      requestedBy: json['requested_by'] as String? ?? '',
    );
  }
}

class VerificationResponse {
  final bool success;
  final String message;
  final VerificationData data;

  VerificationResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory VerificationResponse.fromJson(Map<String, dynamic> json) {
    return VerificationResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: json['data'] is Map<String, dynamic>
          ? VerificationData.fromJson(json['data'] as Map<String, dynamic>)
          : VerificationData(
              reference: '', id: '', idType: '', firstName: '', lastName: '',
              middleName: '', dateOfBirth: '', phoneNumber: '',
              address: Address(town: '', lga: '', state: '', street: ''),
              email: '', birthState: '', birthLga: '', birthCountry: '',
              nextOfKinState: '', religion: '', gender: '',
              validation: Validation(
                firstName: ValidationField(value: '', match: false),
                lastName: ValidationField(value: '', match: false),
                dateOfBirth: ValidationField(value: '', match: false),
                selfie: SelfieValidation(value: '', match: false, confidenceRating: 0.0),
              ),
              requestedBy: '',
            ),
    );
  }
}
