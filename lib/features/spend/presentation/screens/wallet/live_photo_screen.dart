import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy_bee_mobile/features/spend/presentation/screens/wallet/wallet_creation_complete_screen.dart';

import '../../../../../core/widgets/custom_button.dart';

class LivePhotoScreen extends ConsumerStatefulWidget {
  static String path = '/live-photo';

  const LivePhotoScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _LivePhotoScreenState();
}

class _LivePhotoScreenState extends ConsumerState<LivePhotoScreen> {
  bool isVerifying = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Live Photo')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(),
            Text("Camera view"),
            CustomElevatedButton(
              text: isVerifying ? 'Verifying' : 'Take photo',
              onPressed: () {
                context.pushNamed(WalletCreationCompletionScreen.path);
              },
              showArrow: false,
              isLoading: isVerifying,
              buttonColor: CustomButtonColor.black,
            ),
          ],
        ),
      ),
    );
  }
}
