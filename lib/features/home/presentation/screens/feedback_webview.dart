import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart'; // adjust import

class FeedbackWebViewScreen extends StatefulWidget {
  static const String path = '/feedback-webview';

  const FeedbackWebViewScreen({super.key});

  @override
  State<FeedbackWebViewScreen> createState() => _FeedbackWebViewScreenState();
}

class _FeedbackWebViewScreenState extends State<FeedbackWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _formSubmitted = false;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // optional
          },
          onPageStarted: (String url) {
            setState(() => _isLoading = true);
          },
          onPageFinished: (String url) async {
            setState(() => _isLoading = false);

            // Detect thank-you / success page
            // Adjust condition based on your actual thank-you URL or content
            if (url.contains('tally.so') &&
                url.contains('/r/') &&
                !_formSubmitted) {
              // Optional: inject JS to detect submission success more reliably
              final html =
                  await _controller.runJavaScriptReturningResult(
                        "document.body.innerHTML",
                      )
                      as String?;

              if (html != null &&
                  (html.contains('Thank you') ||
                      html.contains('Submitted') ||
                      html.contains('We got it'))) {
                _formSubmitted = true;

                // Wait 1 second → close WebView → show success
                Future.delayed(const Duration(seconds: 1), () {
                  if (mounted) {
                    Navigator.pop(context); // close WebView

                    // Show success message on previous screen (Home)
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          'Thank you for your feedback! 🎉',
                          style: TextStyle(fontFamily: 'GeneralSans'),
                        ),
                        backgroundColor: AppColors.success,
                        duration: const Duration(seconds: 4),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  }
                });
              }
            }

            // Optional: clean UI (hide header/footer if still visible)
            await _controller.runJavaScript('''
              var els = document.querySelectorAll('header, footer, .tally-branding');
              els.forEach(el => el.style.display = 'none');
              document.body.style.margin = '0';
              document.body.style.padding = '16px';
            ''');
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('Web error: ${error.description}');
          },
          onUrlChange: (UrlChange change) {
            // Fallback detection if redirect happens anyway
            if (change.url?.contains('mysavvybee.com') == true) {
              Future.delayed(const Duration(milliseconds: 100), () {
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Thank you! Redirect detected — feedback received.',
                      ),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              });
            }
          },
        ),
      )
      ..loadRequest(Uri.parse('https://tally.so/r/D4d70q'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Feedback',
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
