import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../injection_container.dart';
import '../../../trip/domain/entities/trip_entity.dart';
import '../../../trip/presentation/bloc/trip_bloc.dart';
import '../../../trip/presentation/bloc/trip_event.dart';
import '../../../trip/presentation/bloc/trip_state.dart';
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
                              icon: const Icon(
                                Icons.logout,
                                color: Colors.white,
                              ),
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
                      BlocProvider(
                        create: (_) =>
                            sl<TripBloc>()..add(const LoadActiveTripEvent()),
                        child: const _ActiveTripResumeCard(),
                      ),

                      // Owner row
                      if (user?.isOwner == true || user?.isAdmin == true) ...[
                        Row(
                          children: [
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
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildActionCard(
                                context,
                                icon: Icons.account_balance_wallet_outlined,
                                title: 'Doanh thu',
                                subtitle: 'Thu nhập',
                                color: AppColors.success,
                                onTap: () => context.push('/owner-earnings'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Renter row
                      Row(
                        children: [
                          Expanded(
                            child: _buildActionCard(
                              context,
                              icon: Icons.search_rounded,
                              title: 'Tìm xe',
                              subtitle: 'Duyệt xe',
                              color: AppColors.secondary,
                              onTap: () => context.push('/browse-vehicles'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildActionCard(
                              context,
                              icon: Icons.history_rounded,
                              title: 'Lịch sử',
                              subtitle: 'Chuyến đi',
                              color: AppColors.warning,
                              onTap: () => context.push('/trip-history'),
                            ),
                          ),
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
                                user.isActive
                                    ? Icons.check_circle
                                    : Icons.pending,
                                color: user.isActive
                                    ? AppColors.success
                                    : AppColors.warning,
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

class _ActiveTripResumeCard extends StatelessWidget {
  const _ActiveTripResumeCard();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TripBloc, TripState>(
      builder: (context, state) {
        if (state is! TripLoaded || state.trip.status != TripStatus.ongoing) {
          return const SizedBox.shrink();
        }

        final trip = state.trip;
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00D2FF), Color(0xFF3A7BD5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.18),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                onTap: () => context.push('/active-trip'),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.navigation_rounded,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tiếp tục theo dõi chuyến đi',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              trip.vehicleName ?? 'Chuyến đi đang diễn ra',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                color: Colors.white.withOpacity(0.82),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
