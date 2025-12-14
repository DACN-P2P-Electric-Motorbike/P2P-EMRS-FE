import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../injection_container.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../vehicle/domain/entities/vehicle_entity.dart';
import '../../../vehicle/presentation/bloc/vehicles_list_cubit.dart';
import '../../../vehicle/presentation/widgets/vehicle_card.dart';
import '../../../vehicle/presentation/widgets/filter_bottom_sheet.dart';

/// Browse vehicles page for renters
/// Shows available vehicles with search and filters
class BrowseVehiclesPage extends StatelessWidget {
  const BrowseVehiclesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<VehicleListCubit>()..loadVehicles(),
      child: const _BrowseVehiclesView(),
    );
  }
}

class _BrowseVehiclesView extends StatefulWidget {
  const _BrowseVehiclesView();

  @override
  State<_BrowseVehiclesView> createState() => _BrowseVehiclesViewState();
}

class _BrowseVehiclesViewState extends State<_BrowseVehiclesView> {
  final _searchController = TextEditingController();
  List<VehicleEntity> _allVehicles = [];

  // Filter states (from vehicle_list_page)
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

  // Apply filters method from vehicle_list_page
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

  // Reset filters method from vehicle_list_page
  void _resetFilters() {
    if (mounted) {
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
  }

  // Check if any filters are active
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
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              context.go('/login');
            }
          });
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FD),
        body: SafeArea(
          child: Column(
            children: [
              // Header with user greeting and search
              _buildHeader(context),

              // Active filters chips
              if (_hasActiveFilters) _buildActiveFiltersChips(),

              // Content (Quick Actions + Vehicle List)
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    // Quick Actions
                    _buildQuickActions(context),

                    // Results count
                    // _buildResultsCount(),
                    const SliverToBoxAdapter(child: SizedBox(height: 16)),

                    // Vehicles Grid
                    _buildVehiclesGrid(),

                    const SliverToBoxAdapter(child: SizedBox(height: 100)),
                  ],
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            context.push('/vehicle');
          },
          icon: const Icon(Icons.arrow_forward),
          label: const Text('Xem thêm'),
          backgroundColor: AppColors.primary,
        ),
      ),
    );
  }

  // Header with gradient, user greeting, and search bar
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          // User greeting row
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              final user = state is AuthSuccess
                  ? state.user
                  : (state is AuthAuthenticated ? state.user : null);

              return Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: Text(
                      user?.fullName.isNotEmpty == true
                          ? user!.fullName[0].toUpperCase()
                          : 'U',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Xin chào,',
                          style: GoogleFonts.poppins(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          user?.fullName ?? 'User',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Clear all filters button
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
                  // Filter button
                  IconButton(
                    onPressed: () async {
                      if (!mounted) return;

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

                      if (result != null && mounted) {
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
              );
            },
          ),
          const SizedBox(height: 16),

          // Search bar
          TextField(
            controller: _searchController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Tìm kiếm xe...',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
              prefixIcon: const Icon(Icons.search, color: Colors.white),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.white),
                      onPressed: () {
                        if (mounted) {
                          _searchController.clear();
                          setState(() {});
                          _applyFilters();
                        }
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
                borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.white, width: 2),
              ),
            ),
            onChanged: (value) {
              if (mounted) {
                setState(() {});
                _applyFilters();
              }
            },
          ),
        ],
      ),
    );
  }

  // Active filters chips display
  Widget _buildActiveFiltersChips() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          if (_selectedBrand != null)
            _buildFilterChip('Hãng: ${_selectedBrand!.displayName}', () {
              if (mounted) {
                setState(() => _selectedBrand = null);
                _applyFilters();
              }
            }),
          if (_selectedType != null)
            _buildFilterChip('Loại: ${_selectedType!.displayName}', () {
              if (mounted) {
                setState(() => _selectedType = null);
                _applyFilters();
              }
            }),
          if (_maxPrice != null)
            _buildFilterChip('Giá tối đa: ${_formatPrice(_maxPrice!)}đ/h', () {
              if (mounted) {
                setState(() => _maxPrice = null);
                _applyFilters();
              }
            }),
          if (_minBatteryLevel != null)
            _buildFilterChip('Pin tối thiểu: $_minBatteryLevel%', () {
              if (mounted) {
                setState(() => _minBatteryLevel = null);
                _applyFilters();
              }
            }),
          if (_selectedFeatures.isNotEmpty)
            ..._selectedFeatures.map(
              (feature) => _buildFilterChip(feature.displayName, () {
                if (mounted) {
                  setState(() => _selectedFeatures.remove(feature));
                  _applyFilters();
                }
              }),
            ),
          if (_sortBy != 'default')
            _buildFilterChip('Sắp xếp: ${_getSortLabel(_sortBy)}', () {
              if (mounted) {
                setState(() => _sortBy = 'default');
                _applyFilters();
              }
            }),
        ],
      ),
    );
  }

  // Individual filter chip widget
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

  // Quick actions section
  Widget _buildQuickActions(BuildContext context) {
    return SliverToBoxAdapter(
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final user = state is AuthSuccess
              ? state.user
              : (state is AuthAuthenticated ? state.user : null);

          if (user?.isRenter != true) {
            return const SizedBox.shrink();
          }

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Thao tác nhanh',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildActionCard(
                        context,
                        icon: Icons.history,
                        title: 'Lịch sử',
                        subtitle: 'Chuyến đi',
                        color: AppColors.warning,
                        onTap: () {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Coming soon!')),
                            );
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildActionCard(
                        context,
                        icon: Icons.wallet_outlined,
                        title: 'Ví tiền',
                        subtitle: 'Thanh toán',
                        color: AppColors.success,
                        onTap: () {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Coming soon!')),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Results count display
  Widget _buildResultsCount() {
    return SliverToBoxAdapter(
      child: BlocBuilder<VehicleListCubit, VehicleListState>(
        builder: (context, state) {
          if (state is VehicleListLoaded && state.vehicles.isNotEmpty) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Tìm thấy ${state.vehicles.length} xe',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  // Vehicles grid with all states handled
  Widget _buildVehiclesGrid() {
    return BlocConsumer<VehicleListCubit, VehicleListState>(
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
          return const SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Đang tải danh sách xe...'),
                ],
              ),
            ),
          );
        }

        if (state is VehicleListError) {
          return SliverFillRemaining(
            child: Center(
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
            ),
          );
        }

        if (state is VehicleListLoaded) {
          if (state.vehicles.isEmpty) {
            return SliverFillRemaining(
              child: Center(
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
              ),
            );
          }

          final displayedVehicles = state.vehicles
              .take(6) // giới hạn chỉ hiển thị 6 xe ở trang Browse
              .toList();
          return SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final vehicle = displayedVehicles[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: VehicleCard(
                    vehicle: vehicle,
                    onTap: () {
                      if (mounted) {
                        context.push('/vehicle/${vehicle.id}');
                      }
                    },
                  ),
                );
              }, childCount: displayedVehicles.length),
            ),
          );
        }

        return const SliverToBoxAdapter(child: SizedBox.shrink());
      },
    );
  }

  // Action card widget
  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
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
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper methods
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
