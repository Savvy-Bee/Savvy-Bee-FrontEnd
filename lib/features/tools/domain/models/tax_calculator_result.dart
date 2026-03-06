// lib/features/tools/domain/models/tax_calculator_result.dart

class TaxCalculatorStages {
  final double stage1;
  final double stage2;
  final double stage3;
  final double stage4;
  final double stage5;
  final double stage6;

  const TaxCalculatorStages({
    required this.stage1,
    required this.stage2,
    required this.stage3,
    required this.stage4,
    required this.stage5,
    required this.stage6,
  });

  factory TaxCalculatorStages.fromJson(Map<String, dynamic> json) {
    double _p(String k) => ((json[k] as num)).toDouble();
    return TaxCalculatorStages(
      stage1: _p('stage1'),
      stage2: _p('stage2'),
      stage3: _p('stage3'),
      stage4: _p('stage4'),
      stage5: _p('stage5'),
      stage6: _p('stage6'),
    );
  }

  /// All non-zero stages as label → value pairs for display.
  List<MapEntry<String, double>> get nonZeroEntries {
    final labels = [
      'First ₦800,000 @ 0%',
      'Next ₦2,200,000 @ 15%',
      'Next ₦9,000,000 @ 18%',
      'Next ₦13,000,000 @ 21%',
      'Next ₦25,000,000 @ 23%',
      'Next ₦50,000,000 @ 25%',
    ];
    final values = [stage1, stage2, stage3, stage4, stage5, stage6];
    return [
      for (int i = 0; i < 6; i++)
        if (i != 0 && values[i] != 0) MapEntry(labels[i], values[i]),
    ];
  }

  double get total => stage1 + stage2 + stage3 + stage4 + stage5 + stage6;
}

class TaxCalculatorResult {
  final double totalEarnings;
  final double taxYearly;
  final double taxMonthly;
  final double taxRate;

  /// Total exemptions / deductions applied.
  final double exemption;

  /// Taxable income after exemptions.
  final double taxableIncome;

  final TaxCalculatorStages stages;

  const TaxCalculatorResult({
    required this.totalEarnings,
    required this.taxYearly,
    required this.taxMonthly,
    required this.taxRate,
    required this.exemption,
    required this.taxableIncome,
    required this.stages,
  });

  factory TaxCalculatorResult.fromJson(Map<String, dynamic> json) {
    final tax = json['Tax'] as Map<String, dynamic>;
    return TaxCalculatorResult(
      totalEarnings: ((json['TotalEarnings'] as num)).toDouble(),
      taxYearly: ((tax['yearly'] as num)).toDouble(),
      taxMonthly: ((tax['monthly'] as num)).toDouble(),
      taxRate: ((tax['Rate'] as num)).toDouble(),
      exemption: ((tax['Exemption'] as num)).toDouble(),
      taxableIncome:
          ((json['TotalEarnings'] as num)).toDouble() -
          ((tax['Exemption'] as num)).toDouble(),
      stages: TaxCalculatorStages.fromJson(
        tax['Stages'] as Map<String, dynamic>,
      ),
    );
  }

  double get finalTaxDue => stages.total;
}
