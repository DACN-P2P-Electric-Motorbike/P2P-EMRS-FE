import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/vietnam_time.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/review_entity.dart';
import '../bloc/review_bloc.dart';
import '../bloc/review_event.dart';
import '../bloc/review_state.dart';

class TrustScorePage extends StatelessWidget {
  const TrustScorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ReviewBloc>()..add(const LoadTrustScoreEvent()),
      child: const _TrustScoreView(),
    );
  }
}

class _TrustScoreView extends StatelessWidget {
  const _TrustScoreView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Điểm tin cậy',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<ReviewBloc, ReviewState>(
        builder: (context, state) {
          if (state is ReviewLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ReviewFailure) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, size: 48, color: AppColors.error),
                  const SizedBox(height: 12),
                  Text(state.message),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => context
                        .read<ReviewBloc>()
                        .add(const LoadTrustScoreEvent()),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }
          if (state is TrustScoreLoaded) {
            return _buildContent(context, state.breakdown);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, TrustScoreBreakdown b) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildScoreHeader(b),
          const SizedBox(height: 24),
          if (b.activeWarnings.isNotEmpty) ...[
            _buildWarningsCard(b.activeWarnings),
            const SizedBox(height: 24),
          ],
          _buildBreakdownCard(b),
          const SizedBox(height: 24),
          if (b.recentEvents.isNotEmpty) ...[
            _buildEventsTimeline(b.recentEvents),
            const SizedBox(height: 24),
          ],
          _buildExplanationCard(),
        ],
      ),
    );
  }

  Widget _buildScoreHeader(TrustScoreBreakdown b) {
    final score = b.trustScore;
    Color scoreColor;
    String label;
    // Tier ranges per Trust Score mechanics (range [0, 150]):
    //  <40 Rất thấp · 40–69 Thấp · 70–89 Trung bình · 90–119 Tốt · 120–150 Xuất sắc
    if (score >= 120) {
      scoreColor = AppColors.success;
      label = 'Xuất sắc';
    } else if (score >= 90) {
      scoreColor = AppColors.primary;
      label = 'Tốt';
    } else if (score >= 70) {
      scoreColor = AppColors.warning;
      label = 'Trung bình';
    } else if (score >= 40) {
      scoreColor = AppColors.warning;
      label = 'Thấp';
    } else {
      scoreColor = AppColors.error;
      label = 'Rất thấp';
    }

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [scoreColor.withOpacity(0.1), scoreColor.withOpacity(0.02)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: scoreColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 140,
            height: 140,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 140,
                  height: 140,
                  child: CircularProgressIndicator(
                    value: (score / 150).clamp(0.0, 1.0),
                    strokeWidth: 10,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation(scoreColor),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$score',
                      style: GoogleFonts.poppins(
                        fontSize: 44,
                        fontWeight: FontWeight.bold,
                        color: scoreColor,
                      ),
                    ),
                    Text(
                      '/150',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: scoreColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: scoreColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownCard(TrustScoreBreakdown b) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chi tiết điểm',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          _buildBreakdownRow(
            icon: Icons.star_rounded,
            iconColor: const Color(0xFFFFB300),
            label: 'Đánh giá đã cho',
            value: '${b.reviewsGiven} lần',
            delta: '+${b.reviewsGivenBonus}',
            deltaPositive: true,
          ),
          const Divider(height: 24),

          _buildBreakdownRow(
            icon: Icons.thumb_up_outlined,
            iconColor: AppColors.success,
            label: 'Đánh giá trung bình nhận',
            value: b.avgRatingReceived != null
                ? '${b.avgRatingReceived!.toStringAsFixed(1)}/5 (${b.totalReviewsReceived})'
                : 'Chưa có',
            delta: null,
            deltaPositive: true,
          ),
          const Divider(height: 24),

          _buildBreakdownRow(
            icon: Icons.check_circle_outline,
            iconColor: AppColors.primary,
            label: 'Chuyến đi hoàn thành',
            value: '${b.completedTrips} chuyến',
            delta: null,
            deltaPositive: true,
          ),
          const Divider(height: 24),

          _buildBreakdownRow(
            icon: Icons.cancel_outlined,
            iconColor: AppColors.error,
            label: 'Hủy đơn (người thuê)',
            value: '${b.cancelledBookings} lần',
            delta: _penaltyDelta(b.cancellationPenalty),
            deltaPositive: false,
            warningBadge: _warningBadge(
              b.cancellationPenalty,
              b.cancellationWarnings,
            ),
          ),
          const Divider(height: 24),

          _buildBreakdownRow(
            icon: Icons.block_outlined,
            iconColor: AppColors.warning,
            label: 'Từ chối đơn (chủ xe)',
            value: '${b.rejectedBookings} lần',
            delta: _penaltyDelta(b.rejectionPenalty),
            deltaPositive: false,
            warningBadge: _warningBadge(
              b.rejectionPenalty,
              b.rejectionWarnings,
            ),
          ),
          const Divider(height: 24),

          _buildBreakdownRow(
            icon: Icons.warning_amber_rounded,
            iconColor: AppColors.error,
            label: 'Vi phạm / Sự cố',
            value: '${b.tripsWithIssues} lần',
            delta: _penaltyDelta(b.violationPenalty),
            deltaPositive: false,
            warningBadge: _warningBadge(
              b.violationPenalty,
              b.violationWarnings,
            ),
          ),
        ],
      ),
    );
  }

  /// Returns the negative-delta label only when points were actually deducted.
  /// A warning-only violation deducts nothing, so we hide the misleading "-5".
  String? _penaltyDelta(int penalty) => penalty != 0 ? '$penalty' : null;

  /// Shows a neutral "Cảnh báo" badge when there is an active warning but no
  /// points have been deducted yet (first minor violation in a 30-day window).
  bool _warningBadge(int penalty, int warnings) =>
      penalty == 0 && warnings > 0;

  Widget _buildBreakdownRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required String? delta,
    required bool deltaPositive,
    bool warningBadge = false,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        if (warningBadge)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Cảnh báo',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.warning,
              ),
            ),
          )
        else if (delta != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: deltaPositive
                  ? AppColors.success.withOpacity(0.1)
                  : AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              delta,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: deltaPositive ? AppColors.success : AppColors.error,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildWarningsCard(List<TrustScoreWarning> warnings) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.warning.withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: AppColors.warning,
                size: 22,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Cảnh báo đang theo dõi (${warnings.length})',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Vi phạm nhỏ đầu tiên trong 30 ngày chỉ ghi cảnh báo. Lặp lại '
            'trong thời gian này sẽ áp dụng trừ điểm.',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          ...warnings.map(_buildWarningRow),
        ],
      ),
    );
  }

  Widget _buildWarningRow(TrustScoreWarning warning) {
    final daysLeft = warning.remaining?.inDays;
    final hoursLeft = warning.remaining?.inHours;
    String remainingLabel;
    if (daysLeft != null && daysLeft > 0) {
      remainingLabel = 'Còn $daysLeft ngày';
    } else if (hoursLeft != null && hoursLeft > 0) {
      remainingLabel = 'Còn $hoursLeft giờ';
    } else {
      remainingLabel = 'Sắp hết hạn';
    }

    final meta = _eventMeta(warning.type);
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(meta.icon, color: AppColors.warning, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meta.label,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (warning.reason != null && warning.reason!.isNotEmpty)
                  Text(
                    warning.reason!,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.3,
                    ),
                  ),
                const SizedBox(height: 4),
                Text(
                  '$remainingLabel · Hết hạn '
                  '${VietnamTime.format(warning.expiresAt, 'dd/MM/yyyy')}',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsTimeline(List<TrustScoreEvent> events) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Hoạt động gần đây',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                '${events.length} sự kiện',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Lịch sử thay đổi điểm tin cậy gần nhất',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(events.length, (index) {
            final isLast = index == events.length - 1;
            return _buildEventRow(events[index], isLast: isLast);
          }),
        ],
      ),
    );
  }

  Widget _buildEventRow(TrustScoreEvent event, {required bool isLast}) {
    final meta = _eventMeta(event.type);
    final Color tone;
    final IconData icon;
    if (event.isWarning) {
      tone = AppColors.warning;
      icon = Icons.warning_amber_rounded;
    } else if (event.isPositive) {
      tone = AppColors.success;
      icon = meta.icon;
    } else if (event.isNegative) {
      tone = AppColors.error;
      icon = meta.icon;
    } else {
      tone = AppColors.info;
      icon = meta.icon;
    }

    final deltaText = event.isWarning
        ? 'Cảnh báo'
        : event.delta == 0
        ? '0'
        : event.delta > 0
        ? '+${_formatDelta(event.delta)}'
        : _formatDelta(event.delta);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: tone.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: tone, size: 18),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: AppColors.border,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          meta.label,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: tone.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          deltaText,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: tone,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (event.reason != null && event.reason!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      event.reason!,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    VietnamTime.format(event.createdAt, 'HH:mm dd/MM/yyyy'),
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDelta(double delta) {
    if (delta == delta.roundToDouble()) {
      return delta.toStringAsFixed(0);
    }
    return delta.toStringAsFixed(1);
  }

  _EventMeta _eventMeta(TrustScoreEventType type) {
    switch (type) {
      case TrustScoreEventType.tripCompletedOnTime:
        return const _EventMeta(
          icon: Icons.check_circle_outline,
          label: 'Hoàn tất chuyến đi đúng giờ',
        );
      case TrustScoreEventType.goodReviewReceived:
        return const _EventMeta(
          icon: Icons.thumb_up_outlined,
          label: 'Nhận đánh giá tốt',
        );
      case TrustScoreEventType.reviewSubmitted:
        return const _EventMeta(
          icon: Icons.rate_review_outlined,
          label: 'Đã gửi đánh giá',
        );
      case TrustScoreEventType.kycVerified:
        return const _EventMeta(
          icon: Icons.verified_user_outlined,
          label: 'Xác thực CCCD/CMND',
        );
      case TrustScoreEventType.transactionMilestone:
        return const _EventMeta(
          icon: Icons.emoji_events_outlined,
          label: 'Đạt mốc giao dịch',
        );
      case TrustScoreEventType.badReviewReceived:
        return const _EventMeta(
          icon: Icons.thumb_down_outlined,
          label: 'Nhận đánh giá xấu',
        );
      case TrustScoreEventType.bookingCancelledByRenter:
        return const _EventMeta(
          icon: Icons.cancel_outlined,
          label: 'Hủy đơn (người thuê)',
        );
      case TrustScoreEventType.bookingRejectedByOwner:
        return const _EventMeta(
          icon: Icons.block_outlined,
          label: 'Từ chối đơn (chủ xe)',
        );
      case TrustScoreEventType.lateReturn:
        return const _EventMeta(
          icon: Icons.schedule_outlined,
          label: 'Trả xe trễ',
        );
      case TrustScoreEventType.confirmedReport:
        return const _EventMeta(
          icon: Icons.report_gmailerrorred_outlined,
          label: 'Báo cáo đã xác nhận',
        );
      case TrustScoreEventType.seriousViolation:
        return const _EventMeta(
          icon: Icons.gpp_bad_outlined,
          label: 'Vi phạm nghiêm trọng',
        );
      case TrustScoreEventType.manualAdjustment:
        return const _EventMeta(
          icon: Icons.tune,
          label: 'Điều chỉnh thủ công',
        );
      case TrustScoreEventType.recalculated:
        return const _EventMeta(
          icon: Icons.autorenew,
          label: 'Tính lại điểm hằng ngày',
        );
      case TrustScoreEventType.warning:
        return const _EventMeta(
          icon: Icons.warning_amber_rounded,
          label: 'Cảnh báo (chưa trừ điểm)',
        );
      case TrustScoreEventType.unknown:
        return const _EventMeta(
          icon: Icons.help_outline,
          label: 'Sự kiện khác',
        );
    }
  }

  Widget _buildExplanationCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.info.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, color: AppColors.info, size: 20),
              const SizedBox(width: 8),
              Text(
                'Cách tính điểm tin cậy',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.info,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildExplanationItem('Bắt đầu với 100 điểm, thang điểm 0–150'),
          _buildExplanationItem('Hoàn tất chuyến đi đúng giờ: +2 điểm'),
          _buildExplanationItem('Xác thực CCCD/CMND (KYC): +5 điểm'),
          _buildExplanationItem('Mỗi 10 giao dịch hoàn tất: +3 điểm'),
          _buildExplanationItem('Đánh giá xe: +1 điểm/lần'),
          _buildExplanationItem(
            'Nhận đánh giá tốt (4-5 sao): +1 điểm',
          ),
          _buildExplanationItem(
            'Nhận đánh giá xấu (1-2 sao): -3 điểm',
          ),
          _buildExplanationItem('Hủy đơn (người thuê): -5 điểm/lần'),
          _buildExplanationItem('Từ chối đơn (chủ xe): -2 điểm/lần'),
          _buildExplanationItem('Trả xe trễ trên 30 phút: -3 điểm'),
          _buildExplanationItem(
            'Lần vi phạm nhỏ đầu tiên trong 30 ngày sẽ chỉ ghi cảnh báo, '
            'tái phạm mới bị trừ điểm.',
          ),
        ],
      ),
    );
  }

  Widget _buildExplanationItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.info,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EventMeta {
  final IconData icon;
  final String label;
  const _EventMeta({required this.icon, required this.label});
}
