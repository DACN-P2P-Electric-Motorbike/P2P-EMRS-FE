import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/vehicle_entity.dart';

/// Bottom sheet for toggling vehicle status
class StatusToggleSheet extends StatelessWidget {
  final VehicleStatus currentStatus;
  final Function(VehicleStatus) onStatusSelected;

  const StatusToggleSheet({
    super.key,
    required this.currentStatus,
    required this.onStatusSelected,
  });

  @override
  Widget build(BuildContext context) {
    // Owners can only set AVAILABLE or MAINTENANCE
    final allowedStatuses = [
      VehicleStatus.available,
      VehicleStatus.maintenance,
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Title
          const Text(
            'Update Vehicle Status',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Select a new status for your vehicle',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),

          // Status options
          ...allowedStatuses.map((status) => _buildStatusOption(
                context,
                status,
                isSelected: status == currentStatus,
              )),

          const SizedBox(height: 16),

          // Info text
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 20,
                  color: AppColors.info,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Only "Available" and "Maintenance" status can be set by owners.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.info,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildStatusOption(
    BuildContext context,
    VehicleStatus status, {
    required bool isSelected,
  }) {
    Color accentColor;
    IconData icon;

    switch (status) {
      case VehicleStatus.available:
        accentColor = AppColors.success;
        icon = Icons.check_circle_outline;
        break;
      case VehicleStatus.maintenance:
        accentColor = AppColors.warning;
        icon = Icons.build_outlined;
        break;
      default:
        accentColor = AppColors.textMuted;
        icon = Icons.circle_outlined;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: isSelected ? null : () {
          Navigator.pop(context);
          onStatusSelected(status);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? accentColor.withOpacity(0.1) : AppColors.inputBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? accentColor : Colors.transparent,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: accentColor,
                size: 24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      status.displayName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _getStatusDescription(status),
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: accentColor,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _getStatusDescription(VehicleStatus status) {
    switch (status) {
      case VehicleStatus.available:
        return 'Vehicle is available for rental';
      case VehicleStatus.maintenance:
        return 'Vehicle is under maintenance';
      default:
        return '';
    }
  }
}

