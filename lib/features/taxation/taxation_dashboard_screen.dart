import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';

class TaxationDashboardScreen extends ConsumerStatefulWidget {
  static const String path = '/taxation-dashboard';

  const TaxationDashboardScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _TaxationDashboardScreenState();
}

class _TaxationDashboardScreenState
    extends ConsumerState<TaxationDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tax')),
      
    );
  }
}
