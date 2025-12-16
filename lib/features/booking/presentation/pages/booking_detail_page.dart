import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/services/socket_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/booking.dart';
import '../bloc/booking_bloc.dart';
import '../bloc/booking_event.dart';
import '../bloc/booking_state.dart';

/// Booking Detail Page with real-time updates
class BookingDetailPage extends StatefulWidget {
  final String bookingId;
  final bool isOwnerView;

  const BookingDetailPage({
    super.key,
    required this.bookingId,
    this.isOwnerView = false,
  });

  @override
  State<BookingDetailPage> createState() => _BookingDetailPageState();
}

class _BookingDetailPageState extends State<BookingDetailPage> {
  final SocketService _socketService = sl<SocketService>();
  StreamSubscription? _bookingUpdateSubscription;

  @override
  void initState() {
    super.initState();
    _setupRealtimeUpdates();
  }

  void _setupRealtimeUpdates() {
    // Subscribe to booking updates via WebSocket
    _socketService.subscribeToBooking(widget.bookingId);

    // Listen for updates
    _bookingUpdateSubscription = _socketService.bookingUpdateStream.listen((
      data,
    ) {
      if (data['bookingId'] == widget.bookingId) {
        // Reload booking when status changes
        context.read<BookingBloc>().add(LoadBookingByIdEvent(widget.bookingId));
      }
    });
  }

  @override
  void dispose() {
    _socketService.unsubscribeFromBooking(widget.bookingId);
    _bookingUpdateSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<BookingBloc>()..add(LoadBookingByIdEvent(widget.bookingId)),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FD),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            'Chi tiết booking',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          centerTitle: true,
        ),
        body: BlocConsumer<BookingBloc, BookingState>(
          listener: (context, state) {
            if (state is BookingActionSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.success,
                ),
              );
              // Reload booking
              context.read<BookingBloc>().add(
                LoadBookingByIdEvent(widget.bookingId),
              );
            } else if (state is BookingFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is BookingLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is BookingLoaded) {
              return _buildContent(context, state.booking);
            }

            return const Center(child: Text('Không tìm thấy booking'));
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, BookingEntity booking) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Status Banner
          _buildStatusBanner(booking),

          const SizedBox(height: 16),

          // Booking Information
          _buildInfoCard(booking),

          const SizedBox(height: 16),

          // Time Information
          _buildTimeCard(booking),

          const SizedBox(height: 16),

          // Price Information
          _buildPriceCard(booking),

          const SizedBox(height: 16),

          // Notes
          if (booking.notes != null) _buildNotesCard(booking.notes!),

          // Cancellation Reason
          if (booking.cancellationReason != null)
            _buildCancellationCard(booking.cancellationReason!),

          const SizedBox(height: 16),

          // Actions
          _buildActions(context, booking),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildStatusBanner(BookingEntity booking) {
    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (booking.status) {
      case BookingStatus.PENDING:
        backgroundColor = AppColors.warning.withOpacity(0.1);
        textColor = AppColors.warning;
        icon = Icons.pending_actions;
        break;
      case BookingStatus.CONFIRMED:
        backgroundColor = AppColors.success.withOpacity(0.1);
        textColor = AppColors.success;
        icon = Icons.check_circle;
        break;
      case BookingStatus.ONGOING:
        backgroundColor = AppColors.info.withOpacity(0.1);
        textColor = AppColors.info;
        icon = Icons.directions_bike;
        break;
      case BookingStatus.COMPLETED:
        backgroundColor = AppColors.success.withOpacity(0.1);
        textColor = AppColors.success;
        icon = Icons.task_alt;
        break;
      case BookingStatus.CANCELLED:
        backgroundColor = AppColors.error.withOpacity(0.1);
        textColor = AppColors.error;
        icon = Icons.cancel;
        break;
      case BookingStatus.REJECTED:
        backgroundColor = AppColors.error.withOpacity(0.1);
        textColor = AppColors.error;
        icon = Icons.block;
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: backgroundColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: textColor, size: 24),
          const SizedBox(width: 12),
          Text(
            booking.statusDisplayText,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BookingEntity booking) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thông tin booking',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            Icons.qr_code,
            'Mã booking',
            '#${booking.id.substring(0, 8)}',
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.calendar_today,
            'Ngày tạo',
            DateFormat('dd/MM/yyyy HH:mm').format(booking.createdAt),
          ),
          if (booking.confirmedAt != null) ...[
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.check_circle_outline,
              'Ngày xác nhận',
              DateFormat('dd/MM/yyyy HH:mm').format(booking.confirmedAt!),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeCard(BookingEntity booking) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thời gian thuê',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            Icons.access_time,
            'Bắt đầu',
            DateFormat('dd/MM/yyyy HH:mm').format(booking.startTime),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.access_time_filled,
            'Kết thúc',
            DateFormat('dd/MM/yyyy HH:mm').format(booking.endTime),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.timer,
            'Thời lượng',
            '${booking.durationInHours} giờ',
          ),
        ],
      ),
    );
  }

  Widget _buildPriceCard(BookingEntity booking) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chi phí',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            Icons.payments,
            'Tổng tiền thuê',
            NumberFormat.currency(
              locale: 'vi_VN',
              symbol: 'đ',
            ).format(booking.totalPrice),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.account_balance_wallet,
            'Tiền cọc',
            NumberFormat.currency(
              locale: 'vi_VN',
              symbol: 'đ',
            ).format(booking.deposit),
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tổng cộng',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                NumberFormat.currency(
                  locale: 'vi_VN',
                  symbol: 'đ',
                ).format(booking.totalPrice + booking.deposit),
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotesCard(String notes) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.info.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.note, color: AppColors.info, size: 20),
              const SizedBox(width: 8),
              Text(
                'Ghi chú',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.info,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            notes,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCancellationCard(String reason) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.error.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.error, size: 20),
              const SizedBox(width: 8),
              Text(
                'Lý do hủy/từ chối',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            reason,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textMuted),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context, BookingEntity booking) {
    // Owner actions
    if (widget.isOwnerView && booking.isPending) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _showRejectDialog(context, booking),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.error),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  'Từ chối',
                  style: GoogleFonts.poppins(
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _showApproveDialog(context, booking),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Chấp nhận'),
              ),
            ),
          ],
        ),
      );
    }

    // Renter actions
    if (!widget.isOwnerView && booking.canBeCancelled) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => _showCancelDialog(context, booking),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColors.error),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(
              'Hủy booking',
              style: GoogleFonts.poppins(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  void _showApproveDialog(BuildContext context, BookingEntity booking) {
    final messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          'Xác nhận booking',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: messageController,
              decoration: InputDecoration(
                labelText: 'Tin nhắn (tùy chọn)',
                hintText: 'Gửi lời nhắn...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<BookingBloc>().add(
                ApproveBookingEvent(
                  bookingId: booking.id,
                  message: messageController.text.trim().isNotEmpty
                      ? messageController.text.trim()
                      : null,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(BuildContext context, BookingEntity booking) {
    final reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          'Từ chối booking',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: reasonController,
            decoration: InputDecoration(
              labelText: 'Lý do *',
              hintText: 'Nhập lý do từ chối...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            maxLines: 3,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Vui lòng nhập lý do';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.pop(dialogContext);
                context.read<BookingBloc>().add(
                  RejectBookingEvent(
                    bookingId: booking.id,
                    reason: reasonController.text.trim(),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Từ chối'),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(BuildContext context, BookingEntity booking) {
    final reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          'Hủy booking',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Bạn có chắc chắn muốn hủy booking này?',
                style: GoogleFonts.poppins(fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: reasonController,
                decoration: InputDecoration(
                  labelText: 'Lý do hủy *',
                  hintText: 'Ví dụ: Thay đổi kế hoạch...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập lý do hủy';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Quay lại'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.pop(dialogContext);
                context.read<BookingBloc>().add(
                  CancelBookingEvent(
                    bookingId: booking.id,
                    reason: reasonController.text.trim(),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Hủy booking'),
          ),
        ],
      ),
    );
  }
}
