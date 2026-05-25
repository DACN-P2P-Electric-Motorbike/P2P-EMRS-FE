import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/vietnam_time.dart';
import '../../domain/entities/review_entity.dart';

class BlindReviewStatusCard extends StatelessWidget {
  final BookingReviewStatus status;
  final bool isOwnerView;

  const BlindReviewStatusCard({
    super.key,
    required this.status,
    required this.isOwnerView,
  });

  @override
  Widget build(BuildContext context) {
    final isWaiting = !status.isRevealed;
    final color = isWaiting ? AppColors.warning : AppColors.success;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isWaiting
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 20,
                color: color,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isWaiting ? 'Đánh giá đang ẩn' : 'Đánh giá đã hiển thị',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _statusMessage(),
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          if (isWaiting && status.submitted && status.revealAt != null) ...[
            const SizedBox(height: 6),
            Text(
              'Tự động hiển thị: ${VietnamTime.format(status.revealAt!, 'dd/MM/yyyy HH:mm')}',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
          if (!isWaiting && status.ownReview != null) ...[
            const SizedBox(height: 12),
            _ReviewSnippet(
              label: isOwnerView
                  ? 'Bạn đánh giá người thuê'
                  : 'Bạn đánh giá chuyến đi',
              review: status.ownReview!,
            ),
          ],
          if (!isWaiting && status.receivedReview != null) ...[
            const SizedBox(height: 12),
            _ReviewSnippet(
              label: isOwnerView
                  ? 'Người thuê đánh giá xe'
                  : 'Chủ xe đánh giá bạn',
              review: status.receivedReview!,
            ),
          ],
        ],
      ),
    );
  }

  String _statusMessage() {
    final counterpart = isOwnerView ? 'người thuê' : 'chủ xe';
    if (!status.isRevealed && status.submitted) {
      return 'Bạn đã gửi đánh giá. Đang chờ $counterpart gửi đánh giá.';
    }
    if (!status.isRevealed && status.counterpartSubmitted) {
      return '$counterpart đã gửi đánh giá ẩn. Nội dung sẽ hiển thị sau khi bạn đánh giá.';
    }
    if (status.receivedReview != null) {
      return 'Đánh giá hai chiều của chuyến đi đã được công khai.';
    }
    return 'Đánh giá của bạn đã được công khai.';
  }
}

class _ReviewSnippet extends StatelessWidget {
  final String label;
  final ReviewEntity review;

  const _ReviewSnippet({required this.label, required this.review});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: List.generate(
            5,
            (index) => Icon(
              index < review.rating ? Icons.star : Icons.star_border,
              size: 16,
              color: AppColors.warning,
            ),
          ),
        ),
        if ((review.comment ?? '').trim().isNotEmpty) ...[
          const SizedBox(height: 5),
          Text(
            review.comment!,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ],
    );
  }
}
