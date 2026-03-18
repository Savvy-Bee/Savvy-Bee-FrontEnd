import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:savvy_bee_mobile/core/tracking/minxpanel_tracking.dart';
import 'package:url_launcher/url_launcher.dart';
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

  static const _gameUrl = 'https://savvybee.vercel.app/';

  @override
  void initState() {
    super.initState();

    MixpanelService.trackFirstFeatureUsed('Game');

    if (kIsWeb) return;

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
      ..loadRequest(Uri.parse(_gameUrl));
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
      body: kIsWeb ? _buildWebFallback() : Stack(
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

  Widget _buildWebFallback() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.sports_esports, size: 64, color: AppColors.primary),
            const SizedBox(height: 16),
            const Text(
              'Arcade',
              style: TextStyle(
                fontFamily: 'GeneralSans',
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Open the arcade in a new tab to play.',
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'GeneralSans', fontSize: 14),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                final uri = Uri.parse(_gameUrl);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              icon: const Icon(Icons.open_in_new),
              label: const Text('Open Arcade'),
            ),
          ],
        ),
      ),
    );
  }
}
