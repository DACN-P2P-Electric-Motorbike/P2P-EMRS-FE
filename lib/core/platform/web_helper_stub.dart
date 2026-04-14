import 'dart:async';

/// Stub for non-web platforms. No-op listener that immediately closes.
StreamSubscription<dynamic> listenToPayOSWindowMessage(
  void Function(dynamic data) onMessage,
) {
  // Non-web: nothing to listen to. Return a closed stream subscription.
  return const Stream<dynamic>.empty().listen((_) {});
}
