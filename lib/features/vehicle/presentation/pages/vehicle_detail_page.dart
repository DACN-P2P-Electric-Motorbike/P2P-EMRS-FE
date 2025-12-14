import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../injection_container.dart';
import '../../domain/entities/vehicle_entity.dart';
import '../bloc/vehicle_detail_cubit.dart';
import '../widgets/vehicle_image_carousel.dart';
import '../widgets/booking_bottom_sheet.dart';

class VehicleDetailPage extends StatelessWidget {
  final String vehicleId;

  const VehicleDetailPage({super.key, required this.vehicleId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<VehicleDetailCubit>()..loadVehicle(vehicleId),
      child: const _VehicleDetailView(),
    );
  }
}

class _VehicleDetailView extends StatelessWidget {
  const _VehicleDetailView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<VehicleDetailCubit, VehicleDetailState>(
        builder: (context, state) {
          if (state is VehicleDetailLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is VehicleDetailError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppColors.error.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Có lỗi xảy ra',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      style: GoogleFonts.poppins(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.read<VehicleDetailCubit>().refreshVehicle();
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is VehicleDetailLoaded) {
            return _VehicleDetailContent(
              vehicle: state.vehicle,
              isSaved: state.isSaved,
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _VehicleDetailContent extends StatelessWidget {
  final VehicleEntity vehicle;
  final bool isSaved;

  const _VehicleDetailContent({required this.vehicle, required this.isSaved});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App bar with image carousel
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            leading: IconButton(
              onPressed: () => context.pop(),
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  context.read<VehicleDetailCubit>().toggleSaved();
                },
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isSaved ? Icons.bookmark : Icons.bookmark_outline,
                    color: Colors.white,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  // TODO: Implement share
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Tính năng đang được phát triển'),
                    ),
                  );
                },
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.share, color: Colors.white),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: VehicleImageCarousel(
                images: vehicle.images,
                height: 300,
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header: Brand badge, name, and status
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                vehicle.brand.displayName,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(
                                  vehicle.status,
                                ).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                vehicle.status.displayName,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _getStatusColor(vehicle.status),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Vehicle name and license plate
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    vehicle.displayName,
                                    style: GoogleFonts.poppins(
                                      fontSize: 24,
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
                                  const SizedBox(height: 4),
                                  Text(
                                    vehicle.type.displayName,
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  vehicle.formattedPricePerHour,
                                  style: GoogleFonts.poppins(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                                if (vehicle.pricePerDay != null)
                                  Text(
                                    vehicle.formattedPricePerDay,
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Rating and trips
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: AppColors.warning,
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              vehicle.reviewCount > 0
                                  ? (vehicle.totalRating / vehicle.reviewCount)
                                        .toStringAsFixed(1)
                                  : vehicle.totalRating.toStringAsFixed(1),
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              ' (${vehicle.reviewCount} đánh giá)',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Icon(
                              Icons.electric_moped,
                              size: 18,
                              color: AppColors.textMuted,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${vehicle.totalTrips} chuyến',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Features
                        if (vehicle.features.isNotEmpty) ...[
                          _buildSectionTitle('Tính năng'),
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
                                  color: AppColors.surfaceVariant,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.border),
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
                                        fontSize: 13,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Specifications
                        _buildSectionTitle('Thông số kỹ thuật'),
                        const SizedBox(height: 16),
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 1.5,
                          children: [
                            if (vehicle.batteryCapacity != null)
                              _buildSpecCard(
                                icon: Icons.battery_charging_full,
                                label: 'Dung lượng pin',
                                value: '${vehicle.batteryCapacity} kWh',
                              ),
                            _buildSpecCard(
                              icon: Icons.battery_std,
                              label: 'Pin hiện tại',
                              value: '${vehicle.batteryLevel}%',
                              color: _getBatteryColor(vehicle.batteryLevel),
                            ),
                            if (vehicle.maxSpeed != null)
                              _buildSpecCard(
                                icon: Icons.speed,
                                label: 'Tốc độ tối đa',
                                value: '${vehicle.maxSpeed} km/h',
                              ),
                            if (vehicle.range != null)
                              _buildSpecCard(
                                icon: Icons.route,
                                label: 'Quãng đường',
                                value: '${vehicle.range} km',
                              ),
                            if (vehicle.year != null)
                              _buildSpecCard(
                                icon: Icons.calendar_today,
                                label: 'Năm sản xuất',
                                value: '${vehicle.year}',
                              ),
                            if (vehicle.deposit != null)
                              _buildSpecCard(
                                icon: Icons.account_balance_wallet,
                                label: 'Tiền cọc',
                                value: _formatPrice(vehicle.deposit!),
                              ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Location
                        _buildSectionTitle('Vị trí'),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.location_on,
                                  color: AppColors.primary,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  vehicle.address,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  // TODO: Open map
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Mở bản đồ')),
                                  );
                                },
                                icon: const Icon(Icons.map),
                                color: AppColors.primary,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Description
                        if (vehicle.description != null &&
                            vehicle.description!.isNotEmpty) ...[
                          _buildSectionTitle('Mô tả'),
                          const SizedBox(height: 12),
                          Text(
                            vehicle.description!,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Owner info (placeholder)
                        _buildSectionTitle('Chủ xe'),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 28,
                                backgroundColor: AppColors.primary.withOpacity(
                                  0.1,
                                ),
                                child: const Icon(
                                  Icons.person,
                                  color: AppColors.primary,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Chủ xe',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      'Xem thông tin',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  // TODO: View owner profile
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Xem hồ sơ chủ xe'),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.arrow_forward_ios),
                                iconSize: 16,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 100), // Space for bottom button
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed:
                vehicle.isAvailable && vehicle.status == VehicleStatus.available
                ? () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) =>
                          BookingBottomSheet(vehicle: vehicle),
                    );
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              disabledBackgroundColor: AppColors.textMuted,
            ),
            child: Text(
              vehicle.isAvailable && vehicle.status == VehicleStatus.available
                  ? 'Đặt xe ngay'
                  : 'Không khả dụng',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildSpecCard({
    required IconData icon,
    required String label,
    required String value,
    Color? color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color ?? AppColors.primary, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: AppColors.textMuted,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(VehicleStatus status) {
    switch (status) {
      case VehicleStatus.available:
        return AppColors.success;
      case VehicleStatus.rented:
        return AppColors.warning;
      case VehicleStatus.maintenance:
        return AppColors.error;
      case VehicleStatus.pendingApproval:
        return AppColors.info;
      default:
        return AppColors.textMuted;
    }
  }

  Color _getBatteryColor(int level) {
    if (level >= 80) return AppColors.success;
    if (level >= 50) return AppColors.warning;
    return AppColors.error;
  }

  IconData _getFeatureIcon(VehicleFeature feature) {
    switch (feature) {
      case VehicleFeature.replaceableBattery:
        return Icons.battery_std;
      case VehicleFeature.fastCharging:
        return Icons.bolt;
      case VehicleFeature.difficultTerrain:
        return Icons.terrain;
      case VehicleFeature.gpsTracking:
        return Icons.gps_fixed;
      case VehicleFeature.antiTheft:
        return Icons.security;
    }
  }

  String _formatPrice(double price) {
    return '${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}đ';
  }
}
