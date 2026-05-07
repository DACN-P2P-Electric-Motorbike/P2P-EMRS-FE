import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/utils/open_external_map.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/vehicle_entity.dart';
import '../bloc/owner_vehicle_bloc.dart';
import '../../data/models/update_vehicle_params.dart';
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

                      // Battery Level
                      _buildBatterySection(vehicle),

                      const SizedBox(height: 20),

                      // Features
                      if (vehicle.features.isNotEmpty) ...[
                        _buildFeaturesSection(vehicle),
                        const SizedBox(height: 20),
                      ],

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
          // Availability Toggle - Main feature
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sẵn sàng cho thuê',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isAvailable
                          ? 'Xe đang hiển thị cho người thuê'
                          : 'Xe đang ẩn khỏi danh sách',
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
    // 1. Khởi tạo các Controller với dữ liệu hiện tại
    final nameController = TextEditingController(text: vehicle.model);
    final priceController = TextEditingController(
      text: vehicle.pricePerHour.toString(),
    );
    final descriptionController = TextEditingController(
      text: vehicle.description,
    );
    final formKey = GlobalKey<FormState>();

    // 2. Quản lý danh sách ảnh: Tách biệt ảnh cũ (URL) và ảnh mới (Bytes)
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
          bool isUploading = false; // Trạng thái loading riêng trong popup

          // Hàm chọn ảnh từ thiết bị (Logic từ file register_vehicle_page)
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

          // Hàm xử lý tổng hợp: Upload ảnh mới -> Gộp URL -> Cập nhật API
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

              // Bước 2: Tạo Params và gửi event cập nhật cho Bloc
              final updateParams = UpdateVehicleParams(
                model: nameController.text.trim(),
                pricePerHour: double.tryParse(priceController.text.trim()),
                description: descriptionController.text.trim(),
                images:
                    finalImageUrls, // Danh sách bao gồm URL cũ giữ lại và URL mới vừa upload
              );

              // if (context.mounted) {
              //   context.read<OwnerVehicleBloc>().add(
              //     UpdateVehicleDetails(
              //       vehicleId: vehicle.id,
              //       params: updateParams,
              //     ),
              //   );
              //   Navigator.pop(sheetContext);
              // }

              // 2. SỬ DỤNG BIẾN ownerVehicleBloc ĐÃ LẤY Ở TRÊN
              // Không dùng context.read ở đây nữa vì context này là sheetContext
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
              // Hiển thị lỗi dùng context của Sheet
              ScaffoldMessenger.of(sheetContext).showSnackBar(
                SnackBar(
                  content: Text('Lỗi: $e'),
                  backgroundColor: AppColors.error,
                ),
              );
            } finally {
              setSheetState(() => isUploading = false);
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

                    // Nhập Tên Model
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

                    // Nhập Giá thuê
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
                      validator: (v) => v!.isEmpty ? 'Vui lòng nhập giá' : null,
                    ),
                    const SizedBox(height: 16),

                    // Nhập Mô tả
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

                    // QUẢN LÝ HÌNH ẢNH
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

                    // Nút hành động chính
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
