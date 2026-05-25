import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/vietnam_time.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/claim_summary.dart';
import '../../domain/entities/incident_report.dart';
import '../../domain/usecases/incident_usecases.dart';

class ClaimStatusPage extends StatefulWidget {
  final String bookingId;
  final bool isOwnerView;

  const ClaimStatusPage({
    super.key,
    required this.bookingId,
    this.isOwnerView = false,
  });

  @override
  State<ClaimStatusPage> createState() => _ClaimStatusPageState();
}

class _ClaimStatusPageState extends State<ClaimStatusPage> {
  late Future<Either<Failure, BookingClaimSummaryEntity>> _summaryFuture;

  @override
  void initState() {
    super.initState();
    _summaryFuture = _loadSummary();
  }

  Future<Either<Failure, BookingClaimSummaryEntity>> _loadSummary() {
    return sl<GetBookingClaimSummaryUseCase>()(
      GetBookingClaimSummaryParams(widget.bookingId),
    );
  }

  Future<void> _refresh() async {
    final nextFuture = _loadSummary();
    setState(() {
      _summaryFuture = nextFuture;
    });
    await nextFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Trạng thái claim',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<Either<Failure, BookingClaimSummaryEntity>>(
        future: _summaryFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          final result = snapshot.data;
          if (result == null) {
            return _buildMessage(
              icon: Icons.error_outline,
              title: 'Không tải được claim',
              message: 'Vui lòng thử lại sau.',
            );
          }

          return result.fold(
            (failure) => _buildMessage(
              icon: Icons.error_outline,
              title: 'Không tải được claim',
              message: failure.message,
            ),
            _buildSummaryContent,
          );
        },
      ),
    );
  }

  Widget _buildSummaryContent(BookingClaimSummaryEntity summary) {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          _buildStatusHeader(summary),
          const SizedBox(height: 12),
          if (summary.claimCase != null) ...[
            _buildClaimCaseCard(summary.claimCase!),
            const SizedBox(height: 12),
          ] else if (!summary.hasActiveClaim) ...[
            _buildMessagePanel(
              icon: Icons.verified_outlined,
              title: 'Chưa có claim đang mở',
              message:
                  'Booking này chưa có sự cố, phí sau chuyến, hoặc quyết định cọc cần xử lý.',
              color: AppColors.success,
            ),
            const SizedBox(height: 12),
          ],
          _buildFinancialCard(summary),
          const SizedBox(height: 12),
          _buildBlockersCard(summary.blockers),
          const SizedBox(height: 12),
          _buildActionsCard(summary.nextActions),
          if (summary.incidents.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildIncidentsCard(summary.incidents),
          ],
          if (summary.timeline.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildTimelineCard(summary.timeline),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusHeader(BookingClaimSummaryEntity summary) {
    final color = _claimStatusColor(summary.status);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.gavel_outlined, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      summary.status.displayText,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Booking #${_shortId(summary.bookingId)}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _StatusChip(
                icon: Icons.report_problem_outlined,
                text:
                    '${summary.totals.unresolvedIncidentCount} sự cố chưa chốt',
                color: AppColors.warning,
              ),
              _StatusChip(
                icon: Icons.receipt_long_outlined,
                text:
                    '${_formatMoney(summary.totals.pendingChargeAmount + summary.totals.approvedChargeAmount)} phí chờ xử lý',
                color: AppColors.info,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildClaimCaseCard(ClaimCaseSnapshotEntity claimCase) {
    final sla = claimCase.sla;
    final slaColor = _slaColor(sla?.status);

    return _buildPanel(
      title: 'Hồ sơ claim',
      icon: Icons.folder_special_outlined,
      children: [
        _buildInfoLine('Mã case', claimCase.caseNumber),
        _buildInfoLine('Trạng thái', _claimCaseStatusText(claimCase.status)),
        if (claimCase.outcome != null)
          _buildInfoLine('Kết luận', _claimOutcomeText(claimCase.outcome!)),
        if (claimCase.summary?.trim().isNotEmpty ?? false)
          _buildInfoLine('Tóm tắt', claimCase.summary!.trim()),
        if (sla != null) ...[
          const Divider(height: 22),
          Row(
            children: [
              _StatusChip(
                icon: Icons.schedule_outlined,
                text: _slaStatusText(sla.status),
                color: slaColor,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _slaDetailText(sla),
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
        if (claimCase.firstDecision != null)
          _buildInfoLine(
            'Duyệt lần 1',
            '${_claimOutcomeText(claimCase.firstDecision!)} · ${_formatDateTime(claimCase.firstReviewedAt)}',
          ),
        if (claimCase.secondDecision != null)
          _buildInfoLine(
            'Duyệt lần 2',
            '${_claimOutcomeText(claimCase.secondDecision!)} · ${_formatDateTime(claimCase.secondReviewedAt)}',
          ),
      ],
    );
  }

  Widget _buildFinancialCard(BookingClaimSummaryEntity summary) {
    final rows = [
      _AmountRow('Cọc đang giữ', summary.totals.heldDepositAmount),
      _AmountRow('Cọc có thể hoàn', summary.totals.releasableDepositAmount),
      _AmountRow(
        'Phí chờ xử lý',
        summary.totals.pendingChargeAmount +
            summary.totals.approvedChargeAmount,
      ),
      _AmountRow('Phí đã chốt', summary.totals.finalizedChargeAmount),
      if (widget.isOwnerView)
        _AmountRow('Payout owner', summary.totals.ownerPayoutAmount),
    ];

    return _buildPanel(
      title: 'Tài chính',
      icon: Icons.account_balance_wallet_outlined,
      children: rows
          .map((row) => _buildInfoLine(row.label, _formatMoney(row.amount)))
          .toList(),
    );
  }

  Widget _buildBlockersCard(List<ClaimBlockerEntity> blockers) {
    return _buildPanel(
      title: 'Điểm đang chặn xử lý',
      icon: Icons.lock_clock_outlined,
      children: blockers.isEmpty
          ? [_buildMutedText('Không có blocker đang giữ cọc hoặc payout.')]
          : blockers
                .map(
                  (blocker) => _buildBulletLine(
                    Icons.warning_amber_outlined,
                    _claimBlockerText(blocker),
                    AppColors.warning,
                  ),
                )
                .toList(),
    );
  }

  Widget _buildActionsCard(List<ClaimNextActionEntity> actions) {
    return _buildPanel(
      title: 'Việc tiếp theo',
      icon: Icons.task_alt_outlined,
      children: actions.isEmpty
          ? [_buildMutedText('Chưa có hành động tiếp theo.')]
          : actions
                .map(
                  (action) => _buildBulletLine(
                    Icons.arrow_forward_outlined,
                    '${_claimActorText(action.actor)}: ${_claimActionText(action)}',
                    _actionPriorityColor(action.priority),
                    subtitle: action.reason,
                  ),
                )
                .toList(),
    );
  }

  Widget _buildIncidentsCard(List<IncidentReportEntity> incidents) {
    return _buildPanel(
      title: 'Sự cố liên quan',
      icon: Icons.report_problem_outlined,
      children: incidents.map(_buildIncidentLine).toList(),
    );
  }

  Widget _buildTimelineCard(List<ClaimTimelineEventEntity> timeline) {
    final events = timeline.reversed.toList();
    return _buildPanel(
      title: 'Dòng xử lý',
      icon: Icons.timeline_outlined,
      children: events
          .map(
            (event) => _buildBulletLine(
              Icons.circle,
              _claimTimelineText(event),
              AppColors.info,
              subtitle: VietnamTime.format(
                event.occurredAt,
                'dd/MM/yyyy HH:mm',
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildPanel({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 118,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.textMuted,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletLine(
    IconData icon,
    String text,
    Color color, {
    String? subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                    height: 1.35,
                  ),
                ),
                if (subtitle?.trim().isNotEmpty ?? false) ...[
                  const SizedBox(height: 3),
                  Text(
                    subtitle!.trim(),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.35,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncidentLine(IncidentReportEntity report) {
    return _buildBulletLine(
      Icons.report_outlined,
      '${report.category.displayText} · ${report.status.displayText}',
      _incidentStatusColor(report.status),
      subtitle:
          '${report.severity.displayText} · ${VietnamTime.format(report.createdAt, 'dd/MM/yyyy HH:mm')}',
    );
  }

  Widget _buildMutedText(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 13,
        color: AppColors.textSecondary,
        height: 1.35,
      ),
    );
  }

  Widget _buildMessage({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: _buildMessagePanel(
          icon: icon,
          title: title,
          message: message,
          color: AppColors.error,
        ),
      ),
    );
  }

  Widget _buildMessagePanel({
    required IconData icon,
    required String title,
    required String message,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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

  Color _slaColor(String? status) {
    switch (status) {
      case 'OVERDUE':
        return AppColors.error;
      case 'AT_RISK':
        return AppColors.warning;
      case 'COMPLETED':
        return AppColors.success;
      default:
        return AppColors.info;
    }
  }

  Color _actionPriorityColor(String priority) {
    switch (priority.toUpperCase()) {
      case 'HIGH':
        return AppColors.error;
      case 'MEDIUM':
        return AppColors.warning;
      default:
        return AppColors.info;
    }
  }

  String _claimCaseStatusText(String status) {
    switch (status) {
      case 'OPEN':
        return 'Case mở';
      case 'UNDER_REVIEW':
        return 'Đang review';
      case 'PENDING_SECOND_REVIEW':
        return 'Chờ duyệt lần 2';
      case 'APPROVED':
        return 'Đã duyệt';
      case 'REJECTED':
        return 'Đã bác bỏ';
      case 'RESOLVED':
        return 'Đã xử lý';
      case 'CANCELLED':
        return 'Đã hủy';
      default:
        return status;
    }
  }

  String _claimOutcomeText(String outcome) {
    switch (outcome) {
      case 'OWNER_CLAIM_APPROVED':
        return 'Duyệt claim owner';
      case 'OWNER_CLAIM_PARTIALLY_APPROVED':
        return 'Duyệt một phần';
      case 'OWNER_CLAIM_REJECTED':
        return 'Bác claim owner';
      case 'DEPOSIT_RELEASE_APPROVED':
        return 'Duyệt hoàn cọc';
      case 'PAYOUT_RELEASE_APPROVED':
        return 'Duyệt payout';
      case 'NO_ACTION_REQUIRED':
        return 'Không cần xử lý';
      default:
        return outcome;
    }
  }

  String _slaStatusText(String status) {
    switch (status) {
      case 'OVERDUE':
        return 'Quá hạn';
      case 'AT_RISK':
        return 'Sắp trễ';
      case 'COMPLETED':
        return 'Hoàn tất';
      case 'ON_TRACK':
        return 'Đúng hạn';
      default:
        return status;
    }
  }

  String _slaStageText(String stage) {
    switch (stage) {
      case 'FIRST_REVIEW':
        return 'review lần 1';
      case 'SECOND_REVIEW':
        return 'review lần 2';
      case 'CLOSED':
        return 'đã chốt';
      default:
        return stage.toLowerCase();
    }
  }

  String _slaDetailText(ClaimCaseSlaSnapshotEntity sla) {
    if (sla.isCompleted) return 'Giai đoạn ${_slaStageText(sla.stage)}';
    final dueText = sla.dueAt == null
        ? ''
        : ' · hạn ${_formatDateTime(sla.dueAt)}';
    if (sla.isOverdue) {
      return 'Trễ ${_formatMinutes(sla.overdueMinutes)}$dueText';
    }
    return 'Còn ${_formatMinutes(sla.remainingMinutes)} cho ${_slaStageText(sla.stage)}$dueText';
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
      case 'CLAIM_CASE_OPENED':
        return 'Hồ sơ claim được mở';
      case 'CLAIM_CASE_REVIEWED':
        return 'Hồ sơ claim được admin duyệt';
      case 'CLAIM_CASE_FINALIZED':
        return 'Hồ sơ claim có kết luận';
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

  String _formatMoney(double value) {
    return NumberFormat.currency(
      locale: 'vi_VN',
      symbol: 'đ',
      decimalDigits: 0,
    ).format(value);
  }

  String _formatDateTime(DateTime? value) {
    if (value == null) return '-';
    return VietnamTime.format(value, 'dd/MM/yyyy HH:mm');
  }

  String _formatMinutes(int value) {
    final minutes = value < 0 ? 0 : value;
    final hours = minutes ~/ 60;
    final remainder = minutes % 60;
    if (hours <= 0) return '$remainder phút';
    if (remainder == 0) return '$hours giờ';
    return '$hours giờ $remainder phút';
  }

  String _shortId(String value) {
    if (value.length <= 8) return value;
    return value.substring(0, 8);
  }
}

class _StatusChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _StatusChip({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.sizeOf(context).width - 64,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                text,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AmountRow {
  final String label;
  final double amount;

  const _AmountRow(this.label, this.amount);
}
