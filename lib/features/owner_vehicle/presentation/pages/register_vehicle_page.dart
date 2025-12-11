import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../injection_container.dart';
import '../../data/models/create_vehicle_params.dart';
import '../../domain/entities/vehicle_entity.dart';
import '../bloc/owner_vehicle_bloc.dart';

/// Page for registering a new vehicle
class RegisterVehiclePage extends StatelessWidget {
  const RegisterVehiclePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<OwnerVehicleBloc>(),
      child: const _RegisterVehicleContent(),
    );
  }
}

class _RegisterVehicleContent extends StatefulWidget {
  const _RegisterVehicleContent();

  @override
  State<_RegisterVehicleContent> createState() => _RegisterVehicleContentState();
}

class _RegisterVehicleContentState extends State<_RegisterVehicleContent> {
  final _formKey = GlobalKey<FormState>();
  final _licensePlateController = TextEditingController();
  final _modelController = TextEditingController();
  final _priceController = TextEditingController();
  final _addressController = TextEditingController();
  final _descriptionController = TextEditingController();

  VehicleType _selectedType = VehicleType.vinfastKlara;
  final List<String> _mockImages = [];

  @override
  void dispose() {
    _licensePlateController.dispose();
    _modelController.dispose();
    _priceController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      final params = CreateVehicleParams(
        licensePlate: _licensePlateController.text.trim().toUpperCase(),
        model: _modelController.text.trim(),
        type: _selectedType,
        pricePerHour: double.parse(_priceController.text.trim()),
        address: _addressController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        images: _mockImages.isEmpty
            ? ['https://via.placeholder.com/400x300?text=Vehicle+Image']
            : _mockImages,
      );

      context.read<OwnerVehicleBloc>().add(RegisterVehicleSubmit(params: params));
    }
  }

  void _addMockImage() {
    setState(() {
      _mockImages.add(
        'https://via.placeholder.com/400x300?text=Image+${_mockImages.length + 1}',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OwnerVehicleBloc, OwnerVehicleState>(
      listener: (context, state) {
        if (state.status == OwnerVehicleStatus.registered) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage ?? 'Vehicle registered!'),
              backgroundColor: AppColors.success,
            ),
          );
          context.pop();
        } else if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state.status == OwnerVehicleStatus.registering;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () => context.pop(),
            ),
            title: Text(
              'Register Vehicle',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.info.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppColors.info,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Your vehicle will be reviewed by our team before it becomes available for rent.',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: AppColors.info,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Section: Basic Info
                  _buildSectionTitle('Basic Information'),
                  const SizedBox(height: 16),

                  // License Plate
                  _buildTextField(
                    controller: _licensePlateController,
                    label: 'License Plate',
                    hint: 'e.g., 59A-12345',
                    prefixIcon: Icons.badge_outlined,
                    enabled: !isLoading,
                    textCapitalization: TextCapitalization.characters,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9A-Za-z-]')),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'License plate is required';
                      }
                      if (!RegExp(r'^[0-9]{2}[A-Z]-[0-9]{4,5}$')
                          .hasMatch(value.toUpperCase())) {
                        return 'Format: 59A-12345';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Model
                  _buildTextField(
                    controller: _modelController,
                    label: 'Model Name',
                    hint: 'e.g., VinFast Klara S',
                    prefixIcon: Icons.electric_moped_outlined,
                    enabled: !isLoading,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Model name is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Vehicle Type Dropdown
                  _buildDropdownField(
                    label: 'Vehicle Type',
                    value: _selectedType,
                    items: VehicleType.values,
                    enabled: !isLoading,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedType = value;
                          if (value != VehicleType.other) {
                            _modelController.text = value.displayName;
                          }
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 24),

                  // Section: Pricing & Location
                  _buildSectionTitle('Pricing & Location'),
                  const SizedBox(height: 16),

                  // Price per hour
                  _buildTextField(
                    controller: _priceController,
                    label: 'Price per Hour (VND)',
                    hint: 'e.g., 25000',
                    prefixIcon: Icons.monetization_on_outlined,
                    keyboardType: TextInputType.number,
                    enabled: !isLoading,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Price is required';
                      }
                      final price = double.tryParse(value);
                      if (price == null || price < 1000) {
                        return 'Minimum price is 1,000 VND';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Address
                  _buildTextField(
                    controller: _addressController,
                    label: 'Pickup Address',
                    hint: 'e.g., 123 Nguyen Trai, Quan 1, TP.HCM',
                    prefixIcon: Icons.location_on_outlined,
                    enabled: !isLoading,
                    maxLines: 2,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Address is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Section: Description & Images
                  _buildSectionTitle('Description & Images'),
                  const SizedBox(height: 16),

                  // Description
                  _buildTextField(
                    controller: _descriptionController,
                    label: 'Description (Optional)',
                    hint: 'Describe your vehicle condition, features, etc.',
                    prefixIcon: Icons.description_outlined,
                    enabled: !isLoading,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 16),

                  // Images section
                  _buildImagePicker(),
                  const SizedBox(height: 32),

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _onSubmit,
                      child: isLoading
                          ? const SpinKitThreeBounce(
                              color: Colors.white,
                              size: 20,
                            )
                          : Text(
                              'Register Vehicle',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    IconData? prefixIcon,
    bool enabled = true,
    int maxLines = 1,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      maxLines: maxLines,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      inputFormatters: inputFormatters,
      validator: validator,
      style: GoogleFonts.poppins(
        fontSize: 15,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: AppColors.primary)
            : null,
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required VehicleType value,
    required List<VehicleType> items,
    required bool enabled,
    required void Function(VehicleType?) onChanged,
  }) {
    return DropdownButtonFormField<VehicleType>(
      value: value,
      onChanged: enabled ? onChanged : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(Icons.category_outlined, color: AppColors.primary),
      ),
      style: GoogleFonts.poppins(
        fontSize: 15,
        color: AppColors.textPrimary,
      ),
      items: items.map((type) {
        return DropdownMenuItem(
          value: type,
          child: Text(type.displayName),
        );
      }).toList(),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.photo_library_outlined, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              'Vehicle Images',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              // Add image button
              GestureDetector(
                onTap: _addMockImage,
                child: Container(
                  width: 100,
                  height: 100,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: AppColors.inputBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.border,
                      width: 2,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_a_photo_outlined,
                        color: AppColors.primary,
                        size: 32,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Add Photo',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Image previews
              ..._mockImages.asMap().entries.map((entry) {
                return Container(
                  width: 100,
                  height: 100,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: NetworkImage(entry.value),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _mockImages.removeAt(entry.key);
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.error,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '* At least one image is required',
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}

