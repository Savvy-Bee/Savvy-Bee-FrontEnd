import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GameplayScreen extends ConsumerStatefulWidget {
  static const String path = '/gameplay';

  const GameplayScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _GameplayScreenState();
}

class _GameplayScreenState extends ConsumerState<GameplayScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/gameplay_bg.png'),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
