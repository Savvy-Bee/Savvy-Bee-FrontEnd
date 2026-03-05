// lib/features/tools/domain/models/filing_home_data.dart

class FilingIncomeSource {
  final String source;
  final double amount;

  const FilingIncomeSource({required this.source, required this.amount});

  factory FilingIncomeSource.fromJson(Map<String, dynamic> json) {
    return FilingIncomeSource(
      source: json['Source'] as String,
      amount: ((json['Amount'] as num)).toDouble(),
    );
  }
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
    double _parse(String key) => ((json[key] as num)).toDouble();

    return FilingStages(
      stage1: _parse('stage1'),
      stage2: _parse('stage2'),
      stage3: _parse('stage3'),
      stage4: _parse('stage4'),
      stage5: _parse('stage5'),
      stage6: _parse('stage6'),
    );
  }
}

class FilingHomeData {
  /// Total earnings across all income sources.
  final double totalEarnings;

  /// Portion of earnings that is taxable.
  final double taxableIncome;

  /// Estimated annual tax liability.
  final double estimatedTax;

  /// Estimated PAYE component.
  final double estimatedPAYE;

  /// Effective tax rate as a percentage (e.g. 18 means 18%).
  final double taxRate;

  /// Current Tax Pot balance.
  final double taxPot;

  /// Individual income sources.
  final List<FilingIncomeSource> incomes;

  /// Per-stage breakdown amounts.
  final FilingStages stages;

  const FilingHomeData({
    required this.totalEarnings,
    required this.taxableIncome,
    required this.estimatedTax,
    required this.estimatedPAYE,
    required this.taxRate,
    required this.taxPot,
    required this.incomes,
    required this.stages,
  });

  factory FilingHomeData.fromJson(Map<String, dynamic> json) {
    double _parse(String key) => ((json[key] as num)).toDouble();

    return FilingHomeData(
      totalEarnings: _parse('TotalEarnings'),
      taxableIncome: _parse('TaxableIncome'),
      estimatedTax: _parse('EstimatedTax'),
      estimatedPAYE: _parse('EstimatedPAYE'),
      taxRate: (json['TaxRate'] as num).toDouble(), // already a %
      taxPot: _parse('TaxPot'),
      incomes: (json['Incomes'] as List)
          .map((e) => FilingIncomeSource.fromJson(e as Map<String, dynamic>))
          .toList(),
      stages: FilingStages.fromJson(json['Stages'] as Map<String, dynamic>),
    );
  }

  /// Whether the Tax Pot fully covers the estimated tax.
  bool get taxPotCoversLiability => taxPot >= estimatedTax;

  /// How much of the tax is covered by the Tax Pot (0.0 – 1.0+).
  double get taxPotCoverageRatio =>
      estimatedTax > 0 ? taxPot / estimatedTax : 0;

  /// Remaining Tax Pot balance after paying the tax.
  double get taxPotRemainder => taxPot - estimatedTax;
}
