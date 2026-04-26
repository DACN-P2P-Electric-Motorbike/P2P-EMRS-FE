import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../domain/entities/vehicle_entity.dart';

class FilterBottomSheet extends StatefulWidget {
  final VehicleBrand? selectedBrand;
  final VehicleType? selectedType;
  final double? maxPrice;
  final int? minBatteryLevel;
  final List<VehicleFeature> selectedFeatures;
  final String sortBy;
  final DateTime? selectedStartTime;
  final DateTime? selectedEndTime;

  const FilterBottomSheet({
    super.key,
    this.selectedBrand,
    this.selectedType,
    this.maxPrice,
    this.minBatteryLevel,
    this.selectedFeatures = const [],
    this.sortBy = 'default',
    this.selectedStartTime,
    this.selectedEndTime,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late VehicleBrand? _selectedBrand;
  late VehicleType? _selectedType;
  late double _maxPrice;
  late int _minBatteryLevel;
  late List<VehicleFeature> _selectedFeatures;
  late String _sortBy;
  DateTime? _selectedStartTime;
  DateTime? _selectedEndTime;

  @override
  void initState() {
    super.initState();
    _selectedBrand = widget.selectedBrand;
    _selectedType = widget.selectedType;
    _maxPrice = widget.maxPrice ?? 100000;
    _minBatteryLevel = widget.minBatteryLevel ?? 0;
    _selectedFeatures = List.from(widget.selectedFeatures);
    _sortBy = widget.sortBy;
    _selectedStartTime = widget.selectedStartTime;
    _selectedEndTime = widget.selectedEndTime;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColors.border)),
                ),
                child: Row(
                  children: [
                    Text(
                      'Bộ lọc',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: _resetFilters,
                      child: const Text('Đặt lại'),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),

              // Filter content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Sort by
                    _buildSectionTitle('Sắp xếp theo'),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildChoiceChip(
                          'Mặc định',
                          _sortBy == 'default',
                          () => setState(() => _sortBy = 'default'),
                        ),
                        _buildChoiceChip(
                          'Giá thấp nhất',
                          _sortBy == 'price_low',
                          () => setState(() => _sortBy = 'price_low'),
                        ),
                        _buildChoiceChip(
                          'Giá cao nhất',
                          _sortBy == 'price_high',
                          () => setState(() => _sortBy = 'price_high'),
                        ),
                        _buildChoiceChip(
                          'Đánh giá cao',
                          _sortBy == 'rating',
                          () => setState(() => _sortBy = 'rating'),
                        ),
                        _buildChoiceChip(
                          'Gần nhất',
                          _sortBy == 'distance',
                          () => setState(() => _sortBy = 'distance'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Brand filter
                    _buildSectionTitle('Hãng xe'),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: VehicleBrand.values.map((brand) {
                        return _buildChoiceChip(
                          brand.displayName,
                          _selectedBrand == brand,
                          () {
                            setState(() {
                              _selectedBrand = _selectedBrand == brand
                                  ? null
                                  : brand;
                            });
                          },
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 24),

                    // Vehicle type filter
                    _buildSectionTitle('Loại xe'),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: VehicleType.values.map((type) {
                        return _buildChoiceChip(
                          type.displayName,
                          _selectedType == type,
                          () {
                            setState(() {
                              _selectedType = _selectedType == type
                                  ? null
                                  : type;
                            });
                          },
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 24),

                    // Desired rental time range
                    _buildSectionTitle('Khung giờ muốn thuê'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDateTimeCard(
                            label: 'Từ',
                            value: _selectedStartTime,
                            onTap: () => _pickDateTime(isStart: true),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildDateTimeCard(
                            label: 'Đến',
                            value: _selectedEndTime,
                            onTap: () => _pickDateTime(isStart: false),
                          ),
                        ),
                      ],
                    ),
                    if (_selectedStartTime != null || _selectedEndTime != null)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _selectedStartTime = null;
                              _selectedEndTime = null;
                            });
                          },
                          icon: const Icon(Icons.close, size: 16),
                          label: const Text('Xóa thời gian'),
                        ),
                      ),

                    const SizedBox(height: 24),

                    // Price filter
                    _buildSectionTitle('Giá tối đa (mỗi giờ)'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Slider(
                            value: _maxPrice,
                            min: 10000,
                            max: 100000,
                            divisions: 18,
                            label: '${_formatPrice(_maxPrice)}đ',
                            onChanged: (value) {
                              setState(() => _maxPrice = value);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${_formatPrice(_maxPrice)}đ',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Battery level filter
                    _buildSectionTitle('Pin tối thiểu'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Slider(
                            value: _minBatteryLevel.toDouble(),
                            min: 0,
                            max: 100,
                            divisions: 10,
                            label: '$_minBatteryLevel%',
                            onChanged: (value) {
                              setState(() => _minBatteryLevel = value.toInt());
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '$_minBatteryLevel%',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              color: AppColors.success,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Features filter
                    _buildSectionTitle('Tính năng'),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: VehicleFeature.values.map((feature) {
                        final isSelected = _selectedFeatures.contains(feature);
                        return _buildChoiceChip(
                          feature.displayName,
                          isSelected,
                          () {
                            setState(() {
                              if (isSelected) {
                                _selectedFeatures.remove(feature);
                              } else {
                                _selectedFeatures.add(feature);
                              }
                            });
                          },
                          icon: _getFeatureIcon(feature),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),

              // Apply button
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: AppColors.border)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _applyFilters,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Áp dụng',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
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

  Widget _buildChoiceChip(
    String label,
    bool isSelected,
    VoidCallback onTap, {
    IconData? icon,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _resetFilters() {
    setState(() {
      _selectedBrand = null;
      _selectedType = null;
      _maxPrice = 100000;
      _minBatteryLevel = 0;
      _selectedFeatures.clear();
      _sortBy = 'default';
      _selectedStartTime = null;
      _selectedEndTime = null;
    });
  }

  void _applyFilters() {
    if ((_selectedStartTime == null) != (_selectedEndTime == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn đủ cả thời gian bắt đầu và kết thúc.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_selectedStartTime != null &&
        _selectedEndTime != null &&
        !_selectedEndTime!.isAfter(_selectedStartTime!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thời gian kết thúc phải sau thời gian bắt đầu.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    Navigator.pop(context, {
      'brand': _selectedBrand,
      'type': _selectedType,
      'maxPrice': _maxPrice == 100000 ? null : _maxPrice,
      'minBatteryLevel': _minBatteryLevel == 0 ? null : _minBatteryLevel,
      'features': _selectedFeatures,
      'sortBy': _sortBy,
      'startTime': _selectedStartTime,
      'endTime': _selectedEndTime,
    });
  }

  Widget _buildDateTimeCard({
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
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
            const SizedBox(height: 6),
            Text(
              value == null ? 'Chọn ngày giờ' : _formatDateTime(value),
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: value == null
                    ? AppColors.textMuted
                    : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDateTime({required bool isStart}) async {
    final now = DateTime.now();
    final initial = isStart
        ? (_selectedStartTime ?? now.add(const Duration(hours: 1)))
        : (_selectedEndTime ??
              (_selectedStartTime?.add(const Duration(hours: 2)) ??
                  now.add(const Duration(hours: 2))));

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (pickedDate == null) return;
    if (!mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (pickedTime == null) return;

    final selected = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    if (!mounted) return;
    setState(() {
      if (isStart) {
        _selectedStartTime = selected;
        if (_selectedEndTime != null && !_selectedEndTime!.isAfter(selected)) {
          _selectedEndTime = selected.add(const Duration(hours: 1));
        }
      } else {
        _selectedEndTime = selected;
      }
    });
  }

  String _formatDateTime(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final year = value.year;
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }

  String _formatPrice(double price) {
    return price
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
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
