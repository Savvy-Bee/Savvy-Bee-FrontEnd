// lib/features/tools/data/repositories/tax_calculator_repository.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:savvy_bee_mobile/core/network/api_endpoints.dart';
import 'package:savvy_bee_mobile/features/tools/domain/models/tax_calculator_result.dart';

class TaxCalculatorRepository {
  static const _baseUrl = ApiEndpoints.baseUrl;

  final String bearerToken;

  const TaxCalculatorRepository({required this.bearerToken});

  /// Calls the calculator endpoint.
  ///
  /// [earnings]         — gross annual earnings
  /// [rent]             — rent paid (default 0)
  /// [nhf]              — NHF Contribution (Annual)
  /// [nhis]             — NHIS Contribution
  /// [pension]          — Pension Contribution
  /// [loanInterest]     — Interest on Loan for Owner Occupied House
  /// [lifeInsurance]    — Life Insurance Premium (You & Spouse)
  ///
  /// The backend uses `otherExemptions` to collect the sum of all
  /// non-earnings deductions the user can edit.
  Future<TaxCalculatorResult> calculate({
    required double earnings,
    double rent = 0,
    double nhf = 0,
    double nhis = 0,
    double pension = 0,
    double loanInterest = 0,
    double lifeInsurance = 0,
  }) async {
    final otherExemptions = nhf + nhis + pension + loanInterest + lifeInsurance;

    final uri = Uri.parse('$_baseUrl/tools/taxation/calculator').replace(
      queryParameters: {
        'earnings': earnings.toStringAsFixed(0),
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

    return TaxCalculatorResult.fromJson(body['data'] as Map<String, dynamic>);
  }
}
