import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/payment_entity.dart';

/// Displays all supported payment methods with details and deep-link actions.
/// The user can mark a preferred method; the preference is kept in memory
/// for the lifetime of this page (no backend "saved methods" endpoint exists).
class PaymentMethodsPage extends StatefulWidget {
  const PaymentMethodsPage({super.key});

  @override
  State<PaymentMethodsPage> createState() => _PaymentMethodsPageState();
}

class _PaymentMethodsPageState extends State<PaymentMethodsPage> {
  PaymentMethod _preferred = PaymentMethod.payos;

  // ── Static metadata for each method ──────────────────────────────────────

  static const _methods = [
    _MethodMeta(
      method: PaymentMethod.payos,
      title: 'PayOS',
      subtitle: 'Chuyển khoản ngân hàng & QR Code',
      description:
          'Thanh toán qua cổng PayOS — hỗ trợ tất cả ngân hàng nội địa và '
          'quét mã QR VietQR. Tiền về ngay lập tức.',
      badgeLabel: 'Phổ biến',
      badgeColor: Color(0xFF1A73E8),
      iconData: Icons.account_balance_outlined,
      accentColor: Color(0xFF1A73E8),
      deepLinkScheme: null,
      fallbackUrl: 'https://payos.vn',
    ),
    _MethodMeta(
      method: PaymentMethod.momo,
      title: 'MoMo',
      subtitle: 'Ví điện tử MoMo',
      description:
          'Thanh toán bằng ví MoMo. Ứng dụng MoMo sẽ được mở tự động nếu '
          'đã cài đặt trên thiết bị.',
      badgeLabel: null,
      badgeColor: Color(0xFFAE2070),
      iconData: Icons.account_balance_wallet_outlined,
      accentColor: Color(0xFFAE2070),
      deepLinkScheme: 'momo',
      fallbackUrl: 'https://momo.vn',
    ),
    _MethodMeta(
      method: PaymentMethod.creditCard,
      title: 'Thẻ tín dụng / ghi nợ',
      subtitle: 'Visa, Mastercard, JCB',
      description:
          'Thanh toán bằng thẻ quốc tế. Giao dịch được xử lý an toàn qua '
          'cổng thanh toán bảo mật PCI-DSS.',
      badgeLabel: null,
      badgeColor: AppColors.primary,
      iconData: Icons.credit_card_outlined,
      accentColor: AppColors.primary,
      deepLinkScheme: null,
      fallbackUrl: null,
    ),
    _MethodMeta(
      method: PaymentMethod.cash,
      title: 'Tiền mặt',
      subtitle: 'Thanh toán trực tiếp',
      description:
          'Thanh toán tiền mặt khi nhận xe. Lưu ý: phương thức này không áp '
          'dụng cho đặt xe trực tuyến có bảo hiểm.',
      badgeLabel: null,
      badgeColor: AppColors.success,
      iconData: Icons.payments_outlined,
      accentColor: AppColors.success,
      deepLinkScheme: null,
      fallbackUrl: null,
    ),
  ];

  // ── Helpers ───────────────────────────────────────────────────────────────

  Future<void> _launchMethod(_MethodMeta meta) async {
    if (meta.deepLinkScheme != null) {
      final dlUri = Uri.parse('${meta.deepLinkScheme}://');
      if (await canLaunchUrl(dlUri)) {
        await launchUrl(dlUri, mode: LaunchMode.externalApplication);
        return;
      }
    }
    if (meta.fallbackUrl != null) {
      final uri = Uri.parse(meta.fallbackUrl!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return;
      }
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể mở ứng dụng')),
      );
    }
  }

  void _setPreferred(PaymentMethod method) {
    HapticFeedback.selectionClick();
    setState(() => _preferred = method);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Đã chọn phương thức thanh toán mặc định',
          style: GoogleFonts.poppins(fontSize: 13),
        ),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          color: AppColors.textPrimary,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Phương thức thanh toán',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildInfoBanner(),
          const SizedBox(height: 20),
          Text(
            'Chọn phương thức mặc định',
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ..._methods.map(
            (meta) => _MethodCard(
              meta: meta,
              isPreferred: _preferred == meta.method,
              onSelect: () => _setPreferred(meta.method),
              onAction: meta.deepLinkScheme != null || meta.fallbackUrl != null
                  ? () => _launchMethod(meta)
                  : null,
            ),
          ),
          const SizedBox(height: 24),
          _buildSecurityNote(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.info_outline,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'Phương thức bạn chọn sẽ được đặt làm mặc định khi thanh toán '
              'cho các chuyến thuê xe tiếp theo.',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppColors.primary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityNote() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.success.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.verified_user_outlined,
            color: AppColors.success,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Thanh toán an toàn',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Mọi giao dịch được mã hóa SSL 256-bit. Dream Ride không '
                  'lưu trữ thông tin thẻ của bạn.',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Method Card ───────────────────────────────────────────────────────────────

class _MethodCard extends StatelessWidget {
  final _MethodMeta meta;
  final bool isPreferred;
  final VoidCallback onSelect;
  final VoidCallback? onAction;

  const _MethodCard({
    required this.meta,
    required this.isPreferred,
    required this.onSelect,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isPreferred ? meta.accentColor : AppColors.border,
            width: isPreferred ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isPreferred
                  ? meta.accentColor.withOpacity(0.10)
                  : Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: meta.accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(meta.iconData, color: meta.accentColor, size: 24),
              ),
              title: Row(
                children: [
                  Text(
                    meta.title,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (meta.badgeLabel != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: meta.badgeColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        meta.badgeLabel!,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: meta.badgeColor,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              subtitle: Text(
                meta.subtitle,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
              trailing: GestureDetector(
                onTap: onSelect,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isPreferred
                          ? meta.accentColor
                          : Colors.grey,
                      width: 2,
                    ),
                    color:
                        isPreferred ? meta.accentColor : Colors.transparent,
                  ),
                  child: isPreferred
                      ? const Icon(Icons.check, color: Colors.white, size: 14)
                      : null,
                ),
              ),
              onTap: onSelect,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 1, color: AppColors.border),
                  const SizedBox(height: 12),
                  Text(
                    meta.description,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                  ),
                  if (onAction != null) ...[
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: OutlinedButton.icon(
                        onPressed: onAction,
                        icon: Icon(
                          Icons.open_in_new,
                          size: 14,
                          color: meta.accentColor,
                        ),
                        label: Text(
                          'Mở ứng dụng',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: meta.accentColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          side: BorderSide(
                              color: meta.accentColor, width: 1.2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Metadata ──────────────────────────────────────────────────────────────────

class _MethodMeta {
  final PaymentMethod method;
  final String title;
  final String subtitle;
  final String description;
  final String? badgeLabel;
  final Color badgeColor;
  final IconData iconData;
  final Color accentColor;
  final String? deepLinkScheme;
  final String? fallbackUrl;

  const _MethodMeta({
    required this.method,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.badgeLabel,
    required this.badgeColor,
    required this.iconData,
    required this.accentColor,
    required this.deepLinkScheme,
    required this.fallbackUrl,
  });
}