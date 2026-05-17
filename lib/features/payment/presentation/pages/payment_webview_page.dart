import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../core/theme/app_theme.dart';

/// Result emitted when the in-app payment WebView pops back to the caller.
///
/// The caller is responsible for refreshing the payment status from the API
/// after `success` (the gateway webhook is the source of truth — the WebView
/// only tells us the user finished navigating).
enum PaymentWebViewResult { success, cancelled, dismissed }

/// In-app browser for PayOS / MoMo gateways on Android + iOS.
///
/// The page loads [paymentUrl] in a `WebView` and watches navigation. The
/// gateway redirects to one of the API's return / cancel endpoints (already
/// configured by `payments.service.ts`); when we see that prefix we pop the
/// route with the matching [PaymentWebViewResult] so the caller can refresh
/// payment state instead of asking the user to come back manually.
///
/// Flutter web is **not** supported — `webview_flutter` has no real web
/// implementation. The payment page keeps the existing popup-tab +
/// `postMessage` flow there.
class PaymentWebViewPage extends StatefulWidget {
  final String paymentUrl;
  final String title;

  const PaymentWebViewPage({
    super.key,
    required this.paymentUrl,
    this.title = 'Thanh toán',
  });

  /// Whether `webview_flutter` can run on the current platform.
  ///
  /// Returns `false` on Flutter web and on desktop targets that don't have a
  /// `webview_flutter` platform implementation. Callers should fall back to
  /// `url_launcher` / popup-tab behaviour when this is `false`.
  static bool isSupported() {
    if (kIsWeb) return false;
    final tp = defaultTargetPlatform;
    return tp == TargetPlatform.android || tp == TargetPlatform.iOS;
  }

  @override
  State<PaymentWebViewPage> createState() => _PaymentWebViewPageState();
}

class _PaymentWebViewPageState extends State<PaymentWebViewPage> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _popped = false;

  /// Return-URL path fragments served by the API
  /// (`payments.controller.ts`). We pop as soon as the WebView navigates to
  /// any of these, before the gateway's HTML loads its closing `<script>`.
  /// The webhook (server side) is what actually marks the payment
  /// `COMPLETED` — these URLs are just the completion *signal*.
  static const List<String> _successPathFragments = [
    '/payments/payos-return',
    '/payments/momo-return',
  ];
  static const List<String> _cancelPathFragments = [
    '/payments/payos-cancel',
    '/payments/momo-cancel',
  ];

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFFF8F9FD))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) setState(() => _isLoading = true);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _isLoading = false);
          },
          onNavigationRequest: (request) {
            final result = _classify(request.url);
            if (result != null) {
              _popOnce(result);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  /// Returns the matching [PaymentWebViewResult] when [url] is one of the
  /// API's gateway return endpoints, or `null` otherwise.
  PaymentWebViewResult? _classify(String url) {
    final lower = url.toLowerCase();
    for (final fragment in _successPathFragments) {
      if (lower.contains(fragment)) {
        // PayOS reports cancellation through ?status=CANCELLED on the same
        // return endpoint as well — handle both.
        final status = Uri.tryParse(url)?.queryParameters['status'];
        if (status != null) {
          final upper = status.toUpperCase();
          if (upper == 'CANCELLED' || upper == 'CANCEL') {
            return PaymentWebViewResult.cancelled;
          }
        }
        return PaymentWebViewResult.success;
      }
    }
    for (final fragment in _cancelPathFragments) {
      if (lower.contains(fragment)) {
        return PaymentWebViewResult.cancelled;
      }
    }
    return null;
  }

  void _popOnce(PaymentWebViewResult result) {
    if (_popped || !mounted) return;
    _popped = true;
    Navigator.of(context).pop(result);
  }

  Future<bool> _confirmDismiss() async {
    if (_popped) return true;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Huỷ thanh toán?',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Đóng cửa sổ này có thể huỷ giao dịch đang chờ. Bạn có chắc chắn?',
          style: GoogleFonts.poppins(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Tiếp tục thanh toán'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
    return ok ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        // Allow a programmatic pop (success/cancel) to bypass the dialog
        // because _popOnce flips _popped.
        if (_popped) return;

        // If the WebView itself can navigate back inside the gateway (e.g.
        // user is on a sub-page of PayOS), do that instead of leaving.
        if (await _controller.canGoBack()) {
          await _controller.goBack();
          return;
        }
        if (!mounted) return;
        final shouldClose = await _confirmDismiss();
        if (shouldClose && mounted) {
          _popOnce(PaymentWebViewResult.dismissed);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FD),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            widget.title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.close, color: AppColors.textPrimary),
            onPressed: () async {
              if (await _controller.canGoBack()) {
                await _controller.goBack();
                return;
              }
              if (!mounted) return;
              final shouldClose = await _confirmDismiss();
              if (shouldClose && mounted) {
                _popOnce(PaymentWebViewResult.dismissed);
              }
            },
          ),
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_isLoading)
              const LinearProgressIndicator(
                backgroundColor: Color(0xFFE8EAF0),
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                minHeight: 3,
              ),
          ],
        ),
      ),
    );
  }
}

/// Convenience pusher used by the payment page. Returns the gateway result
/// the WebView observed; the caller is responsible for refreshing payment
/// state from the API afterwards.
///
/// Callers must check [PaymentWebViewPage.isSupported] beforehand and fall
/// back to `url_launcher` / popup-tab when WebView is unavailable.
Future<PaymentWebViewResult?> openPaymentWebView(
  BuildContext context, {
  required String paymentUrl,
  String title = 'Thanh toán',
}) {
  return Navigator.of(context).push<PaymentWebViewResult>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => PaymentWebViewPage(paymentUrl: paymentUrl, title: title),
    ),
  );
}
