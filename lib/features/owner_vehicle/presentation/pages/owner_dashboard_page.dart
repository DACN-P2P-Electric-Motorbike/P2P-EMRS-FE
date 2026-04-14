import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/vehicle_entity.dart';
import '../bloc/owner_vehicle_bloc.dart';
import '../widgets/vehicle_card.dart';

/// Owner Dashboard Page - displays all vehicles owned by the user
class OwnerDashboardPage extends StatelessWidget {
  const OwnerDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<OwnerVehicleBloc>()..add(const LoadMyVehicles()),
      child: const _OwnerDashboardContent(),
    );
  }
}

class _OwnerDashboardContent extends StatefulWidget {
  const _OwnerDashboardContent();

  @override
  State<_OwnerDashboardContent> createState() => _OwnerDashboardContentState();
}

class _OwnerDashboardContentState extends State<_OwnerDashboardContent> {
  void _navigateToDetail(String vehicleId) async {
    await context.push('/owner/vehicle/$vehicleId');
    // Refresh after returning from detail page
    if (mounted) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) {
        context.read<OwnerVehicleBloc>().add(const LoadMyVehicles());
      }
    }
  }

  void _navigateToRegister() async {
    await context.push('/owner/register-vehicle');
    // Refresh after returning from register page
    if (mounted) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) {
        context.read<OwnerVehicleBloc>().add(const LoadMyVehicles());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Xe của tôi',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<OwnerVehicleBloc>().add(const LoadMyVehicles());
            },
          ),
        ],
      ),
      body: BlocConsumer<OwnerVehicleBloc, OwnerVehicleState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppColors.error,
              ),
            );
          }
          if (state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage!),
                backgroundColor: AppColors.success,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.status == OwnerVehicleStatus.loading &&
              state.vehicles.isEmpty) {
            return const Center(
              child: SpinKitFadingCircle(color: AppColors.primary, size: 50),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<OwnerVehicleBloc>().add(const LoadMyVehicles());
              await Future.delayed(const Duration(milliseconds: 500));
            },
            child: CustomScrollView(
              slivers: [
                // Stats header
                SliverToBoxAdapter(child: _buildStatsHeader(state)),

                // Earnings Navigation Card
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: InkWell(
                      onTap: () => context.push('/owner-earnings'),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.account_balance_wallet_outlined,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Doanh thu',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    'Xem thống kê thu nhập từ xe',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right,
                              color: AppColors.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // Vehicle list
                if (state.vehicles.isEmpty)
                  SliverFillRemaining(child: _buildEmptyState())
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final vehicle = state.vehicles[index];
                      return VehicleCard(
                        vehicle: vehicle,
                        onTap: () => _navigateToDetail(vehicle.id),
                      );
                    }, childCount: state.vehicles.length),
                  ),

                // Bottom padding
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToRegister,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text(
          'Thêm xe',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildStatsHeader(OwnerVehicleState state) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tổng quan xe',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatItem(
                icon: Icons.electric_moped,
                label: 'Tổng số',
                value: state.vehicleCount.toString(),
              ),
              const SizedBox(width: 24),
              _buildStatItem(
                icon: Icons.check_circle_outline,
                label: 'Có thể thuê',
                value: state.availableCount.toString(),
              ),
              const SizedBox(width: 24),
              _buildStatItem(
                icon: Icons.pending_outlined,
                label: 'Chờ duyệt',
                value: state.pendingCount.toString(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.inputBackground,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.electric_moped_outlined,
                size: 64,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Chưa có xe nào',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Đăng ký xe điện để bắt đầu kiếm thu nhập thụ động.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _navigateToRegister,
              icon: const Icon(Icons.add),
              label: Text(
                'Đăng ký xe đầu tiên',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
