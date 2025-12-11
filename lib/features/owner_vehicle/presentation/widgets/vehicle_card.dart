import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/vehicle_entity.dart';

/// Card widget displaying vehicle information
class VehicleCard extends StatelessWidget {
  final VehicleEntity vehicle;
  final VoidCallback? onTap;

  const VehicleCard({
    super.key,
    required this.vehicle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Vehicle Image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 100,
                  height: 80,
                  color: AppColors.inputBackground,
                  child: vehicle.images.isNotEmpty
                      ? Image.network(
                          vehicle.thumbnailUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            );
                          },
                          errorBuilder: (_, error, __) {
                            debugPrint('Vehicle card image error: $error');
                            return _buildPlaceholder();
                          },
                        )
                      : _buildPlaceholder(),
                ),
              ),
              const SizedBox(width: 12),

              // Vehicle Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Model name
                    Text(
                      vehicle.model,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // License plate
                    Row(
                      children: [
                        Icon(
                          Icons.badge_outlined,
                          size: 14,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          vehicle.licensePlate,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Price
                    Row(
                      children: [
                        const Icon(
                          Icons.monetization_on_outlined,
                          size: 14,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          vehicle.formattedPrice,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Status Badge
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildStatusBadge(vehicle.status),
                  const SizedBox(height: 8),

                  // Battery indicator
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getBatteryIcon(vehicle.batteryLevel),
                        size: 16,
                        color: _getBatteryColor(vehicle.batteryLevel),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${vehicle.batteryLevel}%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: _getBatteryColor(vehicle.batteryLevel),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return const Center(
      child: Icon(
        Icons.electric_moped,
        size: 40,
        color: AppColors.textMuted,
      ),
    );
  }

  Widget _buildStatusBadge(VehicleStatus status) {
    Color backgroundColor;
    Color textColor;

    switch (status) {
      case VehicleStatus.available:
        backgroundColor = AppColors.success.withOpacity(0.1);
        textColor = AppColors.success;
        break;
      case VehicleStatus.rented:
        backgroundColor = AppColors.info.withOpacity(0.1);
        textColor = AppColors.info;
        break;
      case VehicleStatus.maintenance:
        backgroundColor = AppColors.warning.withOpacity(0.1);
        textColor = AppColors.warning;
        break;
      case VehicleStatus.pendingApproval:
        backgroundColor = Colors.orange.withOpacity(0.1);
        textColor = Colors.orange;
        break;
      case VehicleStatus.rejected:
        backgroundColor = AppColors.error.withOpacity(0.1);
        textColor = AppColors.error;
        break;
      case VehicleStatus.locked:
        backgroundColor = Colors.grey.withOpacity(0.1);
        textColor = Colors.grey;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  IconData _getBatteryIcon(int level) {
    if (level >= 80) return Icons.battery_full;
    if (level >= 50) return Icons.battery_5_bar;
    if (level >= 20) return Icons.battery_2_bar;
    return Icons.battery_alert;
  }

  Color _getBatteryColor(int level) {
    if (level >= 50) return AppColors.success;
    if (level >= 20) return AppColors.warning;
    return AppColors.error;
  }
}

