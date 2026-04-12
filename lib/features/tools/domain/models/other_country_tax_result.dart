// lib/features/tools/domain/models/other_country_tax_result.dart

class OtherCountryTaxBreakdown {
  final double from;
  final double? to;
  final double rate;
  final double taxable;
  final double tax;

  const OtherCountryTaxBreakdown({
    required this.from,
    this.to,
    required this.rate,
    required this.taxable,
    required this.tax,
  });

  factory OtherCountryTaxBreakdown.fromJson(Map<String, dynamic> json) {
    return OtherCountryTaxBreakdown(
      from: (json['from'] as num).toDouble(),
      to: json['to'] != null ? (json['to'] as num).toDouble() : null,
      rate: (json['rate'] as num).toDouble(),
      taxable: (json['taxable'] as num).toDouble(),
      tax: (json['tax'] as num).toDouble(),
    );
  }

  /// Human-readable label, e.g. "Up to $12,400 @ 10%"
  String get label {
    final pct = '${(rate * 100).toStringAsFixed(0)}%';
    if (to == null) {
      return 'Above ${_fmt(from)} @ $pct';
    }
    return '${_fmt(from)} – ${_fmt(to!)} @ $pct';
  }

  String _fmt(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}K';
    return v.toStringAsFixed(0);
  }
}

class OtherCountryTaxResult {
  final String country;
  final String countryCode;
  final String currency;
  final String taxYear;
  final double annualIncome;
  final double taxableIncome;
  final double taxYearly;
  final double taxMonthly;
  final double effectiveRate;
  final List<OtherCountryTaxBreakdown> breakdown;

  const OtherCountryTaxResult({
    required this.country,
    required this.countryCode,
    required this.currency,
    required this.taxYear,
    required this.annualIncome,
    required this.taxableIncome,
    required this.taxYearly,
    required this.taxMonthly,
    required this.effectiveRate,
    required this.breakdown,
  });

  factory OtherCountryTaxResult.fromJson(Map<String, dynamic> json) {
    final tax = json['Tax'] as Map<String, dynamic>;
    final inputs = json['Inputs'] as Map<String, dynamic>? ?? {};
    return OtherCountryTaxResult(
      country: json['Country'] as String? ?? '',
      countryCode: json['CountryCode'] as String? ?? '',
      currency: json['Currency'] as String? ?? '',
      taxYear: json['TaxYear'] as String? ?? '',
      annualIncome: (inputs['annualIncome'] as num?)?.toDouble() ?? 0,
      taxableIncome: (json['TaxableIncome'] as num?)?.toDouble() ?? 0,
      taxYearly: (tax['yearly'] as num?)?.toDouble() ?? 0,
      taxMonthly: (tax['monthly'] as num?)?.toDouble() ?? 0,
      effectiveRate: (tax['effectiveRate'] as num?)?.toDouble() ?? 0,
      breakdown: ((json['Breakdown'] as List<dynamic>?) ?? [])
          .map((e) => OtherCountryTaxBreakdown.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  double get finalTaxDue => taxYearly;
}
