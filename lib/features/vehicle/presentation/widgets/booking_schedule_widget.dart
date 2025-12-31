import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';

/// A compact widget to show upcoming booking time slots for a vehicle
/// Similar to cinema seat selection - shows which times are booked
class BookingScheduleWidget extends StatelessWidget {
  final List<BookingSlot> bookings;
  final bool isExpanded;
  final VoidCallback? onToggle;

  const BookingScheduleWidget({
    super.key,
    required this.bookings,
    this.isExpanded = false,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return _buildEmptyState();
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          InkWell(
            onTap: onToggle,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_month,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Lịch đặt xe',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${bookings.length} lượt đặt',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: AppColors.warning,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 18,
                    color: AppColors.textMuted,
                  ),
                ],
              ),
            ),
          ),

          // Booking slots preview (always show first 2)
          if (!isExpanded) ...[
            const Divider(height: 1),
            _buildCompactSlots(),
          ],

          // Expanded view
          if (isExpanded) ...[
            const Divider(height: 1),
            _buildExpandedSlots(),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.success.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, size: 16, color: AppColors.success),
          const SizedBox(width: 8),
          Text(
            'Xe trống - có thể đặt ngay',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.success,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactSlots() {
    final displayBookings = bookings.take(2).toList();
    final remaining = bookings.length - 2;

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Wrap(
        spacing: 8,
        runSpacing: 6,
        children: [
          ...displayBookings.map(_buildSlotChip),
          if (remaining > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.textMuted.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '+$remaining',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildExpandedSlots() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: bookings.map((booking) => _buildDetailedSlot(booking)).toList(),
      ),
    );
  }

  Widget _buildSlotChip(BookingSlot booking) {
    final dateFormat = DateFormat('dd/MM');
    final timeFormat = DateFormat('HH:mm');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(booking.status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getStatusColor(booking.status).withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getStatusIcon(booking.status),
            size: 12,
            color: _getStatusColor(booking.status),
          ),
          const SizedBox(width: 4),
          Text(
            '${dateFormat.format(booking.startTime)} ${timeFormat.format(booking.startTime)}-${timeFormat.format(booking.endTime)}',
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: _getStatusColor(booking.status),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedSlot(BookingSlot booking) {
    final dateFormat = DateFormat('EEE, dd/MM');
    final timeFormat = DateFormat('HH:mm');

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 36,
            decoration: BoxDecoration(
              color: _getStatusColor(booking.status),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateFormat.format(booking.startTime),
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '${timeFormat.format(booking.startTime)} - ${timeFormat.format(booking.endTime)}',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: _getStatusColor(booking.status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              _getStatusText(booking.status),
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: _getStatusColor(booking.status),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(BookingSlotStatus status) {
    switch (status) {
      case BookingSlotStatus.pending:
        return Colors.orange;
      case BookingSlotStatus.confirmed:
        return AppColors.warning;
      case BookingSlotStatus.ongoing:
        return AppColors.info;
    }
  }

  IconData _getStatusIcon(BookingSlotStatus status) {
    switch (status) {
      case BookingSlotStatus.pending:
        return Icons.schedule;
      case BookingSlotStatus.confirmed:
        return Icons.event_available;
      case BookingSlotStatus.ongoing:
        return Icons.directions_bike;
    }
  }

  String _getStatusText(BookingSlotStatus status) {
    switch (status) {
      case BookingSlotStatus.pending:
        return 'Chờ duyệt';
      case BookingSlotStatus.confirmed:
        return 'Đã đặt';
      case BookingSlotStatus.ongoing:
        return 'Đang thuê';
    }
  }
}

/// Represents a booking time slot
class BookingSlot {
  final String id;
  final DateTime startTime;
  final DateTime endTime;
  final BookingSlotStatus status;

  const BookingSlot({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.status,
  });

  factory BookingSlot.fromJson(Map<String, dynamic> json) {
    return BookingSlot(
      id: json['id'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      status: BookingSlotStatus.fromString(json['status'] as String),
    );
  }
}

enum BookingSlotStatus {
  pending,
  confirmed,
  ongoing;

  static BookingSlotStatus fromString(String value) {
    switch (value.toUpperCase()) {
      case 'PENDING':
        return BookingSlotStatus.pending;
      case 'CONFIRMED':
        return BookingSlotStatus.confirmed;
      case 'ONGOING':
        return BookingSlotStatus.ongoing;
      default:
        return BookingSlotStatus.confirmed;
    }
  }
}

