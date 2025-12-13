import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

/// Bottom Navigation Bar Widget
class BottomNavBar extends StatelessWidget {
  final int currentIndex;

  const BottomNavBar({
    super.key,
    this.currentIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                label: 'Home',
                isActive: currentIndex == 0,
                onTap: () => context.go('/home'),
              ),
              _NavItem(
                icon: Icons.bookmark_outline,
                activeIcon: Icons.bookmark,
                label: 'Saved',
                isActive: currentIndex == 1,
                onTap: () {
                  // TODO: Navigate to saved/bookmarks
                },
              ),
              _NavItem(
                icon: Icons.notifications_outlined,
                activeIcon: Icons.notifications,
                label: 'Alerts',
                isActive: currentIndex == 2,
                onTap: () {
                  // TODO: Navigate to notifications
                },
              ),
              _NavItem(
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                label: 'Profile',
                isActive: currentIndex == 3,
                onTap: () => context.go('/profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive ? activeIcon : icon,
            color: isActive ? AppColors.primary : AppColors.textMuted,
            size: 26,
          ),
        ],
      ),
    );
  }
}

