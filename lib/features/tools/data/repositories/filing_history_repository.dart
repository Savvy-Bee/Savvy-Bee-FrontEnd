// lib/features/tools/data/repositories/filing_history_repository.dart
//
// Handles:
//   GET  /tools/taxation/filling/fetchdata/history           → List<FilingHistoryItem>
//   GET  /tools/taxation/filling/fetchdata/history/:id       → FilingDetailRecord
//   PUT  /tools/taxation/filling/operation/review-response/:id (multipart)
//
// NOTE: Per API spec all monetary values (AnnualRevenue, TaxAmount,
// NoneTaxableIncome, TaxableIncome) are divided by 100 before use.

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:savvy_bee_mobile/core/network/api_endpoints.dart';
import 'package:savvy_bee_mobile/features/tools/domain/models/filing_home_data.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Models
// ─────────────────────────────────────────────────────────────────────────────

/// Lightweight summary shown in the history list.
class FilingHistoryItem {
  final String id;
  final String plan;
  final FillingStatus status;
  final String? classification;
  final String? accountName; // from AcctsDetails.Name
  /// ÷100 as per API spec
  final double annualRevenue;
  final double effectiveTaxRate;

  /// ÷100 as per API spec
  final double taxAmount;
  final int year;

  const FilingHistoryItem({
    required this.id,
    required this.plan,
    required this.status,
    this.classification,
    this.accountName,
    required this.annualRevenue,
    required this.effectiveTaxRate,
    required this.taxAmount,
    required this.year,
  });

  factory FilingHistoryItem.fromJson(Map<String, dynamic> json) {
    final fd = json['FinanceDetails'] as Map<String, dynamic>? ?? {};
    final accts = json['AcctsDetails'] as Map<String, dynamic>? ?? {};
    return FilingHistoryItem(
      id: json['_id'] as String? ?? '',
      plan: json['Plan'] as String? ?? '',
      status: FillingStatus.fromString(json['Status'] as String? ?? ''),
      classification: json['Classification'] as String?,
      accountName: accts['Name'] as String?,
      annualRevenue: _div100(fd['AnnualRevenue']),
      effectiveTaxRate: _toDouble(fd['EffectiveTaxRate']),
      taxAmount: _div100(fd['TaxAmount']),
      year: json['Year'] as int? ?? DateTime.now().year - 1,
    );
  }
}

// ── Review ────────────────────────────────────────────────────────────────────

class FilingReview {
  final String id;
  final String text;

  /// "User" | "TaxAgency"
  final String from;
  final List<String> documentUrls;
  final DateTime createdAt;

  const FilingReview({
    required this.id,
    required this.text,
    required this.from,
    required this.documentUrls,
    required this.createdAt,
  });

  bool get isFromUser => from == 'User';

  factory FilingReview.fromJson(Map<String, dynamic> json) => FilingReview(
    id: json['_id'] as String? ?? '',
    text: json['Text'] as String? ?? '',
    from: json['From'] as String? ?? '',
    documentUrls: (json['DocumentUpload'] as List<dynamic>? ?? [])
        .map((e) => e.toString())
        .toList(),
    createdAt:
        DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
  );
}

// ── Account/contact details ───────────────────────────────────────────────────

class FilingAcctsDetails {
  final String name;
  final String? phoneNo;
  final String? address;
  final String? email;
  final String? cacNumber;

  const FilingAcctsDetails({
    required this.name,
    this.phoneNo,
    this.address,
    this.email,
    this.cacNumber,
  });

  factory FilingAcctsDetails.fromJson(Map<String, dynamic> json) {
    final contact = json['Contact'] as Map<String, dynamic>? ?? {};
    return FilingAcctsDetails(
      name: json['Name'] as String? ?? '',
      phoneNo: contact['PhoneNo'] as String?,
      address: contact['Address'] as String?,
      email: contact['Email'] as String?,
      cacNumber: json['CACNumber'] as String?,
    );
  }
}

// ── Revenue item ──────────────────────────────────────────────────────────────

class FilingRevenueItem {
  final String source;
  final double amount; // raw, entered by user — not divided

  const FilingRevenueItem({required this.source, required this.amount});

  factory FilingRevenueItem.fromJson(Map<String, dynamic> json) =>
      FilingRevenueItem(
        source: json['Source'] as String? ?? '',
        amount: _toDouble(json['Amount']),
      );
}

// ── Full detail record ────────────────────────────────────────────────────────

class FilingDetailRecord {
  final String id;
  final String plan;
  final FillingStatus status;
  final bool withdrawn;
  final String? classification;
  final FilingAcctsDetails? acctsDetails;

  // Finance (monetary fields ÷100)
  final List<FilingRevenueItem> revenues;
  final double annualRevenue;
  final List<FilingRevenueItem> noneTaxableRevenues;
  final double noneTaxableIncome;
  final double taxableIncome;
  final double effectiveTaxRate;
  final double taxAmount;

  final int year;
  final String? tin;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Present when status == Completed
  final String? filingUploadLink;

  /// Ordered newest-first after fromJson
  final List<FilingReview> reviews;

  const FilingDetailRecord({
    required this.id,
    required this.plan,
    required this.status,
    required this.withdrawn,
    this.classification,
    this.acctsDetails,
    required this.revenues,
    required this.annualRevenue,
    required this.noneTaxableRevenues,
    required this.noneTaxableIncome,
    required this.taxableIncome,
    required this.effectiveTaxRate,
    required this.taxAmount,
    required this.year,
    this.tin,
    this.createdAt,
    this.updatedAt,
    this.filingUploadLink,
    required this.reviews,
  });

  bool get isCompleted => status == FillingStatus.completed;
  bool get canReply => status == FillingStatus.rejected;

  factory FilingDetailRecord.fromJson(Map<String, dynamic> json) {
    final fd = json['FinanceDetails'] as Map<String, dynamic>? ?? {};
    final accts = json['AcctsDetails'] as Map<String, dynamic>?;

    return FilingDetailRecord(
      id: json['_id'] as String? ?? '',
      plan: json['Plan'] as String? ?? '',
      status: FillingStatus.fromString(json['Status'] as String? ?? ''),
      withdrawn: json['Withdrawn'] as bool? ?? false,
      classification: json['Classification'] as String?,
      acctsDetails: accts != null ? FilingAcctsDetails.fromJson(accts) : null,

      revenues: (fd['Revenues'] as List<dynamic>? ?? [])
          .map((e) => FilingRevenueItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      annualRevenue: _div100(fd['AnnualRevenue']),
      noneTaxableRevenues: (fd['NoneTaxableRevenues'] as List<dynamic>? ?? [])
          .map((e) => FilingRevenueItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      noneTaxableIncome: _div100(fd['NoneTaxableIncome']),
      taxableIncome: _div100(fd['TaxableIncome']),
      effectiveTaxRate: _toDouble(fd['EffectiveTaxRate']),
      taxAmount: _div100(fd['TaxAmount']),

      year: json['Year'] as int? ?? DateTime.now().year - 1,
      tin: json['TIN'] as String?,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? ''),
      // API key is "FillingUploadLink" (double-l)
      filingUploadLink: json['FillingUploadLink'] as String?,
      reviews: (json['Reviews'] as List<dynamic>? ?? [])
          .map((e) => FilingReview.fromJson(e as Map<String, dynamic>))
          .toList()
          .reversed
          .toList(), // newest-first
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Repository
// ─────────────────────────────────────────────────────────────────────────────

class FilingHistoryRepository {
  static const _base = ApiEndpoints.baseUrl;

  final String bearerToken;
  const FilingHistoryRepository({required this.bearerToken});

  Map<String, String> get _authHeader => {
    'Authorization': 'Bearer $bearerToken',
  };

  // ── GET history list ───────────────────────────────────────────────────────

  Future<List<FilingHistoryItem>> fetchHistory() async {
    final response = await http.get(
      Uri.parse('$_base/tools/taxation/filling/fetchdata/history'),
      headers: _authHeader,
    );
    _checkStatus(response, 'history');
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    _checkSuccess(json, 'history');
    final data = json['data'] as List<dynamic>? ?? [];
    return data
        .map((e) => FilingHistoryItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── GET single detail ──────────────────────────────────────────────────────

  Future<FilingDetailRecord> fetchDetail(String id) async {
    final response = await http.get(
      Uri.parse('$_base/tools/taxation/filling/fetchdata/history/$id'),
      headers: _authHeader,
    );
    _checkStatus(response, 'history/$id');
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    _checkSuccess(json, 'history/$id');
    return FilingDetailRecord.fromJson(json['data'] as Map<String, dynamic>);
  }

  // ── PUT upload review response ─────────────────────────────────────────────

  /// [comment]   → form field "Comment"
  /// [files]     → XFile attachments for "documents" (multipart)
  Future<FilingReview> uploadReview({
    required String filingId,
    required String comment,
    List<XFile> files = const [],
  }) async {
    final req = http.MultipartRequest(
      'PUT',
      Uri.parse(
        '$_base/tools/taxation/filling/operation/review-response/$filingId',
      ),
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
    _checkStatus(response, 'review-response');
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    _checkSuccess(json, 'review-response');
    return FilingReview.fromJson(json['data'] as Map<String, dynamic>);
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

// ── Private helpers ───────────────────────────────────────────────────────────

double _toDouble(dynamic v) => double.tryParse(v?.toString() ?? '0') ?? 0.0;

/// Divide raw API monetary value by 100 per API spec.
double _div100(dynamic v) => _toDouble(v);
