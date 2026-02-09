import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';

class ArcadeWebViewScreen extends StatefulWidget {
  static const String path = '/arcade-webview';

  const ArcadeWebViewScreen({super.key});

  @override
  State<ArcadeWebViewScreen> createState() => _ArcadeWebViewScreenState();
}

class _ArcadeWebViewScreenState extends State<ArcadeWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _gameCompletedOrRedirected = false;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() => _isLoading = true);
          },
          onPageFinished: (String url) async {
            setState(() => _isLoading = false);

            // Optional: improve mobile look (remove margins, hide headers if any)
            await _controller.runJavaScript('''
              document.body.style.margin = '0';
              document.body.style.padding = '0';
              document.documentElement.style.height = '100%';
              var headers = document.querySelectorAll('header, nav');
              headers.forEach(h => h.style.display = 'none');
            ''');
          },
          onUrlChange: (UrlChange change) {
            final url = change.url ?? '';
            // Detect redirect to mysavvybee.com (success case)
            if (url.contains('mysavvybee.com') && !_gameCompletedOrRedirected) {
              _gameCompletedOrRedirected = true;

              Future.delayed(const Duration(milliseconds: 100), () {
                if (mounted) {
                  Navigator.pop(context); // Close WebView

                  // Show success message back on Hive screen
                  // ScaffoldMessenger.of(context).showSnackBar(
                  //   SnackBar(
                  //     content: const Text(
                  //       'Game completed! 🎮 Great job!',
                  //       style: TextStyle(fontFamily: 'GeneralSans'),
                  //     ),
                  //     backgroundColor: AppColors.success,
                  //     duration: const Duration(seconds: 4),
                  //     behavior: SnackBarBehavior.floating,
                  //     shape: RoundedRectangleBorder(
                  //       borderRadius: BorderRadius.circular(12),
                  //     ),
                  //   ),
                  // );
                }
              });
            }
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('WebView error: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse('https://savvybee.vercel.app/'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Arcade',
          style: TextStyle(fontFamily: 'GeneralSans'),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
        ],
      ),
    );
  }
}
