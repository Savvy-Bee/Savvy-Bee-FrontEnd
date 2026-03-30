// lib/features/tools/domain/models/complex_paye_models.dart

// ── Status enum ───────────────────────────────────────────────────────────────

enum ComplexPayeStatus {
  processing,
  assignedPrice,
  pendingPayment,
  finished,
  rejected,
  unknown;

  static ComplexPayeStatus fromString(String raw) {
    switch (raw) {
      case 'Processing':
        return processing;
      case 'Assigned-Price':
        return assignedPrice;
      case 'PendingPayment':
        return pendingPayment;
      case 'Finished':
        return finished;
      case 'Rejected':
        return rejected;
      default:
        return unknown;
    }
  }

  String get displayLabel {
    switch (this) {
      case processing:
        return 'Processing';
      case assignedPrice:
        return 'Price Assigned';
      case pendingPayment:
        return 'Pending Payment';
      case finished:
        return 'Finished';
      case rejected:
        return 'Rejected';
      case unknown:
        return 'Unknown';
    }
  }
}

// ── Income source ─────────────────────────────────────────────────────────────

class ComplexPayeIncomeSource {
  final String source;
  final double amount;

  const ComplexPayeIncomeSource({required this.source, required this.amount});

  Map<String, dynamic> toJson() => {'Source': source, 'Amount': amount};

  factory ComplexPayeIncomeSource.fromJson(Map<String, dynamic> json) =>
      ComplexPayeIncomeSource(
        source: json['Source'] as String? ?? '',
        amount: _toDouble(json['Amount']),
      );
}

// ── Review ────────────────────────────────────────────────────────────────────

class ComplexPayeReview {
  final String id;
  final String text;
  final String from;
  final List<String> documentUrls;
  final DateTime createdAt;

  const ComplexPayeReview({
    required this.id,
    required this.text,
    required this.from,
    required this.documentUrls,
    required this.createdAt,
  });

  bool get isFromUser => from == 'User';

  factory ComplexPayeReview.fromJson(Map<String, dynamic> json) =>
      ComplexPayeReview(
        id: json['_id'] as String? ?? '',
        text: json['Text'] as String? ?? '',
        from: json['From'] as String? ?? '',
        documentUrls: (json['DocumentUpload'] as List<dynamic>? ?? [])
            .map((e) => e.toString())
            .toList(),
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
            DateTime.now(),
      );
}

// ── History item ──────────────────────────────────────────────────────────────

class ComplexPayeHistoryItem {
  final String id;
  final String businessName;
  final ComplexPayeStatus status;
  final double filingFee;
  final double taxLiability;
  final int year;

  const ComplexPayeHistoryItem({
    required this.id,
    required this.businessName,
    required this.status,
    required this.filingFee,
    required this.taxLiability,
    required this.year,
  });

  factory ComplexPayeHistoryItem.fromJson(Map<String, dynamic> json) {
    final fd = json['FinanceDetails'] as Map<String, dynamic>? ?? {};
    return ComplexPayeHistoryItem(
      id: json['_id'] as String? ?? '',
      businessName: json['BusinessName'] as String? ?? '',
      status: ComplexPayeStatus.fromString(json['Status'] as String? ?? ''),
      filingFee: _toDouble(fd['PayePrice']),
      taxLiability: _toDouble(fd['TaxAmount']),
      year: json['Year'] as int? ?? DateTime.now().year - 1,
    );
  }
}

// ── Detail record ─────────────────────────────────────────────────────────────

class ComplexPayeDetailRecord {
  final String id;
  final String businessName;
  final String tin;
  final String description;
  final String classification;
  final String name;
  final String cacNumber;
  final String phone;
  final String address;
  final String email;
  final List<ComplexPayeIncomeSource> revenues;
  final List<ComplexPayeIncomeSource> noneTaxableRevenues;
  final ComplexPayeStatus status;
  final double filingFee;
  final double taxLiability;
  final double assignedPrice;
  final List<ComplexPayeReview> reviews;
  final int year;
  final DateTime? createdAt;

  const ComplexPayeDetailRecord({
    required this.id,
    required this.businessName,
    required this.tin,
    required this.description,
    required this.classification,
    required this.name,
    required this.cacNumber,
    required this.phone,
    required this.address,
    required this.email,
    required this.revenues,
    required this.noneTaxableRevenues,
    required this.status,
    required this.filingFee,
    required this.taxLiability,
    required this.assignedPrice,
    required this.reviews,
    required this.year,
    this.createdAt,
  });

  bool get canReply => status == ComplexPayeStatus.processing;
  bool get canPay => status == ComplexPayeStatus.assignedPrice ||
      status == ComplexPayeStatus.pendingPayment;
  bool get autoTriggerPayment => status == ComplexPayeStatus.pendingPayment;
  bool get isFinished => status == ComplexPayeStatus.finished;
  bool get isRejected => status == ComplexPayeStatus.rejected;

  factory ComplexPayeDetailRecord.fromJson(Map<String, dynamic> json) {
    final fd = json['FinanceDetails'] as Map<String, dynamic>? ?? {};
    final contact = json['Contact'] as Map<String, dynamic>? ?? {};
    return ComplexPayeDetailRecord(
      id: json['_id'] as String? ?? '',
      businessName: json['BusinessName'] as String? ?? '',
      tin: json['TIN'] as String? ?? '',
      description: json['Description'] as String? ?? '',
      classification: json['Classification'] as String? ?? '',
      name: json['Name'] as String? ?? '',
      cacNumber: json['CACNumber'] as String? ?? '',
      phone: contact['PhoneNo'] as String? ?? '',
      address: contact['Address'] as String? ?? '',
      email: contact['Email'] as String? ?? '',
      revenues: (fd['Revenues'] as List<dynamic>? ?? [])
          .map((e) => ComplexPayeIncomeSource.fromJson(e as Map<String, dynamic>))
          .toList(),
      noneTaxableRevenues:
          (fd['NoneTaxableRevenues'] as List<dynamic>? ?? [])
              .map(
                (e) => ComplexPayeIncomeSource.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList(),
      status: ComplexPayeStatus.fromString(json['Status'] as String? ?? ''),
      filingFee: _toDouble(fd['PayePrice']),
      taxLiability: _toDouble(fd['TaxAmount']),
      assignedPrice: _toDouble(fd['AssignedPrice']),
      reviews: (json['Reviews'] as List<dynamic>? ?? [])
          .map((e) => ComplexPayeReview.fromJson(e as Map<String, dynamic>))
          .toList()
          .reversed
          .toList(),
      year: json['Year'] as int? ?? DateTime.now().year - 1,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
    );
  }
}

// ── Payment result ────────────────────────────────────────────────────────────

class ComplexPayeInitPaymentResult {
  final String id;
  final double filingFee;
  final double taxLiability;
  final double walletBalance;

  const ComplexPayeInitPaymentResult({
    required this.id,
    required this.filingFee,
    required this.taxLiability,
    required this.walletBalance,
  });

  factory ComplexPayeInitPaymentResult.fromJson(Map<String, dynamic> json) {
    final fd = json['FinanceDetails'] as Map<String, dynamic>? ?? {};
    return ComplexPayeInitPaymentResult(
      id: json['_id'] as String? ?? '',
      filingFee: _toDouble(fd['PayePrice']),
      taxLiability: _toDouble(fd['TaxAmount']),
      walletBalance:
          double.tryParse(json['Wallet']?.toString() ?? '0') ?? 0.0,
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

double _toDouble(dynamic v) => double.tryParse(v?.toString() ?? '0') ?? 0.0;
