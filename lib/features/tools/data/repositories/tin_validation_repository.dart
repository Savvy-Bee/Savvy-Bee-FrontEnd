// lib/features/tools/data/repositories/tin_validation_repository.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:savvy_bee_mobile/core/network/api_endpoints.dart';

// ── Model ─────────────────────────────────────────────────────────────────────

class TinValidationResult {
  /// The raw TIN the user entered.
  final String tin;

  final String taxpayerName;
  final String cacRegNumber;
  final String firstin;
  final String jittin;
  final String? nrsTin;
  final String taxOffice;
  final String phoneNumber;
  final String email;
  final String address;

  /// "INDIVIDUAL" | "BUSINESS" etc.
  final String tinType;

  const TinValidationResult({
    required this.tin,
    required this.taxpayerName,
    required this.cacRegNumber,
    required this.firstin,
    required this.jittin,
    required this.nrsTin,
    required this.taxOffice,
    required this.phoneNumber,
    required this.email,
    required this.address,
    required this.tinType,
  });

  factory TinValidationResult.fromJson(
    Map<String, dynamic> json, {
    required String tin,
  }) =>
      TinValidationResult(
        tin: tin,
        taxpayerName: (json['taxpayer_name'] as String? ?? ''),
        cacRegNumber: (json['cac_reg_number'] as String? ?? ''),
        firstin: (json['firstin'] as String? ?? ''),
        jittin: (json['jittin'] as String? ?? ''),
        nrsTin: json['nrs_tin'] as String?,
        taxOffice: (json['tax_office'] as String? ?? ''),
        phoneNumber: (json['phone_number'] as String? ?? ''),
        email: (json['email'] as String? ?? ''),
        address: (json['address'] as String? ?? ''),
        tinType: (json['tin_type'] as String? ?? ''),
      );
}

// ── Repository ────────────────────────────────────────────────────────────────

class TinValidationRepository {
  static const _base = ApiEndpoints.baseUrl;

  final String bearerToken;
  const TinValidationRepository({required this.bearerToken});

  /// GET /tools/taxation/filling/fetchdata/tin/:id
  Future<TinValidationResult> validateTin(String tin) async {
    final uri =
        Uri.parse('$_base/tools/taxation/filling/fetchdata/tin/$tin');

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $bearerToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      // Try to parse an error message from the body
      String message = 'TIN validation failed (${response.statusCode})';
      try {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        if (body['message'] != null) message = body['message'] as String;
      } catch (_) {}
      throw Exception(message);
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (body['success'] != true) {
      throw Exception(body['message'] ?? 'TIN validation failed');
    }

    return TinValidationResult.fromJson(
      body['data'] as Map<String, dynamic>,
      tin: tin,
    );
  }
}