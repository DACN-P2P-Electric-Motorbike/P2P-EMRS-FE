import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../domain/entities/vehicle_entity.dart';
import '../bloc/vehicles_list_cubit.dart';

/// Bottom sheet widget showing nearby vehicles sorted by distance.
/// Used inside the DraggableScrollableSheet on the map page.
class NearbyVehiclesSheet extends StatelessWidget {
  final ScrollController scrollController;
  final double radiusKm;

  const NearbyVehiclesSheet({
    super.key,
    required this.scrollController,
    required this.radiusKm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          BlocBuilder<VehicleListCubit, VehicleListState>(
            builder: (context, state) {
              final count = state is VehicleListLoaded
                  ? state.vehicles.length
                  : 0;
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 4,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '$count xe gần bạn',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Icon(Icons.sort, color: AppColors.textMuted, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      'Gần nhất',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          const Divider(height: 1),

          // Vehicle list
          Expanded(
            child: BlocBuilder<VehicleListCubit, VehicleListState>(
              builder: (context, state) {
                if (state is VehicleListLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is VehicleListError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: AppColors.error.withOpacity(0.5),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            state.message,
                            style: GoogleFonts.poppins(
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () {
                              context.read<VehicleListCubit>().loadVehicles();
                            },
                            icon: const Icon(Icons.refresh, size: 18),
                            label: const Text('Thử lại'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (state is VehicleListLoaded) {
                  if (state.vehicles.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.electric_moped,
                              size: 64,
                              color: AppColors.textMuted.withOpacity(0.5),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Không có xe nào trong bán kính ${radiusKm.toStringAsFixed(0)} km',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: state.vehicles.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1, indent: 16, endIndent: 16),
                    itemBuilder: (context, index) {
                      return _NearbyVehicleListTile(
                        vehicle: state.vehicles[index],
                      );
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// A single vehicle tile in the nearby vehicles list.
class _NearbyVehicleListTile extends StatelessWidget {
  final VehicleEntity vehicle;

  const _NearbyVehicleListTile({required this.vehicle});

  @override
  Widget build(BuildContext context) {
    final isAvailable =
        vehicle.isAvailable && vehicle.status == VehicleStatus.available;

    return InkWell(
      onTap: () => context.push('/vehicle/${vehicle.id}'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Vehicle image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AppNetworkImage(
                imageUrl: vehicle.thumbnailUrl,
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                cacheWidth: 160,
                errorWidget: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.electric_moped,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Center: name, brand, rating & battery
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vehicle.displayName,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${vehicle.brand.displayName} • ${vehicle.type.displayName}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        size: 14,
                        color: AppColors.warning,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        vehicle.reviewCount > 0
                            ? (vehicle.totalRating / vehicle.reviewCount)
                                  .toStringAsFixed(1)
                            : '—',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.battery_charging_full,
                        size: 14,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${vehicle.batteryLevel}%',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Right: price, distance, status
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  vehicle.formattedPricePerHour,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                _buildDistanceBadge(),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isAvailable
                        ? AppColors.success.withOpacity(0.1)
                        : AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isAvailable ? 'Có sẵn' : 'Đã thuê',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: isAvailable ? AppColors.success : AppColors.error,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDistanceBadge() {
    final distance = vehicle.distanceFromUser;
    if (distance == null) return const SizedBox.shrink();

    Color badgeColor;
    if (distance < 2) {
      badgeColor = AppColors.success;
    } else if (distance < 5) {
      badgeColor = AppColors.warning;
    } else {
      badgeColor = AppColors.error;
    }

    final label = distance < 1
        ? '${(distance * 1000).toStringAsFixed(0)} m'
        : '${distance.toStringAsFixed(1)} km';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: badgeColor,
        ),
      ),
    );
  }
}
