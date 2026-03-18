// Conditional export: selects the web implementation when dart:html is
// available (Flutter Web), otherwise falls back to the stub.
export 'web_download_stub.dart'
    if (dart.library.html) 'web_download_web.dart';
