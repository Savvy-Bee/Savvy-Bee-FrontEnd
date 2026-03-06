// lib/features/tools/presentation/providers/filing_tax_due_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Written by Step 3 when the user confirms the return.
/// Steps 4, 5, and 6 read this as the authoritative tax liability.
/// Falls back to 0.0 until Step 3 sets it.
final filingTaxDueProvider = StateProvider<double>((ref) => 0.0);