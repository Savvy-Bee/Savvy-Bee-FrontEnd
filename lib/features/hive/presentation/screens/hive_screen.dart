import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HiveScreen extends ConsumerStatefulWidget {
  static String path = '/hive';

  const HiveScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HiveScreenState();
}

class _HiveScreenState extends ConsumerState<HiveScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
      ),
    );
  }
}
