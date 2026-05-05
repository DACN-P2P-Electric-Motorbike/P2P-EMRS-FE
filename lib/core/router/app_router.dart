import 'package:fe_capstone_project/features/booking/presentation/pages/booking_detail_page.dart';
import 'package:fe_capstone_project/features/booking/presentation/pages/booking_page.dart';
import 'package:fe_capstone_project/features/notification/presentation/pages/notification_pages.dart';
import 'package:fe_capstone_project/features/owner_vehicle/presentation/pages/owner_dashboard_page.dart';
import 'package:fe_capstone_project/features/owner_vehicle/presentation/pages/owner_entry_page.dart';
import 'package:fe_capstone_project/features/renter/presentation/pages/become_owner_page.dart';
import 'package:fe_capstone_project/features/review/presentation/pages/trust_score_page.dart';
import 'package:fe_capstone_project/features/settings/presentation/pages/app_settings_page.dart';
import 'package:fe_capstone_project/features/trip/presentation/pages/active_trip_page.dart';
import 'package:fe_capstone_project/features/trip/presentation/pages/trip_history_page.dart';
import 'package:fe_capstone_project/features/vehicle/presentation/pages/browse_vehices_page.dart';
import 'package:fe_capstone_project/features/vehicle/presentation/pages/vehicle_detail_page.dart';
import 'package:fe_capstone_project/features/vehicle/presentation/pages/vehicle_list_page.dart';
import 'package:fe_capstone_project/features/vehicle/presentation/pages/vehicle_map_page.dart';
import 'package:fe_capstone_project/features/vehicle/presentation/bloc/vehicles_list_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/domain/entities/user.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/pages/splash_page.dart';

import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/otp_verification_page.dart';
import '../../features/auth/presentation/pages/password_reset_success_page.dart';
import '../../features/auth/presentation/pages/profile.dart';
import '../../features/auth/presentation/pages/profile_edit_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/reset_password_page.dart';
import '../../features/main/presentation/pages/main_shell.dart';
import '../../features/owner_vehicle/presentation/pages/bike_registration_page.dart';
import '../../features/owner_vehicle/presentation/pages/vehicle_detail_edit_page.dart';
import '../../injection_container.dart';

import 'package:fe_capstone_project/features/payment/presentation/pages/payment_sandbox_page.dart';
import 'package:fe_capstone_project/features/payment/presentation/pages/owner_earnings_page.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

/// App Router with ShellRoute for persistent BottomNavigationBar
class AppRouter {
  AppRouter._();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final authState = context.read<AuthBloc>().state;

      // While auth check is still in progress, don't redirect at all.
      // This prevents the white screen / flicker on release builds where
      // the auth check completes slightly later than in debug mode.
      if (authState is AuthInitial || authState is AuthLoading) {
        return null;
      }

      // If user is accessing owner routes, verify role
      final isOwnerRoute =
          state.uri.path.startsWith('/owner') ||
          state.uri.path == '/owner-earnings';

      if (isOwnerRoute &&
          (authState is AuthAuthenticated || authState is AuthSuccess)) {
        final user = authState is AuthAuthenticated
            ? authState.user
            : (authState as AuthSuccess).user;
        if (!user.isOwner && !user.isAdmin) {
          // If not owner/admin, redirect to become-owner page
          return '/become-owner';
        }
      }

      final isAuthRoute =
          state.uri.path == '/login' ||
          state.uri.path == '/register' ||
          state.uri.path.startsWith('/forgot-password') ||
          state.uri.path.startsWith('/reset-password') ||
          state.uri.path.startsWith('/otp-verify');

      // Once auth is determined, redirect away from splash screen
      final isSplash = state.uri.path == '/splash';
      if (isSplash) {
        if (authState is AuthAuthenticated || authState is AuthSuccess) {
          return '/home';
        }
        if (authState is AuthUnauthenticated || authState is AuthFailure) {
          return '/login';
        }
      }

      // Only redirect to login when we KNOW the user is unauthenticated
      if (!isAuthRoute && !isSplash && authState is AuthUnauthenticated) {
        return '/login';
      }

      // Redirect authenticated users away from auth pages
      if (isAuthRoute &&
          (authState is AuthAuthenticated || authState is AuthSuccess)) {
        return '/home';
      }

      return null;
    },
    routes: [
      // ==================== SPLASH ROUTE ====================
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),

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
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: '/otp-verify',
        name: 'otp-verify',
        builder: (context, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          return OtpVerificationPage(email: email);
        },
      ),
      GoRoute(
        path: '/reset-password',
        name: 'reset-password',
        builder: (context, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          final otp = state.uri.queryParameters['otp'] ?? '';
          return ResetPasswordPage(email: email, otp: otp);
        },
      ),
      GoRoute(
        path: '/reset-success',
        name: 'reset-success',
        builder: (context, state) => const PasswordResetSuccessPage(),
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
          } else if (path.startsWith('/profile') ||
              path.startsWith('/settings')) {
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

          GoRoute(
            path: '/settings',
            name: 'settings',
            builder: (context, state) => const AppSettingsPage(),
          ),
        ],
      ),

      // ==================== FULL SCREEN ROUTES (No navbar) ====================
      GoRoute(
        path: '/payment-sandbox',
        name: 'payment-sandbox',
        builder: (context, state) => const PaymentSandboxPage(),
      ),

      GoRoute(
        path: '/owner-earnings',
        name: 'owner-earnings',
        builder: (context, state) => const OwnerEarningsPage(),
      ),

      GoRoute(
        path: '/profile/edit',
        name: 'profile-edit',
        builder: (context, state) {
          final user = state.extra as UserEntity?;
          if (user == null) return const SizedBox.shrink();
          return ProfileEditPage(user: user);
        },
      ),

      // Public vehicle listing (fullscreen)
      GoRoute(
        path: '/vehicle',
        name: 'list-vehicle',
        builder: (context, state) => const VehicleListPage(),
        routes: [
          GoRoute(
            path: 'map',
            name: 'vehicleMap',
            builder: (context, state) => BlocProvider(
              create: (_) => sl<VehicleListCubit>(),
              child: const VehicleMapPage(),
            ),
          ),
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

      // Trip history (fullscreen)
      GoRoute(
        path: '/trip-history',
        name: 'trip-history',
        builder: (context, state) => const TripHistoryPage(),
      ),

      GoRoute(
        path: '/active-trip',
        name: 'active-trip',
        builder: (context, state) => const ActiveTripPage(),
      ),

      // Trust score detail (fullscreen)
      GoRoute(
        path: '/trust-score',
        name: 'trust-score',
        builder: (context, state) => const TrustScorePage(),
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
