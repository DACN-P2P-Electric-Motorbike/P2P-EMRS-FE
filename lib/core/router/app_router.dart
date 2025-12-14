import 'package:fe_capstone_project/features/owner_vehicle/presentation/pages/owner_dashboard_page.dart';
import 'package:fe_capstone_project/features/renter/presentation/pages/become_owner_page.dart';
import 'package:fe_capstone_project/features/vehicle/presentation/pages/vehicle_detail_page.dart';
import 'package:fe_capstone_project/features/vehicle/presentation/pages/vehicle_list_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/main/presentation/pages/main_shell.dart';
import '../../features/owner_vehicle/presentation/pages/bike_registration_page.dart';
import '../../features/owner_vehicle/presentation/pages/vehicle_detail_edit_page.dart';

/// App Router configuration using GoRouter
class AppRouter {
  AppRouter._();

  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/login',
    debugLogDiagnostics: true,
    routes: [
      // Auth routes
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

      // Main app with bottom navigation (Home tab = index 0)
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const MainShell(initialIndex: 0),
      ),

      // Profile tab (index 3)
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const MainShell(initialIndex: 3),
      ),

      // Owner routes (outside main shell for full-screen experience)
      GoRoute(
        path: '/owner',
        name: 'owner-dashboard',
        // builder: (context, state) => const YourBikePage(),
        builder: (context, state) => const OwnerDashboardPage(),
        routes: [
          GoRoute(
            path: 'register-vehicle',
            name: 'register-vehicle',
            builder: (context, state) => const BikeRegistrationPage(),
          ),
          GoRoute(
            path: 'vehicle/:id',
            name: 'vehicle-detail',
            builder: (context, state) {
              final vehicleId = state.pathParameters['id']!;
              return VehicleDetailEditPage(vehicleId: vehicleId);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/become-owner',
        name: 'become-owner',
        builder: (context, state) => const BecomeOwnerPage(),
        routes: [
          GoRoute(
            path: 'register-vehicle',
            name: 'become-owner-register-vehicle',
            builder: (context, state) =>
                const BikeRegistrationPage(isBecomeOwnerFlow: true),
          ),
        ],
      ),
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
