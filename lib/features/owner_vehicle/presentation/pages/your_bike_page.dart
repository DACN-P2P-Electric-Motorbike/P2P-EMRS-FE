import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/vehicle_entity.dart';
import '../bloc/owner_vehicle_bloc.dart';

/// Your Bike Page - displays all vehicles owned by the user
class YourBikePage extends StatelessWidget {
  const YourBikePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<OwnerVehicleBloc>()..add(const LoadMyVehicles()),
      child: const _YourBikeContent(),
    );
  }
}

class _YourBikeContent extends StatefulWidget {
  const _YourBikeContent();

  @override
  State<_YourBikeContent> createState() => _YourBikeContentState();
}

class _YourBikeContentState extends State<_YourBikeContent>
    with RouteAware, WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Subscribe to route changes
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      // Route observer would be used here if configured
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh when app comes back to foreground
      context.read<OwnerVehicleBloc>().add(const LoadMyVehicles());
    }
  }

  void _navigateToDetail(String vehicleId) async {
    // Navigate to detail page and refresh when returning
    await context.push('/owner/vehicle/$vehicleId');
    // Refresh the list when returning from detail page
    // Use a small delay to ensure navigation has fully completed
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
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        title: Text(
          'Xe của tôi',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
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
            // Reset state after showing success message
            context.read<OwnerVehicleBloc>().add(
              const ResetOwnerVehicleState(),
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
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Vehicle Cards
                ...state.vehicles.map(
                  (vehicle) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildVehicleCard(context, vehicle),
                  ),
                ),

                // Add New Bike Card
                _buildAddNewBikeCard(context),

                const SizedBox(height: 100),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildVehicleCard(BuildContext context, VehicleEntity vehicle) {
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
      child: Column(
        children: [
          // Main content - tappable to view detail
          InkWell(
            onTap: () => _navigateToDetail(vehicle.id),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
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
                          ? AppNetworkImage(
                              imageUrl: vehicle.thumbnailUrl,
                              width: 100,
                              height: 80,
                              fit: BoxFit.cover,
                              cacheWidth: 220,
                              errorWidget: _buildPlaceholderImage(),
                            )
                          : _buildPlaceholderImage(),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Vehicle Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Model Name
                        Text(
                          vehicle.model,
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 4),

                        // Location
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 12,
                              color: AppColors.textMuted,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                vehicle.address,
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // Status Badge and Price
                        Row(
                          children: [
                            // Status Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(
                                  vehicle.status,
                                ).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: _getStatusColor(vehicle.status),
                                ),
                              ),
                              child: Text(
                                vehicle.status.displayName,
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: _getStatusColor(vehicle.status),
                                ),
                              ),
                            ),

                            const SizedBox(width: 8),

                            // Price
                            Text(
                              vehicle.formattedPricePerDay,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Availability Toggle Section
          if (vehicle.canEditStatus)
            Container(
              decoration: BoxDecoration(
                color: AppColors.inputBackground,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(16),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        vehicle.isAvailable
                            ? Icons.visibility
                            : Icons.visibility_off,
                        size: 18,
                        color: vehicle.isAvailable
                            ? AppColors.success
                            : AppColors.textMuted,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        vehicle.isAvailable ? 'Đang cho thuê' : 'Đã tắt',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: vehicle.isAvailable
                              ? AppColors.success
                              : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  BlocBuilder<OwnerVehicleBloc, OwnerVehicleState>(
                    builder: (context, state) {
                      final isUpdating =
                          state.status == OwnerVehicleStatus.updating;
                      return Transform.scale(
                        scale: 0.8,
                        child: isUpdating
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primary,
                                ),
                              )
                            : Switch.adaptive(
                                value: vehicle.isAvailable,
                                onChanged: (_) {
                                  context.read<OwnerVehicleBloc>().add(
                                    ToggleVehicleAvailability(vehicle.id),
                                  );
                                },
                                activeColor: AppColors.success,
                                inactiveThumbColor: AppColors.textMuted,
                              ),
                      );
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _navigateToRegister() async {
    // Navigate to register page and refresh when returning
    await context.push('/owner/register-vehicle');
    // Refresh the list when returning from register page
    if (mounted) {
      context.read<OwnerVehicleBloc>().add(const LoadMyVehicles());
    }
  }

  Widget _buildAddNewBikeCard(BuildContext context) {
    return GestureDetector(
      onTap: _navigateToRegister,
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.border,
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: CustomPaint(
          painter: DashedBorderPainter(
            color: AppColors.textMuted.withOpacity(0.5),
            strokeWidth: 2,
            gap: 8,
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add, size: 40, color: AppColors.textMuted),
                const SizedBox(height: 12),
                Text(
                  'Thêm xe mới',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Center(
      child: Icon(Icons.two_wheeler, size: 40, color: AppColors.textMuted),
    );
  }

  Color _getStatusColor(VehicleStatus status) {
    switch (status) {
      case VehicleStatus.available:
        return const Color(0xFFE5A400); // Yellow/Gold for "For rent"
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
}

/// Custom painter for dashed border
class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;

  DashedBorderPainter({
    required this.color,
    this.strokeWidth = 1,
    this.gap = 5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          const Radius.circular(16),
        ),
      );

    // Draw dashed border
    final dashPath = Path();
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final start = distance;
        final end = (distance + gap).clamp(0, metric.length);
        dashPath.addPath(
          metric.extractPath(start, end.toDouble()),
          Offset.zero,
        );
        distance += gap * 2;
      }
    }
    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
