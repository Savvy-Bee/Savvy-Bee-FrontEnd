import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Displays a KoraPay checkout URL in-app.
/// Pops with [true] when the user's browser navigates away from the
/// korapay.com domain (i.e. payment completed / redirected to success URL).
/// Pops with [false] if the user taps the close button without completing.
class KoraPaymentWebView extends StatefulWidget {
  final String checkoutUrl;
  final String title;

  const KoraPaymentWebView({
    super.key,
    required this.checkoutUrl,
    this.title = 'Complete Payment',
  });

  /// Push this screen and await the bool result.
  static Future<bool?> show(
    BuildContext context, {
    required String checkoutUrl,
    String title = 'Complete Payment',
  }) =>
      Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) =>
              KoraPaymentWebView(checkoutUrl: checkoutUrl, title: title),
        ),
      );

  @override
  State<KoraPaymentWebView> createState() => _KoraPaymentWebViewState();
}

class _KoraPaymentWebViewState extends State<KoraPaymentWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _paymentHandled = false;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) return;

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _isLoading = true),
          onPageFinished: (_) => setState(() => _isLoading = false),
          onUrlChange: (UrlChange change) {
            final url = change.url ?? '';
            // When URL moves away from the KoraPay checkout domain,
            // the payment is complete (redirected to merchant success URL).
            if (url.isNotEmpty &&
                !url.contains('korapay.com') &&
                !_paymentHandled) {
              _paymentHandled = true;
              Future.delayed(const Duration(milliseconds: 300), () {
                if (mounted) Navigator.pop(context, true);
              });
            }
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('KoraPay WebView error: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.checkoutUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(fontFamily: 'GeneralSans'),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context, false),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: kIsWeb
          ? const Center(
              child: Text(
                'Please open this link in a browser to complete payment.',
                style: TextStyle(fontFamily: 'GeneralSans'),
                textAlign: TextAlign.center,
              ),
            )
          : Stack(
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
