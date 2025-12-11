import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

/// Owner Profile Page with grid menu
class OwnerProfilePage extends StatelessWidget {
  const OwnerProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          context.go('/login');
        }
      },
      builder: (context, state) {
        final user = state is AuthSuccess
            ? state.user
            : (state is AuthAuthenticated ? state.user : null);

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Profile Header
                  _buildProfileHeader(context, user),

                  const Divider(height: 32, color: AppColors.border),

                  // Feature Grid
                  _buildFeatureGrid(context),

                  const SizedBox(height: 24),

                  // Menu List
                  _buildMenuList(context),

                  const SizedBox(height: 40),

                  // Logout Button
                  _buildLogoutButton(context),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(BuildContext context, dynamic user) {
    return Row(
      children: [
        // Avatar
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: AppColors.inputBackground,
            image: user?.avatarUrl != null
                ? DecorationImage(
                    image: NetworkImage(user.avatarUrl),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: user?.avatarUrl == null
              ? Center(
                  child: Text(
                    user?.fullName?.isNotEmpty == true
                        ? user.fullName[0].toUpperCase()
                        : 'U',
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                )
              : null,
        ),

        const SizedBox(width: 16),

        // Name & Edit Profile
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user?.fullName ?? 'User Name',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              GestureDetector(
                onTap: () {
                  // TODO: Navigate to edit profile
                },
                child: Text(
                  'Edit Profile',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Edit icon
        IconButton(
          onPressed: () {
            // TODO: Navigate to edit profile
          },
          icon: Icon(
            Icons.edit_outlined,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureGrid(BuildContext context) {
    final features = [
      _FeatureItem(
        icon: Icons.credit_card_outlined,
        label: 'License',
        onTap: () {},
      ),
      _FeatureItem(
        icon: Icons.badge_outlined,
        label: 'Passport',
        onTap: () {},
      ),
      _FeatureItem(
        icon: Icons.description_outlined,
        label: 'Contract',
        onTap: () {},
      ),
      _FeatureItem(
        icon: Icons.two_wheeler_outlined,
        label: 'Your Bike',
        isHighlighted: true,
        onTap: () => context.push('/owner'),
      ),
      _FeatureItem(
        icon: Icons.account_balance_wallet_outlined,
        label: 'Earnings',
        onTap: () {},
      ),
      _FeatureItem(
        icon: Icons.bar_chart_outlined,
        label: 'Statistics',
        onTap: () {},
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        final feature = features[index];
        return _buildFeatureCard(feature);
      },
    );
  }

  Widget _buildFeatureCard(_FeatureItem feature) {
    return InkWell(
      onTap: feature.onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              feature.icon,
              size: 32,
              color: feature.isHighlighted ? AppColors.primary : AppColors.textPrimary,
            ),
            const SizedBox(height: 8),
            Text(
              feature.label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuList(BuildContext context) {
    final menuItems = [
      _MenuItem(
        icon: Icons.person_outline,
        label: 'My Profile',
        onTap: () {},
      ),
      _MenuItem(
        icon: Icons.calendar_today_outlined,
        label: 'My Bookings',
        onTap: () {},
      ),
      _MenuItem(
        icon: Icons.settings_outlined,
        label: 'Settings',
        onTap: () {},
      ),
    ];

    return Column(
      children: menuItems.map((item) {
        return Column(
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.inputBackground,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  item.icon,
                  color: AppColors.textPrimary,
                ),
              ),
              title: Text(
                item.label,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              trailing: Icon(
                Icons.chevron_right,
                color: AppColors.textMuted,
              ),
              onTap: item.onTap,
            ),
            if (item != menuItems.last)
              const Divider(color: AppColors.border),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.inputBackground,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          Icons.logout_outlined,
          color: AppColors.textPrimary,
        ),
      ),
      title: Text(
        'Logout',
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
      onTap: () {
        _showLogoutDialog(context);
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          'Logout',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<AuthBloc>().add(const AuthLogoutStarted());
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

class _FeatureItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isHighlighted;

  const _FeatureItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isHighlighted = false,
  });
}

class _MenuItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}
