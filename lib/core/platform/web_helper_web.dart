import 'dart:async';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

/// Web implementation: listens for window.postMessage events where
/// `data['type'] == 'payos_result'` and calls [onMessage] with the data.
StreamSubscription<dynamic> listenToPayOSWindowMessage(
  void Function(dynamic data) onMessage,
) {
  return html.window.onMessage.listen((event) {
    final data = event.data;
    if (data is Map && data['type'] == 'payos_result') {
      onMessage(data);
    }
  });
}
