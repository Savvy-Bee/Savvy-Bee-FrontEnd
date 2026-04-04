// lib/features/tools/data/repositories/filing_payment_repository.dart

import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:savvy_bee_mobile/core/network/api_endpoints.dart';
import 'package:savvy_bee_mobile/features/tools/domain/models/filing_home_data.dart';

// ── Contact info model ────────────────────────────────────────────────────────

class FilingContactInfo {
  final String phoneNo;
  final String address;
  final String email;

  const FilingContactInfo({
    required this.phoneNo,
    required this.address,
    required this.email,
  });

  Map<String, dynamic> toJson() => {
    'PhoneNo': phoneNo,
    'Address': address,
    'Email': email,
  };
}

// ── Result models ─────────────────────────────────────────────────────────────

class FilingInitResult {
  final String id;
  final String plan;
  final String status;
  final FillingFinanceDetails financeDetails;

  /// Wallet balance returned by payment/init (field: "Wallet").
  /// The API sends this as a numeric string e.g. "2349852.00" — parsed to double.
  /// Written to [filingWalletBalanceProvider] by Step 3 so Steps 4 & 5 can
  /// display the user's spendable balance without an extra API call.
  final double walletBalance;

  const FilingInitResult({
    required this.id,
    required this.plan,
    required this.status,
    required this.financeDetails,
    this.walletBalance = 0.0,
  });

  factory FilingInitResult.fromJson(
    Map<String, dynamic> json,
  ) => FilingInitResult(
    id: (json['_id'] as String? ?? ''),
    plan: (json['Plan'] as String? ?? ''),
    status: (json['Status'] as String? ?? ''),
    financeDetails: FillingFinanceDetails.fromJson(
      json['FinanceDetails'] as Map<String, dynamic>? ?? {},
    ),
    // "Wallet" may arrive as a String ("2349852.00") or as a num — handle both
    walletBalance: double.tryParse(json['Wallet']?.toString() ?? '0') ?? 0.0,
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
    required String classification,
    required String name,
    required String cacNumber,
    required FilingContactInfo contact,
    required List<FilingIncomeSource> revenues,
    required List<FilingIncomeSource> noneTaxableRevenues,
  }) async {
    final body = <String, dynamic>{
      'Plan': plan == 'Basic PAYE'
          ? 'Basic PAYE'
          : plan == 'Freelancer'
          ? 'Freelance'
          : plan == 'SME Lite'
          ? 'SME Lite'
          : 'Pro Complex',
      'TIN': tin,
      'Classification': classification,
      'Name': name,
      'Revenues': revenues.map((r) => r.toJson()).toList(),
      'NoneTaxableRevenues': noneTaxableRevenues
          .map((r) => r.toJson())
          .toList(),
      'Contact': contact.toJson(),
    };

    // Only include CACNumber when it is non-empty (corporate filers)
    if (cacNumber.isNotEmpty) body['CACNumber'] = cacNumber;

    print('Request Body: $body');

    final response = await http.post(
      Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.filingPaymentInit}'),
      headers: _headers,
      body: jsonEncode(body),
    );

    _logResponse(response);
    print('payment/init → ${response.statusCode}: ${response.body}');

    _checkStatus(response, 'payment/init');
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    _checkSuccess(json, 'payment/init');
    return FilingInitResult.fromJson(json['data'] as Map<String, dynamic>);
  }

  /// POST /tools/taxation/filling/payment/fillingfee
  Future<FilingFeeResult> payFillingFee({
    required String pin,
    required String Id,
  }) async {
    final body = <String, String>{'Pin': pin};

    print('ID: $Id');

    final response = await http.post(
      Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.filingFillingFee(Id)}'),
      headers: _headers,
      body: jsonEncode(body),
    );

    print('payment/fillingfee → ${response.statusCode}: ${response.body}');

    _checkStatus(response, 'payment/fillingfee');
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    _checkSuccess(json, 'payment/fillingfee');

    final data = json['data'];
    final txJson = (data is List ? data.first : data) as Map<String, dynamic>;
    return FilingFeeResult.fromJson(txJson);
  }

  /// POST /tools/taxation/filling/payment/liabilityfee
  Future<LiabilityFeeResult> payLiabilityFee({
    required String pin,
    required String Id,
  }) async {
    final body = <String, String>{'Pin': pin};

    print('ID: $Id');

    final response = await http.post(
      Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.filingLiabilityFee(Id)}'),
      headers: _headers,
      body: jsonEncode(body),
    );

    print('payment/liabilityfee → ${response.statusCode}: ${response.body}');

    _checkStatus(response, 'payment/liabilityfee');
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    _checkSuccess(json, 'payment/liabilityfee');
    return LiabilityFeeResult.fromJson(json['data'] as Map<String, dynamic>);
  }

  void _checkStatus(http.Response resp, String ep) {
    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      String msg = 'Request failed (${resp.statusCode})';
      try {
        final body = jsonDecode(resp.body) as Map<String, dynamic>;
        if (body['message'] != null) msg = body['message'] as String;
      } catch (_) {}
      throw Exception(msg);
    }
  }

  void _logResponse(http.Response response) {
    if (!kDebugMode) return;
    log('╔════════════════════════════════════════════════════════════════');
    log('║ RESPONSE');
    log('╠════════════════════════════════════════════════════════════════');
    log('║ Status Code: ${response.statusCode}');
    log('║ Reason Phrase: ${response.reasonPhrase ?? "No reason provided"}');
    log('║ URL: ${response.request?.url.toString() ?? "unknown"}');
    log('║ Body preview: ${response.body}');
    log('╚════════════════════════════════════════════════════════════════');
  }

  void _checkSuccess(Map<String, dynamic> json, String ep) {
    if (json['success'] != true) {
      throw Exception(json['message'] ?? '$ep returned success=false');
    }
  }
}// // lib/features/tools/data/repositories/filing_payment_repository.dart





// import 'dart:convert';
// import 'dart:developer';
// import 'package:flutter/foundation.dart';
// import 'package:http/http.dart' as http;
// import 'package:savvy_bee_mobile/core/network/api_endpoints.dart';
// import 'package:savvy_bee_mobile/features/tools/domain/models/filing_home_data.dart';

// // ── Contact info model (new in payment/init) ──────────────────────────────────

// class FilingContactInfo {
//   final String phoneNo;
//   final String address;
//   final String email;

//   const FilingContactInfo({
//     required this.phoneNo,
//     required this.address,
//     required this.email,
//   });

//   Map<String, dynamic> toJson() => {
//     'PhoneNo': phoneNo,
//     'Address': address,
//     'Email': email,
//   };
// }

// // ── Result models ─────────────────────────────────────────────────────────────

// class FilingInitResult {
//   final String id;
//   final String plan;
//   final String status;
//   final FillingFinanceDetails financeDetails;

//   const FilingInitResult({
//     required this.id,
//     required this.plan,
//     required this.status,
//     required this.financeDetails,
//   });

//   factory FilingInitResult.fromJson(Map<String, dynamic> json) =>
//       FilingInitResult(
//         id: (json['_id'] as String? ?? ''),
//         plan: (json['Plan'] as String? ?? ''),
//         status: (json['Status'] as String? ?? ''),
//         financeDetails: FillingFinanceDetails.fromJson(
//           json['FinanceDetails'] as Map<String, dynamic>? ?? {},
//         ),
//       );
// }

// class FilingFeeResult {
//   final String transactionId;
//   final double amount;
//   final String status;
//   final String narration;

//   const FilingFeeResult({
//     required this.transactionId,
//     required this.amount,
//     required this.status,
//     required this.narration,
//   });

//   factory FilingFeeResult.fromJson(Map<String, dynamic> json) =>
//       FilingFeeResult(
//         transactionId: (json['id'] as String? ?? ''),
//         amount: double.tryParse(json['Amount']?.toString() ?? '0') ?? 0.0,
//         status: (json['Status'] as String? ?? ''),
//         narration: (json['Narration'] as String? ?? ''),
//       );
// }

// class LiabilityFeeResult {
//   final String id;
//   final FillingStatus status;
//   final FillingFinanceDetails financeDetails;

//   const LiabilityFeeResult({
//     required this.id,
//     required this.status,
//     required this.financeDetails,
//   });

//   factory LiabilityFeeResult.fromJson(Map<String, dynamic> json) =>
//       LiabilityFeeResult(
//         id: (json['_id'] as String? ?? ''),
//         status: FillingStatus.fromString(json['Status'] as String? ?? ''),
//         financeDetails: FillingFinanceDetails.fromJson(
//           json['FinanceDetails'] as Map<String, dynamic>? ?? {},
//         ),
//       );
// }

// // ── Repository ────────────────────────────────────────────────────────────────

// class FilingPaymentRepository {
//   static const _base = ApiEndpoints.baseUrl;

//   final String bearerToken;
//   const FilingPaymentRepository({required this.bearerToken});

//   Map<String, String> get _headers => {
//     'Authorization': 'Bearer $bearerToken',
//     'Content-Type': 'application/json',
//   };

//   /// POST /tools/taxation/filling/payment/init
//   ///
//   /// New required fields (as of latest API version):
//   ///   [classification] → "Individual" or "Coperate"
//   ///   [name]           → taxpayer / business full name
//   ///   [cacNumber]      → CAC registration number (businesses only; pass '' for individuals)
//   ///   [contact]        → phone, address, email
//   Future<FilingInitResult> initPayment({
//     required String plan,
//     required String tin,
//     required String classification,
//     required String name,
//     required String cacNumber,
//     required FilingContactInfo contact,
//     required List<FilingIncomeSource> revenues,
//     required List<FilingIncomeSource> noneTaxableRevenues,
//   }) async {
//     final body = <String, dynamic>{
//       'Plan': plan == 'Basic PAYE'
//           ? 'Basic PAYE'
//           : plan == 'Freelancer'
//           ? 'Freelance'
//           : plan == 'SME Lite'
//           ? 'SME Lite'
//           : 'Pro Complex',
//       'TIN': tin,
//       'Classification': classification, // "Individual" | "Coperate"
//       'Name': name,
//       'CACNumber': cacNumber,
//       'Revenues': revenues.map((r) => r.toJson()).toList(),
//       'NoneTaxableRevenues': noneTaxableRevenues
//           .map((r) => r.toJson())
//           .toList(),
//       'Contact': contact.toJson(),
//     };

//     print('Request Body: $body');

//     // Only include CACNumber when it is non-empty (corporate filers)
//     if (cacNumber.isNotEmpty) body['CACNumber'] = cacNumber;

//     final response = await http.post(
//       Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.filingPaymentInit}'),
//       headers: _headers,
//       body: jsonEncode(body),
//     );

//     _logResponse(response);

//     print('payment/init → ${response.statusCode}: ${response.body}');

//     _checkStatus(response, 'payment/init');
//     final json = jsonDecode(response.body) as Map<String, dynamic>;
//     _checkSuccess(json, 'payment/init');
//     return FilingInitResult.fromJson(json['data'] as Map<String, dynamic>);
//   }

//   /// POST /tools/taxation/filling/payment/fillingfee  (form-data)
//   Future<FilingFeeResult> payFillingFee({
//     required String pin,
//     required String Id,
//   }) async {
//     // final req =
//     //     http.MultipartRequest(
//     //         'POST',
//     //         Uri.parse('$_base/tools/taxation/filling/payment/fillingfee'),
//     //       )
//     //       ..headers['Authorization'] = 'Bearer $bearerToken'
//     //       ..fields['Pin'] = pin;

//     // final streamed = await req.send();
//     // final response = await http.Response.fromStream(streamed);

//     final body = <String, String>{'Pin': pin};

//     print('ID: $Id');

//     final response = await http.post(
//       Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.filingFillingFee(Id)}'),
//       headers: _headers,
//       body: jsonEncode(body),
//     );

//     print('payment/fillingfee → ${response.statusCode}: ${response.body}');

//     _checkStatus(response, 'payment/fillingfee');
//     final json = jsonDecode(response.body) as Map<String, dynamic>;
//     _checkSuccess(json, 'payment/fillingfee');

//     final data = json['data'];
//     final txJson = (data is List ? data.first : data) as Map<String, dynamic>;
//     return FilingFeeResult.fromJson(txJson);
//   }

//   /// POST /tools/taxation/filling/payment/liabilityfee  (form-data)
//   Future<LiabilityFeeResult> payLiabilityFee({
//     required String pin,
//     required String Id,
//   }) async {
//     // final req =
//     //     http.MultipartRequest(
//     //         'POST',
//     //         Uri.parse('$_base/tools/taxation/filling/payment/liabilityfee'),
//     //       )
//     //       ..headers['Authorization'] = 'Bearer $bearerToken'
//     //       ..fields['Pin'] = pin;

//     // final streamed = await req.send();
//     // final response = await http.Response.fromStream(streamed);

//     final body = <String, String>{'Pin': pin};

//     print('ID: $Id');

//     final response = await http.post(
//       Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.filingLiabilityFee(Id)}'),
//       headers: _headers,
//       body: jsonEncode(body),
//     );

//     print('payment/liabilityfee → ${response.statusCode}: ${response.body}');

//     _checkStatus(response, 'payment/liabilityfee');
//     final json = jsonDecode(response.body) as Map<String, dynamic>;
//     _checkSuccess(json, 'payment/liabilityfee');
//     return LiabilityFeeResult.fromJson(json['data'] as Map<String, dynamic>);
//   }

//   void _checkStatus(http.Response resp, String ep) {
//     if (resp.statusCode < 200 || resp.statusCode >= 300) {
//       // Try to surface the API's own message if available
//       String msg = 'Request failed (${resp.statusCode})';
//       try {
//         final body = jsonDecode(resp.body) as Map<String, dynamic>;
//         if (body['message'] != null) msg = body['message'] as String;
//       } catch (_) {}
//       throw Exception(msg);
//     }
//   }

//   /// Enhanced response logging
//   void _logResponse(http.Response response) {
//     if (!kDebugMode) return;

//     log('╔════════════════════════════════════════════════════════════════');
//     log('║ RESPONSE');
//     log('╠════════════════════════════════════════════════════════════════');
//     log('║ Status Code: ${response.statusCode}');
//     log('║ Reason Phrase: ${response.reasonPhrase ?? "No reason provided"}');
//     log('║ URL: ${response.request?.url.toString() ?? "unknown"}');

//     // if (response.headers.isNotEmpty) {
//     //   log('║ Headers: ${response.headers}');
//     // }

//     final bodyPreview = response.body;

//     log('║ Body preview: $bodyPreview');
//     log('╚════════════════════════════════════════════════════════════════');
//   }

//   void _checkSuccess(Map<String, dynamic> json, String ep) {
//     if (json['success'] != true) {
//       // Surface the API message directly — e.g. "You have begun your filling
//       // process for the year already, kindly go check the current Status!"
//       throw Exception(json['message'] ?? '$ep returned success=false');
//     }
//   }
// }
