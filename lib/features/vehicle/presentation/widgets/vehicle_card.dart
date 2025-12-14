import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../domain/entities/vehicle_entity.dart';

class VehicleCard extends StatelessWidget {
  final VehicleEntity vehicle;
  final VoidCallback onTap;

  const VehicleCard({super.key, required this.vehicle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vehicle Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: vehicle.images.isNotEmpty
                      ? Image.network(
                          vehicle.images.first,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildPlaceholder();
                          },
                        )
                      : _buildPlaceholder(),
                ),

                // Status badges
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(vehicle.status),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      vehicle.status.displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                // Battery level
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getBatteryColor(vehicle.batteryLevel),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.battery_charging_full,
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${vehicle.batteryLevel}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Vehicle Details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Brand and Model
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          vehicle.brand.displayName,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          vehicle.displayName,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Vehicle Type
                  Text(
                    vehicle.type.displayName,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Features
                  if (vehicle.features.isNotEmpty)
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: vehicle.features.take(3).map((feature) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getFeatureIcon(feature),
                                size: 12,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                feature.displayName,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),

                  const SizedBox(height: 12),

                  // Location
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 16,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          vehicle.address,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Bottom row - Price and Rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Price
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            vehicle.formattedPricePerHour,
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          if (vehicle.pricePerDay != null)
                            Text(
                              vehicle.formattedPricePerDay,
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: AppColors.textMuted,
                              ),
                            ),
                        ],
                      ),

                      // Rating and trips
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                size: 16,
                                color: AppColors.warning,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                vehicle.reviewCount > 0
                                    ? (vehicle.totalRating /
                                              vehicle.reviewCount)
                                          .toStringAsFixed(1)
                                    : vehicle.totalRating.toStringAsFixed(1),
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                ' (${vehicle.reviewCount})',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${vehicle.totalTrips} chuyến',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: 200,
      width: double.infinity,
      color: AppColors.surfaceVariant,
      child: Center(
        child: Icon(
          Icons.electric_moped,
          size: 80,
          color: AppColors.primary.withOpacity(0.3),
        ),
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
}
