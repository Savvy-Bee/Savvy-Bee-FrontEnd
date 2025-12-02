import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class CustomLoadingWidget extends StatelessWidget {
  final String? text;

  const CustomLoadingWidget({super.key, this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          const Gap(16),
          Text(text ?? 'Fetching data...'),
        ],
      ),
    );
  }
}
