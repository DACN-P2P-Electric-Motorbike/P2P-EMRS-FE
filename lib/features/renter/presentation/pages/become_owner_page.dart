import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/app_theme.dart';

/// Prompt page for users to become owners
class BecomeOwnerPage extends StatelessWidget {
  const BecomeOwnerPage({super.key});

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

              const SizedBox(height: 40),

              // CTA Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    context.push('/become-owner/register-vehicle');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Đăng ký xe ngay',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
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
