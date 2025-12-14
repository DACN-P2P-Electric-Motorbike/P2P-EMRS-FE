import 'package:fe_capstone_project/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fe_capstone_project/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

/// Browse vehicles page for renters
/// Shows available vehicles with search and filters
class BrowseVehiclesPage extends StatefulWidget {
  const BrowseVehiclesPage({super.key});

  @override
  State<BrowseVehiclesPage> createState() => _BrowseVehiclesPageState();
}

class _BrowseVehiclesPageState extends State<BrowseVehiclesPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'all';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          context.go('/login');
        }
      },
      builder: (context, state) {
        // Get user from AuthSuccess or AuthAuthenticated state
        final user = state is AuthSuccess
            ? state.user
            : (state is AuthAuthenticated ? state.user : null);
        final isLoading = state is AuthLoading;

        return Scaffold(
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                // App Bar Header
                SliverToBoxAdapter(
                  child: Container(
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
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            // Avatar
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
                            // IconButton(
                            //   icon: const Icon(
                            //     Icons.logout,
                            //     color: Colors.white,
                            //   ),
                            //   onPressed: () => _showLogoutDialog(context),
                            // ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Content
                SliverPadding(
                  padding: const EdgeInsets.all(20),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // User Info Card
                      // if (user != null) ...[
                      //   Container(
                      //     padding: const EdgeInsets.all(20),
                      //     decoration: BoxDecoration(
                      //       color: Colors.white,
                      //       borderRadius: BorderRadius.circular(16),
                      //       boxShadow: [
                      //         BoxShadow(
                      //           color: Colors.black.withOpacity(0.05),
                      //           blurRadius: 10,
                      //           offset: const Offset(0, 4),
                      //         ),
                      //       ],
                      //     ),
                      //     child: Column(
                      //       crossAxisAlignment: CrossAxisAlignment.start,
                      //       children: [
                      //         Row(
                      //           children: [
                      //             const Icon(
                      //               Icons.person_outline,
                      //               color: AppColors.primary,
                      //             ),
                      //             const SizedBox(width: 8),
                      //             Text(
                      //               'Thông tin tài khoản',
                      //               style: GoogleFonts.poppins(
                      //                 fontSize: 16,
                      //                 fontWeight: FontWeight.bold,
                      //                 color: AppColors.textPrimary,
                      //               ),
                      //             ),
                      //           ],
                      //         ),
                      //         const Divider(height: 24),
                      //         _buildInfoRow(
                      //           'Email',
                      //           user.email,
                      //           Icons.email_outlined,
                      //         ),
                      //         const SizedBox(height: 12),
                      //         _buildInfoRow(
                      //           'Số điện thoại',
                      //           user.phone,
                      //           Icons.phone_outlined,
                      //         ),
                      //         const SizedBox(height: 12),
                      //         _buildInfoRow(
                      //           'Vai trò',
                      //           user.displayRole,
                      //           Icons.badge_outlined,
                      //         ),
                      //         const SizedBox(height: 12),
                      //         _buildInfoRow(
                      //           'Điểm tin cậy',
                      //           '${user.trustScore.toStringAsFixed(1)}/100',
                      //           Icons.verified_outlined,
                      //         ),
                      //       ],
                      //     ),
                      //   ),
                      //   const SizedBox(height: 24),
                      // ],

                      // Quick Actions Title
                      Text(
                        'Thao tác nhanh',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Action Cards - Row 1 (Role-based)
                      Row(
                        children: [
                          // Owner-only: My Bikes
                          // if (user?.isOwner == true || user?.isAdmin == true)
                          //   Expanded(
                          //     child: _buildActionCard(
                          //       context,
                          //       icon: Icons.electric_moped,
                          //       title: 'Xe của tôi',
                          //       subtitle: 'Quản lý xe',
                          //       color: AppColors.primary,
                          //       onTap: () => context.push('/owner'),
                          //     ),
                          //   ),
                          // if (user?.isOwner == true || user?.isAdmin == true)
                          //   const SizedBox(width: 16),
                          // // All users: Find bike to rent
                          // Expanded(
                          //   child: _buildActionCard(
                          //     context,
                          //     icon: Icons.search,
                          //     title: 'Tìm xe',
                          //     subtitle: 'Thuê xe',
                          //     color: AppColors.secondary,
                          //     onTap: () {
                          //       ScaffoldMessenger.of(context).showSnackBar(
                          //         const SnackBar(content: Text('Coming soon!')),
                          //       );
                          //     },
                          //   ),
                          // ),
                          // Renter-only: Show history in first row
                          if (user?.isRenter == true) ...[
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildActionCard(
                                context,
                                icon: Icons.history,
                                title: 'Lịch sử',
                                subtitle: 'Chuyến đi',
                                color: AppColors.warning,
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Coming soon!'),
                                    ),
                                  );
                                },
                              ),
                            ),
                            Expanded(
                              child: _buildActionCard(
                                context,
                                icon: Icons.wallet_outlined,
                                title: 'Ví tiền',
                                subtitle: 'Thanh toán',
                                color: AppColors.success,
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Coming soon!'),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ],
                      ),
                      // Action Cards - Row 2
                      Row(
                        children: [
                          // Owner: Show history and earnings
                          if (user?.isOwner == true ||
                              user?.isAdmin == true) ...[
                            // Expanded(
                            //   child: _buildActionCard(
                            //     context,
                            //     icon: Icons.history,
                            //     title: 'Lịch sử',
                            //     subtitle: 'Chuyến đi',
                            //     color: AppColors.warning,
                            //     onTap: () {
                            //       ScaffoldMessenger.of(context).showSnackBar(
                            //         const SnackBar(
                            //           content: Text('Coming soon!'),
                            //         ),
                            //       );
                            //     },
                            //   ),
                            // ),
                            // const SizedBox(width: 16),
                            // Expanded(
                            //   child: _buildActionCard(
                            //     context,
                            //     icon: Icons.account_balance_wallet_outlined,
                            //     title: 'Thu nhập',
                            //     subtitle: 'Doanh thu',
                            //     color: AppColors.success,
                            //     onTap: () {
                            //       ScaffoldMessenger.of(context).showSnackBar(
                            //         const SnackBar(content: Text('Coming soon!')),
                            //       );
                            //     },
                            //   ),
                            // ),
                          ],
                          // Renter: Show wallet and support
                          if (user?.isRenter == true) ...[
                            // const SizedBox(width: 16),
                            // Expanded(
                            //   child: _buildActionCard(
                            //     context,
                            //     icon: Icons.support_agent_outlined,
                            //     title: 'Hỗ trợ',
                            //     subtitle: 'Liên hệ',
                            //     color: AppColors.info,
                            //     onTap: () {
                            //       ScaffoldMessenger.of(context).showSnackBar(
                            //         const SnackBar(
                            //           content: Text('Coming soon!'),
                            //         ),
                            //       );
                            //     },
                            //   ),
                            // ),
                          ],
                        ],
                      ),
                      // Status Badge
                      // if (user != null)
                      //   Container(
                      //     padding: const EdgeInsets.symmetric(
                      //       horizontal: 16,
                      //       vertical: 12,
                      //     ),
                      //     decoration: BoxDecoration(
                      //       color: user.isActive
                      //           ? AppColors.success.withOpacity(0.1)
                      //           : AppColors.warning.withOpacity(0.1),
                      //       borderRadius: BorderRadius.circular(12),
                      //       border: Border.all(
                      //         color: user.isActive
                      //             ? AppColors.success.withOpacity(0.3)
                      //             : AppColors.warning.withOpacity(0.3),
                      //       ),
                      //     ),
                      //     child: Row(
                      //       children: [
                      //         Icon(
                      //           user.isActive
                      //               ? Icons.check_circle
                      //               : Icons.pending,
                      //           color: user.isActive
                      //               ? AppColors.success
                      //               : AppColors.warning,
                      //         ),
                      //         const SizedBox(width: 12),
                      //         Expanded(
                      //           child: Column(
                      //             crossAxisAlignment: CrossAxisAlignment.start,
                      //             children: [
                      //               Text(
                      //                 user.isActive
                      //                     ? 'Tài khoản đã xác thực'
                      //                     : 'Đang chờ xác thực',
                      //                 style: GoogleFonts.poppins(
                      //                   fontWeight: FontWeight.w600,
                      //                   color: user.isActive
                      //                       ? AppColors.success
                      //                       : AppColors.warning,
                      //                 ),
                      //               ),
                      //               Text(
                      //                 user.isActive
                      //                     ? 'Bạn có thể sử dụng đầy đủ tính năng'
                      //                     : 'Vui lòng hoàn tất xác thực KYC',
                      //                 style: GoogleFonts.poppins(
                      //                   fontSize: 12,
                      //                   color: AppColors.textSecondary,
                      //                 ),
                      //               ),
                      //             ],
                      //           ),
                      //         ),
                      //       ],
                      //     ),
                      //   ),

                      // Loading indicator
                      if (isLoading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32),
                            child: CircularProgressIndicator(),
                          ),
                        ),
                    ]),
                  ),
                ),

                // Search Bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Tìm xe gần bạn...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.tune),
                          onPressed: _showFilterSheet,
                        ),
                        filled: true,
                        fillColor: AppColors.surfaceVariant,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ),

                // Filter Chips
                SliverToBoxAdapter(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        _buildFilterChip('Tất cả', 'all'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Gần tôi', 'nearby'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Giá rẻ', 'cheap'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Đánh giá cao', 'top_rated'),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // Vehicles Grid
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildVehicleCard(index),
                      childCount: 10, // TODO: Replace with actual data
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 100)),
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
      },
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final bool isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
        });
      },
      backgroundColor: Colors.white,
      selectedColor: AppColors.primary.withOpacity(0.2),
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? AppColors.primary : AppColors.border,
      ),
    );
  }

  Widget _buildVehicleCard(int index) {
    // TODO: Replace with actual vehicle data
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to vehicle details
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vehicle Image
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(
                        Icons.electric_moped,
                        size: 60,
                        color: AppColors.primary.withOpacity(0.3),
                      ),
                    ),
                    // Battery Badge
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.battery_charging_full,
                              size: 14,
                              color: Colors.white,
                            ),
                            SizedBox(width: 4),
                            Text(
                              '95%',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Vehicle Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'VinFast Klara',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 12,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '1.2 km',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '25,000đ/h',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      Row(
                        children: const [
                          Icon(Icons.star, size: 14, color: AppColors.warning),
                          SizedBox(width: 4),
                          Text(
                            '4.8',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bộ lọc', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 24),
            // TODO: Add filter options
            const Text('Tính năng đang được phát triển'),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Áp dụng'),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
}
