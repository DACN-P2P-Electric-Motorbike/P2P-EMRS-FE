import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../injection_container.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../../features/payment/presentation/pages/payment_methods_page.dart';

/// Profile page - redesigned similar to OwnerProfilePage
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          context.go('/login');
        }
      },
      builder: (context, state) {
        final user = state is AuthSuccess
            ? state.user
            : (state is AuthAuthenticated ? state.user : null);

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Profile Header
                  _buildProfileHeader(context, user),

                  const Divider(height: 32, color: AppColors.border),

                  // Trust Score Card
                  _buildTrustScoreCard(context, user),

                  const SizedBox(height: 24),

                  // Account Info Section
                  _buildAccountInfoSection(user),

                  if (user?.isPending == true) ...[
                    const SizedBox(height: 24),
                    _buildPendingBanner(context),
                  ],

                  const SizedBox(height: 24),

                  // Settings Menu
                  _buildMenuList(context),

                  const SizedBox(height: 40),

                  // Logout Button
                  _buildLogoutButton(context),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(BuildContext context, dynamic user) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => _uploadAvatar(context),
          child: AppAvatar(
            imageUrl: user?.avatarUrl,
            fallbackText: user?.fullName ?? 'U',
            size: 80,
            backgroundColor: AppColors.inputBackground,
          ),
        ),

        const SizedBox(width: 16),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user?.fullName ?? 'User Name',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              if (user?.roles != null && user!.roles.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: (user.roles as List<dynamic>)
                      .map((role) => _buildRoleBadge(role.toString()))
                      .toList(),
                ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  if (user != null) {
                    context.push('/profile/edit', extra: user);
                  }
                },
                child: Text(
                  'Chỉnh sửa hồ sơ',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),

        IconButton(
          onPressed: () {
            if (user != null) {
              context.push('/profile/edit', extra: user);
            }
          },
          icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
        ),
      ],
    );
  }

  Widget _buildTrustScoreCard(BuildContext context, dynamic user) {
    return GestureDetector(
      onTap: () => context.push('/trust-score'),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.verified_outlined,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Điểm tin cậy',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.textMuted,
                  size: 18,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '${user?.trustScore?.toStringAsFixed(0) ?? '0'}/100',
              style: GoogleFonts.poppins(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: (user?.trustScore ?? 0) / 100,
                backgroundColor: AppColors.border,
                valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                minHeight: 10,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Nhấn để xem chi tiết',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountInfoSection(dynamic user) {
    final infoItems = [
      _InfoItem(
        icon: Icons.email_outlined,
        label: 'Email',
        value: user?.email ?? '',
      ),
      _InfoItem(
        icon: Icons.phone_outlined,
        label: 'Số điện thoại',
        value: user?.phone ?? '',
      ),
      if (user?.address != null)
        _InfoItem(
          icon: Icons.location_on_outlined,
          label: 'Địa chỉ',
          value: user.address!,
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Thông tin tài khoản',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        ...infoItems.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.inputBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Icon(item.icon, color: AppColors.primary, size: 24),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.label,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.value,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuList(BuildContext context) {
    final menuItems = [
      _MenuItem(
        icon: Icons.payment_outlined,
        label: 'Phương thức thanh toán',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PaymentMethodsPage()),
          );
        },
      ),
      _MenuItem(
        icon: Icons.history,
        label: 'Lịch sử giao dịch',
        onTap: () => context.push('/trip-history'),
      ),
      _MenuItem(
        icon: Icons.notifications_outlined,
        label: 'Thông báo',
        onTap: () => context.push('/notifications'),
      ),
      _MenuItem(
        icon: Icons.settings_outlined,
        label: 'Cài đặt ứng dụng',
        onTap: () => context.push('/settings'),
      ),
      _MenuItem(
        icon: Icons.help_outline,
        label: 'Trợ giúp & Hỗ trợ',
        onTap: () => _showSupportBottomSheet(context),
      ),
      _MenuItem(
        icon: Icons.description_outlined,
        label: 'Điều khoản & Chính sách',
        onTap: () async {
          final url = Uri.parse('https://dreamride.vn/terms');
          if (await canLaunchUrl(url)) {
            await launchUrl(url);
          } else {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Không thể mở liên kết'),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          }
        },
      ),
      _MenuItem(
        icon: Icons.info_outline,
        label: 'Về Dream Ride',
        onTap: () => _showAboutDialog(context),
      ),
      // Dev-only: uncomment to access payment sandbox
      // _MenuItem(
      //   icon: Icons.developer_mode,
      //   label: 'Dev: Payment Sandbox',
      //   onTap: () => context.push('/payment-sandbox'),
      // ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cài đặt',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: menuItems.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isLast = index == menuItems.length - 1;

              return Column(
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.inputBackground,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(item.icon, color: AppColors.textPrimary),
                    ),
                    title: Text(
                      item.label,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: AppColors.textMuted,
                    ),
                    onTap: item.onTap,
                  ),
                  if (!isLast)
                    const Divider(height: 1, color: AppColors.border),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.inputBackground,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.logout_outlined, color: AppColors.error),
      ),
      title: Text(
        'Đăng xuất',
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.error,
        ),
      ),
      onTap: () => _showLogoutDialog(context),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          'Đăng xuất',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<AuthBloc>().add(const AuthLogoutStarted());
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AboutDialog(
        applicationName: 'Dream Ride',
        applicationVersion: '1.0.0',
        applicationIcon: SizedBox(
          width: 60,
          height: 60,
          child: Icon(Icons.electric_moped, color: AppColors.primary, size: 30),
        ),
        children: [
          Text(
            'Nền tảng chia sẻ xe máy điện P2P hàng đầu Việt Nam',
            style: TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Future<void> _uploadAvatar(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return;
    if (!context.mounted) return;

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) =>
          const Center(child: CircularProgressIndicator()),
    );

    try {
      final dioClient = sl<DioClient>();
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          pickedFile.path,
          filename: pickedFile.name,
        ),
      });

      await dioClient.post('/auth/upload-avatar', data: formData);

      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        context.read<AuthBloc>().add(const AuthCheckRequested());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cập nhật ảnh đại diện thành công'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lỗi khi tải ảnh lên'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Widget _buildRoleBadge(String role) {
    Color badgeColor;
    String displayRole;
    switch (role.toUpperCase()) {
      case 'RENTER':
        badgeColor = AppColors.info;
        displayRole = 'Người thuê xe';
        break;
      case 'OWNER':
        badgeColor = AppColors.success;
        displayRole = 'Chủ xe';
        break;
      case 'ADMIN':
        badgeColor = AppColors.error;
        displayRole = 'Quản trị viên';
        break;
      default:
        badgeColor = AppColors.primary;
        displayRole = role;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: badgeColor.withOpacity(0.2)),
      ),
      child: Text(
        displayRole,
        style: GoogleFonts.poppins(
          fontSize: 12,
          color: badgeColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildPendingBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.warning.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: AppColors.warning),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Tài khoản chưa xác thực',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.warning,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Hoàn tất KYC để mở khóa đầy đủ tính năng.',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                try {
                  context.push('/kyc');
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Tính năng đang được phát triển'),
                      backgroundColor: AppColors.warning,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.warning,
                foregroundColor: Colors.white,
              ),
              child: const Text('Xác thực ngay'),
            ),
          ),
        ],
      ),
    );
  }

  void _showSupportBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Trợ giúp & Hỗ trợ',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(
                Icons.phone_outlined,
                color: AppColors.primary,
              ),
              title: Text('Gọi điện thoại', style: GoogleFonts.poppins()),
              onTap: () async {
                Navigator.pop(context);
                final url = Uri.parse('tel:19001234');
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                }
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.email_outlined,
                color: AppColors.primary,
              ),
              title: Text('Gửi Email', style: GoogleFonts.poppins()),
              onTap: () async {
                Navigator.pop(context);
                final url = Uri.parse('mailto:support@dreamride.vn');
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                }
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.chat_outlined,
                color: AppColors.primary,
              ),
              title: Text('Chat với chúng tôi', style: GoogleFonts.poppins()),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tính năng chat đang được phát triển'),
                    backgroundColor: AppColors.primary,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoItem {
  final IconData icon;
  final String label;
  final String value;

  _InfoItem({required this.icon, required this.label, required this.value});
}

class _MenuItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  _MenuItem({required this.icon, required this.label, required this.onTap});
}
