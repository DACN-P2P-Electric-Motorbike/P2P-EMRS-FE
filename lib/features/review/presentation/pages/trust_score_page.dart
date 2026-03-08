import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
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
          _buildBreakdownCard(b),
          const SizedBox(height: 24),
          _buildExplanationCard(),
        ],
      ),
    );
  }

  Widget _buildScoreHeader(TrustScoreBreakdown b) {
    final score = b.trustScore;
    Color scoreColor;
    String label;
    if (score >= 80) {
      scoreColor = AppColors.success;
      label = 'Rất tốt';
    } else if (score >= 60) {
      scoreColor = AppColors.primary;
      label = 'Tốt';
    } else if (score >= 40) {
      scoreColor = AppColors.warning;
      label = 'Trung bình';
    } else {
      scoreColor = AppColors.error;
      label = 'Cần cải thiện';
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
                    value: score / 100,
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
                      '/100',
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
            delta: b.cancellationPenalty != 0
                ? '${b.cancellationPenalty}'
                : null,
            deltaPositive: false,
          ),
          const Divider(height: 24),

          _buildBreakdownRow(
            icon: Icons.block_outlined,
            iconColor: AppColors.warning,
            label: 'Từ chối đơn (chủ xe)',
            value: '${b.rejectedBookings} lần',
            delta: b.rejectionPenalty != 0
                ? '${b.rejectionPenalty}'
                : null,
            deltaPositive: false,
          ),
          const Divider(height: 24),

          _buildBreakdownRow(
            icon: Icons.warning_amber_rounded,
            iconColor: AppColors.error,
            label: 'Vi phạm / Sự cố',
            value: '${b.tripsWithIssues} lần',
            delta: b.violationPenalty != 0
                ? '${b.violationPenalty}'
                : null,
            deltaPositive: false,
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required String? delta,
    required bool deltaPositive,
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
        if (delta != null)
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
          _buildExplanationItem('Bắt đầu với 100 điểm'),
          _buildExplanationItem('Đánh giá xe: +1 điểm/lần'),
          _buildExplanationItem(
            'Nhận đánh giá tốt (4-5 sao): +1 điểm',
          ),
          _buildExplanationItem(
            'Nhận đánh giá xấu (1-2 sao): -3 điểm',
          ),
          _buildExplanationItem('Hủy đơn (người thuê): -5 điểm/lần'),
          _buildExplanationItem('Từ chối đơn (chủ xe): -2 điểm/lần'),
          _buildExplanationItem('Vi phạm / Sự cố: -3 điểm/lần'),
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
