import 'dart:io';
import 'package:bot_toast/bot_toast.dart';
import 'package:fe_capstone_project/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fe_capstone_project/features/auth/presentation/bloc/auth_event.dart';
import 'package:fe_capstone_project/features/auth/presentation/bloc/auth_state.dart';
import 'package:fe_capstone_project/features/booking/presentation/bloc/booking_bloc.dart';
import 'package:fe_capstone_project/features/notification/presentation/bloc/notification_bloc.dart';
import 'package:fe_capstone_project/features/notification/presentation/bloc/notification_event.dart';
import 'package:fe_capstone_project/features/notification/presentation/widgets/notification_listener.dart';
import 'package:fe_capstone_project/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:logger/logger.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/services/socket_service.dart';
import 'core/services/fcm_service.dart';
import 'features/notification/domain/usecases/notification_usecases.dart';
import 'injection_container.dart' as di;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// Global logger instance
final Logger _logger = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
    errorMethodCount: 5,
    lineLength: 80,
    colors: true,
    printEmojis: true,
    dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
  ),
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    _logger.i('🚀 Starting application initialization');

    // Initialize Firebase
    _logger.d('Initializing Firebase');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    _logger.i('✅ Firebase initialized successfully');

    // Set preferred orientations (skip on web)
    if (!kIsWeb) {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
      _logger.d('Screen orientation set to portrait only');

      // Set system UI overlay style
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: AppColors.background,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      );
      _logger.d('System UI overlay style configured');
    }

    // Initialize dependency injection
    _logger.d('Initializing dependency injection');
    await di.init();
    _logger.i('✅ Dependency injection initialized');

    // Initialize FCM (mobile only)
    if (!kIsWeb) {
      await di.sl<FcmService>().initialize();
      _logger.i('✅ FCM initialized');
    } else {
      _logger.i('⚠️ Running on WEB - FCM skipped, using WebSocket only');
    }

    _logger.i('🎉 Application initialization complete');
  runApp(const MyApp());
  } catch (e, stackTrace) {
    _logger.e(
      '❌ Fatal error during app initialization',
      error: e,
      stackTrace: stackTrace,
    );
    rethrow;
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final SocketService _socketService = di.sl<SocketService>();
  FcmService? _fcmService;

  @override
  void initState() {
    super.initState();
    // Only initialize FCM on mobile
    _fcmService = kIsWeb ? null : di.sl<FcmService>();
    _logger.d('MyApp state initialized');
  }

  Future<void> _registerFcmToken() async {
    if (kIsWeb || _fcmService == null) return;

    try {
      final fcmToken = _fcmService!.fcmToken;
      if (fcmToken != null) {
        _logger.i('FCM token available: ${fcmToken.substring(0, 20)}...');

        final platform = Platform.isIOS ? 'ios' : 'android';
        _logger.d('Registering FCM token with backend (platform: $platform)');

        final registerUseCase = di.sl<RegisterFcmTokenUseCase>();
        final result = await registerUseCase(
          RegisterFcmTokenParams(token: fcmToken, platform: platform),
        );

        result.fold(
          (failure) {
            _logger.w('Failed to register FCM token: ${failure.message}');
          },
          (_) {
            _logger.i('✅ FCM token registered successfully');
          },
        );
      } else {
        _logger.w('FCM token not available');
      }
    } catch (e, stackTrace) {
      _logger.e(
        'Error registering FCM token',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  void _setupFcmCallbacks() {
    if (kIsWeb || _fcmService == null) return;

    _logger.d('Setting up FCM callbacks');

    // Handle notification taps (when app is in background/terminated)
    _fcmService!.onNotificationTapped = (message) {
      _logger.i('📱 Notification tapped');
      _logger.d('Message data: ${message.data}');

      final bookingId = message.data['bookingId'] as String?;
      if (bookingId != null) {
        _logger.i('Navigating to booking: $bookingId');
        AppRouter.router.push('/booking/$bookingId');
      }
    };

    // Handle foreground notifications
    _fcmService!.onForegroundMessage = (message) {
      _logger.i('📬 Foreground FCM message received');
      _logger.d('Title: ${message.notification?.title}');
      _logger.d('Body: ${message.notification?.body}');
    };

    _logger.i('✅ FCM callbacks configured');
  }

  @override
  void dispose() {
    _logger.d('MyApp disposing - disconnecting socket');
    _socketService.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Auth Bloc - Global
        BlocProvider<AuthBloc>(
          create: (_) {
            _logger.d('🏗️ Creating AuthBloc instance');
            return di.sl<AuthBloc>()..add(const AuthCheckRequested());
          },
        ),

        // Notification Bloc - Global
        BlocProvider<NotificationBloc>(
          create: (_) {
            _logger.d('🏗️ Creating NotificationBloc instance');
            return di.sl<NotificationBloc>();
          },
        ),

        // Booking Bloc - Global
        BlocProvider<BookingBloc>(
          create: (_) {
            _logger.d('🏗️ Creating BookingBloc instance');
            return di.sl<BookingBloc>();
          },
        ),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) async {
          if (state is AuthAuthenticated) {
            _logger.i('✅ User authenticated: ${state.user.email}');

            // Connect socket
            if (!_socketService.isConnected) {
              _logger.d('Socket not connected, attempting connection');
              final serverUrl = 'http://localhost:3000';
              await _socketService.connect(serverUrl);
            } else {
              _logger.d('Socket already connected');
            }

            // Setup FCM callbacks and register token (mobile only)
            if (!kIsWeb && _fcmService != null) {
              _setupFcmCallbacks();
              await _registerFcmToken();
            }

            // Load notifications
            _logger.d('Loading user notifications');
            context.read<NotificationBloc>().add(
              const LoadNotificationsEvent(),
            );
          } else if (state is AuthSuccess) {
            // Register FCM token immediately after login without waiting for
            // the AuthCheckRequested → AuthAuthenticated round-trip.
            _logger.i('✅ Login succeeded: ${state.user.email}');
            if (!kIsWeb && _fcmService != null) {
              _setupFcmCallbacks();
              await _registerFcmToken();
            }
          } else if (state is AuthUnauthenticated) {
            _logger.i('User unauthenticated, disconnecting socket');
            _socketService.disconnect();

            // Unregister FCM token (mobile only)
            if (!kIsWeb && _fcmService != null) {
              final fcmToken = _fcmService!.fcmToken;
              if (fcmToken != null) {
                final unregisterUseCase = di.sl<UnregisterFcmTokenUseCase>();
                await unregisterUseCase(UnregisterFcmTokenParams(fcmToken));
              }
            }
          }
        },
        child: MaterialApp.router(
          title: 'P2P Electric Motorbike Rental',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          routerConfig: AppRouter.router,

          // ✅ bot_toast integration
          builder: (context, child) {
            // Wrap with NotificationListenerWidget first
            child = NotificationListenerWidget(
              child: child ?? const SizedBox(),
            );

            // ✅ Initialize bot_toast
            return BotToastInit()(context, child);
          },

          // ✅ Add bot_toast navigator observer
          // Note: GoRouter handles this internally, but if using Navigator directly:
          // navigatorObservers: [BotToastNavigatorObserver()],
        ),
      ),
    );
  }
}
