import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../injection_container.dart';
import '../../domain/entities/vehicle_entity.dart';
import '../bloc/vehicles_list_cubit.dart';
import '../widgets/vehicle_card.dart';
import '../widgets/filter_bottom_sheet.dart';

class VehicleListPage extends StatelessWidget {
  const VehicleListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<VehicleListCubit>()..loadVehicles(),
      child: const _VehicleListView(),
    );
  }
}

class _VehicleListView extends StatefulWidget {
  const _VehicleListView();

  @override
  State<_VehicleListView> createState() => _VehicleListViewState();
}

class _VehicleListViewState extends State<_VehicleListView> {
  final _searchController = TextEditingController();
  List<VehicleEntity> _allVehicles = [];

  // Filter states
  VehicleBrand? _selectedBrand;
  VehicleType? _selectedType;
  double? _maxPrice;
  int? _minBatteryLevel;
  List<VehicleFeature> _selectedFeatures = [];
  String _sortBy = 'default'; // default, price_low, price_high, rating

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    if (_allVehicles.isEmpty) return;

    context.read<VehicleListCubit>().filterVehicles(
      _allVehicles,
      searchQuery: _searchController.text.trim().isEmpty
          ? null
          : _searchController.text.trim(),
      maxPrice: _maxPrice,
      brand: _selectedBrand,
      type: _selectedType,
      minBatteryLevel: _minBatteryLevel,
      features: _selectedFeatures.isEmpty ? null : _selectedFeatures,
      sortBy: _sortBy,
    );
  }

  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _selectedBrand = null;
      _selectedType = null;
      _maxPrice = null;
      _minBatteryLevel = null;
      _selectedFeatures = [];
      _sortBy = 'default';
    });

    if (_allVehicles.isNotEmpty) {
      context.read<VehicleListCubit>().filterVehicles(_allVehicles);
    }
  }

  bool get _hasActiveFilters {
    return _selectedBrand != null ||
        _selectedType != null ||
        _maxPrice != null ||
        _minBatteryLevel != null ||
        _selectedFeatures.isNotEmpty ||
        _sortBy != 'default' ||
        _searchController.text.trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => context.pop(),
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Text(
                        'Xe có sẵn',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      if (_hasActiveFilters)
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          child: IconButton(
                            onPressed: _resetFilters,
                            icon: const Icon(Icons.clear_all),
                            color: Colors.white,
                            tooltip: 'Xóa bộ lọc',
                          ),
                        ),
                      IconButton(
                        onPressed: () async {
                          final result =
                              await showModalBottomSheet<Map<String, dynamic>>(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (context) => FilterBottomSheet(
                                  selectedBrand: _selectedBrand,
                                  selectedType: _selectedType,
                                  maxPrice: _maxPrice,
                                  minBatteryLevel: _minBatteryLevel,
                                  selectedFeatures: _selectedFeatures,
                                  sortBy: _sortBy,
                                ),
                              );

                          if (result != null) {
                            setState(() {
                              _selectedBrand = result['brand'];
                              _selectedType = result['type'];
                              _maxPrice = result['maxPrice'];
                              _minBatteryLevel = result['minBatteryLevel'];
                              _selectedFeatures = result['features'] ?? [];
                              _sortBy = result['sortBy'] ?? 'default';
                            });
                            _applyFilters();
                          }
                        },
                        icon: Stack(
                          children: [
                            const Icon(Icons.tune),
                            if (_hasActiveFilters)
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppColors.error,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        color: Colors.white,
                        tooltip: 'Bộ lọc',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Search bar
                  TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm xe...',
                      hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                      ),
                      prefixIcon: const Icon(Icons.search, color: Colors.white),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                Icons.clear,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                                _applyFilters();
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.2),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {});
                      _applyFilters();
                    },
                  ),
                ],
              ),
            ),

            // Active filters chips
            if (_hasActiveFilters)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                color: Colors.white,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (_selectedBrand != null)
                      _buildFilterChip(
                        'Hãng: ${_selectedBrand!.displayName}',
                        () {
                          setState(() => _selectedBrand = null);
                          _applyFilters();
                        },
                      ),
                    if (_selectedType != null)
                      _buildFilterChip(
                        'Loại: ${_selectedType!.displayName}',
                        () {
                          setState(() => _selectedType = null);
                          _applyFilters();
                        },
                      ),
                    if (_maxPrice != null)
                      _buildFilterChip(
                        'Giá tối đa: ${_formatPrice(_maxPrice!)}đ/h',
                        () {
                          setState(() => _maxPrice = null);
                          _applyFilters();
                        },
                      ),
                    if (_minBatteryLevel != null)
                      _buildFilterChip('Pin tối thiểu: $_minBatteryLevel%', () {
                        setState(() => _minBatteryLevel = null);
                        _applyFilters();
                      }),
                    if (_selectedFeatures.isNotEmpty)
                      ..._selectedFeatures.map(
                        (feature) => _buildFilterChip(feature.displayName, () {
                          setState(() => _selectedFeatures.remove(feature));
                          _applyFilters();
                        }),
                      ),
                    if (_sortBy != 'default')
                      _buildFilterChip(
                        'Sắp xếp: ${_getSortLabel(_sortBy)}',
                        () {
                          setState(() => _sortBy = 'default');
                          _applyFilters();
                        },
                      ),
                  ],
                ),
              ),

            // Vehicle list
            Expanded(
              child: BlocConsumer<VehicleListCubit, VehicleListState>(
                listener: (context, state) {
                  if (state is VehicleListLoaded) {
                    // Store all vehicles for filtering
                    if (_allVehicles.isEmpty) {
                      _allVehicles = List.from(state.vehicles);
                    }
                  }
                },
                builder: (context, state) {
                  if (state is VehicleListLoading) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Đang tải danh sách xe...'),
                        ],
                      ),
                    );
                  }

                  if (state is VehicleListError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: AppColors.error.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Có lỗi xảy ra',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              state.message,
                              style: GoogleFonts.poppins(
                                color: AppColors.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () {
                                _allVehicles.clear();
                                context.read<VehicleListCubit>().loadVehicles();
                              },
                              icon: const Icon(Icons.refresh),
                              label: const Text('Thử lại'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (state is VehicleListLoaded) {
                    if (state.vehicles.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.electric_moped,
                                size: 80,
                                color: AppColors.textMuted.withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _hasActiveFilters
                                    ? 'Không tìm thấy xe phù hợp'
                                    : 'Không có xe nào',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _hasActiveFilters
                                    ? 'Thử điều chỉnh bộ lọc của bạn'
                                    : 'Hãy quay lại sau',
                                style: GoogleFonts.poppins(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              if (_hasActiveFilters) ...[
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: _resetFilters,
                                  icon: const Icon(Icons.clear_all),
                                  label: const Text('Xóa bộ lọc'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        _allVehicles.clear();
                        context.read<VehicleListCubit>().loadVehicles();
                      },
                      child: Column(
                        children: [
                          // Results count
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            color: Colors.white,
                            child: Text(
                              'Tìm thấy ${state.vehicles.length} xe',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: state.vehicles.length,
                              itemBuilder: (context, index) {
                                final vehicle = state.vehicles[index];
                                return VehicleCard(
                                  vehicle: vehicle,
                                  onTap: () {
                                    context.push('/vehicle/${vehicle.id}');
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Navigate to map view
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Bản đồ đang được phát triển'),
              backgroundColor: AppColors.primary,
            ),
          );
        },
        icon: const Icon(Icons.map),
        label: const Text('Xem bản đồ'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onRemove) {
    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      deleteIcon: const Icon(Icons.close, size: 16),
      onDeleted: onRemove,
      backgroundColor: AppColors.primary.withOpacity(0.1),
      deleteIconColor: AppColors.primary,
      labelStyle: const TextStyle(color: AppColors.primary),
      side: const BorderSide(color: AppColors.primary),
    );
  }

  String _formatPrice(double price) {
    return price
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
  }

  String _getSortLabel(String sortBy) {
    switch (sortBy) {
      case 'price_low':
        return 'Giá thấp';
      case 'price_high':
        return 'Giá cao';
      case 'rating':
        return 'Đánh giá';
      case 'distance':
        return 'Khoảng cách';
      default:
        return 'Mặc định';
    }
  }
}
