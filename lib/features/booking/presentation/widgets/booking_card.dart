import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/booking.dart';

/// Returns a synthetic payment status label when no payment record exists yet
String? _defaultPaymentStatus(BookingStatus bookingStatus) {
  switch (bookingStatus) {
    case BookingStatus.PENDING:
      return null; // No payment context while still pending owner approval
    case BookingStatus.CONFIRMED:
      return 'AWAITING'; // Confirmed but not yet paid
    case BookingStatus.COMPLETED:
      return 'COMPLETED'; // Should have been paid
    case BookingStatus.CANCELLED:
    case BookingStatus.REJECTED:
      return null; // Not relevant
    case BookingStatus.ONGOING:
      return null; // Should have a real payment record at this stage
  }
}

/// Booking Card for Renter
class BookingCard extends StatelessWidget {
  final BookingEntity booking;
  final VoidCallback onTap;

  const BookingCard({super.key, required this.booking, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Row 1: Status badge + payment badge + booking ID
                Row(
                  children: [
                    _StatusBadge(status: booking.status),
                    Builder(builder: (_) {
                      final ps = booking.paymentStatus ?? _defaultPaymentStatus(booking.status);
                      if (ps == null) return const SizedBox.shrink();
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(width: 6),
                          _PaymentBadge(paymentStatus: ps),
                        ],
                      );
                    }),
                    const Spacer(),
                    Text(
                      '#${booking.id.substring(0, 8)}',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: AppColors.textMuted,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Row 2: Vehicle icon + name
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.electric_moped,
                        color: AppColors.primary,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.vehicleName ?? 'Xe điện',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${booking.durationInHours}h · ${DateFormat('dd/MM/yyyy').format(booking.startTime)}',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1),
                ),

                // Row 3: Time range
                Row(
                  children: [
                    Expanded(
                      child: _TimeChip(
                        icon: Icons.login_rounded,
                        label: 'Nhận xe',
                        value: DateFormat('dd/MM  HH:mm').format(booking.startTime),
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 32,
                      color: AppColors.border,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    Expanded(
                      child: _TimeChip(
                        icon: Icons.logout_rounded,
                        label: 'Trả xe',
                        value: DateFormat('dd/MM  HH:mm').format(booking.endTime),
                        alignRight: true,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Row 4: Total price
                Row(
                  children: [
                    Icon(
                      Icons.payments_outlined,
                      size: 16,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Tổng tiền',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      NumberFormat.currency(
                        locale: 'vi_VN',
                        symbol: 'đ',
                        decimalDigits: 0,
                      ).format(booking.totalPrice),
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final BookingStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg, IconData icon, String label) = switch (status) {
      BookingStatus.PENDING => (
          AppColors.warning.withOpacity(0.12),
          AppColors.warning,
          Icons.schedule_rounded,
          'Chờ xác nhận',
        ),
      BookingStatus.CONFIRMED => (
          AppColors.success.withOpacity(0.12),
          AppColors.success,
          Icons.check_circle_outline_rounded,
          'Đã xác nhận',
        ),
      BookingStatus.ONGOING => (
          AppColors.info.withOpacity(0.12),
          AppColors.info,
          Icons.directions_bike_rounded,
          'Đang thuê',
        ),
      BookingStatus.COMPLETED => (
          AppColors.success.withOpacity(0.12),
          AppColors.success,
          Icons.task_alt_rounded,
          'Hoàn thành',
        ),
      BookingStatus.CANCELLED => (
          AppColors.error.withOpacity(0.12),
          AppColors.error,
          Icons.cancel_outlined,
          'Đã hủy',
        ),
      BookingStatus.REJECTED => (
          AppColors.error.withOpacity(0.12),
          AppColors.error,
          Icons.block_rounded,
          'Bị từ chối',
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: fg),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentBadge extends StatelessWidget {
  final String paymentStatus;
  const _PaymentBadge({required this.paymentStatus});

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg, IconData icon, String label) = switch (paymentStatus) {
      'AWAITING' => (
          Colors.grey.withOpacity(0.10),
          Colors.grey.shade600,
          Icons.credit_card_outlined,
          'Chưa TT',
        ),
      'COMPLETED' => (
          const Color(0xFF00C853).withOpacity(0.10),
          const Color(0xFF00873E),
          Icons.check_circle_outline,
          'Đã TT',
        ),
      'PENDING' => (
          Colors.orange.withOpacity(0.10),
          Colors.orange.shade700,
          Icons.hourglass_top_rounded,
          'Chờ TT',
        ),
      'PROCESSING' => (
          Colors.blue.withOpacity(0.10),
          Colors.blue.shade700,
          Icons.sync_rounded,
          'Đang TT',
        ),
      'REFUNDED' => (
          Colors.purple.withOpacity(0.10),
          Colors.purple.shade600,
          Icons.replay_rounded,
          'Hoàn tiền',
        ),
      'FAILED' => (
          AppColors.error.withOpacity(0.10),
          AppColors.error,
          Icons.error_outline_rounded,
          'TT thất bại',
        ),
      _ => (
          Colors.grey.withOpacity(0.10),
          Colors.grey.shade600,
          Icons.help_outline_rounded,
          paymentStatus,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fg.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: fg),
          const SizedBox(width: 3),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool alignRight;

  const _TimeChip({
    required this.icon,
    required this.label,
    required this.value,
    this.alignRight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!alignRight) ...[
              Icon(icon, size: 13, color: AppColors.textMuted),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: AppColors.textMuted,
              ),
            ),
            if (alignRight) ...[
              const SizedBox(width: 4),
              Icon(icon, size: 13, color: AppColors.textMuted),
            ],
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
