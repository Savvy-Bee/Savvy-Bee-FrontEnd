// lib/features/tools/data/repositories/filing_payment_repository.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:savvy_bee_mobile/core/network/api_endpoints.dart';
import 'package:savvy_bee_mobile/features/tools/domain/models/filing_home_data.dart';

// ── Result models ─────────────────────────────────────────────────────────────

class FilingInitResult {
  final String id;
  final String plan;
  final String status;
  final FillingFinanceDetails financeDetails;

  const FilingInitResult({
    required this.id,
    required this.plan,
    required this.status,
    required this.financeDetails,
  });

  factory FilingInitResult.fromJson(Map<String, dynamic> json) =>
      FilingInitResult(
        id: (json['_id'] as String? ?? ''),
        plan: (json['Plan'] as String? ?? ''),
        status: (json['Status'] as String? ?? ''),
        financeDetails: FillingFinanceDetails.fromJson(
          json['FinanceDetails'] as Map<String, dynamic>? ?? {},
        ),
      );
}

class FilingFeeResult {
  final String transactionId;
  final double amount;
  final String status;
  final String narration;

  const FilingFeeResult({
    required this.transactionId,
    required this.amount,
    required this.status,
    required this.narration,
  });

  factory FilingFeeResult.fromJson(Map<String, dynamic> json) =>
      FilingFeeResult(
        transactionId: (json['id'] as String? ?? ''),
        amount: double.tryParse(json['Amount']?.toString() ?? '0') ?? 0.0,
        status: (json['Status'] as String? ?? ''),
        narration: (json['Narration'] as String? ?? ''),
      );
}

class LiabilityFeeResult {
  final String id;
  final FillingStatus status;
  final FillingFinanceDetails financeDetails;

  const LiabilityFeeResult({
    required this.id,
    required this.status,
    required this.financeDetails,
  });

  factory LiabilityFeeResult.fromJson(Map<String, dynamic> json) =>
      LiabilityFeeResult(
        id: (json['_id'] as String? ?? ''),
        status: FillingStatus.fromString(json['Status'] as String? ?? ''),
        financeDetails: FillingFinanceDetails.fromJson(
          json['FinanceDetails'] as Map<String, dynamic>? ?? {},
        ),
      );
}

// ── Repository ────────────────────────────────────────────────────────────────

class FilingPaymentRepository {
  static const _base = ApiEndpoints.baseUrl;

  final String bearerToken;
  const FilingPaymentRepository({required this.bearerToken});

  Map<String, String> get _headers => {
    'Authorization': 'Bearer $bearerToken',
    'Content-Type': 'application/json',
  };

  /// POST /tools/taxation/filling/payment/init
  Future<FilingInitResult> initPayment({
    required String plan,
    required String tin,
    required List<FilingIncomeSource> revenues,
    required List<FilingIncomeSource> noneTaxableRevenues,
  }) async {
    final response = await http.post(
      Uri.parse('$_base/tools/taxation/filling/payment/init'),
      headers: _headers,
      body: jsonEncode({
        'Plan': plan == 'Basic PAYE'
            ? 'Basic PAYE'
            : plan == 'Freelancer'
            ? 'Freelance'
            : plan == 'SME Lite'
            ? 'SME Lite'
            : 'Pro Complex',
        'TIN': tin,
        'Revenues': revenues.map((r) => r.toJson()).toList(),
        'NoneTaxableRevenues': noneTaxableRevenues
            .map((r) => r.toJson())
            .toList(),
      }),
    );
    _checkStatus(response, 'payment/init');
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    _checkSuccess(json, 'payment/init');
    return FilingInitResult.fromJson(json['data'] as Map<String, dynamic>);
  }

  /// POST /tools/taxation/filling/payment/fillingfee  (form-data)
  Future<FilingFeeResult> payFillingFee({required String pin}) async {
    final req =
        http.MultipartRequest(
            'POST',
            Uri.parse('$_base/tools/taxation/filling/payment/fillingfee'),
          )
          ..headers['Authorization'] = 'Bearer $bearerToken'
          ..fields['Pin'] = pin;

    final streamed = await req.send();
    final response = await http.Response.fromStream(streamed);
    _checkStatus(response, 'payment/fillingfee');
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    _checkSuccess(json, 'payment/fillingfee');

    final data = json['data'];
    final txJson = (data is List ? data.first : data) as Map<String, dynamic>;
    return FilingFeeResult.fromJson(txJson);
  }

  /// POST /tools/taxation/filling/payment/liabilityfee  (form-data)
  Future<LiabilityFeeResult> payLiabilityFee({required String pin}) async {
    final req =
        http.MultipartRequest(
            'POST',
            Uri.parse('$_base/tools/taxation/filling/payment/liabilityfee'),
          )
          ..headers['Authorization'] = 'Bearer $bearerToken'
          ..fields['Pin'] = pin;

    final streamed = await req.send();
    final response = await http.Response.fromStream(streamed);
    _checkStatus(response, 'payment/liabilityfee');
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    _checkSuccess(json, 'payment/liabilityfee');
    return LiabilityFeeResult.fromJson(json['data'] as Map<String, dynamic>);
  }

  void _checkStatus(http.Response resp, String ep) {
    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw Exception('$ep failed [${resp.statusCode}]: ${resp.body}');
    }
  }

  void _checkSuccess(Map<String, dynamic> json, String ep) {
    if (json['success'] != true) {
      throw Exception('$ep returned success=false: ${json['message']}');
    }
  }
}
