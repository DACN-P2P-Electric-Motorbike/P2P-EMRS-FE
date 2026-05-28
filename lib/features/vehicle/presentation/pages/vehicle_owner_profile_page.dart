import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../domain/entities/vehicle_entity.dart';

class VehicleOwnerProfilePage extends StatelessWidget {
  final VehicleEntity vehicle;

  const VehicleOwnerProfilePage({super.key, required this.vehicle});

  @override
  Widget build(BuildContext context) {
    final owner = vehicle.owner;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(title: const Text('Hồ sơ chủ xe')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOwnerHeader(owner),
            const SizedBox(height: 24),
            Text(
              'Thông tin tin cậy',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _buildTrustScore(owner),
            const SizedBox(height: 24),
            Text(
              'Lịch sử của xe',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _MetricTile(
                    icon: Icons.route_outlined,
                    value: '${vehicle.totalTrips}',
                    label: 'Chuyến',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MetricTile(
                    icon: Icons.star_outline_rounded,
                    value: vehicle.formattedRating,
                    label: 'Đánh giá',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MetricTile(
                    icon: Icons.chat_bubble_outline,
                    value: '${vehicle.reviewCount}',
                    label: 'Nhận xét',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Điều kiện của xe này',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _TermRow(
              icon: vehicle.instantBook
                  ? Icons.bolt_outlined
                  : Icons.schedule_outlined,
              label: 'Đặt xe',
              value: vehicle.instantBook
                  ? 'Xác nhận tự động'
                  : 'Chủ xe xác nhận',
            ),
            const SizedBox(height: 10),
            _TermRow(
              icon: Icons.event_available_outlined,
              label: 'Hoàn huỷ',
              value: vehicle.cancellationPolicy.summaryText,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOwnerHeader(VehicleOwnerSummary? owner) {
    final name = owner?.fullName ?? 'Chủ xe';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          AppAvatar(
            imageUrl: owner?.avatarUrl,
            fallbackText: name,
            size: 64,
            semanticLabel: 'Ảnh đại diện chủ xe',
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  owner == null
                      ? 'Thông tin công khai chưa cập nhật'
                      : 'Chủ xe DreamRide',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrustScore(VehicleOwnerSummary? owner) {
    final score = owner?.trustScore;
    if (score == null) {
      return _TermRow(
        icon: Icons.verified_outlined,
        label: 'Điểm tin cậy',
        value: 'Chưa có dữ liệu công khai',
      );
    }

    final scoreLabel = _scoreLabel(score);
    final scoreColor = _scoreColor(score);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.verified_outlined, color: scoreColor),
              const SizedBox(width: 10),
              Text(
                'Điểm tin cậy',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                '${score.toStringAsFixed(0)}/150',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: scoreColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (score / 150).clamp(0.0, 1.0),
              minHeight: 8,
              color: scoreColor,
              backgroundColor: AppColors.border,
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              scoreLabel,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: scoreColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _scoreColor(double score) {
    if (score >= 120) return AppColors.success;
    if (score >= 90) return AppColors.primary;
    if (score >= 40) return AppColors.warning;
    return AppColors.error;
  }

  String _scoreLabel(double score) {
    if (score >= 120) return 'Xuất sắc';
    if (score >= 90) return 'Tốt';
    if (score >= 70) return 'Trung bình';
    if (score >= 40) return 'Thấp';
    return 'Rất thấp';
  }
}

class _MetricTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _MetricTile({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 96,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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

class _TermRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _TermRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: AppColors.primary),
          const SizedBox(width: 12),
          SizedBox(
            width: 92,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
