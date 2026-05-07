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
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:logger/logger.dart';
import 'core/localization/app_localizations.dart';
import 'core/settings/app_preferences_controller.dart';
import 'core/storage/storage_service.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/services/socket_service.dart';
import 'core/services/fcm_service.dart';
import 'features/notification/domain/usecases/notification_usecases.dart';
import 'injection_container.dart' as di;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sentry_flutter/sentry_flutter.dart';

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
  // MUST be the very first call before anything else
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await SentryFlutter.init((options) {
      options.dsn =
          'https://2ef5d655413d89931cb3808290c64541@o4510500035297280.ingest.us.sentry.io/4511327880282112';
      options.tracesSampleRate = 1.0;
      options.profilesSampleRate = 1.0;
    }, appRunner: () => _appMain());
  } catch (e) {
    // If Sentry fails to init, run the app anyway
    _logger.e('Sentry init failed, running app without Sentry', error: e);
    await _appMain();
  }
}

Future<void> _appMain() async {
  // Ensure binding is initialized (safe to call multiple times)
  WidgetsFlutterBinding.ensureInitialized();

  try {
    _logger.i('🚀 Starting application initialization');

    // Initialize Firebase (check if already initialized)
    _logger.d('Initializing Firebase');
    try {
      // Check if Firebase app already exists to avoid duplicate-app error
      Firebase.app();
      _logger.i('✅ Firebase already initialized');
    } catch (e) {
      // Firebase app doesn't exist, initialize it
      try {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        _logger.i('✅ Firebase initialized successfully');
      } catch (e, stackTrace) {
        _logger.e(
          '❌ Firebase initialization failed',
          error: e,
          stackTrace: stackTrace,
        );
        rethrow;
      }
    }

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
    try {
      await di.init();
      _logger.i('✅ Dependency injection initialized');
    } catch (e, stackTrace) {
      _logger.e(
        '❌ Dependency injection initialization failed',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }

    final appPreferences = AppPreferencesController(di.sl<StorageService>());
    await appPreferences.load();

    // Initialize FCM (mobile only)
    if (!kIsWeb) {
      try {
        await di.sl<FcmService>().initialize();
        _logger.i('✅ FCM initialized');
      } catch (e, stackTrace) {
        _logger.w(
          '⚠️ FCM initialization warning (non-critical)',
          error: e,
          stackTrace: stackTrace,
        );
      }
    } else {
      _logger.i('⚠️ Running on WEB - FCM skipped, using WebSocket only');
    }

    _logger.i('🎉 Application initialization complete');
    runApp(SentryWidget(child: MyApp(appPreferences: appPreferences)));
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
  final AppPreferencesController appPreferences;

  const MyApp({super.key, required this.appPreferences});

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
    return AppPreferencesScope(
      controller: widget.appPreferences,
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (_) {
              _logger.d('🏗️ Creating AuthBloc instance');
              return di.sl<AuthBloc>()..add(const AuthCheckRequested());
            },
          ),
          BlocProvider<NotificationBloc>(
            create: (_) {
              _logger.d('🏗️ Creating NotificationBloc instance');
              return di.sl<NotificationBloc>();
            },
          ),
          BlocProvider<BookingBloc>(
            create: (_) {
              _logger.d('🏗️ Creating BookingBloc instance');
              return di.sl<BookingBloc>();
            },
          ),
        ],
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) async {
            // Handle both AuthAuthenticated (from app startup) and AuthSuccess (from login)
            if (state is AuthAuthenticated || state is AuthSuccess) {
              final userEmail = state is AuthAuthenticated
                  ? (state).user.email
                  : (state as AuthSuccess).user.email;
              _logger.i('✅ User authenticated: $userEmail');

              if (!_socketService.isConnected) {
                _logger.d('Socket not connected, attempting connection');
                const serverUrl = 'https://p2p-emrs.onrender.com';
                await _socketService.connect(serverUrl);
              } else {
                _logger.d('Socket already connected');
              }

              if (!kIsWeb && _fcmService != null) {
                _setupFcmCallbacks();
                await _registerFcmToken();
              }

              if (!context.mounted) return;
              _logger.d('Loading user notifications');
              context.read<NotificationBloc>().add(
                const LoadNotificationsEvent(),
              );
            } else if (state is AuthUnauthenticated) {
              _logger.i('User unauthenticated, disconnecting socket');
              _socketService.disconnect();

              if (!kIsWeb && _fcmService != null) {
                final fcmToken = _fcmService!.fcmToken;
                if (fcmToken != null) {
                  final unregisterUseCase = di.sl<UnregisterFcmTokenUseCase>();
                  await unregisterUseCase(UnregisterFcmTokenParams(fcmToken));
                }
              }

              // Force navigation to login screen when user logs out
              if (context.mounted) {
                _logger.i('🔐 Logging out: navigating to login screen');
                // Schedule navigation on next frame to ensure proper cleanup
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (context.mounted) {
                    AppRouter.router.go('/login');
                  }
                });
              }
            }
          },
          child: AnimatedBuilder(
            animation: widget.appPreferences,
            builder: (context, _) {
              return MaterialApp.router(
                title: AppLocalizations(
                  widget.appPreferences.locale,
                ).t('appTitle'),
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: widget.appPreferences.themeMode,
                locale: widget.appPreferences.locale,
                supportedLocales: AppLocalizations.supportedLocales,
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                routerConfig: AppRouter.router,
                builder: (context, child) {
                  child = NotificationListenerWidget(
                    child: child ?? const SizedBox(),
                  );
                  return BotToastInit()(context, child);
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
