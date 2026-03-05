// lib/features/tools/presentation/providers/selected_filing_plan_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Holds the name of the plan the user selected in Step 2.
/// Step 2 writes to this; Step 3 reads from it for Filing Status.
final selectedFilingPlanProvider = StateProvider<String>((ref) => 'Freelancer');