import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/services/location_service.dart';
import '../../../../core/services/socket_service.dart';
import '../../../../core/services/upload_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/vietnam_time.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../injection_container.dart';
import '../../../financial/domain/entities/financial_summary.dart';
import '../../../financial/domain/usecases/financial_usecases.dart';
import '../../../financial/presentation/cubit/financial_cubit.dart';
import '../../../financial/presentation/widgets/financial_summary_card.dart';
import '../../../handover/domain/entities/handover.dart';
import '../../../handover/domain/usecases/handover_usecases.dart';
import '../../../handover/presentation/pages/check_in_page.dart';
import '../../../handover/presentation/pages/handover_summary_page.dart';
import '../../../incident/domain/entities/claim_summary.dart';
import '../../../incident/domain/entities/incident_report.dart';
import '../../../incident/domain/usecases/incident_usecases.dart';
import '../../../payment/presentation/pages/payment_page.dart';
import '../../../review/domain/entities/review_entity.dart';
import '../../../review/domain/usecases/review_usecases.dart';
import '../../../review/presentation/pages/create_review_page.dart';
import '../../../review/presentation/widgets/blind_review_status_card.dart';
import '../../../trip/presentation/bloc/trip_bloc.dart';
import '../../../trip/presentation/bloc/trip_event.dart';
import '../../../trip/presentation/bloc/trip_state.dart';
import '../../../trip/presentation/pages/active_trip_page.dart';
import '../../domain/entities/booking.dart';
import '../../domain/entities/cancellation_refund_preview.dart';
import '../../domain/usecases/booking_usecases.dart';
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
  Future<BookingReviewStatus?>? _reviewStatusFuture;

  @override
  void initState() {
    super.initState();
    _setupRealtimeUpdates();
    // ✅ Load booking data when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookingBloc>().add(LoadBookingByIdEvent(widget.bookingId));
    });
    _reviewStatusFuture = _loadReviewStatus();
  }

  void _setupRealtimeUpdates() {
    // Subscribe to booking updates via WebSocket
    _socketService.subscribeToBooking(widget.bookingId);

    // Listen for updates
    _bookingUpdateSubscription = _socketService.bookingUpdateStream.listen((
      data,
    ) {
      if (data['bookingId'] == widget.bookingId) {
        if (!mounted) return;
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

  Future<BookingReviewStatus?> _loadReviewStatus() async {
    final result = await sl<GetBookingReviewStatusUseCase>()(
      GetBookingReviewStatusParams(widget.bookingId),
    );
    return result.fold((_) => null, (status) => status);
  }

  void _refreshReviewStatus() {
    setState(() {
      _reviewStatusFuture = _loadReviewStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

          if (_shouldShowFinancialSummary(booking)) ...[
            const SizedBox(height: 16),
            BlocProvider(
              create: (_) => sl<FinancialCubit>()..load(booking.id),
              child: FinancialSummaryCard(
                allowDisputes: !widget.isOwnerView,
                onDisputeCharge: (charge) =>
                    _showDisputeChargeDialog(context, booking, charge),
              ),
            ),
          ],

          if (_shouldShowIncidentPanel(booking)) ...[
            const SizedBox(height: 16),
            _buildIncidentReportsCard(context, booking),
          ],

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

  bool _shouldShowFinancialSummary(BookingEntity booking) {
    return booking.deposit > 0 &&
        (booking.isPaymentCompleted ||
            booking.isOngoing ||
            booking.isCompleted);
  }

  bool _shouldShowIncidentPanel(BookingEntity booking) {
    return booking.isConfirmed || booking.isOngoing || booking.isCompleted;
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
            VietnamTime.format(booking.createdAt, 'dd/MM/yyyy HH:mm'),
          ),
          if (booking.confirmedAt != null) ...[
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.check_circle_outline,
              'Ngày xác nhận',
              VietnamTime.format(booking.confirmedAt!, 'dd/MM/yyyy HH:mm'),
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
            VietnamTime.format(booking.startTime, 'dd/MM/yyyy HH:mm'),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.access_time_filled,
            'Kết thúc',
            VietnamTime.format(booking.endTime, 'dd/MM/yyyy HH:mm'),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.timer, 'Thời lượng', booking.durationDisplayText),
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
            Icons.verified_user_outlined,
            'Gói bảo vệ ${_protectionPlanLabel(booking.protectionPlan)}',
            '${NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(booking.protectionFee)} - khấu trừ ${NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(booking.protectionDeductible)}',
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
                NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(
                  booking.totalPrice + booking.protectionFee + booking.deposit,
                ),
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

  String _protectionPlanLabel(String value) {
    switch (value.toUpperCase()) {
      case 'BASIC':
        return 'Cơ bản';
      case 'PREMIUM':
        return 'Cao cấp';
      case 'STANDARD':
      default:
        return 'Tiêu chuẩn';
    }
  }

  Widget _buildIncidentReportsCard(
    BuildContext context,
    BookingEntity booking,
  ) {
    final summaryFuture = sl<GetBookingClaimSummaryUseCase>()(
      GetBookingClaimSummaryParams(booking.id),
    );

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
      child: FutureBuilder(
        future: summaryFuture,
        builder: (context, snapshot) {
          final summary = snapshot.data?.fold<BookingClaimSummaryEntity?>(
            (_) => null,
            (item) => item,
          );
          final reports = summary?.incidents ?? <IncidentReportEntity>[];
          final failureMessage = snapshot.data?.fold(
            (failure) => failure.message,
            (_) => null,
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Sự cố / yêu cầu bồi thường',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () =>
                        _showIncidentReportDialog(context, booking),
                    icon: const Icon(Icons.report_problem_outlined, size: 18),
                    label: const Text('Báo cáo'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (snapshot.connectionState != ConnectionState.done)
                const LinearProgressIndicator(minHeight: 3)
              else if (failureMessage != null)
                Text(
                  failureMessage,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppColors.error,
                  ),
                )
              else ...[
                if (summary != null)
                  _buildClaimSummaryOverview(context, summary),
                if (reports.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Chưa có báo cáo sự cố cho booking này.',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  )
                else ...[
                  const SizedBox(height: 12),
                  ...reports.map(_buildIncidentReportRow),
                ],
                if (summary != null && summary.timeline.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _buildClaimTimeline(summary.timeline),
                ],
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildClaimSummaryOverview(
    BuildContext context,
    BookingClaimSummaryEntity summary,
  ) {
    final color = _claimStatusColor(summary.status);
    final formatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
      decimalDigits: 0,
    );
    final firstActions = summary.nextActions.take(2).toList();
    final firstBlockers = summary.blockers.take(2).toList();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  summary.status.displayText,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${summary.totals.unresolvedIncidentCount} sự cố mở · ${formatter.format(summary.totals.pendingChargeAmount + summary.totals.approvedChargeAmount)} phí chờ xử lý',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          if (firstBlockers.isNotEmpty) ...[
            const SizedBox(height: 10),
            ...firstBlockers.map(
              (blocker) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.lock_clock_outlined,
                      size: 14,
                      color: AppColors.warning,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _claimBlockerText(blocker),
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (firstActions.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...firstActions.map(
              (action) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.task_alt_outlined,
                      size: 14,
                      color: AppColors.info,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${_claimActorText(action.actor)}: ${_claimActionText(action)}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _IncidentMetaChip(
                icon: Icons.account_balance_wallet_outlined,
                text:
                    'Cọc còn lại: ${formatter.format(summary.totals.releasableDepositAmount)}',
              ),
              _IncidentMetaChip(
                icon: Icons.payments_outlined,
                text:
                    'Payout: ${formatter.format(summary.totals.ownerPayoutAmount)}',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () {
                final ownerQuery = widget.isOwnerView ? '?owner=1' : '';
                context.push('/bookings/${summary.bookingId}/claim$ownerQuery');
              },
              icon: const Icon(Icons.open_in_new_outlined, size: 16),
              label: const Text('Xem trạng thái'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClaimTimeline(List<ClaimTimelineEventEntity> timeline) {
    final recent = timeline.reversed.take(4).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dòng xử lý',
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        ...recent.map(
          (event) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(top: 5),
                  decoration: BoxDecoration(
                    color: AppColors.info,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${VietnamTime.format(event.occurredAt, 'dd/MM HH:mm')} · ${_claimTimelineText(event)}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIncidentReportRow(IncidentReportEntity report) {
    final color = _incidentStatusColor(report.status);
    final evidenceCount =
        report.evidenceUrls.length + report.handoverPhotoCount;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  report.category.displayText,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  report.status.displayText,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            report.description,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _IncidentMetaChip(
                icon: Icons.priority_high_outlined,
                text: 'Mức độ: ${report.severity.displayText}',
              ),
              _IncidentMetaChip(
                icon: Icons.image_outlined,
                text: '$evidenceCount bằng chứng',
              ),
              _IncidentMetaChip(
                icon: Icons.schedule_outlined,
                text: VietnamTime.format(report.createdAt, 'dd/MM HH:mm'),
              ),
            ],
          ),
          if (report.adminNotes?.trim().isNotEmpty ?? false) ...[
            const SizedBox(height: 8),
            Text(
              'Admin: ${report.adminNotes}',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _incidentStatusColor(IncidentStatus status) {
    switch (status) {
      case IncidentStatus.open:
        return AppColors.warning;
      case IncidentStatus.underReview:
        return AppColors.info;
      case IncidentStatus.resolved:
        return AppColors.success;
      case IncidentStatus.rejected:
        return AppColors.error;
    }
  }

  Color _claimStatusColor(ClaimWorkflowStatus status) {
    switch (status) {
      case ClaimWorkflowStatus.noClaim:
      case ClaimWorkflowStatus.resolved:
        return AppColors.success;
      case ClaimWorkflowStatus.open:
      case ClaimWorkflowStatus.awaitingChargeReview:
      case ClaimWorkflowStatus.awaitingDepositDecision:
        return AppColors.warning;
      case ClaimWorkflowStatus.underReview:
      case ClaimWorkflowStatus.awaitingPayout:
        return AppColors.info;
    }
  }

  String _claimBlockerText(ClaimBlockerEntity blocker) {
    switch (blocker.code) {
      case 'UNRESOLVED_INCIDENTS':
        return '${blocker.count} sự cố đang mở hoặc đang xét duyệt';
      case 'UNRESOLVED_POST_TRIP_CHARGES':
        return '${blocker.count} phí sau chuyến cần admin duyệt';
      case 'APPROVED_CHARGES_NOT_CAPTURED':
        return '${blocker.count} phí đã duyệt chưa được khấu trừ hoặc miễn';
      case 'DEPOSIT_DECISION_PENDING':
        return 'Tiền cọc đang chờ quyết định xử lý';
      case 'OWNER_PAYOUT_ON_HOLD':
        return 'Payout owner đang bị giữ';
      default:
        return blocker.label;
    }
  }

  String _claimActorText(String actor) {
    switch (actor.toUpperCase()) {
      case 'ADMIN':
        return 'Admin';
      case 'OWNER':
        return 'Owner';
      case 'RENTER':
        return 'Người thuê';
      default:
        return actor;
    }
  }

  String _claimActionText(ClaimNextActionEntity action) {
    switch (action.action) {
      case 'Move incident reports under review':
        return 'chuyển sự cố sang đang xét duyệt';
      case 'Resolve or reject incident reports':
        return 'kết luận sự cố';
      case 'Review disputed or pending post-trip charges':
        return 'duyệt phí sau chuyến';
      case 'Capture approved charges or waive them':
        return 'khấu trừ hoặc miễn phí đã duyệt';
      case 'Release remaining deposit':
        return 'hoàn phần cọc còn lại';
      case 'Wait for admin deposit decision':
        return 'chờ quyết định tiền cọc';
      case 'Process owner payout':
        return 'xử lý payout owner';
      case 'Wait for payout hold to clear':
        return 'chờ gỡ giữ payout';
      case 'Create or refresh owner payout':
        return 'tạo hoặc cập nhật payout owner';
      default:
        return action.action;
    }
  }

  String _claimTimelineText(ClaimTimelineEventEntity event) {
    switch (event.type) {
      case 'BOOKING_CREATED':
        return 'Booking được tạo';
      case 'PAYMENT_COMPLETED':
        return 'Thanh toán hoàn tất';
      case 'TRIP_COMPLETED':
        return 'Chuyến đi hoàn tất';
      case 'DEPOSIT_HELD':
        return 'Tiền cọc được ghi nhận';
      case 'DEPOSIT_DISPUTED':
        return 'Tiền cọc chuyển sang tranh chấp';
      case 'DEPOSIT_RELEASED':
        return 'Tiền cọc đã hoàn';
      case 'POST_TRIP_CHARGE_CREATED':
        return 'Phí sau chuyến được tạo';
      case 'POST_TRIP_CHARGE_REVIEWED':
        return 'Phí sau chuyến được duyệt';
      case 'INCIDENT_CREATED':
        return 'Sự cố được báo cáo';
      case 'INCIDENT_REVIEWED':
        return 'Sự cố được admin xem xét';
      case 'INCIDENT_RESOLVED':
        return 'Sự cố được kết luận';
      case 'OWNER_PAYOUT_CREATED':
        return 'Payout owner được chuẩn bị';
      case 'OWNER_PAYOUT_PROCESSED':
        return 'Payout owner bắt đầu xử lý';
      case 'OWNER_PAYOUT_COMPLETED':
        return 'Payout owner hoàn tất';
      default:
        return event.label;
    }
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

    if (widget.isOwnerView && (booking.isConfirmed || booking.isOngoing)) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => HandoverSummaryPage(
                  bookingId: booking.id,
                  allowCheckOut: booking.isOngoing,
                ),
              ),
            ),
            icon: const Icon(Icons.assignment_turned_in_outlined),
            label: Text(
              'Biên bản bàn giao',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      );
    }

    if (widget.isOwnerView && booking.isCompleted) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showManualChargeDialog(context, booking),
                icon: const Icon(Icons.add_card_outlined),
                label: Text(
                  'Thêm phí sau chuyến',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildReviewExperience(context, booking),
          ],
        ),
      );
    }

    // Renter actions for CONFIRMED bookings
    if (!widget.isOwnerView && booking.isConfirmed) {
      final canStartTrip = booking.isPaymentCompleted;
      final isWithinStartWindow = booking.isWithinStartWindow;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            if (!canStartTrip) ...[
              _buildPaymentRequiredCard(booking),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _navigateToPayment(context, booking),
                  icon: const Icon(Icons.payment),
                  label: Text(
                    booking.paymentStatus?.toUpperCase() == 'FAILED'
                        ? 'Thanh toán lại'
                        : 'Thanh toán',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.lock_outline),
                  label: Text(
                    'Hoàn tất thanh toán để bắt đầu',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ] else ...[
              _buildPaidReadyCard(),
              const SizedBox(height: 12),
              if (isWithinStartWindow)
                BlocProvider(
                  create: (_) => sl<TripBloc>(),
                  child: _StartTripButton(booking: booking),
                )
              else
                _buildStartWindowLockedButton(booking),
            ],
            const SizedBox(height: 12),
            // Cancel button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _showCancelDialog(context, booking),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.error),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
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
          ],
        ),
      );
    }

    if (!widget.isOwnerView && booking.isOngoing) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => context.push('/active-trip'),
            icon: const Icon(Icons.navigation_rounded),
            label: Text(
              'Theo dõi chuyến đi',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      );
    }

    // Renter actions for PENDING bookings (cancel only)
    if (!widget.isOwnerView && booking.isPending) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => _showCancelDialog(context, booking),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColors.error),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
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

    // Completed booking - show review button
    if (!widget.isOwnerView && booking.isCompleted) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: _buildReviewExperience(context, booking),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildReviewExperience(BuildContext context, BookingEntity booking) {
    return FutureBuilder<BookingReviewStatus?>(
      future: _reviewStatusFuture,
      builder: (context, snapshot) {
        final isChecking = snapshot.connectionState != ConnectionState.done;
        final status = snapshot.data;
        final hasSubmitted = status?.submitted ?? false;
        final hasActivity = status?.hasActivity ?? false;
        return Column(
          children: [
            if (hasActivity)
              BlindReviewStatusCard(
                status: status!,
                isOwnerView: widget.isOwnerView,
              ),
            if (hasActivity && !hasSubmitted) const SizedBox(height: 12),
            if (!hasSubmitted)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isChecking
                      ? null
                      : () => _navigateToReview(context, booking),
                  icon: Icon(
                    widget.isOwnerView
                        ? Icons.person_search_outlined
                        : Icons.star_outline,
                  ),
                  label: Text(
                    isChecking
                        ? 'Đang kiểm tra đánh giá...'
                        : widget.isOwnerView
                        ? 'Đánh giá người thuê'
                        : 'Đánh giá chuyến đi',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFB300),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.textMuted.withValues(
                      alpha: 0.18,
                    ),
                    disabledForegroundColor: AppColors.textMuted,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildPaymentRequiredCard(BookingEntity booking) {
    final totalAmount = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: 'đ',
    ).format(booking.totalPrice + booking.protectionFee + booking.deposit);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: AppColors.warning, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Bạn cần thanh toán $totalAmount trước khi bắt đầu chuyến đi. Tiền cọc sẽ được giữ tạm và hoàn lại sau khi trả xe nếu không có hư hỏng.',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaidReadyCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.success.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Icon(Icons.verified_outlined, color: AppColors.success, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Đã thanh toán. Bạn có thể bắt đầu chuyến đi khi đến thời gian thuê.',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartWindowLockedButton(BookingEntity booking) {
    final now = DateTime.now();
    final earliestStart = booking.startTime.subtract(
      const Duration(minutes: 15),
    );
    final message = now.isBefore(earliestStart)
        ? 'Có thể bắt đầu từ ${VietnamTime.format(earliestStart, 'HH:mm dd/MM')}'
        : 'Đã quá thời gian bắt đầu cho phép';

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: null,
        icon: const Icon(Icons.schedule_outlined),
        label: Text(
          message,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Future<void> _navigateToPayment(
    BuildContext context,
    BookingEntity booking,
  ) async {
    final bookingBloc = context.read<BookingBloc>();
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentPage(
          bookingId: booking.id,
          totalAmount: booking.totalPrice,
          protectionFee: booking.protectionFee,
          deposit: booking.deposit,
        ),
      ),
    );

    if (context.mounted) {
      bookingBloc.add(LoadBookingByIdEvent(booking.id));
    }
  }

  Future<void> _navigateToReview(
    BuildContext context,
    BookingEntity booking,
  ) async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CreateReviewPage(
          vehicleId: booking.vehicleId,
          vehicleName: widget.isOwnerView
              ? 'Người thuê ${booking.renterId.substring(0, 8)}'
              : booking.vehicleName ?? 'Xe đã thuê',
          bookingId: booking.id,
          isOwnerReview: widget.isOwnerView,
        ),
      ),
    );
    if (created == true && mounted) {
      _refreshReviewStatus();
    }
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

  void _showCancelDialog(
    BuildContext dialogBookingContext,
    BookingEntity booking,
  ) {
    final reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final previewFuture = sl<GetCancellationRefundPreviewUseCase>()(
      GetCancellationRefundPreviewParams(booking.id),
    );

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          'Hủy booking',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Bạn có chắc chắn muốn hủy booking này?',
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
                const SizedBox(height: 14),
                FutureBuilder(
                  future: previewFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: LinearProgressIndicator(minHeight: 3),
                      );
                    }

                    final result = snapshot.data;
                    if (result == null) {
                      return const SizedBox.shrink();
                    }

                    return result.fold(
                      (_) => const SizedBox.shrink(),
                      (preview) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _CancellationRefundPreviewPanel(
                          preview: preview,
                        ),
                      ),
                    );
                  },
                ),
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

  void _showIncidentReportDialog(BuildContext context, BookingEntity booking) {
    final descriptionController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final handoverFuture = sl<GetHandoverByBookingUseCase>()(
      GetHandoverByBookingParams(booking.id),
    );
    var selectedCategory = IncidentCategory.mechanicalIssue;
    var selectedSeverity = IncidentSeverity.medium;
    var uploadedEvidenceUrls = <String>[];
    var selectedHandoverPhotoIds = <String>{};
    var isUploading = false;
    var isSubmitting = false;
    final bookingBloc = context.read<BookingBloc>();

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          final requiresEvidence =
              selectedCategory.requiresEvidence ||
              selectedSeverity == IncidentSeverity.critical;

          Future<void> pickAndUploadEvidence() async {
            if (uploadedEvidenceUrls.length >= 10) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tối đa 10 ảnh bằng chứng.'),
                  backgroundColor: AppColors.warning,
                ),
              );
              return;
            }

            final result = await FilePicker.platform.pickFiles(
              type: FileType.image,
              allowMultiple: false,
              withData: true,
            );
            if (result == null || result.files.isEmpty) return;
            final file = result.files.first;
            final bytes = file.bytes;
            if (bytes == null) return;

            setDialogState(() => isUploading = true);
            try {
              final uploaded = await sl<UploadService>().uploadIncidentImage(
                fileBytes: bytes,
                fileName: file.name,
              );
              setDialogState(() {
                uploadedEvidenceUrls = [...uploadedEvidenceUrls, uploaded.url];
              });
            } catch (e) {
              if (!mounted || !context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Tải ảnh bằng chứng thất bại: $e'),
                  backgroundColor: AppColors.error,
                ),
              );
            } finally {
              if (dialogContext.mounted) {
                setDialogState(() => isUploading = false);
              }
            }
          }

          Future<void> submit() async {
            if (!(formKey.currentState?.validate() ?? false)) return;
            if (requiresEvidence &&
                uploadedEvidenceUrls.isEmpty &&
                selectedHandoverPhotoIds.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Loại sự cố này cần ảnh tải lên hoặc ảnh bàn giao.',
                  ),
                  backgroundColor: AppColors.error,
                ),
              );
              return;
            }

            setDialogState(() => isSubmitting = true);
            final messenger = ScaffoldMessenger.of(context);
            final navigator = Navigator.of(dialogContext);
            final result = await sl<CreateIncidentReportUseCase>()(
              CreateIncidentReportParams(
                bookingId: booking.id,
                category: selectedCategory,
                severity: selectedSeverity,
                description: descriptionController.text.trim(),
                evidenceUrls: uploadedEvidenceUrls.isEmpty
                    ? null
                    : uploadedEvidenceUrls,
                handoverPhotoIds: selectedHandoverPhotoIds.isEmpty
                    ? null
                    : selectedHandoverPhotoIds.toList(),
              ),
            );

            if (!mounted || !dialogContext.mounted) return;
            result.fold(
              (failure) {
                setDialogState(() => isSubmitting = false);
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(failure.message),
                    backgroundColor: AppColors.error,
                  ),
                );
              },
              (_) {
                navigator.pop();
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Đã gửi báo cáo sự cố cho Admin'),
                    backgroundColor: AppColors.success,
                  ),
                );
                bookingBloc.add(LoadBookingByIdEvent(booking.id));
              },
            );
          }

          return AlertDialog(
            title: Text(
              'Báo cáo sự cố',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<IncidentCategory>(
                      initialValue: selectedCategory,
                      decoration: InputDecoration(
                        labelText: 'Loại sự cố',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: IncidentCategory.values.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category.displayText),
                        );
                      }).toList(),
                      onChanged: isSubmitting || isUploading
                          ? null
                          : (category) {
                              if (category != null) {
                                setDialogState(
                                  () => selectedCategory = category,
                                );
                              }
                            },
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<IncidentSeverity>(
                      initialValue: selectedSeverity,
                      decoration: InputDecoration(
                        labelText: 'Mức độ',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: IncidentSeverity.values.map((severity) {
                        return DropdownMenuItem(
                          value: severity,
                          child: Text(severity.displayText),
                        );
                      }).toList(),
                      onChanged: isSubmitting || isUploading
                          ? null
                          : (severity) {
                              if (severity != null) {
                                setDialogState(
                                  () => selectedSeverity = severity,
                                );
                              }
                            },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: descriptionController,
                      enabled: !isSubmitting && !isUploading,
                      maxLines: 4,
                      maxLength: 1000,
                      decoration: InputDecoration(
                        labelText: 'Mô tả *',
                        hintText:
                            'Mô tả sự cố, thời điểm xảy ra và bằng chứng liên quan...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Nhập mô tả sự cố';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: requiresEvidence
                            ? AppColors.warning.withOpacity(0.08)
                            : AppColors.info.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: requiresEvidence
                              ? AppColors.warning.withOpacity(0.25)
                              : AppColors.info.withOpacity(0.18),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            requiresEvidence
                                ? 'Cần ảnh tải lên hoặc ảnh bàn giao đã lưu.'
                                : 'Thêm ảnh mới hoặc dùng ảnh bàn giao đã lưu.',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              ...uploadedEvidenceUrls.asMap().entries.map(
                                (entry) => Chip(
                                  label: Text('Ảnh ${entry.key + 1}'),
                                  deleteIcon: const Icon(Icons.close, size: 16),
                                  onDeleted: isSubmitting || isUploading
                                      ? null
                                      : () {
                                          setDialogState(() {
                                            uploadedEvidenceUrls = [
                                              ...uploadedEvidenceUrls,
                                            ]..removeAt(entry.key);
                                          });
                                        },
                                ),
                              ),
                              ActionChip(
                                avatar: isUploading
                                    ? const SizedBox(
                                        height: 16,
                                        width: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.add_a_photo, size: 18),
                                label: Text(
                                  isUploading ? 'Đang tải...' : 'Thêm ảnh',
                                ),
                                onPressed: isSubmitting || isUploading
                                    ? null
                                    : pickAndUploadEvidence,
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'Ảnh bàn giao đã lưu',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          FutureBuilder(
                            future: handoverFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState !=
                                  ConnectionState.done) {
                                return const LinearProgressIndicator(
                                  minHeight: 2,
                                );
                              }

                              final handover = snapshot.data
                                  ?.fold<HandoverSummary?>(
                                    (_) => null,
                                    (summary) => summary,
                                  );
                              final photos = <HandoverPhoto>[
                                ...?handover?.checkOut?.photos,
                                ...?handover?.checkIn?.photos,
                              ];

                              if (photos.isEmpty) {
                                return Text(
                                  'Chưa có ảnh bàn giao để chọn.',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                );
                              }

                              return Column(
                                children: photos.map((photo) {
                                  final isSelected = selectedHandoverPhotoIds
                                      .contains(photo.id);
                                  final type =
                                      photos.indexOf(photo) <
                                          (handover?.checkOut?.photos.length ??
                                              0)
                                      ? 'Check-out'
                                      : 'Check-in';
                                  return CheckboxListTile(
                                    value: isSelected,
                                    contentPadding: EdgeInsets.zero,
                                    dense: true,
                                    controlAffinity:
                                        ListTileControlAffinity.leading,
                                    title: Row(
                                      children: [
                                        AppNetworkImage(
                                          imageUrl: photo.photoUrl,
                                          width: 44,
                                          height: 44,
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                          cacheWidth: 88,
                                          cacheHeight: 88,
                                          semanticLabel:
                                              'Ảnh bàn giao ${photo.photoType}',
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            '$type · ${photo.photoType}',
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    onChanged: isSubmitting || isUploading
                                        ? null
                                        : (selected) {
                                            if (selected == true &&
                                                selectedHandoverPhotoIds
                                                        .length >=
                                                    10) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Tối đa 10 ảnh bàn giao.',
                                                  ),
                                                  backgroundColor:
                                                      AppColors.warning,
                                                ),
                                              );
                                              return;
                                            }
                                            setDialogState(() {
                                              selectedHandoverPhotoIds = {
                                                ...selectedHandoverPhotoIds,
                                              };
                                              if (selected == true) {
                                                selectedHandoverPhotoIds.add(
                                                  photo.id,
                                                );
                                              } else {
                                                selectedHandoverPhotoIds.remove(
                                                  photo.id,
                                                );
                                              }
                                            });
                                          },
                                  );
                                }).toList(),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: isSubmitting || isUploading
                    ? null
                    : () => Navigator.pop(dialogContext),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: isSubmitting || isUploading ? null : submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.warning,
                ),
                child: isSubmitting
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Gửi báo cáo'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showManualChargeDialog(BuildContext context, BookingEntity booking) {
    final amountController = TextEditingController();
    final descriptionController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    var selectedType = PostTripChargeType.damage;
    var isSubmitting = false;
    final bookingBloc = context.read<BookingBloc>();

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          Future<void> submit() async {
            if (!(formKey.currentState?.validate() ?? false)) return;
            setDialogState(() => isSubmitting = true);

            final amount = double.parse(amountController.text.trim());
            final messenger = ScaffoldMessenger.of(context);
            final navigator = Navigator.of(dialogContext);
            final result = await sl<CreateManualPostTripChargeUseCase>()(
              CreateManualPostTripChargeParams(
                bookingId: booking.id,
                type: selectedType,
                amount: amount,
                description: descriptionController.text.trim(),
              ),
            );

            if (!mounted || !dialogContext.mounted) return;
            result.fold(
              (failure) {
                setDialogState(() => isSubmitting = false);
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(failure.message),
                    backgroundColor: AppColors.error,
                  ),
                );
              },
              (_) {
                navigator.pop();
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Đã gửi phí sau chuyến để xét duyệt'),
                    backgroundColor: AppColors.success,
                  ),
                );
                bookingBloc.add(LoadBookingByIdEvent(booking.id));
              },
            );
          }

          return AlertDialog(
            title: Text(
              'Thêm phí sau chuyến',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<PostTripChargeType>(
                      initialValue: selectedType,
                      decoration: InputDecoration(
                        labelText: 'Loại phí',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items:
                          const [
                            PostTripChargeType.damage,
                            PostTripChargeType.cleaning,
                            PostTripChargeType.roadsideAssistance,
                            PostTripChargeType.other,
                          ].map((type) {
                            return DropdownMenuItem(
                              value: type,
                              child: Text(_manualChargeTypeLabel(type)),
                            );
                          }).toList(),
                      onChanged: isSubmitting
                          ? null
                          : (type) {
                              if (type != null) {
                                setDialogState(() => selectedType = type);
                              }
                            },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      enabled: !isSubmitting,
                      decoration: InputDecoration(
                        labelText: 'Số tiền *',
                        hintText: 'Ví dụ: 50000',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        final amount = double.tryParse(value?.trim() ?? '');
                        if (amount == null || amount <= 0) {
                          return 'Nhập số tiền hợp lệ';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: descriptionController,
                      enabled: !isSubmitting,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Mô tả *',
                        hintText: 'Mô tả lý do phát sinh phí...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Nhập mô tả phí';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: isSubmitting
                    ? null
                    : () => Navigator.pop(dialogContext),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: isSubmitting ? null : submit,
                child: isSubmitting
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Gửi phí'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showDisputeChargeDialog(
    BuildContext context,
    BookingEntity booking,
    PostTripChargeEntity charge,
  ) {
    final reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    var isSubmitting = false;
    final bookingBloc = context.read<BookingBloc>();
    final currency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          Future<void> submit() async {
            if (!(formKey.currentState?.validate() ?? false)) return;
            setDialogState(() => isSubmitting = true);

            final messenger = ScaffoldMessenger.of(context);
            final navigator = Navigator.of(dialogContext);
            final result = await sl<DisputePostTripChargeUseCase>()(
              DisputePostTripChargeParams(
                chargeId: charge.id,
                reason: reasonController.text.trim(),
              ),
            );

            if (!mounted || !dialogContext.mounted) return;
            result.fold(
              (failure) {
                setDialogState(() => isSubmitting = false);
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(failure.message),
                    backgroundColor: AppColors.error,
                  ),
                );
              },
              (_) {
                navigator.pop();
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Đã gửi khiếu nại phí sau chuyến'),
                    backgroundColor: AppColors.success,
                  ),
                );
                bookingBloc.add(LoadBookingByIdEvent(booking.id));
              },
            );
          }

          return AlertDialog(
            title: Text(
              'Khiếu nại phí',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${charge.type.displayText} - ${currency.format(charge.amount)}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (charge.description.trim().isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        charge.description,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: reasonController,
                      enabled: !isSubmitting,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: 'Lý do khiếu nại *',
                        hintText: 'Mô tả vì sao bạn không đồng ý với phí này',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Nhập lý do khiếu nại';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: isSubmitting
                    ? null
                    : () => Navigator.pop(dialogContext),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: isSubmitting ? null : submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.warning,
                ),
                child: isSubmitting
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Gửi khiếu nại'),
              ),
            ],
          );
        },
      ),
    );
  }

  static String _manualChargeTypeLabel(PostTripChargeType type) {
    switch (type) {
      case PostTripChargeType.damage:
        return 'Hư hỏng';
      case PostTripChargeType.cleaning:
        return 'Vệ sinh';
      case PostTripChargeType.roadsideAssistance:
        return 'Hỗ trợ sự cố';
      case PostTripChargeType.other:
        return 'Phí khác';
      case PostTripChargeType.lateReturn:
        return 'Trả xe trễ';
      case PostTripChargeType.excessDistance:
        return 'Vượt giới hạn km';
      case PostTripChargeType.lowBattery:
        return 'Pin thấp khi trả xe';
    }
  }
}

class _IncidentMetaChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _IncidentMetaChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.textMuted.withOpacity(0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.textMuted),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _CancellationRefundPreviewPanel extends StatelessWidget {
  final CancellationRefundPreview preview;

  const _CancellationRefundPreviewPanel({required this.preview});

  static final NumberFormat _currency = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: 'đ',
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.receipt_long_outlined,
                color: AppColors.warning,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  preview.policyDisplayText,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _row('Hoàn tiền thuê', preview.refundableRentalAmount),
          if (preview.protectionAmount > 0) ...[
            const SizedBox(height: 6),
            _row('Hoàn phí bảo vệ', preview.refundableProtectionAmount),
          ],
          const SizedBox(height: 6),
          _row('Hoàn tiền cọc', preview.refundableDepositAmount),
          const Divider(height: 18),
          _row(
            'Dự kiến hoàn',
            preview.refundAmount,
            valueColor: AppColors.success,
            emphasize: true,
          ),
          if (preview.forfeitedAmount > 0) ...[
            const SizedBox(height: 6),
            _row(
              'Không hoàn',
              preview.forfeitedAmount,
              valueColor: AppColors.error,
            ),
          ],
          if (preview.trustPenalty > 0) ...[
            const SizedBox(height: 8),
            Text(
              'Trừ ${preview.trustPenalty.toStringAsFixed(0)} điểm tin cậy',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.error,
              ),
            ),
          ],
          if (!preview.isPaid) ...[
            const SizedBox(height: 8),
            Text(
              'Chưa ghi nhận thanh toán',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _row(
    String label,
    double value, {
    Color valueColor = AppColors.textPrimary,
    bool emphasize = false,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            _currency.format(value),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: emphasize ? 14 : 12,
              fontWeight: emphasize ? FontWeight.w700 : FontWeight.w600,
              color: valueColor,
            ),
          ),
        ),
      ],
    );
  }
}

/// Start Trip button — collects GPS before dispatching [StartTripEvent].
class _StartTripButton extends StatefulWidget {
  final BookingEntity booking;

  const _StartTripButton({required this.booking});

  @override
  State<_StartTripButton> createState() => _StartTripButtonState();
}

class _StartTripButtonState extends State<_StartTripButton> {
  bool _isGettingLocation = false;

  String _startTripFailureMessage(String rawMessage) {
    if (rawMessage.contains('startLatitude') ||
        rawMessage.contains('startLongitude') ||
        rawMessage.contains('Start location')) {
      return 'Không lấy được vị trí xuất phát. Vui lòng bật định vị và thử lại.';
    }
    if (rawMessage.contains('startBattery')) {
      return 'Không có thông tin pin lúc bắt đầu chuyến đi. Vui lòng tải lại booking và thử lại.';
    }
    if (rawMessage.contains('check-in handover')) {
      return 'Vui lòng hoàn tất biên bản nhận xe và xác nhận từ hai bên trước khi bắt đầu.';
    }
    return rawMessage;
  }

  Future<void> _handleStartTrip() async {
    final handoverReady = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CheckInPage(
          bookingId: widget.booking.id,
          initialBatteryLevel: widget.booking.vehicleBatteryLevel,
        ),
      ),
    );

    if (!mounted || handoverReady != true) return;
    setState(() => _isGettingLocation = true);

    double? lat;
    double? lng;
    String? address;
    String? locationError;

    try {
      final result = await sl<LocationService>().getCurrentPositionResult();
      locationError = result.errorMessage;
      final position = result.position;
      if (position != null) {
        lat = position.latitude;
        lng = position.longitude;
        // Build a simple address string from coords (reverse geocode not
        // needed here — backend stores raw coords for distance calc)
        address =
            '${position.latitude.toStringAsFixed(5)}, '
            '${position.longitude.toStringAsFixed(5)}';
      }
    } catch (error) {
      locationError = error.toString();
    }

    if (!mounted) return;
    setState(() => _isGettingLocation = false);

    if (lat == null || lng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            locationError == null || locationError.isEmpty
                ? 'Không lấy được vị trí xuất phát. Vui lòng bật định vị và thử lại.'
                : 'Không lấy được vị trí xuất phát. $locationError',
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    context.read<TripBloc>().add(
      StartTripEvent(
        bookingId: widget.booking.id,
        startLatitude: lat,
        startLongitude: lng,
        startAddress: address,
        startBattery: widget.booking.vehicleBatteryLevel?.toDouble(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TripBloc, TripState>(
      listener: (context, state) {
        if (state is TripStarted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ActiveTripPage(
                tripId: state.trip.id,
                bookingId: widget.booking.id,
              ),
            ),
          );
        } else if (state is TripFailure) {
          final message = _startTripFailureMessage(state.message);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        final isBusy = state is TripLoading || _isGettingLocation;
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: isBusy ? null : _handleStartTrip,
            icon: isBusy
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.play_circle_outline),
            label: Text(
              _isGettingLocation ? 'Đang lấy vị trí...' : 'Bắt đầu chuyến đi',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        );
      },
    );
  }
}
