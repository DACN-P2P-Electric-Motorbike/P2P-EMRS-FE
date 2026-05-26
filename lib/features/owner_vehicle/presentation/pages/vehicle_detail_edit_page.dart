import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/availability_time_zone.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/utils/open_external_map.dart';
import '../../../../injection_container.dart';
import '../../data/models/availability_window_model.dart';
import '../../data/models/update_vehicle_params.dart';
import '../../domain/entities/vehicle_entity.dart';
import '../bloc/owner_vehicle_bloc.dart';
import 'dart:typed_data'; // Cần cho Uint8List
import 'package:file_picker/file_picker.dart'; // Cần cho FilePicker
import '../../../../core/services/upload_service.dart'; // Cần cho UploadService

/// Vehicle Detail & Edit Page
class VehicleDetailEditPage extends StatelessWidget {
  final String vehicleId;

  const VehicleDetailEditPage({super.key, required this.vehicleId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<OwnerVehicleBloc>()
        ..add(LoadVehicleById(vehicleId))
        ..add(LoadVehicleAvailability(vehicleId)),
      child: const _VehicleDetailContent(),
    );
  }
}

class _VehicleDetailContent extends StatefulWidget {
  const _VehicleDetailContent();

  @override
  State<_VehicleDetailContent> createState() => _VehicleDetailContentState();
}

// Widget phụ trợ hiển thị ảnh có nút xóa
class _ImagePreview extends StatelessWidget {
  final ImageProvider image;
  final VoidCallback onDelete;

  const _ImagePreview({required this.image, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 10),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image(
              image: image,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: onDelete,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 14, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
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
              content: Text(state.successMessage ?? 'Cập nhật thành công'),
              backgroundColor: AppColors.success,
            ),
          );
        }
        if (state.status == OwnerVehicleStatus.deleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage ?? 'Đã xóa xe thành công'),
              backgroundColor: AppColors.success,
            ),
          );
          // Navigate back after successful deletion
          context.pop();
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
        final isDeleting = state.status == OwnerVehicleStatus.deleting;

        if (isDeleting) {
          return Scaffold(
            appBar: _buildAppBar(context, 'Đang xóa...'),
            body: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SpinKitFadingCircle(color: AppColors.error, size: 50),
                  SizedBox(height: 16),
                  Text('Đang xóa xe...'),
                ],
              ),
            ),
          );
        }

        if (isLoading && vehicle == null) {
          return Scaffold(
            appBar: _buildAppBar(context, 'Đang tải...'),
            body: const Center(
              child: SpinKitFadingCircle(color: AppColors.primary, size: 50),
            ),
          );
        }

        if (vehicle == null) {
          return Scaffold(
            appBar: _buildAppBar(context, 'Lỗi'),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: AppColors.error),
                  const SizedBox(height: 16),
                  Text(
                    'Không tìm thấy xe',
                    style: GoogleFonts.poppins(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.pop(),
                    child: const Text('Quay lại'),
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

                      _buildAvailabilitySection(
                        context,
                        vehicle,
                        state.availabilityWindows,
                        state.isAvailabilityLoading,
                      ),

                      const SizedBox(height: 20),

                      // Battery Level
                      _buildBatterySection(vehicle),

                      const SizedBox(height: 20),

                      _buildEvConditionSection(vehicle),

                      const SizedBox(height: 20),

                      // Features
                      if (vehicle.features.isNotEmpty) ...[
                        _buildFeaturesSection(vehicle),
                        const SizedBox(height: 20),
                      ],

                      _buildRentalPolicySection(vehicle),
                      const SizedBox(height: 20),

                      // Location
                      _buildLocationSection(context, vehicle),

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
            // Lấy vehicle mới nhất từ state của Bloc hiện tại
            final vehicle = context
                .read<OwnerVehicleBloc>()
                .state
                .selectedVehicle;

            if (vehicle != null) {
              _showEditVehicleSheet(context, vehicle);
            }
          }, // Truyền vehicle hiện tại vào
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
                return AppNetworkImage(
                  imageUrl: vehicle.images[index],
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                  cacheWidth: 1080,
                  errorWidget: _buildPlaceholderImage(),
                );
              },
            )
          : _buildPlaceholderImage(),
    );
  }

  Widget _buildPlaceholderImage() {
    return Center(
      child: Icon(Icons.two_wheeler, size: 80, color: AppColors.textMuted),
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
                label: 'Giá thuê',
                value: vehicle.formattedPricePerDay,
              ),
              const SizedBox(width: 24),
              _buildStatItem(
                icon: Icons.trip_origin,
                label: 'Tổng chuyến',
                value: vehicle.totalTrips.toString(),
              ),
              const SizedBox(width: 24),
              _buildStatItem(
                icon: Icons.star,
                label: 'Đánh giá',
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
    final canToggle = vehicle.canEditStatus;
    final isAvailable = vehicle.isAvailable;

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
                      'Hiển thị trong tìm kiếm',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isAvailable
                          ? 'Xe có thể xuất hiện nếu lịch còn trống'
                          : 'Xe đang ẩn khỏi danh sách thuê',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: isAvailable,
                onChanged: canToggle
                    ? (_) {
                        context.read<OwnerVehicleBloc>().add(
                          ToggleVehicleAvailability(vehicle.id),
                        );
                      }
                    : null,
                activeColor: AppColors.success,
                inactiveThumbColor: AppColors.textMuted,
              ),
            ],
          ),

          if (!canToggle) ...[
            const SizedBox(height: 12),
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
                      'Không thể thay đổi khi xe đang ${vehicle.status.displayName.toLowerCase()}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.warning,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),

          // Current Status Badge
          Text(
            'Trạng thái hiện tại',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          _buildStatusBadge(vehicle.status),
        ],
      ),
    );
  }

  Widget _buildAvailabilitySection(
    BuildContext context,
    VehicleEntity vehicle,
    List<VehicleAvailabilityWindowEntity> windows,
    bool isLoading,
  ) {
    final visibleWindows = [...windows]
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

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
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lịch cho thuê',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Đặt khung giờ xe rảnh hoặc chặn ngày bận.',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _showAvailabilityWindowSheet(context, vehicle),
                icon: const Icon(Icons.add_circle_outline),
                color: AppColors.primary,
                tooltip: 'Thêm lịch',
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else if (visibleWindows.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.inputBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Chưa có lịch riêng. Xe vẫn dùng trạng thái sẵn sàng hiện tại cho đến khi bạn thêm khung lịch.',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            )
          else
            Column(
              children: visibleWindows
                  .take(5)
                  .map((window) => _buildAvailabilityWindowRow(vehicle, window))
                  .toList(),
            ),
          if (visibleWindows.length > 5) ...[
            const SizedBox(height: 8),
            Text(
              '+${visibleWindows.length - 5} khung lịch khác',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAvailabilityWindowRow(
    VehicleEntity vehicle,
    VehicleAvailabilityWindowEntity window,
  ) {
    final color = window.isAvailableWindow
        ? AppColors.success
        : AppColors.warning;
    final weeklyStart = AvailabilityTimeZone.toWallTime(
      window.startTime,
      timezoneName: window.timezoneName,
      fallbackOffsetMinutes: window.timezoneOffsetMinutes,
    );
    final weeklyEnd = AvailabilityTimeZone.toWallTime(
      window.endTime,
      timezoneName: window.timezoneName,
      fallbackOffsetMinutes: window.timezoneOffsetMinutes,
    );
    final weeklyEndsAt = window.recurrenceEndsAt == null
        ? null
        : AvailabilityTimeZone.toWallTime(
            window.recurrenceEndsAt!,
            timezoneName: window.timezoneName,
            fallbackOffsetMinutes: window.timezoneOffsetMinutes,
          );

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Row(
        children: [
          Icon(
            window.isAvailableWindow ? Icons.event_available : Icons.event_busy,
            color: color,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  window.type.displayName,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  window.isWeekly
                      ? '${_formatWeekdays(window.recurringWeekdays)} · ${_formatTime(weeklyStart)} - ${_formatTime(weeklyEnd)}'
                      : '${_formatDateTime(window.startTime)} - ${_formatDateTime(window.endTime)}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (window.isWeekly) ...[
                  const SizedBox(height: 2),
                  Text(
                    window.recurrenceEndsAt == null
                        ? 'Lặp lại hàng tuần · ${_availabilityTimezoneLabel(window)}'
                        : 'Lặp lại đến ${_formatWallDate(weeklyEndsAt!)} · ${_availabilityTimezoneLabel(window)}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                if (window.note != null && window.note!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    window.note!,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: () => _showAvailabilityWindowSheet(
              context,
              vehicle,
              existingWindow: window,
            ),
            icon: const Icon(Icons.edit_outlined),
            color: AppColors.primary,
            tooltip: 'Sửa lịch',
          ),
          IconButton(
            onPressed: () {
              context.read<OwnerVehicleBloc>().add(
                DeleteVehicleAvailability(
                  vehicleId: vehicle.id,
                  windowId: window.id,
                ),
              );
            },
            icon: const Icon(Icons.delete_outline),
            color: AppColors.error,
            tooltip: 'Xóa lịch',
          ),
        ],
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
                'Mức pin',
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
              overlayColor: _getBatteryColor(
                _batteryLevel.toInt(),
              ).withOpacity(0.2),
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

  Widget _buildEvConditionSection(VehicleEntity vehicle) {
    final hasMetadata =
        vehicle.firstRegistrationYear != null ||
        vehicle.condition != null ||
        vehicle.batteryType != null ||
        vehicle.batteryHealth != null ||
        vehicle.batteryCycleCount != null ||
        vehicle.batteryLastServicedAt != null;

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
            'Tình trạng xe điện',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          if (!hasMetadata)
            Text(
              'Chưa có thông tin tình trạng pin và vòng đời xe.',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            )
          else ...[
            if (vehicle.condition != null)
              _buildPolicyRow(
                icon: Icons.verified_outlined,
                label: 'Tình trạng',
                value: vehicle.condition!.displayName,
              ),
            if (vehicle.firstRegistrationYear != null)
              _buildPolicyRow(
                icon: Icons.event_outlined,
                label: 'Năm đăng ký',
                value: '${vehicle.firstRegistrationYear}',
              ),
            if (vehicle.batteryType != null)
              _buildPolicyRow(
                icon: Icons.battery_unknown_outlined,
                label: 'Loại pin',
                value: vehicle.batteryType!.displayName,
              ),
            if (vehicle.batteryHealth != null)
              _buildPolicyRow(
                icon: Icons.health_and_safety_outlined,
                label: 'Sức khỏe pin',
                value: '${vehicle.batteryHealth}%',
                color: _getBatteryColor(vehicle.batteryHealth!),
              ),
            if (vehicle.batteryCycleCount != null)
              _buildPolicyRow(
                icon: Icons.repeat_outlined,
                label: 'Chu kỳ sạc',
                value: '${vehicle.batteryCycleCount}',
              ),
            if (vehicle.batteryLastServicedAt != null)
              _buildPolicyRow(
                icon: Icons.build_circle_outlined,
                label: 'Bảo dưỡng pin',
                value: _formatDate(vehicle.batteryLastServicedAt!),
              ),
          ],
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
            'Tính năng',
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

  Widget _buildRentalPolicySection(VehicleEntity vehicle) {
    final discountText = [
      if (vehicle.weeklyDiscount != null)
        'Tuần ${_formatPercent(vehicle.weeklyDiscount!)}%',
      if (vehicle.monthlyDiscount != null)
        'Tháng ${_formatPercent(vehicle.monthlyDiscount!)}%',
    ].join(' · ');

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
            'Chính sách thuê',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          if (vehicle.instantBook)
            _buildPolicyRow(
              icon: Icons.flash_on,
              label: 'Đặt xe nhanh',
              value: 'Tự động xác nhận',
              color: AppColors.warning,
            ),
          _buildPolicyRow(
            icon: Icons.event_busy_outlined,
            label: 'Chính sách hủy',
            value: vehicle.cancellationPolicy.displayName,
          ),
          if (vehicle.dailyKmLimit != null)
            _buildPolicyRow(
              icon: Icons.route,
              label: 'Giới hạn quãng đường',
              value: '${vehicle.dailyKmLimit} km/ngày',
            ),
          if (vehicle.excessKmPrice != null)
            _buildPolicyRow(
              icon: Icons.payments_outlined,
              label: 'Phí vượt giới hạn',
              value: '${_formatPrice(vehicle.excessKmPrice!)}/km',
            ),
          if (discountText.isNotEmpty)
            _buildPolicyRow(
              icon: Icons.local_offer_outlined,
              label: 'Ưu đãi dài ngày',
              value: discountText,
              color: AppColors.success,
            ),
          if (vehicle.allowSmoke)
            _buildPolicyRow(
              icon: Icons.smoke_free,
              label: 'Hút thuốc',
              value: 'Được phép',
            ),
          if (vehicle.allowPets)
            _buildPolicyRow(
              icon: Icons.pets_outlined,
              label: 'Thú cưng',
              value: 'Được phép',
            ),
          if (vehicle.geoRestriction != null)
            _buildPolicyRow(
              icon: Icons.map_outlined,
              label: 'Phạm vi di chuyển',
              value: _geoRestrictionLabel(vehicle.geoRestriction!),
            ),
          if (vehicle.batteryReturnMin != null)
            _buildPolicyRow(
              icon: Icons.battery_saver,
              label: 'Pin khi trả xe',
              value: 'Tối thiểu ${vehicle.batteryReturnMin}%',
            ),
        ],
      ),
    );
  }

  Widget _buildPolicyRow({
    required IconData icon,
    required String label,
    required String value,
    Color color = AppColors.primary,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection(BuildContext context, VehicleEntity vehicle) {
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
            'Địa điểm nhận xe',
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
                child: Icon(Icons.location_on, color: AppColors.primary),
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
              IconButton(
                onPressed: () => openVehicleLocationInExternalMaps(
                  context,
                  address: vehicle.address,
                  latitude: vehicle.latitude,
                  longitude: vehicle.longitude,
                ),
                icon: const Icon(Icons.map),
                color: AppColors.primary,
                tooltip: 'Open map',
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
          'Xóa xe',
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
          'Xóa xe',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Bạn có chắc muốn xóa "${vehicle.model}"? Hành động này không thể hoàn tác.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<OwnerVehicleBloc>().add(DeleteVehicle(vehicle.id));
              // Don't pop here - the listener will pop after successful deletion
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  void _showAvailabilityWindowSheet(
    BuildContext context,
    VehicleEntity vehicle, {
    VehicleAvailabilityWindowEntity? existingWindow,
  }) {
    final noteController = TextEditingController(text: existingWindow?.note);
    var type = existingWindow?.type ?? AvailabilityWindowType.available;
    var recurrence =
        existingWindow?.recurrence ?? AvailabilityWindowRecurrence.once;
    var startTime =
        existingWindow?.startTime ??
        DateTime.now().add(const Duration(hours: 2));
    var endTime =
        existingWindow?.endTime ?? startTime.add(const Duration(hours: 8));
    final recurringWeekdays =
        existingWindow?.recurringWeekdays.toSet() ?? <int>{startTime.weekday};
    DateTime? recurrenceEndsAt = existingWindow?.recurrenceEndsAt;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) {
          Future<void> pickDateTime(bool isStart) async {
            final current = isStart ? startTime : endTime;
            final date = await showDatePicker(
              context: sheetContext,
              initialDate: current,
              firstDate: DateTime.now().subtract(const Duration(days: 1)),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (date == null || !sheetContext.mounted) return;

            final time = await showTimePicker(
              context: sheetContext,
              initialTime: TimeOfDay.fromDateTime(current),
            );
            if (time == null) return;

            final next = DateTime(
              date.year,
              date.month,
              date.day,
              time.hour,
              time.minute,
            );
            setSheetState(() {
              if (isStart) {
                startTime = next;
                if (!endTime.isAfter(startTime)) {
                  endTime = startTime.add(const Duration(hours: 1));
                }
              } else {
                endTime = next;
              }
            });
          }

          Future<void> pickRecurrenceEndDate() async {
            final date = await showDatePicker(
              context: sheetContext,
              initialDate:
                  recurrenceEndsAt ?? startTime.add(const Duration(days: 90)),
              firstDate: startTime,
              lastDate: startTime.add(const Duration(days: 730)),
            );
            if (date == null) return;
            setSheetState(() {
              recurrenceEndsAt = DateTime(
                date.year,
                date.month,
                date.day,
                23,
                59,
                59,
              );
            });
          }

          void submit() {
            if (!endTime.isAfter(startTime)) {
              ScaffoldMessenger.of(sheetContext).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Thời gian kết thúc phải sau thời gian bắt đầu',
                  ),
                  backgroundColor: AppColors.error,
                ),
              );
              return;
            }
            if (recurrence == AvailabilityWindowRecurrence.weekly &&
                (recurringWeekdays.isEmpty ||
                    endTime.difference(startTime) > const Duration(days: 1))) {
              ScaffoldMessenger.of(sheetContext).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Lịch hàng tuần cần ít nhất một ngày và khung giờ tối đa 24 giờ',
                  ),
                  backgroundColor: AppColors.error,
                ),
              );
              return;
            }

            final params = CreateAvailabilityWindowParams(
              type: type,
              recurrence: recurrence,
              recurringWeekdays: recurringWeekdays.toList()..sort(),
              timezoneOffsetMinutes:
                  existingWindow?.timezoneOffsetMinutes ??
                  AvailabilityTimeZone.vietnamOffsetMinutes,
              timezoneName: recurrence == AvailabilityWindowRecurrence.weekly
                  ? existingWindow?.timezoneName ??
                        (existingWindow == null ||
                                existingWindow.timezoneOffsetMinutes ==
                                    AvailabilityTimeZone.vietnamOffsetMinutes
                            ? AvailabilityTimeZone.vietnamName
                            : null)
                  : null,
              recurrenceEndsAt: recurrenceEndsAt,
              startTime: startTime,
              endTime: endTime,
              note: noteController.text,
            );
            if (existingWindow == null) {
              context.read<OwnerVehicleBloc>().add(
                CreateVehicleAvailability(
                  vehicleId: vehicle.id,
                  params: params,
                ),
              );
            } else {
              context.read<OwnerVehicleBloc>().add(
                UpdateVehicleAvailability(
                  vehicleId: vehicle.id,
                  windowId: existingWindow.id,
                  params: params,
                ),
              );
            }
            Navigator.of(sheetContext).pop();
          }

          return SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
              left: 20,
              right: 20,
              top: 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  existingWindow == null
                      ? 'Thêm lịch cho thuê'
                      : 'Sửa lịch cho thuê',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<AvailabilityWindowType>(
                  value: type,
                  decoration: InputDecoration(
                    labelText: 'Loại lịch',
                    prefixIcon: const Icon(Icons.event_note),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: AvailabilityWindowType.values
                      .map(
                        (value) => DropdownMenuItem(
                          value: value,
                          child: Text(value.displayName),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setSheetState(() => type = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                SegmentedButton<AvailabilityWindowRecurrence>(
                  segments: AvailabilityWindowRecurrence.values
                      .map(
                        (value) => ButtonSegment(
                          value: value,
                          label: Text(value.displayName),
                          icon: Icon(
                            value == AvailabilityWindowRecurrence.once
                                ? Icons.event_outlined
                                : Icons.repeat,
                          ),
                        ),
                      )
                      .toList(),
                  selected: {recurrence},
                  onSelectionChanged: (selected) {
                    setSheetState(() => recurrence = selected.first);
                  },
                ),
                if (recurrence == AvailabilityWindowRecurrence.weekly) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Ngày lặp lại',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(7, (index) {
                      final weekday = index + 1;
                      return FilterChip(
                        label: Text(_weekdayLabel(weekday)),
                        selected: recurringWeekdays.contains(weekday),
                        onSelected: (selected) {
                          setSheetState(() {
                            if (selected) {
                              recurringWeekdays.add(weekday);
                            } else {
                              recurringWeekdays.remove(weekday);
                            }
                          });
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Đặt ngày kết thúc'),
                    value: recurrenceEndsAt != null,
                    onChanged: (enabled) async {
                      if (enabled) {
                        await pickRecurrenceEndDate();
                      } else {
                        setSheetState(() => recurrenceEndsAt = null);
                      }
                    },
                  ),
                  if (recurrenceEndsAt != null)
                    _buildDateTimeTile(
                      label: 'Lặp lại đến',
                      value: _formatDate(recurrenceEndsAt!),
                      onTap: pickRecurrenceEndDate,
                    ),
                  const SizedBox(height: 8),
                  Text(
                    existingWindow?.timezoneName != null
                        ? 'Múi giờ: ${existingWindow!.timezoneName}'
                        : existingWindow != null &&
                              existingWindow.timezoneOffsetMinutes !=
                                  AvailabilityTimeZone.vietnamOffsetMinutes
                        ? 'Múi giờ: UTC${_offsetLabel(existingWindow.timezoneOffsetMinutes)}'
                        : 'Múi giờ: Việt Nam (GMT+7)',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                _buildDateTimeTile(
                  label: recurrence == AvailabilityWindowRecurrence.weekly
                      ? 'Giờ bắt đầu (mốc đầu tiên)'
                      : 'Bắt đầu',
                  value: _formatDateTime(startTime),
                  onTap: () => pickDateTime(true),
                ),
                const SizedBox(height: 12),
                _buildDateTimeTile(
                  label: recurrence == AvailabilityWindowRecurrence.weekly
                      ? 'Giờ kết thúc (mốc đầu tiên)'
                      : 'Kết thúc',
                  value: _formatDateTime(endTime),
                  onTap: () => pickDateTime(false),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: noteController,
                  decoration: InputDecoration(
                    labelText: 'Ghi chú',
                    prefixIcon: const Icon(Icons.notes),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  maxLength: 200,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: submit,
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Lưu lịch'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ).whenComplete(noteController.dispose);
  }

  Widget _buildDateTimeTile({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.schedule, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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

  void _showEditVehicleSheet(BuildContext context, VehicleEntity vehicle) {
    final ownerVehicleBloc = context.read<OwnerVehicleBloc>();
    final nameController = TextEditingController(text: vehicle.model);
    final priceController = TextEditingController(
      text: vehicle.pricePerHour.toStringAsFixed(0),
    );
    final pricePerDayController = TextEditingController(
      text: vehicle.pricePerDay?.toStringAsFixed(0) ?? '',
    );
    final dailyKmLimitController = TextEditingController(
      text: vehicle.dailyKmLimit?.toString() ?? '',
    );
    final excessKmPriceController = TextEditingController(
      text: vehicle.excessKmPrice?.toStringAsFixed(0) ?? '',
    );
    final weeklyDiscountController = TextEditingController(
      text: vehicle.weeklyDiscount?.toStringAsFixed(0) ?? '',
    );
    final monthlyDiscountController = TextEditingController(
      text: vehicle.monthlyDiscount?.toStringAsFixed(0) ?? '',
    );
    final firstRegistrationYearController = TextEditingController(
      text: vehicle.firstRegistrationYear?.toString() ?? '',
    );
    final batteryHealthController = TextEditingController(
      text: vehicle.batteryHealth?.toString() ?? '',
    );
    final batteryCycleCountController = TextEditingController(
      text: vehicle.batteryCycleCount?.toString() ?? '',
    );
    final descriptionController = TextEditingController(
      text: vehicle.description,
    );
    final formKey = GlobalKey<FormState>();
    var instantBook = vehicle.instantBook;
    var cancellationPolicy = vehicle.cancellationPolicy;
    var allowSmoke = vehicle.allowSmoke;
    var allowPets = vehicle.allowPets;
    var geoRestriction = vehicle.geoRestriction ?? 'no_restriction';
    var enforceBatteryReturn = vehicle.batteryReturnMin != null;
    var batteryReturnMin = (vehicle.batteryReturnMin ?? 20).toDouble();
    var condition = vehicle.condition;
    var batteryType = vehicle.batteryType;
    var batteryLastServicedAt = vehicle.batteryLastServicedAt;
    var isUploading = false;

    List<String> existingUrls = List.from(vehicle.images);
    List<Uint8List> newImageBytes = [];
    List<String> newImageNames = [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) {
          Future<void> _pickImage() async {
            final result = await FilePicker.platform.pickFiles(
              type: FileType.image,
              allowMultiple: true,
              withData: true,
            );

            if (result != null) {
              setSheetState(() {
                for (var file in result.files) {
                  if (file.bytes != null) {
                    newImageBytes.add(file.bytes!);
                    newImageNames.add(file.name);
                  }
                }
              });
            }
          }

          Future<void> _handleUpdate() async {
            if (!formKey.currentState!.validate()) return;

            setSheetState(() => isUploading = true);

            try {
              List<String> finalImageUrls = List.from(existingUrls);

              // Bước 1: Upload các ảnh mới lên S3 (nếu có) bằng UploadService
              if (newImageBytes.isNotEmpty) {
                final uploadService = sl<UploadService>();
                for (int i = 0; i < newImageBytes.length; i++) {
                  final result = await uploadService.uploadVehicleImage(
                    fileBytes: newImageBytes[i],
                    fileName: newImageNames[i],
                  );
                  finalImageUrls.add(result.url);
                }
              }

              final fieldsToClear = <String>{};
              final pricePerDay = _optionalDouble(
                pricePerDayController.text,
                clearField: 'pricePerDay',
                fieldsToClear: fieldsToClear,
              );
              final dailyKmLimit = _optionalInt(
                dailyKmLimitController.text,
                clearField: 'dailyKmLimit',
                fieldsToClear: fieldsToClear,
              );
              final excessKmPrice = _optionalDouble(
                excessKmPriceController.text,
                clearField: 'excessKmPrice',
                fieldsToClear: fieldsToClear,
              );
              final weeklyDiscount = _optionalDouble(
                weeklyDiscountController.text,
                clearField: 'weeklyDiscount',
                fieldsToClear: fieldsToClear,
              );
              final monthlyDiscount = _optionalDouble(
                monthlyDiscountController.text,
                clearField: 'monthlyDiscount',
                fieldsToClear: fieldsToClear,
              );
              final firstRegistrationYear = _optionalInt(
                firstRegistrationYearController.text,
                clearField: 'firstRegistrationYear',
                fieldsToClear: fieldsToClear,
              );
              final batteryHealth = _optionalInt(
                batteryHealthController.text,
                clearField: 'batteryHealth',
                fieldsToClear: fieldsToClear,
              );
              final batteryCycleCount = _optionalInt(
                batteryCycleCountController.text,
                clearField: 'batteryCycleCount',
                fieldsToClear: fieldsToClear,
              );
              final currentYear = DateTime.now().year;
              if (firstRegistrationYear != null &&
                  (firstRegistrationYear < 2000 ||
                      firstRegistrationYear > currentYear + 1)) {
                throw Exception(
                  'Năm đăng ký phải nằm trong khoảng 2000-${currentYear + 1}',
                );
              }
              if (batteryHealth != null &&
                  (batteryHealth < 0 || batteryHealth > 100)) {
                throw Exception('Sức khỏe pin phải từ 0 đến 100%');
              }
              if (batteryCycleCount != null && batteryCycleCount < 0) {
                throw Exception('Số chu kỳ pin không được âm');
              }
              if (!enforceBatteryReturn) {
                fieldsToClear.add('batteryReturnMin');
              }
              if (condition == null) {
                fieldsToClear.add('condition');
              }
              if (batteryType == null) {
                fieldsToClear.add('batteryType');
              }
              if (batteryLastServicedAt == null) {
                fieldsToClear.add('batteryLastServicedAt');
              }

              final updateParams = UpdateVehicleParams(
                model: nameController.text.trim(),
                pricePerHour: double.tryParse(priceController.text.trim()),
                pricePerDay: pricePerDay,
                instantBook: instantBook,
                cancellationPolicy: cancellationPolicy,
                dailyKmLimit: dailyKmLimit,
                excessKmPrice: excessKmPrice,
                weeklyDiscount: weeklyDiscount,
                monthlyDiscount: monthlyDiscount,
                allowSmoke: allowSmoke,
                allowPets: allowPets,
                geoRestriction: geoRestriction,
                batteryReturnMin: enforceBatteryReturn
                    ? batteryReturnMin.round()
                    : null,
                firstRegistrationYear: firstRegistrationYear,
                condition: condition,
                batteryType: batteryType,
                batteryHealth: batteryHealth,
                batteryCycleCount: batteryCycleCount,
                batteryLastServicedAt: batteryLastServicedAt,
                description: descriptionController.text.trim(),
                images: finalImageUrls,
                fieldsToClear: fieldsToClear,
              );

              ownerVehicleBloc.add(
                UpdateVehicleDetails(
                  vehicleId: vehicle.id,
                  params: updateParams,
                ),
              );
              if (sheetContext.mounted) {
                Navigator.pop(sheetContext);
              }
            } catch (e) {
              ScaffoldMessenger.of(sheetContext).showSnackBar(
                SnackBar(
                  content: Text('Lỗi: $e'),
                  backgroundColor: AppColors.error,
                ),
              );
            } finally {
              if (sheetContext.mounted) {
                setSheetState(() => isUploading = false);
              }
            }
          }

          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
              left: 20,
              right: 20,
              top: 20,
            ),
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Thanh kéo trang trí
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Chỉnh sửa thông tin xe',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),

                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Tên dòng xe',
                        prefixIcon: const Icon(Icons.motorcycle),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (v) =>
                          v!.isEmpty ? 'Không được để trống' : null,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: priceController,
                      decoration: InputDecoration(
                        labelText: 'Giá thuê mỗi giờ',
                        prefixIcon: const Icon(Icons.payments_outlined),
                        suffixText: 'đ',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (v) {
                        final value = double.tryParse(v?.trim() ?? '');
                        if (value == null) return 'Vui lòng nhập giá';
                        if (value < 1000) return 'Giá tối thiểu 1.000đ';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: pricePerDayController,
                      decoration: InputDecoration(
                        labelText: 'Giá thuê mỗi ngày',
                        prefixIcon: const Icon(Icons.today_outlined),
                        suffixText: 'đ',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return null;
                        final value = double.tryParse(v.trim());
                        if (value == null) return 'Giá không hợp lệ';
                        if (value < 1000) return 'Giá tối thiểu 1.000đ';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Mô tả xe',
                        alignLabelWithHint: true,
                        prefixIcon: const Icon(Icons.description_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),

                    Text(
                      'Chính sách thuê',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      secondary: Icon(
                        Icons.flash_on,
                        color: instantBook
                            ? AppColors.primary
                            : AppColors.textMuted,
                      ),
                      title: Text(
                        'Đặt xe nhanh',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        'Tự động xác nhận booking khi khung giờ còn trống',
                        style: GoogleFonts.poppins(fontSize: 12),
                      ),
                      value: instantBook,
                      activeThumbColor: AppColors.primary,
                      onChanged: (value) =>
                          setSheetState(() => instantBook = value),
                    ),
                    const Divider(height: 24),
                    DropdownButtonFormField<CancellationPolicy>(
                      initialValue: cancellationPolicy,
                      decoration: InputDecoration(
                        labelText: 'Chính sách hủy của người thuê',
                        prefixIcon: const Icon(Icons.event_busy_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: CancellationPolicy.values
                          .map(
                            (value) => DropdownMenuItem(
                              value: value,
                              child: Text(value.displayName),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setSheetState(() => cancellationPolicy = value);
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    Text(
                      cancellationPolicy.summaryText,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const Divider(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: _buildPolicyNumberField(
                            controller: dailyKmLimitController,
                            label: 'Km/ngày',
                            hintText: 'Bỏ trống = không giới hạn',
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return null;
                              }
                              final parsed = int.tryParse(value.trim());
                              if (parsed == null || parsed < 1) {
                                return 'Tối thiểu 1';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildPolicyNumberField(
                            controller: excessKmPriceController,
                            label: 'Phí vượt/km',
                            hintText: 'VD: 3000',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildPolicyNumberField(
                            controller: weeklyDiscountController,
                            label: 'Giảm tuần (%)',
                            hintText: 'VD: 10',
                            validator: _discountValidator,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildPolicyNumberField(
                            controller: monthlyDiscountController,
                            label: 'Giảm tháng (%)',
                            hintText: 'VD: 20',
                            validator: _discountValidator,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: geoRestriction,
                      decoration: InputDecoration(
                        labelText: 'Phạm vi di chuyển',
                        prefixIcon: const Icon(Icons.map_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'no_restriction',
                          child: Text('Không giới hạn'),
                        ),
                        DropdownMenuItem(
                          value: 'city',
                          child: Text('Trong thành phố'),
                        ),
                        DropdownMenuItem(
                          value: 'district',
                          child: Text('Trong quận/huyện'),
                        ),
                        DropdownMenuItem(
                          value: 'province',
                          child: Text('Trong tỉnh/thành'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setSheetState(() => geoRestriction = value);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      secondary: Icon(
                        Icons.battery_saver,
                        color: enforceBatteryReturn
                            ? AppColors.primary
                            : AppColors.textMuted,
                      ),
                      title: Text(
                        'Yêu cầu pin tối thiểu khi trả',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        enforceBatteryReturn
                            ? '${batteryReturnMin.round()}%'
                            : 'Không áp dụng',
                        style: GoogleFonts.poppins(fontSize: 12),
                      ),
                      value: enforceBatteryReturn,
                      activeThumbColor: AppColors.primary,
                      onChanged: (value) =>
                          setSheetState(() => enforceBatteryReturn = value),
                    ),
                    if (enforceBatteryReturn)
                      Slider(
                        value: batteryReturnMin,
                        min: 0,
                        max: 100,
                        divisions: 20,
                        label: '${batteryReturnMin.round()}%',
                        onChanged: (value) =>
                            setSheetState(() => batteryReturnMin = value),
                      ),
                    const Divider(height: 24),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      secondary: Icon(
                        Icons.smoke_free,
                        color: allowSmoke
                            ? AppColors.primary
                            : AppColors.textMuted,
                      ),
                      title: Text(
                        'Cho phép hút thuốc',
                        style: GoogleFonts.poppins(fontSize: 14),
                      ),
                      value: allowSmoke,
                      activeThumbColor: AppColors.primary,
                      onChanged: (value) =>
                          setSheetState(() => allowSmoke = value),
                    ),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      secondary: Icon(
                        Icons.pets_outlined,
                        color: allowPets
                            ? AppColors.primary
                            : AppColors.textMuted,
                      ),
                      title: Text(
                        'Cho phép thú cưng',
                        style: GoogleFonts.poppins(fontSize: 14),
                      ),
                      value: allowPets,
                      activeThumbColor: AppColors.primary,
                      onChanged: (value) =>
                          setSheetState(() => allowPets = value),
                    ),
                    const SizedBox(height: 24),

                    Text(
                      'Tình trạng xe điện',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<VehicleCondition>(
                      initialValue: condition,
                      decoration: InputDecoration(
                        labelText: 'Tình trạng xe',
                        prefixIcon: const Icon(Icons.verified_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: VehicleCondition.values
                          .map(
                            (value) => DropdownMenuItem(
                              value: value,
                              child: Text(value.displayName),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setSheetState(() => condition = value),
                    ),
                    if (condition != null)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () =>
                              setSheetState(() => condition = null),
                          child: const Text('Xóa tình trạng'),
                        ),
                      ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<BatteryType>(
                      initialValue: batteryType,
                      decoration: InputDecoration(
                        labelText: 'Loại pin',
                        prefixIcon: const Icon(Icons.battery_unknown_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: BatteryType.values
                          .map(
                            (value) => DropdownMenuItem(
                              value: value,
                              child: Text(value.displayName),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setSheetState(() => batteryType = value),
                    ),
                    if (batteryType != null)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () =>
                              setSheetState(() => batteryType = null),
                          child: const Text('Xóa loại pin'),
                        ),
                      ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildPolicyNumberField(
                            controller: firstRegistrationYearController,
                            label: 'Năm đăng ký',
                            hintText: 'VD: 2023',
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return null;
                              }
                              final parsed = int.tryParse(value.trim());
                              final currentYear = DateTime.now().year;
                              if (parsed == null ||
                                  parsed < 2000 ||
                                  parsed > currentYear + 1) {
                                return '2000-${currentYear + 1}';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildPolicyNumberField(
                            controller: batteryHealthController,
                            label: 'Sức khỏe pin (%)',
                            hintText: 'VD: 92',
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return null;
                              }
                              final parsed = int.tryParse(value.trim());
                              if (parsed == null ||
                                  parsed < 0 ||
                                  parsed > 100) {
                                return '0-100';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildPolicyNumberField(
                      controller: batteryCycleCountController,
                      label: 'Số chu kỳ sạc',
                      hintText: 'VD: 180',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return null;
                        final parsed = int.tryParse(value.trim());
                        if (parsed == null || parsed < 0) return 'Không hợp lệ';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () async {
                        final now = DateTime.now();
                        final date = await showDatePicker(
                          context: sheetContext,
                          initialDate: batteryLastServicedAt ?? now,
                          firstDate: DateTime(2000),
                          lastDate: now,
                        );
                        if (date != null) {
                          setSheetState(() => batteryLastServicedAt = date);
                        }
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Ngày bảo dưỡng pin gần nhất',
                          prefixIcon: const Icon(Icons.build_circle_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                batteryLastServicedAt == null
                                    ? 'Chưa chọn'
                                    : _formatDate(batteryLastServicedAt!),
                                style: GoogleFonts.poppins(
                                  color: batteryLastServicedAt == null
                                      ? AppColors.textMuted
                                      : AppColors.textPrimary,
                                ),
                              ),
                            ),
                            if (batteryLastServicedAt != null)
                              IconButton(
                                onPressed: () => setSheetState(
                                  () => batteryLastServicedAt = null,
                                ),
                                icon: const Icon(Icons.close, size: 18),
                                color: AppColors.textMuted,
                                tooltip: 'Xóa ngày',
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    Text(
                      'Hình ảnh xe (${existingUrls.length + newImageBytes.length})',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 100,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          // Nút thêm ảnh mới
                          GestureDetector(
                            onTap: isUploading ? null : _pickImage,
                            child: _buildAddImageButton(),
                          ),
                          // Previews ảnh hiện tại từ Server (URL)
                          ...existingUrls.asMap().entries.map(
                            (entry) => _ImagePreview(
                              image: NetworkImage(entry.value),
                              onDelete: () => setSheetState(
                                () => existingUrls.removeAt(entry.key),
                              ),
                            ),
                          ),
                          // Previews ảnh mới vừa chọn từ thiết bị (Bytes)
                          ...newImageBytes.asMap().entries.map(
                            (entry) => _ImagePreview(
                              image: MemoryImage(entry.value),
                              onDelete: () => setSheetState(() {
                                newImageBytes.removeAt(entry.key);
                                newImageNames.removeAt(entry.key);
                              }),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isUploading ? null : _handleUpdate,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isUploading
                            ? const SpinKitThreeBounce(
                                color: Colors.white,
                                size: 20,
                              )
                            : const Text('Cập nhật thay đổi'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    ).whenComplete(() {
      nameController.dispose();
      priceController.dispose();
      pricePerDayController.dispose();
      dailyKmLimitController.dispose();
      excessKmPriceController.dispose();
      weeklyDiscountController.dispose();
      monthlyDiscountController.dispose();
      firstRegistrationYearController.dispose();
      batteryHealthController.dispose();
      batteryCycleCountController.dispose();
      descriptionController.dispose();
    });
  }

  int? _optionalInt(
    String value, {
    required String clearField,
    required Set<String> fieldsToClear,
  }) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      fieldsToClear.add(clearField);
      return null;
    }
    return int.tryParse(trimmed);
  }

  double? _optionalDouble(
    String value, {
    required String clearField,
    required Set<String> fieldsToClear,
  }) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      fieldsToClear.add(clearField);
      return null;
    }
    return double.tryParse(trimmed);
  }

  String? _discountValidator(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final parsed = double.tryParse(value.trim());
    if (parsed == null) return 'Không hợp lệ';
    if (parsed < 0 || parsed > 100) return '0-100%';
    return null;
  }

  Widget _buildPolicyNumberField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      validator: validator,
    );
  }

  // Widget phụ trợ để hiển thị preview ảnh với nút xóa
  Widget _buildAddImageButton() {
    return Container(
      width: 100,
      height: 100,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, style: BorderStyle.solid),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_a_photo_outlined, color: AppColors.primary),
          Text('Thêm ảnh', style: TextStyle(fontSize: 11)),
        ],
      ),
    );
  }

  String _formatPrice(double price) {
    return '${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}đ';
  }

  String _formatPercent(double value) {
    return value % 1 == 0 ? value.toStringAsFixed(0) : value.toStringAsFixed(1);
  }

  String _formatDateTime(DateTime value) {
    final twoDigits = (int number) => number.toString().padLeft(2, '0');
    return '${twoDigits(value.day)}/${twoDigits(value.month)}/${value.year} ${twoDigits(value.hour)}:${twoDigits(value.minute)}';
  }

  String _formatTime(DateTime value) {
    final twoDigits = (int number) => number.toString().padLeft(2, '0');
    return '${twoDigits(value.hour)}:${twoDigits(value.minute)}';
  }

  String _formatWallDate(DateTime value) {
    final twoDigits = (int number) => number.toString().padLeft(2, '0');
    return '${twoDigits(value.day)}/${twoDigits(value.month)}/${value.year}';
  }

  String _availabilityTimezoneLabel(VehicleAvailabilityWindowEntity window) {
    if (window.timezoneName == AvailabilityTimeZone.vietnamName) {
      return 'GMT+7';
    }
    return window.timezoneName ??
        'UTC${_offsetLabel(window.timezoneOffsetMinutes)}';
  }

  String _offsetLabel(int? minutes) {
    final offset = minutes ?? 0;
    final sign = offset >= 0 ? '+' : '-';
    final absolute = offset.abs();
    final hours = (absolute ~/ 60).toString().padLeft(2, '0');
    final remaining = (absolute % 60).toString().padLeft(2, '0');
    return '$sign$hours:$remaining';
  }

  String _weekdayLabel(int weekday) {
    return weekday == 7 ? 'CN' : 'T${weekday + 1}';
  }

  String _formatWeekdays(List<int> weekdays) {
    if (weekdays.length == 7) return 'Mỗi ngày';
    return weekdays.map(_weekdayLabel).join(', ');
  }

  String _formatDate(DateTime value) {
    final local = value.toLocal();
    final twoDigits = (int number) => number.toString().padLeft(2, '0');
    return '${twoDigits(local.day)}/${twoDigits(local.month)}/${local.year}';
  }

  String _geoRestrictionLabel(String value) {
    switch (value) {
      case 'city':
        return 'Trong thành phố';
      case 'district':
        return 'Trong quận/huyện';
      case 'province':
        return 'Trong tỉnh/thành';
      case 'no_restriction':
        return 'Không giới hạn';
      default:
        return value;
    }
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
    if (level > 80) return 'Pin đầy';
    if (level > 60) return 'Pin tốt';
    if (level > 40) return 'Pin trung bình';
    if (level > 20) return 'Pin yếu';
    return 'Cần sạc ngay';
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
