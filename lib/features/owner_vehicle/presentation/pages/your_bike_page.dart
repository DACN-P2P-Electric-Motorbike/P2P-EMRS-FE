import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
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

class _YourBikeContent extends StatelessWidget {
  const _YourBikeContent();

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
          'Your Bike',
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
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Vehicle Cards
                ...state.vehicles.map((vehicle) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildVehicleCard(context, vehicle),
                    )),

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
      child: InkWell(
        onTap: () => context.push('/owner/vehicle/${vehicle.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Vehicle Image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 120,
                  height: 100,
                  color: AppColors.inputBackground,
                  child: vehicle.images.isNotEmpty
                      ? Image.network(
                          vehicle.thumbnailUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                                strokeWidth: 2,
                                color: AppColors.primary,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            debugPrint('Image load error: $error');
                            debugPrint('Image URL: ${vehicle.thumbnailUrl}');
                            return _buildPlaceholderImage();
                          },
                        )
                      : _buildPlaceholderImage(),
                ),
              ),

              const SizedBox(width: 16),

              // Vehicle Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Model Name
                    Text(
                      vehicle.model,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
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
                          size: 14,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            vehicle.address,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Status and Fee
                    Row(
                      children: [
                        // Status
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 14,
                              color: AppColors.textMuted,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Status',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(width: 16),

                        // Fee
                        Row(
                          children: [
                            Icon(
                              Icons.monetization_on_outlined,
                              size: 14,
                              color: AppColors.textMuted,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Fee',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // Status Badge and Price
                    Row(
                      children: [
                        // Status Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(vehicle.status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
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

                        const SizedBox(width: 16),

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
    );
  }

  Widget _buildAddNewBikeCard(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/owner/register-vehicle'),
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
                Icon(
                  Icons.add,
                  size: 40,
                  color: AppColors.textMuted,
                ),
                const SizedBox(height: 12),
                Text(
                  'Add a new bike',
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
      child: Icon(
        Icons.two_wheeler,
        size: 40,
        color: AppColors.textMuted,
      ),
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
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(16),
      ));

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

