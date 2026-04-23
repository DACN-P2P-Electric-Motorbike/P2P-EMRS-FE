import 'dart:typed_data';

import 'package:fe_capstone_project/core/storage/storage_service.dart';
import 'package:fe_capstone_project/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fe_capstone_project/features/auth/presentation/bloc/auth_event.dart';
import 'package:fe_capstone_project/features/renter/presentation/bloc/become_owner_cubiit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';

import 'package:latlong2/latlong.dart' as latlong2;

import '../../../../core/services/geocoding_service.dart';
import '../../../../core/services/upload_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/location_picker_page.dart';
import '../../../../injection_container.dart';
import '../../data/models/create_vehicle_params.dart';
import '../../domain/entities/vehicle_entity.dart';
import '../bloc/owner_vehicle_bloc.dart';

/// Multi-step Bike Registration Page
class BikeRegistrationPage extends StatelessWidget {
  final bool isBecomeOwnerFlow;
  const BikeRegistrationPage({super.key, this.isBecomeOwnerFlow = false});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<OwnerVehicleBloc>()),
        if (isBecomeOwnerFlow)
          BlocProvider(create: (_) => sl<BecomeOwnerCubit>()),
      ],
      child: _BikeRegistrationContent(isBecomeOwnerFlow: isBecomeOwnerFlow),
    );
  }
}

class _BikeRegistrationContent extends StatefulWidget {
  final bool isBecomeOwnerFlow;
  const _BikeRegistrationContent({this.isBecomeOwnerFlow = false});

  @override
  State<_BikeRegistrationContent> createState() =>
      _BikeRegistrationContentState();
}

class _BikeRegistrationContentState extends State<_BikeRegistrationContent> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 3;

  // Step 1: Basic Info
  final _modelController = TextEditingController();
  final _licensePlateController = TextEditingController();
  VehicleBrand? _selectedBrand;
  final List<VehicleFeature> _selectedFeatures = [];
  String? _vehicleImageName;
  Uint8List? _vehicleImageBytes;
  String? _vehicleImageUrl; // S3 URL after upload

  // Step 2: Supporting Documents
  final _licenseNumberController = TextEditingController();
  String? _licenseFrontName;
  Uint8List? _licenseFrontBytes;
  String? _licenseFrontUrl; // S3 URL after upload
  String? _licenseBackName;
  Uint8List? _licenseBackBytes;
  String? _licenseBackUrl; // S3 URL after upload

  // Upload state
  bool _isUploading = false;
  String? _uploadError;

  // Step 3: Pricing & Location
  final _pricePerDayController = TextEditingController();
  final _addressController = TextEditingController();
  double? _pickedLatitude;
  double? _pickedLongitude;

  @override
  void dispose() {
    _pageController.dispose();
    _modelController.dispose();
    _licensePlateController.dispose();
    _licenseNumberController.dispose();
    _pricePerDayController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _submitRegistration();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      context.pop();
    }
  }

  Future<void> _submitRegistration() async {
    // Validate required fields
    if (_selectedBrand == null) {
      _showError('Vui lòng chọn hãng xe');
      return;
    }
    if (_modelController.text.isEmpty) {
      _showError('Vui lòng nhập tên model');
      return;
    }
    if (_licensePlateController.text.isEmpty) {
      _showError('Vui lòng nhập biển số xe');
      return;
    }
    if (_pricePerDayController.text.isEmpty) {
      _showError('Vui lòng nhập giá thuê');
      return;
    }

    final pricePerDay = double.tryParse(_pricePerDayController.text) ?? 0;
    if (pricePerDay < 1000) {
      _showError('Giá thuê tối thiểu là 1.000 VND/ngày');
      return;
    }

    // Upload images first if there are any to upload
    if (_vehicleImageBytes != null ||
        _licenseFrontBytes != null ||
        _licenseBackBytes != null) {
      final uploadSuccess = await _uploadAllImages();
      if (!uploadSuccess) {
        _showError(
          _uploadError ?? 'Tải lên ảnh thất bại. Vui lòng thử lại.',
        );
        return;
      }
    }

    final params = CreateVehicleParams(
      licensePlate: _licensePlateController.text.trim().toUpperCase(),
      model: _modelController.text.trim(),
      brand: _selectedBrand!,
      type: VehicleType.other,
      features: _selectedFeatures,
      pricePerHour: pricePerDay / 24,
      pricePerDay: pricePerDay,
      address: _addressController.text.isNotEmpty
          ? _addressController.text.trim()
          : 'Ho Chi Minh City',
      latitude: _pickedLatitude,
      longitude: _pickedLongitude,
      description: null,
      images: _vehicleImageUrl != null
          ? [_vehicleImageUrl!]
          : ['https://via.placeholder.com/400x300?text=No+Image'],
      licenseNumber: _licenseNumberController.text.trim(),
      licenseFront: _licenseFrontUrl,
      licenseBack: _licenseBackUrl,
    );

    if (!mounted) return;
    if (widget.isBecomeOwnerFlow) {
      // Become owner flow
      context.read<BecomeOwnerCubit>().submitBecomeOwner(params);
    } else {
      // Normal register vehicle flow
      context.read<OwnerVehicleBloc>().add(
        RegisterVehicleSubmit(params: params),
      );
    }
  }

  Future<void> _openLocationPicker(BuildContext context) async {
    // Pre-populate picker with whatever the user typed in the address field
    final currentAddress = _addressController.text.trim();
    final result = await Navigator.push<LocationPickerResult>(
      context,
      MaterialPageRoute(
        builder: (_) => LocationPickerPage(
          initialAddress: currentAddress.isNotEmpty ? currentAddress : null,
          initialLatLng: (_pickedLatitude != null && _pickedLongitude != null)
              ? latlong2.LatLng(_pickedLatitude!, _pickedLongitude!)
              : null,
        ),
      ),
    );
    if (result != null && mounted) {
      setState(() {
        _pickedLatitude = result.latitude;
        _pickedLongitude = result.longitude;
        // Overwrite the text field only when the address differs
        if (result.address.isNotEmpty) {
          _addressController.text = result.address;
        }
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  size: 60,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Registration Successful!',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your bike has been submitted for review. You will be notified once approved.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    context.go('/owner');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Done',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // ============================================
        // Listener 1: OwnerVehicleBloc (normal flow)
        // ============================================
        BlocListener<OwnerVehicleBloc, OwnerVehicleState>(
          listener: (context, state) {
            // Only handle if NOT become owner flow
            if (!widget.isBecomeOwnerFlow) {
              if (state.status == OwnerVehicleStatus.registered) {
                _showSuccessDialog();
              } else if (state.errorMessage != null) {
                _showError(state.errorMessage!);
              }
            }
          },
        ),

        // ============================================
        // Listener 2: BecomeOwnerCubit (become owner flow)
        // Only add this listener if isBecomeOwnerFlow = true
        // ============================================
        if (widget.isBecomeOwnerFlow)
          BlocListener<BecomeOwnerCubit, BecomeOwnerState>(
            listener: (context, state) async {
              if (state is BecomeOwnerSuccess) {
                try {
                  // 1. Save new token
                  await sl<StorageService>().saveToken(
                    state.response.accessToken,
                  );

                  // 2. Refresh auth to update roles
                  if (context.mounted) {
                    context.read<AuthBloc>().add(const AuthCheckRequested());
                  }

                  // 3. Wait for auth to update
                  await Future.delayed(const Duration(milliseconds: 500));

                  // 4. Show success & navigate
                  if (context.mounted) {
                    _showSuccessDialog();
                  }
                } catch (e) {
                  if (context.mounted) {
                    _showError('Failed to update auth: $e');
                  }
                }
              } else if (state is BecomeOwnerError) {
                _showError(state.message);
              }
            },
          ),
      ],
      child: BlocBuilder<OwnerVehicleBloc, OwnerVehicleState>(
        builder: (context, state) {
          final isLoading =
              state.status == OwnerVehicleStatus.registering || _isUploading;

          return Scaffold(
            backgroundColor: const Color(0xFFF8F9FD),
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: AppColors.textPrimary,
                ),
                onPressed: _previousStep,
              ),
              title: Text(
                'Đăng ký xe',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              centerTitle: true,
            ),
            body: Column(
              children: [
                // Step Indicator
                _buildStepIndicator(),

                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildStep1BasicInfo(),
                      _buildStep2Documents(),
                      _buildStep3Availability(),
                    ],
                  ),
                ),

                // Next Button
                Container(
                  padding: const EdgeInsets.all(20),
                  color: Colors.white,
                  child: SafeArea(
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _nextStep,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: isLoading
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SpinKitThreeBounce(
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  if (_isUploading) ...[
                                    const SizedBox(width: 8),
                                    Text(
                                      'Đang tải lên...',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ],
                              )
                            : Text(
                                _currentStep == _totalSteps - 1
                                    ? 'Đăng ký'
                                    : 'Tiếp theo',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          for (int i = 0; i < _totalSteps; i++) ...[
            _StepCircle(
              index: i,
              currentStep: _currentStep,
            ),
            if (i < _totalSteps - 1)
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 2,
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    color: i < _currentStep
                        ? AppColors.primary
                        : AppColors.border,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  /// Step 1: Basic Vehicle Information
  Widget _buildStep1BasicInfo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Upload Vehicle Image
          _buildImageUploadCard(),
          const SizedBox(height: 24),

          // Model Brand Dropdown
          _buildLabel('Hãng xe *'),
          _buildDropdown<VehicleBrand>(
            hint: 'Chọn hãng xe',
            value: _selectedBrand,
            items: VehicleBrand.values,
            itemLabel: (brand) => brand.displayName,
            onChanged: (value) => setState(() => _selectedBrand = value),
          ),
          const SizedBox(height: 20),

          // Additional Features
          _buildLabel('Tính năng bổ sung'),
          _buildMultiSelectDropdown(),
          const SizedBox(height: 20),

          // Model Name
          _buildLabel('Tên model *'),
          _buildTextField(
            controller: _modelController,
            hintText: 'VD: VinFast Evo200',
          ),
          const SizedBox(height: 20),

          // Number Plate
          _buildLabel('Biển số xe *'),
          _buildTextField(
            controller: _licensePlateController,
            hintText: 'VD: 59A-12345',
            textCapitalization: TextCapitalization.characters,
          ),
        ],
      ),
    );
  }

  /// Step 2: Supporting Documents
  Widget _buildStep2Documents() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Giấy tờ xe',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tải lên các giấy tờ đăng ký xe của bạn',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),

          // License Number
          _buildLabel('Số đăng ký xe'),
          _buildTextField(
            controller: _licenseNumberController,
            hintText: 'Nhập số đăng ký xe',
          ),
          const SizedBox(height: 20),

          // License Photos (Front & Back)
          Text(
            'Ảnh giấy đăng ký xe',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDocUploadCard(
                  label: 'Mặt trước',
                  fileName: _licenseFrontName,
                  isFront: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDocUploadCard(
                  label: 'Mặt sau',
                  fileName: _licenseBackName,
                  isFront: false,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Info box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.info.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.info),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Giấy tờ giúp xác minh quyền sở hữu xe của bạn. Bước này tùy chọn nhưng được khuyến khích.',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.info,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Step 3: Pricing & Location (removed available time - availability controlled by toggle)
  Widget _buildStep3Availability() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Giá thuê & Địa điểm',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sau khi đăng ký, bạn có thể bật/tắt cho thuê xe bất cứ lúc nào từ trang quản lý.',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),

          // Rental Fee
          _buildLabel('Giá thuê (VND/ngày) *'),
          Container(
            decoration: BoxDecoration(
              color: AppColors.inputBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  child: Text(
                    '₫',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _pricePerDayController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: GoogleFonts.poppins(fontSize: 16),
                    decoration: InputDecoration(
                      hintText: 'VD: 150000',
                      hintStyle: GoogleFonts.poppins(
                        color: AppColors.textMuted,
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Text(
                    '/ngày',
                    style: GoogleFonts.poppins(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Gợi ý: 100,000 - 300,000 VND/ngày',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 24),

          // Pickup Address
          _buildLabel('Địa chỉ nhận xe *'),
          _buildTextField(
            controller: _addressController,
            hintText: 'VD: 123 Nguyễn Huệ, Quận 1, TP.HCM',
          ),
          const SizedBox(height: 8),
          // Map location picker button
          OutlinedButton.icon(
            onPressed: () => _openLocationPicker(context),
            icon: Icon(
              _pickedLatitude != null
                  ? Icons.edit_location_alt_outlined
                  : Icons.map_outlined,
              size: 18,
            ),
            label: Text(
              _pickedLatitude != null
                  ? 'Đã chọn vị trí trên bản đồ  ✓'
                  : 'Chọn vị trí chính xác trên bản đồ',
              style: GoogleFonts.poppins(fontSize: 13),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: _pickedLatitude != null
                  ? AppColors.success
                  : AppColors.primary,
              side: BorderSide(
                color: _pickedLatitude != null
                    ? AppColors.success
                    : AppColors.primary,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Info box about availability toggle
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.info.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb_outline, color: AppColors.info, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cách quản lý cho thuê xe',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.info,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '• Bật "Sẵn sàng cho thuê" = xe hiển thị cho người thuê\n'
                        '• Tắt khi bạn không muốn cho thuê nữa',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: AppColors.info,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Summary Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tóm tắt',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 12),
                _buildSummaryRow('Hãng xe', _selectedBrand?.displayName ?? '-'),
                _buildSummaryRow(
                  'Model',
                  _modelController.text.isEmpty ? '-' : _modelController.text,
                ),
                _buildSummaryRow(
                  'Biển số',
                  _licensePlateController.text.isEmpty
                      ? '-'
                      : _licensePlateController.text,
                ),
                _buildSummaryRow(
                  'Giá thuê',
                  _pricePerDayController.text.isEmpty
                      ? '-'
                      : '${_formatNumber(int.tryParse(_pricePerDayController.text) ?? 0)} VND/ngày',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickVehicleImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true, // Important: get file bytes
    );

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      if (file.bytes != null) {
        setState(() {
          _vehicleImageName = file.name;
          _vehicleImageBytes = file.bytes;
          _vehicleImageUrl = null; // Reset URL when new file is picked
        });
      }
    }
  }

  Widget _buildImageUploadCard() {
    return GestureDetector(
      onTap: _pickVehicleImage,
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.border,
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: _vehicleImageName != null
            ? Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: AppColors.primary.withOpacity(0.1),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.two_wheeler,
                            size: 60,
                            color: AppColors.primary,
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              _vehicleImageName!,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: AppColors.textPrimary,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => setState(() {
                        _vehicleImageName = null;
                        _vehicleImageBytes = null;
                        _vehicleImageUrl = null;
                      }),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 48,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Nhấn để tải ảnh xe lên',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'JPG, PNG (max 5MB)',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _pickLicenseImage(bool isFront) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true, // Important: get file bytes
    );

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      if (file.bytes != null) {
        setState(() {
          if (isFront) {
            _licenseFrontName = file.name;
            _licenseFrontBytes = file.bytes;
            _licenseFrontUrl = null; // Reset URL when new file is picked
          } else {
            _licenseBackName = file.name;
            _licenseBackBytes = file.bytes;
            _licenseBackUrl = null; // Reset URL when new file is picked
          }
        });
      }
    }
  }

  /// Upload all images to S3 before submitting the vehicle
  Future<bool> _uploadAllImages() async {
    setState(() {
      _isUploading = true;
      _uploadError = null;
    });

    try {
      final uploadService = sl<UploadService>();

      // Upload vehicle image if exists
      if (_vehicleImageBytes != null && _vehicleImageName != null) {
        final result = await uploadService.uploadVehicleImage(
          fileBytes: _vehicleImageBytes!,
          fileName: _vehicleImageName!,
        );
        _vehicleImageUrl = result.url;
      }

      // Upload license front if exists
      if (_licenseFrontBytes != null && _licenseFrontName != null) {
        final result = await uploadService.uploadLicenseImage(
          fileBytes: _licenseFrontBytes!,
          fileName: _licenseFrontName!,
        );
        _licenseFrontUrl = result.url;
      }

      // Upload license back if exists
      if (_licenseBackBytes != null && _licenseBackName != null) {
        final result = await uploadService.uploadLicenseImage(
          fileBytes: _licenseBackBytes!,
          fileName: _licenseBackName!,
        );
        _licenseBackUrl = result.url;
      }

      setState(() {
        _isUploading = false;
      });
      return true;
    } catch (e) {
      setState(() {
        _isUploading = false;
        _uploadError = e.toString();
      });
      return false;
    }
  }

  Widget _buildDocUploadCard({
    required String label,
    required String? fileName,
    required bool isFront,
  }) {
    final isUploaded = fileName != null;
    return GestureDetector(
      onTap: () => _pickLicenseImage(isFront),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: isUploaded
              ? AppColors.success.withOpacity(0.1)
              : AppColors.inputBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isUploaded ? AppColors.success : AppColors.border,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isUploaded
                        ? Icons.check_circle
                        : Icons.add_a_photo_outlined,
                    size: 32,
                    color: isUploaded ? AppColors.success : AppColors.textMuted,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: isUploaded
                          ? AppColors.success
                          : AppColors.textSecondary,
                      fontWeight: isUploaded
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                  if (isUploaded) ...[
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        fileName!,
                        style: GoogleFonts.poppins(
                          fontSize: 9,
                          color: AppColors.success,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (isUploaded)
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isFront) {
                        _licenseFrontName = null;
                        _licenseFrontBytes = null;
                        _licenseFrontUrl = null;
                      } else {
                        _licenseBackName = null;
                        _licenseBackBytes = null;
                        _licenseBackUrl = null;
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        textCapitalization: textCapitalization,
        style: GoogleFonts.poppins(fontSize: 14),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.poppins(
            color: AppColors.textMuted,
            fontSize: 14,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String hint,
    required T? value,
    required List<T> items,
    required String Function(T) itemLabel,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonFormField<T>(
        value: value,
        hint: Text(
          hint,
          style: GoogleFonts.poppins(color: AppColors.textMuted, fontSize: 14),
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16),
        ),
        items: items.map((item) {
          return DropdownMenuItem<T>(
            value: item,
            child: Text(
              itemLabel(item),
              style: GoogleFonts.poppins(fontSize: 14),
            ),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  /// Format number with thousand separators
  String _formatNumber(int number) {
    final str = number.toString();
    final result = StringBuffer();
    for (var i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        result.write(',');
      }
      result.write(str[i]);
    }
    return result.toString();
  }

  Widget _buildMultiSelectDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        title: Text(
          _selectedFeatures.isEmpty
              ? 'Chọn tính năng (tùy chọn)'
              : _selectedFeatures.map((f) => f.displayName).join(', '),
          style: GoogleFonts.poppins(
            color: _selectedFeatures.isEmpty
                ? AppColors.textMuted
                : AppColors.textPrimary,
            fontSize: 14,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        children: VehicleFeature.values.map((feature) {
          final isSelected = _selectedFeatures.contains(feature);
          return ListTile(
            title: Text(
              feature.displayName,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            trailing: isSelected
                ? Icon(Icons.check, color: AppColors.primary)
                : null,
            onTap: () {
              setState(() {
                if (isSelected) {
                  _selectedFeatures.remove(feature);
                } else {
                  _selectedFeatures.add(feature);
                }
              });
            },
          );
        }).toList(),
      ),
    );
  }
}

class _StepCircle extends StatelessWidget {
  final int index;
  final int currentStep;

  const _StepCircle({required this.index, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    final isCompleted = index < currentStep;
    final isActive = index == currentStep;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isCompleted || isActive ? AppColors.primary : AppColors.border,
        shape: BoxShape.circle,
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.35),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Center(
        child: isCompleted
            ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
            : Text(
                '${index + 1}',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isActive ? Colors.white : AppColors.textMuted,
                ),
              ),
      ),
    );
  }
}
