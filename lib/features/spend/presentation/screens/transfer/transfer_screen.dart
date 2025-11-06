import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TransferScreen extends ConsumerStatefulWidget {
  static String path = '/transfer';

  const TransferScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TransferScreenState();
}

class _TransferScreenState extends ConsumerState<TransferScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('data'),),
    );
  }
}
