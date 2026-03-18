// Stub implementation for non-web platforms.
// The web implementation lives in web_download_web.dart and is selected via
// the conditional export in web_download.dart.

Future<void> triggerBrowserDownload(
  List<int> bytes,
  String filename,
  String mimeType,
) async {
  throw UnsupportedError('triggerBrowserDownload is only available on web');
}
