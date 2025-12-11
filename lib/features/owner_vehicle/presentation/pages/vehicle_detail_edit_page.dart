import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/vehicle_entity.dart';
import '../bloc/owner_vehicle_bloc.dart';

/// Vehicle Detail & Edit Page
class VehicleDetailEditPage extends StatelessWidget {
  final String vehicleId;

  const VehicleDetailEditPage({
    super.key,
    required this.vehicleId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<OwnerVehicleBloc>()..add(LoadVehicleById(vehicleId)),
      child: const _VehicleDetailContent(),
    );
  }
}

class _VehicleDetailContent extends StatefulWidget {
  const _VehicleDetailContent();

  @override
  State<_VehicleDetailContent> createState() => _VehicleDetailContentState();
}

class _VehicleDetailContentState extends State<_VehicleDetailContent> {
  double _batteryLevel = 100;
  bool _isEditingBattery = false;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OwnerVehicleBloc, OwnerVehicleState>(
      listener: (context, state) {
        if (state.status == OwnerVehicleStatus.updated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage ?? 'Updated successfully'),
              backgroundColor: AppColors.success,
            ),
          );
        }
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        final vehicle = state.selectedVehicle;
        final isLoading = state.status == OwnerVehicleStatus.loading;

        if (isLoading && vehicle == null) {
          return Scaffold(
            appBar: _buildAppBar(context, 'Loading...'),
            body: const Center(
              child: SpinKitFadingCircle(
                color: AppColors.primary,
                size: 50,
              ),
            ),
          );
        }

        if (vehicle == null) {
          return Scaffold(
            appBar: _buildAppBar(context, 'Error'),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Vehicle not found',
                    style: GoogleFonts.poppins(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.pop(),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            ),
          );
        }

        // Initialize battery level from vehicle
        if (!_isEditingBattery) {
          _batteryLevel = vehicle.batteryLevel.toDouble();
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FD),
          appBar: _buildAppBar(context, vehicle.model),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Vehicle Image
                _buildVehicleImage(vehicle),

                // Vehicle Info Cards
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Basic Info Card
                      _buildInfoCard(vehicle),

                      const SizedBox(height: 20),

                      // Status Toggle
                      _buildStatusSection(vehicle),

                      const SizedBox(height: 20),

                      // Battery Level
                      _buildBatterySection(vehicle),

                      const SizedBox(height: 20),

                      // Features
                      if (vehicle.features.isNotEmpty) ...[
                        _buildFeaturesSection(vehicle),
                        const SizedBox(height: 20),
                      ],

                      // Location
                      _buildLocationSection(vehicle),

                      const SizedBox(height: 32),

                      // Delete Button
                      _buildDeleteButton(context, vehicle),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  AppBar _buildAppBar(BuildContext context, String title) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
        onPressed: () => context.pop(),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
          onPressed: () {
            // TODO: Navigate to full edit page
          },
        ),
      ],
    );
  }

  Widget _buildVehicleImage(VehicleEntity vehicle) {
    return Container(
      height: 250,
      width: double.infinity,
      color: AppColors.inputBackground,
      child: vehicle.images.isNotEmpty
          ? PageView.builder(
              itemCount: vehicle.images.length,
              itemBuilder: (context, index) {
                return Image.network(
                  vehicle.images[index],
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildPlaceholderImage(),
                );
              },
            )
          : _buildPlaceholderImage(),
    );
  }

  Widget _buildPlaceholderImage() {
    return Center(
      child: Icon(
        Icons.two_wheeler,
        size: 80,
        color: AppColors.textMuted,
      ),
    );
  }

  Widget _buildInfoCard(VehicleEntity vehicle) {
    return Container(
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vehicle.model,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      vehicle.licensePlate,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(vehicle.status),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),

          // Stats Row
          Row(
            children: [
              _buildStatItem(
                icon: Icons.attach_money,
                label: 'Price',
                value: vehicle.formattedPricePerDay,
              ),
              const SizedBox(width: 24),
              _buildStatItem(
                icon: Icons.trip_origin,
                label: 'Total Trips',
                value: vehicle.totalTrips.toString(),
              ),
              const SizedBox(width: 24),
              _buildStatItem(
                icon: Icons.star,
                label: 'Rating',
                value: vehicle.totalRating.toStringAsFixed(1),
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
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSection(VehicleEntity vehicle) {
    return Container(
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
          Text(
            'Vehicle Status',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 16),

          if (!vehicle.canEditStatus)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.warning, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Status cannot be changed while ${vehicle.status.displayName.toLowerCase()}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.warning,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: _buildStatusOption(
                    label: 'Available',
                    status: VehicleStatus.available,
                    currentStatus: vehicle.status,
                    vehicle: vehicle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatusOption(
                    label: 'Maintenance',
                    status: VehicleStatus.maintenance,
                    currentStatus: vehicle.status,
                    vehicle: vehicle,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildStatusOption({
    required String label,
    required VehicleStatus status,
    required VehicleStatus currentStatus,
    required VehicleEntity vehicle,
  }) {
    final isSelected = status == currentStatus;
    return GestureDetector(
      onTap: vehicle.canEditStatus && !isSelected
          ? () {
              context.read<OwnerVehicleBloc>().add(
                    UpdateVehicleStatus(
                      vehicleId: vehicle.id,
                      newStatus: status,
                    ),
                  );
            }
          : null,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBatterySection(VehicleEntity vehicle) {
    return Container(
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Battery Level',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '${_batteryLevel.toInt()}%',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _getBatteryColor(_batteryLevel.toInt()),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Battery Slider
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 8,
              activeTrackColor: _getBatteryColor(_batteryLevel.toInt()),
              inactiveTrackColor: AppColors.border,
              thumbColor: _getBatteryColor(_batteryLevel.toInt()),
              overlayColor:
                  _getBatteryColor(_batteryLevel.toInt()).withOpacity(0.2),
            ),
            child: Slider(
              value: _batteryLevel,
              min: 0,
              max: 100,
              divisions: 100,
              onChanged: (value) {
                setState(() {
                  _batteryLevel = value;
                  _isEditingBattery = true;
                });
              },
              onChangeEnd: (value) {
                context.read<OwnerVehicleBloc>().add(
                      UpdateVehicleBattery(
                        vehicleId: vehicle.id,
                        batteryLevel: value.toInt(),
                      ),
                    );
                _isEditingBattery = false;
              },
            ),
          ),

          // Battery Status
          Row(
            children: [
              Icon(
                _batteryLevel > 20 ? Icons.battery_full : Icons.battery_alert,
                color: _getBatteryColor(_batteryLevel.toInt()),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                _getBatteryStatus(_batteryLevel.toInt()),
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection(VehicleEntity vehicle) {
    return Container(
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
          Text(
            'Features',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: vehicle.features.map((feature) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getFeatureIcon(feature),
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      feature.displayName,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection(VehicleEntity vehicle) {
    return Container(
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
          Text(
            'Pickup Location',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.location_on,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  vehicle.address,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteButton(BuildContext context, VehicleEntity vehicle) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _showDeleteConfirmation(context, vehicle),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.error,
          side: const BorderSide(color: AppColors.error),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: const Icon(Icons.delete_outline),
        label: Text(
          'Delete Vehicle',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, VehicleEntity vehicle) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          'Delete Vehicle',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Are you sure you want to delete "${vehicle.model}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<OwnerVehicleBloc>().add(DeleteVehicle(vehicle.id));
              context.pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(VehicleStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _getStatusColor(status)),
      ),
      child: Text(
        status.displayName,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: _getStatusColor(status),
        ),
      ),
    );
  }

  Color _getStatusColor(VehicleStatus status) {
    switch (status) {
      case VehicleStatus.available:
        return const Color(0xFFE5A400);
      case VehicleStatus.rented:
        return AppColors.info;
      case VehicleStatus.maintenance:
        return AppColors.warning;
      case VehicleStatus.pendingApproval:
        return Colors.orange;
      case VehicleStatus.rejected:
        return AppColors.error;
      case VehicleStatus.locked:
        return Colors.grey;
      case VehicleStatus.unavailable:
        return Colors.grey.shade600;
    }
  }

  Color _getBatteryColor(int level) {
    if (level > 60) return AppColors.success;
    if (level > 20) return AppColors.warning;
    return AppColors.error;
  }

  String _getBatteryStatus(int level) {
    if (level > 80) return 'Fully charged';
    if (level > 60) return 'Good battery';
    if (level > 40) return 'Moderate';
    if (level > 20) return 'Low battery';
    return 'Critical - needs charging';
  }

  IconData _getFeatureIcon(VehicleFeature feature) {
    switch (feature) {
      case VehicleFeature.replaceableBattery:
        return Icons.battery_charging_full;
      case VehicleFeature.fastCharging:
        return Icons.flash_on;
      case VehicleFeature.difficultTerrain:
        return Icons.terrain;
      case VehicleFeature.gpsTracking:
        return Icons.gps_fixed;
      case VehicleFeature.antiTheft:
        return Icons.security;
    }
  }
}
