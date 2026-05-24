import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fe_capstone_project/features/kyc/domain/entities/kyc_verification.dart';
import 'package:fe_capstone_project/features/kyc/presentation/cubit/kyc_cubit.dart';
import 'package:fe_capstone_project/injection_container.dart';
import '../../../../../core/theme/app_theme.dart';

/// Prompt page for users to become owners
class BecomeOwnerPage extends StatelessWidget {
  const BecomeOwnerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<KycCubit>()..loadStatus(),
      child: const _BecomeOwnerContent(),
    );
  }
}

class _BecomeOwnerContent extends StatelessWidget {
  const _BecomeOwnerContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Trở thành chủ xe',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 32),

              // Illustration
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.electric_moped,
                    size: 80,
                    color: AppColors.primary,
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Title
              Text(
                'Kiếm thu nhập từ xe nhàn rỗi',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              // Description
              Text(
                'Chia sẻ xe điện của bạn và kiếm thêm thu nhập thụ động mỗi tháng',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Benefits
              _buildBenefit(
                icon: Icons.attach_money_rounded,
                title: 'Thu nhập thụ động',
                description: 'Kiếm tiền khi xe không sử dụng',
              ),
              const SizedBox(height: 14),
              _buildBenefit(
                icon: Icons.verified_user_outlined,
                title: 'Bảo hiểm toàn diện',
                description: 'Xe được bảo vệ trong mọi chuyến đi',
              ),
              const SizedBox(height: 14),
              _buildBenefit(
                icon: Icons.schedule_rounded,
                title: 'Linh hoạt thời gian',
                description: 'Tự quyết định khi nào cho thuê',
              ),

              const SizedBox(height: 24),

              BlocBuilder<KycCubit, KycState>(
                builder: (context, state) {
                  return _buildKycRequirement(state);
                },
              ),

              const SizedBox(height: 40),

              // CTA Button
              BlocBuilder<KycCubit, KycState>(
                builder: (context, state) {
                  final status = state.verification.status;
                  final isLoading =
                      state.viewStatus == KycViewStatus.initial ||
                      state.viewStatus == KycViewStatus.loading;

                  return SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () => _handleRegisterTap(context, status),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _ctaLabel(status, isLoading),
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              // Skip button
              TextButton(
                onPressed: () => context.go('/home'),
                child: Text(
                  'Để sau',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.textMuted,
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _handleRegisterTap(BuildContext context, KycStatus status) {
    if (status == KycStatus.approved) {
      context.push('/become-owner/register-vehicle');
      return;
    }

    final message = status == KycStatus.pending
        ? 'Hồ sơ KYC của bạn đang chờ duyệt trước khi đăng ký xe.'
        : 'Bạn cần xác minh KYC trước khi đăng ký xe cho thuê.';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.warning),
    );
    context.push('/kyc');
  }

  String _ctaLabel(KycStatus status, bool isLoading) {
    if (isLoading) return 'Đang kiểm tra...';
    switch (status) {
      case KycStatus.approved:
        return 'Đăng ký xe ngay';
      case KycStatus.pending:
        return 'Xem trạng thái KYC';
      case KycStatus.rejected:
      case KycStatus.notSubmitted:
        return 'Xác minh KYC';
    }
  }

  Widget _buildKycRequirement(KycState state) {
    final status = state.verification.status;
    final isApproved = status == KycStatus.approved;
    final color = isApproved ? AppColors.success : AppColors.warning;
    final icon = isApproved
        ? Icons.verified_user_rounded
        : Icons.assignment_ind_outlined;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'KYC: ${status.displayName}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _kycDescription(state),
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _kycDescription(KycState state) {
    if (state.viewStatus == KycViewStatus.loading ||
        state.viewStatus == KycViewStatus.initial) {
      return 'Đang kiểm tra trạng thái xác minh.';
    }
    if (state.viewStatus == KycViewStatus.error) {
      return state.errorMessage ?? 'Không thể kiểm tra trạng thái KYC.';
    }

    switch (state.verification.status) {
      case KycStatus.approved:
        return 'Bạn có thể đăng ký xe cho thuê.';
      case KycStatus.pending:
        return 'Vui lòng chờ Admin duyệt hồ sơ trước khi đăng ký xe.';
      case KycStatus.rejected:
        return 'Hồ sơ cần gửi lại trước khi đăng ký xe.';
      case KycStatus.notSubmitted:
        return 'Hoàn tất selfie và CCCD trước khi đăng ký xe.';
    }
  }

  Widget _buildBenefit({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: AppColors.primary, size: 24),
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
                description,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
