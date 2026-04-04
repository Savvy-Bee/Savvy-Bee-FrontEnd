// lib/features/tools/data/repositories/complex_paye_repository.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:savvy_bee_mobile/core/network/api_endpoints.dart';
import 'package:savvy_bee_mobile/features/tools/domain/models/complex_paye_models.dart';

class ComplexPayeRepository {

  final String bearerToken;
  const ComplexPayeRepository({required this.bearerToken});

  Map<String, String> get _jsonHeaders => {
    'Authorization': 'Bearer $bearerToken',
    'Content-Type': 'application/json',
  };

  Map<String, String> get _authHeader => {
    'Authorization': 'Bearer $bearerToken',
  };

  // ── Submit filing ──────────────────────────────────────────────────────────

  /// POST /tools/taxation/complexpayee/filing
  /// Returns the `_id` of the created record.
  Future<String> submitFiling({
    required String businessName,
    required String tin,
    required String description,
    required String classification,
    required String name,
    required String cacNumber,
    required String phoneNo,
    required String address,
    required String email,
    required List<ComplexPayeIncomeSource> revenues,
    required List<ComplexPayeIncomeSource> noneTaxableRevenues,
  }) async {
    final body = <String, dynamic>{
      'BusinessName': businessName,
      'TIN': tin,
      'Description': description,
      'Classification': classification,
      'Name': name,
      'Contact': {'PhoneNo': phoneNo, 'Address': address, 'Email': email},
      'Revenues': revenues.map((r) => r.toJson()).toList(),
      'NoneTaxableRevenues': noneTaxableRevenues.map((r) => r.toJson()).toList(),
    };
    if (cacNumber.isNotEmpty) body['CACNumber'] = cacNumber;

    print('ComplexPAYE submit body: $body');

    final response = await http.post(
      Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.complexPayeTempFiling}'),
      headers: _jsonHeaders,
      body: jsonEncode(body),
    );

    print('tempfilling/complexpaye → ${response.statusCode}: ${response.body}');

    _checkStatus(response, 'tempfilling/complexpaye');
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    _checkSuccess(json, 'tempfilling/complexpaye');
    final data = json['data'] as Map<String, dynamic>;
    return data['_id'] as String? ?? '';
  }

  // ── Init payment ───────────────────────────────────────────────────────────

  /// PUT /tools/taxation/filling/payment/init/complexpayee/:id
  Future<ComplexPayeInitPaymentResult> initPayment(String id) async {
    final response = await http.put(
      Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.complexPayePaymentInit(id)}'),
      headers: _jsonHeaders,
      body: jsonEncode(<String, dynamic>{}),
    );

    print('payment/init/complexpayee → ${response.statusCode}: ${response.body}');

    _checkStatus(response, 'payment/init/complexpayee');
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    _checkSuccess(json, 'payment/init/complexpayee');
    return ComplexPayeInitPaymentResult.fromJson(
      json['data'] as Map<String, dynamic>,
    );
  }

  // ── Fetch history list ─────────────────────────────────────────────────────

  /// GET /tools/taxation/filling/fetchdata/temp/complexpaye/history
  Future<List<ComplexPayeHistoryItem>> fetchHistory() async {
    final response = await http.get(
      Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.complexPayeTempHistory}'),
      headers: _authHeader,
    );

    _checkStatus(response, 'temp/complexpaye/history');
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    _checkSuccess(json, 'temp/complexpaye/history');
    final data = json['data'] as List<dynamic>? ?? [];
    return data
        .map((e) => ComplexPayeHistoryItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── Fetch single detail ────────────────────────────────────────────────────

  /// GET /tools/taxation/filling/fetchdata/temp/complexpaye/:id
  Future<ComplexPayeDetailRecord> fetchDetail(String id) async {
    final response = await http.get(
      Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.complexPayeTempById(id)}'),
      headers: _authHeader,
    );

    _checkStatus(response, 'temp/complexpaye/$id');
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    _checkSuccess(json, 'temp/complexpaye/$id');
    return ComplexPayeDetailRecord.fromJson(
      json['data'] as Map<String, dynamic>,
    );
  }

  // ── Upload review ──────────────────────────────────────────────────────────

  /// PUT /tools/taxation/filling/operation/tempfilling/review-response/:id
  Future<ComplexPayeReview> uploadReview({
    required String id,
    required String comment,
    List<XFile> files = const [],
  }) async {
    final req = http.MultipartRequest(
      'PUT',
      Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.complexPayeReviewResponse(id)}'),
    )..headers['Authorization'] = 'Bearer $bearerToken';

    req.fields['Comment'] = comment;

    for (final xfile in files) {
      final bytes = await xfile.readAsBytes();
      req.files.add(
        http.MultipartFile.fromBytes('documents', bytes, filename: xfile.name),
      );
    }

    final streamed = await req.send();
    final response = await http.Response.fromStream(streamed);

    _checkStatus(response, 'tempfilling/review-response');
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    _checkSuccess(json, 'tempfilling/review-response');
    return ComplexPayeReview.fromJson(json['data'] as Map<String, dynamic>);
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

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

  void _checkSuccess(Map<String, dynamic> json, String ep) {
    if (json['success'] != true) {
      throw Exception(json['message'] ?? '$ep returned success=false');
    }
  }
}
