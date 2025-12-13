import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

/// Home page displayed after successful authentication
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          context.go('/login');
        }
      },
      builder: (context, state) {
        // Get user from AuthSuccess or AuthAuthenticated state
        final user = state is AuthSuccess
            ? state.user
            : (state is AuthAuthenticated ? state.user : null);
        final isLoading = state is AuthLoading;

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FD),
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                // App Bar Header
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(24),
                        bottomRight: Radius.circular(24),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            // Avatar
                            CircleAvatar(
                              radius: 28,
                              backgroundColor: Colors.white.withOpacity(0.2),
                              child: Text(
                                user?.fullName.isNotEmpty == true
                                    ? user!.fullName[0].toUpperCase()
                                    : 'U',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Xin chào,',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    user?.fullName ?? 'User',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.logout, color: Colors.white),
                              onPressed: () => _showLogoutDialog(context),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Content
                SliverPadding(
                  padding: const EdgeInsets.all(20),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // User Info Card
                      if (user != null) ...[
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.person_outline,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Thông tin tài khoản',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 24),
                              _buildInfoRow('Email', user.email, Icons.email_outlined),
                              const SizedBox(height: 12),
                              _buildInfoRow('Số điện thoại', user.phone, Icons.phone_outlined),
                              const SizedBox(height: 12),
                              _buildInfoRow('Vai trò', user.displayRole, Icons.badge_outlined),
                              const SizedBox(height: 12),
                              _buildInfoRow(
                                'Điểm tin cậy',
                                '${user.trustScore.toStringAsFixed(1)}/100',
                                Icons.verified_outlined,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Quick Actions Title
                      Text(
                        'Thao tác nhanh',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Action Cards - Row 1 (Role-based)
                      Row(
                        children: [
                          // Owner-only: My Bikes
                          if (user?.isOwner == true || user?.isAdmin == true)
                            Expanded(
                              child: _buildActionCard(
                                context,
                                icon: Icons.electric_moped,
                                title: 'Xe của tôi',
                                subtitle: 'Quản lý xe',
                                color: AppColors.primary,
                                onTap: () => context.push('/owner'),
                              ),
                            ),
                          if (user?.isOwner == true || user?.isAdmin == true)
                            const SizedBox(width: 16),
                          // All users: Find bike to rent
                          Expanded(
                            child: _buildActionCard(
                              context,
                              icon: Icons.search,
                              title: 'Tìm xe',
                              subtitle: 'Thuê xe',
                              color: AppColors.secondary,
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Coming soon!')),
                                );
                              },
                            ),
                          ),
                          // Renter-only: Show history in first row
                          if (user?.isRenter == true) ...[
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildActionCard(
                                context,
                                icon: Icons.history,
                                title: 'Lịch sử',
                                subtitle: 'Chuyến đi',
                                color: AppColors.warning,
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Coming soon!')),
                                  );
                                },
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Action Cards - Row 2
                      Row(
                        children: [
                          // Owner: Show history and earnings
                          if (user?.isOwner == true || user?.isAdmin == true) ...[
                            Expanded(
                              child: _buildActionCard(
                                context,
                                icon: Icons.history,
                                title: 'Lịch sử',
                                subtitle: 'Chuyến đi',
                                color: AppColors.warning,
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Coming soon!')),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildActionCard(
                                context,
                                icon: Icons.account_balance_wallet_outlined,
                                title: 'Thu nhập',
                                subtitle: 'Doanh thu',
                                color: AppColors.success,
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Coming soon!')),
                                  );
                                },
                              ),
                            ),
                          ],
                          // Renter: Show wallet and support
                          if (user?.isRenter == true) ...[
                            Expanded(
                              child: _buildActionCard(
                                context,
                                icon: Icons.wallet_outlined,
                                title: 'Ví tiền',
                                subtitle: 'Thanh toán',
                                color: AppColors.success,
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Coming soon!')),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildActionCard(
                                context,
                                icon: Icons.support_agent_outlined,
                                title: 'Hỗ trợ',
                                subtitle: 'Liên hệ',
                                color: AppColors.info,
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Coming soon!')),
                                  );
                                },
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Status Badge
                      if (user != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: user.isActive
                                ? AppColors.success.withOpacity(0.1)
                                : AppColors.warning.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: user.isActive
                                  ? AppColors.success.withOpacity(0.3)
                                  : AppColors.warning.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                user.isActive ? Icons.check_circle : Icons.pending,
                                color: user.isActive ? AppColors.success : AppColors.warning,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user.isActive
                                          ? 'Tài khoản đã xác thực'
                                          : 'Đang chờ xác thực',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        color: user.isActive
                                            ? AppColors.success
                                            : AppColors.warning,
                                      ),
                                    ),
                                    Text(
                                      user.isActive
                                          ? 'Bạn có thể sử dụng đầy đủ tính năng'
                                          : 'Vui lòng hoàn tất xác thực KYC',
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
                        ),

                      // Loading indicator
                      if (isLoading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32),
                            child: CircularProgressIndicator(),
                          ),
                        ),

                      const SizedBox(height: 20),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
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
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
