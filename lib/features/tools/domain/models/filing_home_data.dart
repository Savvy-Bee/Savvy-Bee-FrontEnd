// lib/features/tools/domain/models/filing_home_data.dart

class FilingIncomeSource {
  final String source;
  final double amount;

  const FilingIncomeSource({required this.source, required this.amount});

  factory FilingIncomeSource.fromJson(Map<String, dynamic> json) =>
      FilingIncomeSource(
        source: json['Source'] as String,
        amount: ((json['Amount'] as num)).toDouble(),
      );

  Map<String, dynamic> toJson() => {'Source': source, 'Amount': amount};
}

class FilingStages {
  final double stage1;
  final double stage2;
  final double stage3;
  final double stage4;
  final double stage5;
  final double stage6;

  const FilingStages({
    required this.stage1,
    required this.stage2,
    required this.stage3,
    required this.stage4,
    required this.stage5,
    required this.stage6,
  });

  factory FilingStages.fromJson(Map<String, dynamic> json) {
    double p(String k) => ((json[k] as num)).toDouble();
    return FilingStages(
      stage1: p('stage1'),
      stage2: p('stage2'),
      stage3: p('stage3'),
      stage4: p('stage4'),
      stage5: p('stage5'),
      stage6: p('stage6'),
    );
  }
}

// ── FillingProcess ────────────────────────────────────────────────────────────

enum FillingStatus {
  pendingPayment,
  payedFillingFee,
  payedLiabilityFee,
  validatingTax,
  rejected,
  completed,
  failed,
  unknown;

  static FillingStatus fromString(String raw) => switch (raw) {
    'PendingPayment' => FillingStatus.pendingPayment,
    'Payed-Fillingfee' => FillingStatus.payedFillingFee,
    'Payed-Liabilityfee' => FillingStatus.payedLiabilityFee,
    'ValidatingTax' => FillingStatus.validatingTax,
    'Rejected' => FillingStatus.rejected,
    'Completed' => FillingStatus.completed,
    'Failed' => FillingStatus.failed,
    _ => FillingStatus.unknown,
  };

  String get displayLabel => switch (this) {
    FillingStatus.pendingPayment => 'Pending Payment',
    FillingStatus.payedFillingFee => 'Filing Fee Paid',
    FillingStatus.payedLiabilityFee => 'Liability Paid',
    FillingStatus.validatingTax => 'Validating Tax',
    FillingStatus.rejected => 'Rejected',
    FillingStatus.completed => 'Completed',
    FillingStatus.failed => 'Failed',
    FillingStatus.unknown => 'Unknown',
  };
}

class FillingFinanceDetails {
  final List<FilingIncomeSource> revenues;
  final double annualRevenue;
  final List<FilingIncomeSource> noneTaxableRevenues;
  final double noneTaxableIncome;
  final double taxableIncome;
  final double effectiveTaxRate;
  final double taxAmount;

  const FillingFinanceDetails({
    required this.revenues,
    required this.annualRevenue,
    required this.noneTaxableRevenues,
    required this.noneTaxableIncome,
    required this.taxableIncome,
    required this.effectiveTaxRate,
    required this.taxAmount,
  });

  factory FillingFinanceDetails.fromJson(Map<String, dynamic> json) {
    double p(String k) => ((json[k] as num? ?? 0)).toDouble();
    return FillingFinanceDetails(
      revenues: (json['Revenues'] as List? ?? [])
          .map((e) => FilingIncomeSource.fromJson(e as Map<String, dynamic>))
          .toList(),
      annualRevenue: p('AnnualRevenue'),
      noneTaxableRevenues: (json['NoneTaxableRevenues'] as List? ?? [])
          .map((e) => FilingIncomeSource.fromJson(e as Map<String, dynamic>))
          .toList(),
      noneTaxableIncome: p('NoneTaxableIncome'),
      taxableIncome: p('TaxableIncome'),
      effectiveTaxRate: p('EffectiveTaxRate'),
      taxAmount: p('TaxAmount'),
    );
  }

  double deductionFor(String keyword) {
    final match = noneTaxableRevenues.where(
      (r) => r.source.toLowerCase().contains(keyword.toLowerCase()),
    );
    return match.isEmpty ? 0.0 : match.first.amount;
  }
}

class FillingProcess {
  final String id;
  final String plan;
  final FillingStatus status;
  final int year;
  final FillingFinanceDetails financeDetails;

  const FillingProcess({
    required this.id,
    required this.plan,
    required this.status,
    required this.year,
    required this.financeDetails,
  });

  factory FillingProcess.fromJson(Map<String, dynamic> json) => FillingProcess(
    id: (json['_id'] as String? ?? ''),
    plan: (json['Plan'] as String? ?? ''),
    status: FillingStatus.fromString(json['Status'] as String? ?? ''),
    year: (json['Year'] as num? ?? 0).toInt(),
    financeDetails: FillingFinanceDetails.fromJson(
      json['FinanceDetails'] as Map<String, dynamic>? ?? {},
    ),
  );
}

// ── Main model ────────────────────────────────────────────────────────────────

class FilingHomeData {
  final double totalEarnings;
  final double taxableIncome;
  final double estimatedTax;
  final double estimatedPAYE;
  final double taxRate;
  final double taxPot;
  final List<FilingIncomeSource> incomes;
  final FilingStages stages;

  /// Null when the user has no active filing process.
  final FillingProcess? fillingProcess;

  const FilingHomeData({
    required this.totalEarnings,
    required this.taxableIncome,
    required this.estimatedTax,
    required this.estimatedPAYE,
    required this.taxRate,
    required this.taxPot,
    required this.incomes,
    required this.stages,
    this.fillingProcess,
  });

  factory FilingHomeData.fromJson(Map<String, dynamic> json) {
    double p(String k) => ((json[k] as num)).toDouble();

    FillingProcess? process;
    final raw = json['FillingProcess'];
    if (raw != null && raw is Map<String, dynamic>) {
      process = FillingProcess.fromJson(raw);
    }

    return FilingHomeData(
      totalEarnings: p('TotalEarnings'),
      taxableIncome: p('TaxableIncome'),
      estimatedTax: p('EstimatedTax'),
      estimatedPAYE: p('EstimatedPAYE'),
      taxRate: (json['TaxRate'] as num).toDouble(),
      taxPot: p('TaxPot'),
      incomes: (json['Incomes'] as List)
          .map((e) => FilingIncomeSource.fromJson(e as Map<String, dynamic>))
          .toList(),
      stages: FilingStages.fromJson(json['Stages'] as Map<String, dynamic>),
      fillingProcess: process,
    );
  }

  bool get taxPotCoversLiability => taxPot >= estimatedTax;
  double get taxPotCoverageRatio =>
      estimatedTax > 0 ? taxPot / estimatedTax : 0;
  double get taxPotRemainder => taxPot - estimatedTax;
  bool get hasActiveProcess => fillingProcess != null;
}

// // lib/features/tools/domain/models/filing_home_data.dart

// class FilingIncomeSource {
//   final String source;
//   final double amount;

//   const FilingIncomeSource({required this.source, required this.amount});

//   factory FilingIncomeSource.fromJson(Map<String, dynamic> json) {
//     return FilingIncomeSource(
//       source: json['Source'] as String,
//       amount: ((json['Amount'] as num)).toDouble(),
//     );
//   }
// }

// class FilingStages {
//   final double stage1;
//   final double stage2;
//   final double stage3;
//   final double stage4;
//   final double stage5;
//   final double stage6;

//   const FilingStages({
//     required this.stage1,
//     required this.stage2,
//     required this.stage3,
//     required this.stage4,
//     required this.stage5,
//     required this.stage6,
//   });

//   factory FilingStages.fromJson(Map<String, dynamic> json) {
//     double _parse(String key) => ((json[key] as num)).toDouble();

//     return FilingStages(
//       stage1: _parse('stage1'),
//       stage2: _parse('stage2'),
//       stage3: _parse('stage3'),
//       stage4: _parse('stage4'),
//       stage5: _parse('stage5'),
//       stage6: _parse('stage6'),
//     );
//   }
// }

// class FilingHomeData {
//   /// Total earnings across all income sources.
//   final double totalEarnings;

//   /// Portion of earnings that is taxable.
//   final double taxableIncome;

//   /// Estimated annual tax liability.
//   final double estimatedTax;

//   /// Estimated PAYE component.
//   final double estimatedPAYE;

//   /// Effective tax rate as a percentage (e.g. 18 means 18%).
//   final double taxRate;

//   /// Current Tax Pot balance.
//   final double taxPot;

//   /// Individual income sources.
//   final List<FilingIncomeSource> incomes;

//   /// Per-stage breakdown amounts.
//   final FilingStages stages;

//   const FilingHomeData({
//     required this.totalEarnings,
//     required this.taxableIncome,
//     required this.estimatedTax,
//     required this.estimatedPAYE,
//     required this.taxRate,
//     required this.taxPot,
//     required this.incomes,
//     required this.stages,
//   });

//   factory FilingHomeData.fromJson(Map<String, dynamic> json) {
//     double _parse(String key) => ((json[key] as num)).toDouble();

//     return FilingHomeData(
//       totalEarnings: _parse('TotalEarnings'),
//       taxableIncome: _parse('TaxableIncome'),
//       estimatedTax: _parse('EstimatedTax'),
//       estimatedPAYE: _parse('EstimatedPAYE'),
//       taxRate: (json['TaxRate'] as num).toDouble(), // already a %
//       taxPot: _parse('TaxPot'),
//       incomes: (json['Incomes'] as List)
//           .map((e) => FilingIncomeSource.fromJson(e as Map<String, dynamic>))
//           .toList(),
//       stages: FilingStages.fromJson(json['Stages'] as Map<String, dynamic>),
//     );
//   }

//   /// Whether the Tax Pot fully covers the estimated tax.
//   bool get taxPotCoversLiability => taxPot >= estimatedTax;

//   /// How much of the tax is covered by the Tax Pot (0.0 – 1.0+).
//   double get taxPotCoverageRatio =>
//       estimatedTax > 0 ? taxPot / estimatedTax : 0;

//   /// Remaining Tax Pot balance after paying the tax.
//   double get taxPotRemainder => taxPot - estimatedTax;
// }
