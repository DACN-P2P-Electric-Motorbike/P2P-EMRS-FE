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

class _OwnerDashboardContent extends StatelessWidget {
  const _OwnerDashboardContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'My Vehicles',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
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
          if (state.status == OwnerVehicleStatus.loading && state.vehicles.isEmpty) {
            return const Center(
              child: SpinKitFadingCircle(
                color: AppColors.primary,
                size: 50,
              ),
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
                SliverToBoxAdapter(
                  child: _buildStatsHeader(state),
                ),

                // Vehicle list
                if (state.vehicles.isEmpty)
                  SliverFillRemaining(
                    child: _buildEmptyState(context),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final vehicle = state.vehicles[index];
                        return VehicleCard(
                          vehicle: vehicle,
                          onTap: () {
                            context.push('/owner/vehicle/${vehicle.id}');
                          },
                        );
                      },
                      childCount: state.vehicles.length,
                    ),
                  ),

                // Bottom padding
                const SliverToBoxAdapter(
                  child: SizedBox(height: 100),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/owner/register-vehicle');
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text(
          'Add Vehicle',
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
            'Vehicle Overview',
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
                label: 'Total',
                value: state.vehicleCount.toString(),
              ),
              const SizedBox(width: 24),
              _buildStatItem(
                icon: Icons.check_circle_outline,
                label: 'Available',
                value: state.availableCount.toString(),
              ),
              const SizedBox(width: 24),
              _buildStatItem(
                icon: Icons.pending_outlined,
                label: 'Pending',
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
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
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

  Widget _buildEmptyState(BuildContext context) {
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
              'No Vehicles Yet',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start earning by registering your electric motorbike for rent.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.push('/owner/register-vehicle');
              },
              icon: const Icon(Icons.add),
              label: const Text('Register Your First Vehicle'),
            ),
          ],
        ),
      ),
    );
  }
}

