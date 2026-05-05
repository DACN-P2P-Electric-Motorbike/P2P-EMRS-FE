import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/platform/web_helper.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/payment_entity.dart';
import '../bloc/payment_bloc.dart';
import '../bloc/payment_event.dart';
import '../bloc/payment_state.dart';

class PaymentPage extends StatelessWidget {
  final String bookingId;
  final double totalAmount;
  final double deposit;

  const PaymentPage({
    super.key,
    required this.bookingId,
    required this.totalAmount,
    required this.deposit,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<PaymentBloc>()..add(LoadPaymentByBookingEvent(bookingId)),
      child: _PaymentView(
        bookingId: bookingId,
        totalAmount: totalAmount,
        deposit: deposit,
      ),
    );
  }
}

class _PaymentView extends StatefulWidget {
  final String bookingId;
  final double totalAmount;
  final double deposit;

  const _PaymentView({
    required this.bookingId,
    required this.totalAmount,
    required this.deposit,
  });

  @override
  State<_PaymentView> createState() => _PaymentViewState();
}

class _PaymentViewState extends State<_PaymentView>
    with WidgetsBindingObserver {
  PaymentMethod _selectedMethod = PaymentMethod.payos;
  StreamSubscription<dynamic>? _webMessageSub;

  final _formatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Web: listen for postMessage from the PayOS result tab (platform-safe)
    _webMessageSub = listenToPayOSWindowMessage((data) {
      if (mounted) {
        context.read<PaymentBloc>().add(
          LoadPaymentByBookingEvent(widget.bookingId),
        );
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _webMessageSub?.cancel();
    super.dispose();
  }

  // Mobile: reload when user returns from external browser
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      context.read<PaymentBloc>().add(
        LoadPaymentByBookingEvent(widget.bookingId),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Thanh toán',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<PaymentBloc, PaymentState>(
        listener: (context, state) {
          if (state is PaymentSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
              ),
            );
            Navigator.pop(context, true);
          } else if (state is PaymentCreated) {
            _handleAfterCreate(context, state.payment);
          } else if (state is PaymentUrlGenerated) {
            _handlePaymentUrlGenerated(context, state);
          } else if (state is PaymentFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is PaymentLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is PaymentLoaded && state.payment.isCompleted) {
            return _buildAlreadyPaid(context, state.payment);
          }

          return _buildPaymentForm(context, state);
        },
      ),
    );
  }

  void _handleAfterCreate(BuildContext context, PaymentEntity payment) {
    switch (_selectedMethod) {
      case PaymentMethod.payos:
        context.read<PaymentBloc>().add(InitiatePayOSEvent(payment.id));
      case PaymentMethod.momo:
        context.read<PaymentBloc>().add(InitiateMoMoEvent(payment.id));
      case PaymentMethod.cash:
      case PaymentMethod.creditCard:
        context.read<PaymentBloc>().add(
          SimulatePaymentSuccessEvent(payment.id),
        );
    }
  }

  Future<void> _handlePaymentUrlGenerated(
    BuildContext context,
    PaymentUrlGenerated state,
  ) async {
    final url = Uri.tryParse(state.paymentUrl);
    if (url == null || state.paymentUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể tạo URL thanh toán')),
      );
      return;
    }

    // Try to launch deeplink (MoMo app) first, then fall back to payUrl
    final deeplink = state.deeplink;
    bool launched = false;

    if (deeplink != null && deeplink.isNotEmpty) {
      final dlUri = Uri.tryParse(deeplink);
      if (dlUri != null && await canLaunchUrl(dlUri)) {
        await launchUrl(dlUri, mode: LaunchMode.externalApplication);
        launched = true;
      }
    }

    if (!launched) {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
        launched = true;
      }
    }

    if (!launched && context.mounted) {
      _showPaymentUrlFallbackDialog(context, state);
    }
  }

  void _showPaymentUrlFallbackDialog(
    BuildContext context,
    PaymentUrlGenerated state,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Thanh toán',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mở link bên dưới để hoàn tất thanh toán:',
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () async {
                final uri = Uri.parse(state.paymentUrl);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Text(
                  state.paymentUrl,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.primary,
                    decoration: TextDecoration.underline,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  Widget _buildAlreadyPaid(BuildContext context, PaymentEntity payment) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 80, color: AppColors.success),
            const SizedBox(height: 24),
            Text(
              'Đã thanh toán',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _formatter.format(payment.amount),
              style: GoogleFonts.poppins(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Phương thức: ${payment.methodDisplayText}',
              style: GoogleFonts.poppins(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            if (payment.paidAt != null) ...[
              const SizedBox(height: 4),
              Text(
                'Ngày thanh toán: ${DateFormat('dd/MM/yyyy HH:mm').format(payment.paidAt!)}',
                style: GoogleFonts.poppins(
                  color: AppColors.textMuted,
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentForm(BuildContext context, PaymentState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Card
          _buildSummaryCard(),
          const SizedBox(height: 24),

          // Payment Method Selection
          Text(
            'Phương thức thanh toán',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _buildMethodCard(
            method: PaymentMethod.payos,
            title: 'PayOS',
            subtitle: 'Chuyển khoản ngân hàng / QR Code',
            icon: 'assets/icons/payos.png',
            fallbackIcon: Icons.account_balance,
            color: const Color(0xFF1A73E8),
          ),
          const SizedBox(height: 12),
          _buildMethodCard(
            method: PaymentMethod.momo,
            title: 'MoMo',
            subtitle: 'Thanh toán qua ví MoMo (sandbox)',
            icon: 'assets/icons/momo.png',
            fallbackIcon: Icons.account_balance_wallet,
            color: const Color(0xFFAE2070),
          ),
          const SizedBox(height: 12),
          _buildMethodCard(
            method: PaymentMethod.cash,
            title: 'Tiền mặt',
            subtitle: 'Thanh toán trực tiếp (sandbox simulation)',
            icon: '',
            fallbackIcon: Icons.money,
            color: AppColors.success,
          ),
          const SizedBox(height: 32),

          // Revenue breakdown
          _buildRevenueBreakdown(),
          const SizedBox(height: 32),

          // Pay Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: state is PaymentLoading ? null : () => _onPay(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: state is PaymentLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'Thanh toán ${_formatter.format(widget.totalAmount + widget.deposit)}',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withBlue(220)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tóm tắt thanh toán',
            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Text(
            _formatter.format(widget.totalAmount + widget.deposit),
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _summaryItem('Tiền thuê', _formatter.format(widget.totalAmount)),
              _summaryItem('Tiền cọc', _formatter.format(widget.deposit)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(color: Colors.white60, fontSize: 12),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildMethodCard({
    required PaymentMethod method,
    required String title,
    required String subtitle,
    required String icon,
    required IconData fallbackIcon,
    required Color color,
  }) {
    final isSelected = _selectedMethod == method;

    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = method),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.primary.withOpacity(0.1)
                  : Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(fallbackIcon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : Colors.grey[300]!,
                  width: 2,
                ),
                color: isSelected ? AppColors.primary : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 14)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueBreakdown() {
    final platformFee = widget.totalAmount * 0.15;
    final ownerAmount = widget.totalAmount - platformFee;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Phân chia doanh thu',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _revenueRow(
            'Chủ xe nhận (85%)',
            _formatter.format(ownerAmount),
            AppColors.success,
          ),
          const SizedBox(height: 8),
          _revenueRow(
            'Phí nền tảng (15%)',
            _formatter.format(platformFee),
            AppColors.textMuted,
          ),
          if (widget.deposit > 0) ...[
            const SizedBox(height: 8),
            _revenueRow(
              'Tiền cọc giữ tạm',
              _formatter.format(widget.deposit),
              AppColors.info,
            ),
          ],
        ],
      ),
    );
  }

  Widget _revenueRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  void _onPay(BuildContext context) {
    context.read<PaymentBloc>().add(
      CreatePaymentEvent(bookingId: widget.bookingId, method: _selectedMethod),
    );
  }
}
