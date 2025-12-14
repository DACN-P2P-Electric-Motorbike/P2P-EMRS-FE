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
      appBar: AppBar(
        title: const Text('Trở thành chủ xe'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Illustration
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.electric_moped,
                    size: 100,
                    color: AppColors.primary,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Title
              Text(
                'Kiếm thu nhập từ xe nhàn rỗi',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Description
              Text(
                'Chia sẻ xe điện của bạn và kiếm thêm thu nhập thụ động mỗi tháng',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Benefits
              _buildBenefit(
                icon: Icons.attach_money,
                title: 'Thu nhập thụ động',
                description: 'Kiếm tiền khi xe không sử dụng',
              ),
              const SizedBox(height: 16),
              _buildBenefit(
                icon: Icons.security,
                title: 'Bảo hiểm toàn diện',
                description: 'Xe được bảo vệ trong mọi chuyến đi',
              ),
              const SizedBox(height: 16),
              _buildBenefit(
                icon: Icons.schedule,
                title: 'Linh hoạt thời gian',
                description: 'Tự quyết định khi nào cho thuê',
              ),

              const Spacer(),

              // CTA Button - Navigate to vehicle registration
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to become owner registration page
                    context.push('/become-owner/register-vehicle');
                  },
                  child: const Text(
                    'Đăng ký xe ngay',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Skip button - Go to home
              TextButton(
                onPressed: () {
                  // Navigate to home screen
                  context.go('/home');
                },
                child: const Text('Để sau'),
              ),
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
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
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
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
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
