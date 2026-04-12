// lib/features/tools/data/repositories/other_country_tax_repository.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:savvy_bee_mobile/core/network/api_endpoints.dart';
import 'package:savvy_bee_mobile/features/tools/domain/models/other_country_tax_result.dart';

class OtherCountryTaxRepository {
  final String bearerToken;

  const OtherCountryTaxRepository({required this.bearerToken});

  /// Calls the other-country calculator endpoint.
  ///
  /// [country]        — ISO country code (uk, us, fr, ci, sn, cd, cm)
  /// [annualIncome]   — gross annual income
  /// [rent]           — annual rent paid (default 0)
  /// [nhf]            — NHF Contribution (default 0)
  /// [nhis]           — NHIS Contribution (default 0)
  /// [pension]        — Pension Contribution (default 0)
  /// [loanInterest]   — Interest on Loan for Owner Occupied House (default 0)
  /// [lifeInsurance]  — Life Insurance Premium (You & Spouse) (default 0)
  Future<OtherCountryTaxResult> calculate({
    required String country,
    required double annualIncome,
    double rent = 0,
    double nhf = 0,
    double nhis = 0,
    double pension = 0,
    double loanInterest = 0,
    double lifeInsurance = 0,
  }) async {
    final otherExemptions = nhf + nhis + pension + loanInterest + lifeInsurance;

    final uri = Uri.parse(
      '${ApiEndpoints.baseUrl}${ApiEndpoints.taxationCalculatorOtherCountry(country)}',
    ).replace(
      queryParameters: {
        'annualIncome': annualIncome.toStringAsFixed(0),
        'rent': rent.toStringAsFixed(0),
        'otherExemptions': otherExemptions.toStringAsFixed(0),
      },
    );

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $bearerToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Calculator failed: ${response.statusCode} ${response.body}',
      );
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (body['success'] != true) {
      throw Exception('Calculator API error: ${body['message']}');
    }

    return OtherCountryTaxResult.fromJson(body['data'] as Map<String, dynamic>);
  }
}
