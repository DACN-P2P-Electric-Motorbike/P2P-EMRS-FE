import 'package:fe_capstone_project/features/booking/presentation/pages/booking_detail_page.dart';
import 'package:fe_capstone_project/features/booking/presentation/pages/booking_page.dart';
import 'package:fe_capstone_project/features/notification/presentation/pages/notification_pages.dart';
import 'package:fe_capstone_project/features/owner_vehicle/presentation/pages/owner_dashboard_page.dart';
import 'package:fe_capstone_project/features/owner_vehicle/presentation/pages/owner_entry_page.dart';
import 'package:fe_capstone_project/features/renter/presentation/pages/become_owner_page.dart';
import 'package:fe_capstone_project/features/vehicle/presentation/pages/browse_vehices_page.dart';
import 'package:fe_capstone_project/features/vehicle/presentation/pages/vehicle_detail_page.dart';
import 'package:fe_capstone_project/features/vehicle/presentation/pages/vehicle_list_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/profile.dart';
import '../../features/main/presentation/pages/main_shell.dart';
import '../../features/owner_vehicle/presentation/pages/bike_registration_page.dart';
import '../../features/owner_vehicle/presentation/pages/vehicle_detail_edit_page.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

/// App Router with ShellRoute for persistent BottomNavigationBar
class AppRouter {
  AppRouter._();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/login',
    debugLogDiagnostics: true,
    routes: [
      // ==================== AUTH ROUTES (No navbar) ====================
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),

      // ==================== MAIN APP WITH BOTTOM NAV ====================
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          // Determine tab index based on route
          int selectedIndex = 0;
          final path = state.uri.path;

          if (path.startsWith('/home') || path == '/') {
            selectedIndex = 0;
          } else if (path.startsWith('/owner') ||
              path.startsWith('/become-owner')) {
            selectedIndex = 1;
          } else if (path.startsWith('/bookings')) {
            selectedIndex = 2;
          } else if (path.startsWith('/notifications')) {
            selectedIndex = 3;
          } else if (path.startsWith('/profile')) {
            selectedIndex = 4;
          }

          return MainShell(initialIndex: selectedIndex, child: child);
        },
        routes: [
          // HOME TAB - Browse Vehicles
          GoRoute(
            path: '/home',
            name: 'home',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const BrowseVehiclesPage(),
            ),
            routes: [
              // Vehicle detail (with navbar)
              GoRoute(
                path: 'vehicle/:id',
                name: 'home-vehicle-detail',
                builder: (context, state) {
                  final vehicleId = state.pathParameters['id']!;
                  return VehicleDetailPage(vehicleId: vehicleId);
                },
              ),
            ],
          ),

          GoRoute(
            path: '/owner-entry',
            name: 'owner-entry',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const OwnerEntryPage(),
            ),
          ),

          // OWNER/BECOME OWNER TAB
          GoRoute(
            path: '/owner',
            name: 'owner-dashboard-tab',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const OwnerDashboardPage(),
            ),
            routes: [
              GoRoute(
                path: 'register-vehicle',
                name: 'owner-register-vehicle',
                builder: (context, state) => const BikeRegistrationPage(),
              ),
              GoRoute(
                path: 'vehicle/:id',
                name: 'owner-vehicle-detail',
                builder: (context, state) {
                  final vehicleId = state.pathParameters['id']!;
                  return VehicleDetailEditPage(vehicleId: vehicleId);
                },
              ),
            ],
          ),

          GoRoute(
            path: '/become-owner',
            name: 'become-owner-tab',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const BecomeOwnerPage(),
            ),
            routes: [
              GoRoute(
                path: 'register-vehicle',
                name: 'become-owner-register-vehicle',
                builder: (context, state) =>
                    const BikeRegistrationPage(isBecomeOwnerFlow: true),
              ),
            ],
          ),

          // BOOKINGS TAB - UNIFIED PAGE FOR BOTH RENTER AND OWNER
          GoRoute(
            path: '/bookings',
            name: 'bookings-page',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const UnifiedBookingsPage(),
            ),
            routes: [
              // Booking detail (with navbar)
              GoRoute(
                path: ':id',
                name: 'booking-detail',
                builder: (context, state) {
                  final bookingId = state.pathParameters['id']!;
                  return BookingDetailPage(bookingId: bookingId);
                },
              ),
            ],
          ),

          // NOTIFICATIONS TAB
          GoRoute(
            path: '/notifications',
            name: 'notifications',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const NotificationsPage(),
            ),
          ),

          // PROFILE TAB
          GoRoute(
            path: '/profile',
            name: 'profile',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const ProfilePage(),
            ),
          ),
        ],
      ),

      // ==================== FULL SCREEN ROUTES (No navbar) ====================

      // Public vehicle listing (fullscreen)
      GoRoute(
        path: '/vehicle',
        name: 'list-vehicle',
        builder: (context, state) => const VehicleListPage(),
        routes: [
          GoRoute(
            path: 'available',
            name: 'available-vehicle',
            builder: (context, state) => const VehicleListPage(),
          ),
          GoRoute(
            path: ':id',
            name: 'view-detail-vehicle-info',
            builder: (context, state) {
              final vehicleId = state.pathParameters['id']!;
              return VehicleDetailPage(vehicleId: vehicleId);
            },
          ),
        ],
      ),
    ],

    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              state.uri.toString(),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/login'),
              child: const Text('Go to Login'),
            ),
          ],
        ),
      ),
    ),
  );
}
