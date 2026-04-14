/// Platform-conditional export for web-specific helpers.
///
/// On web: uses dart:html to listen for postMessage events.
/// On all other platforms: no-op stub.
export 'web_helper_stub.dart'
    if (dart.library.html) 'web_helper_web.dart';
