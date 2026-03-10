// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:savvy_bee_mobile/core/theme/app_colors.dart';
// import 'package:webview_flutter/webview_flutter.dart';
// import 'package:webview_flutter_android/webview_flutter_android.dart';
// import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

// /// Opened when the dashboard detects a reauth error.
// /// Shows the Mono reauth URL in an in-app WebView with camera access
// /// so Mono's facial recognition step works on both Android and iOS.
// /// Pops with `true` when Mono's redirect_url ("/") is intercepted.
// class ReauthWebViewScreen extends StatefulWidget {
//   static const String path = 'reauth-webview';

//   final String url;

//   const ReauthWebViewScreen({super.key, required this.url});

//   @override
//   State<ReauthWebViewScreen> createState() => _ReauthWebViewScreenState();
// }

// class _ReauthWebViewScreenState extends State<ReauthWebViewScreen> {
//   late final WebViewController _controller;
//   bool _isLoading = true;
//   int _loadingProgress = 0;

//   @override
//   void initState() {
//     super.initState();
//     _requestCameraPermission();
//     _initWebView();
//   }

//   /// Request camera + microphone from the OS upfront so the WebView
//   /// can access them when Mono's facial recognition step fires.
//   Future<void> _requestCameraPermission() async {
//     await [
//       Permission.camera,
//       Permission.microphone,
//     ].request();
//   }

//   void _initWebView() {
//     // ── Platform-specific controller params ───────────────────────────────
//     late final PlatformWebViewControllerCreationParams params;

//     if (defaultTargetPlatform == TargetPlatform.iOS) {
//       // iOS: enable camera / mic access inside WKWebView
//       params = WebKitWebViewControllerCreationParams(
//         allowsInlineMediaPlayback: true,
//         mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
//       );
//     } else {
//       params = const PlatformWebViewControllerCreationParams();
//     }

//     _controller = WebViewController.fromPlatformCreationParams(params)
//       ..setJavaScriptMode(JavaScriptMode.unrestricted)
//       ..setNavigationDelegate(
//         NavigationDelegate(
//           onProgress: (progress) {
//             if (mounted) setState(() => _loadingProgress = progress);
//           },
//           onPageStarted: (url) {
//             if (mounted) setState(() => _isLoading = true);
//             _checkForCompletion(url);
//           },
//           onPageFinished: (url) {
//             if (mounted) setState(() => _isLoading = false);
//             _checkForCompletion(url);
//           },
//           onNavigationRequest: (request) {
//             final uri = Uri.tryParse(request.url);
//             final path = uri?.path ?? '';

//             // Intercept Mono's redirect_url ("/") fired on reauth completion
//             if (path == '/' || path.isEmpty) {
//               Future.delayed(const Duration(milliseconds: 400), () {
//                 if (mounted) Navigator.of(context).pop(true);
//               });
//               return NavigationDecision.prevent;
//             }

//             return NavigationDecision.navigate;
//           },
//           onWebResourceError: (error) {
//             if (error.url != null) {
//               final path = Uri.tryParse(error.url!)?.path ?? '';
//               if ((path == '/' || path.isEmpty) && mounted) {
//                 Navigator.of(context).pop(true);
//               }
//             }
//           },
//         ),
//       )
//       ..loadRequest(Uri.parse(widget.url));

//     // ── Android: auto-grant WebView-level permission requests ─────────────
//     if (_controller.platform is AndroidWebViewController) {
//       final androidController =
//           _controller.platform as AndroidWebViewController;
//       androidController.setOnPlatformPermissionRequest(
//         (request) => request.grant(),
//       );
//     }

//     // ── iOS: allow the WKWebView to capture camera / mic ──────────────────
//     if (_controller.platform is WebKitWebViewController) {
//       final webKitController =
//           _controller.platform as WebKitWebViewController;
//       webKitController.setMediaCapturePermissionDecisionHandler(
//         (_, __) => MediaCapturePermissionDecision.grant,
//       );
//     }
//   }

//   /// Secondary check: catches JS-driven redirects that bypass
//   /// onNavigationRequest by inspecting the URL in page lifecycle callbacks.
//   void _checkForCompletion(String url) {
//     final uri = Uri.tryParse(url);
//     final path = uri?.path ?? '';
//     if (path == '/' || path.isEmpty) {
//       Future.delayed(const Duration(milliseconds: 400), () {
//         if (mounted) Navigator.of(context).pop(true);
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.close, color: Colors.black),
//           onPressed: () => Navigator.of(context).pop(false),
//         ),
//         title: const Text(
//           'Reauthorize Account',
//           style: TextStyle(
//             fontFamily: 'GeneralSans',
//             fontWeight: FontWeight.w600,
//             fontSize: 16,
//             color: Colors.black,
//           ),
//         ),
//         centerTitle: true,
//         bottom: _isLoading
//             ? PreferredSize(
//                 preferredSize: const Size.fromHeight(3),
//                 child: LinearProgressIndicator(
//                   value: _loadingProgress / 100,
//                   backgroundColor: AppColors.greyLight,
//                   valueColor: const AlwaysStoppedAnimation<Color>(
//                     AppColors.primary,
//                   ),
//                   minHeight: 3,
//                 ),
//               )
//             : null,
//       ),
//       body: WebViewWidget(controller: _controller),
//     );
//   }
// }