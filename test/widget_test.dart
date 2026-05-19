import 'package:fe_capstone_project/core/settings/app_preferences_controller.dart';
import 'package:fe_capstone_project/core/storage/storage_service.dart';
import 'package:fe_capstone_project/core/widgets/app_avatar.dart';
import 'package:fe_capstone_project/core/widgets/app_network_image.dart';
import 'package:fe_capstone_project/core/utils/vietnam_time.dart';
import 'package:fe_capstone_project/core/localization/notification_text_localizer.dart';
import 'package:fe_capstone_project/features/booking/data/models/booking_model.dart';
import 'package:fe_capstone_project/core/localization/app_localizations.dart';
import 'package:fe_capstone_project/features/booking/domain/entities/booking.dart';
import 'package:fe_capstone_project/features/auth/data/models/user_model.dart';
import 'package:fe_capstone_project/features/auth/domain/entities/user.dart';
import 'package:fe_capstone_project/features/review/data/models/review_model.dart';
import 'package:fe_capstone_project/features/review/domain/entities/review_entity.dart';
import 'package:fe_capstone_project/features/settings/data/privacy_remote_data_source.dart';
import 'package:fe_capstone_project/features/settings/presentation/pages/app_settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
  });

  testWidgets(
    'AppNetworkImage shows a placeholder when data saver is enabled',
    (tester) async {
      final preferences = AppPreferencesController(StorageService());
      await preferences.setDataSaverEnabled(true);

      await tester.pumpWidget(
        AppPreferencesScope(
          controller: preferences,
          child: const MaterialApp(
            home: Scaffold(
              body: AppNetworkImage(
                imageUrl: 'https://example.com/vehicle.jpg',
                width: 120,
                height: 80,
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.image_not_supported_outlined), findsOneWidget);
      expect(find.byType(Image), findsNothing);
    },
  );

  test('BookingEntity displays sub-hour durations in minutes', () {
    final now = DateTime.utc(2026, 5, 9, 8);
    final booking = BookingEntity(
      id: 'booking-id',
      renterId: 'renter-id',
      ownerId: 'owner-id',
      vehicleId: 'vehicle-id',
      status: BookingStatus.CONFIRMED,
      startTime: now,
      endTime: now.add(const Duration(minutes: 30)),
      totalPrice: 25000,
      deposit: 200000,
      createdAt: now,
      updatedAt: now,
    );

    expect(booking.durationInHours, 0);
    expect(booking.durationDisplayText, '30 phút');
  });

  test('BookingModel reads payment status from nested payment payload', () {
    final model = BookingModel.fromJson({
      'id': 'booking-id',
      'renterId': 'renter-id',
      'ownerId': 'owner-id',
      'vehicleId': 'vehicle-id',
      'status': 'CONFIRMED',
      'startTime': '2026-05-10T03:00:00.000Z',
      'endTime': '2026-05-10T04:00:00.000Z',
      'totalPrice': 25000,
      'deposit': 200000,
      'createdAt': '2026-05-09T03:00:00.000Z',
      'updatedAt': '2026-05-09T03:00:00.000Z',
      'vehicle': {'batteryLevel': 87},
      'payment': {'status': 'COMPLETED'},
    });

    final booking = model.toEntity();
    expect(booking.paymentStatus, 'COMPLETED');
    expect(booking.isPaymentCompleted, isTrue);
    expect(booking.vehicleBatteryLevel, 87);
  });

  test('VietnamTime formats UTC API timestamps as GMT+7', () {
    final utcTime = DateTime.parse('2026-05-10T03:00:00.000Z');

    expect(VietnamTime.format(utcTime, 'dd/MM/yyyy HH:mm'), '10/05/2026 10:00');
    expect(
      VietnamTime.toApiIsoString(DateTime(2026, 5, 10, 10, 0)),
      '2026-05-10T10:00:00.000+07:00',
    );
  });

  test('ReviewModel reads reviewed booking id from nested trip payload', () {
    final model = ReviewModel.fromJson({
      'id': 'review-id',
      'userId': 'user-id',
      'vehicleId': 'vehicle-id',
      'tripId': 'trip-id',
      'rating': 5,
      'comment': 'Xe tốt',
      'createdAt': '2026-05-09T03:00:00.000Z',
      'updatedAt': '2026-05-09T03:00:00.000Z',
      'trip': {'bookingId': 'booking-id'},
    });

    expect(model.tripId, 'trip-id');
    expect(model.bookingId, 'booking-id');
    expect(model.toEntity().bookingId, 'booking-id');
  });

  test('TrustScoreBreakdownModel parses recent events and active warnings', () {
    final model = TrustScoreBreakdownModel.fromJson({
      'trustScore': 95,
      'breakdown': {
        'reviewsGiven': 4,
        'reviewsGivenBonus': 4,
        'avgRatingReceived': 4.5,
        'totalReviewsReceived': 8,
        'cancelledBookings': 1,
        'cancellationPenalty': -5,
        'rejectedBookings': 0,
        'rejectionPenalty': 0,
        'completedTrips': 5,
        'tripsWithIssues': 0,
        'violationPenalty': 0,
      },
      'recentEvents': [
        {
          'id': 'evt-1',
          'type': 'KYC_VERIFIED',
          'delta': 5,
          'scoreBefore': 100,
          'scoreAfter': 105,
          'reason': 'Identity document submitted during registration',
          'createdAt': '2026-05-15T10:00:00.000Z',
        },
        {
          'id': 'evt-2',
          'type': 'WARNING',
          'delta': 0,
          'scoreBefore': 105,
          'scoreAfter': 105,
          'reason': 'Late return warning',
          'createdAt': '2026-05-15T11:00:00.000Z',
        },
        {
          'id': 'evt-3',
          'type': 'BAD_REVIEW_RECEIVED',
          'delta': -3,
          'scoreBefore': 105,
          'scoreAfter': 102,
          'reason': 'Received a low rating',
          'createdAt': '2026-05-15T12:00:00.000Z',
        },
      ],
      'activeWarnings': [
        {
          'id': 'warn-1',
          'type': 'LATE_RETURN',
          'reason': 'Returned vehicle 45 minutes late',
          'createdAt': '2026-05-15T11:00:00.000Z',
          'expiresAt': '2026-06-14T11:00:00.000Z',
        },
      ],
    });

    final breakdown = model.entity;
    expect(breakdown.trustScore, 95);
    expect(breakdown.recentEvents, hasLength(3));
    expect(breakdown.recentEvents[0].type, TrustScoreEventType.kycVerified);
    expect(breakdown.recentEvents[0].isPositive, isTrue);
    expect(breakdown.recentEvents[1].type, TrustScoreEventType.warning);
    expect(breakdown.recentEvents[1].isWarning, isTrue);
    expect(
      breakdown.recentEvents[2].type,
      TrustScoreEventType.badReviewReceived,
    );
    expect(breakdown.recentEvents[2].isNegative, isTrue);

    expect(breakdown.activeWarnings, hasLength(1));
    expect(breakdown.activeWarnings.first.type, TrustScoreEventType.lateReturn);
    expect(breakdown.activeWarnings.first.penalizedAt, isNull);
  });

  test('TrustScoreBreakdownModel handles missing events/warnings fields', () {
    final model = TrustScoreBreakdownModel.fromJson({
      'trustScore': 100,
      'breakdown': {
        'reviewsGiven': 0,
        'reviewsGivenBonus': 0,
        'avgRatingReceived': null,
        'totalReviewsReceived': 0,
        'cancelledBookings': 0,
        'cancellationPenalty': 0,
        'rejectedBookings': 0,
        'rejectionPenalty': 0,
        'completedTrips': 0,
        'tripsWithIssues': 0,
        'violationPenalty': 0,
      },
    });

    expect(model.entity.recentEvents, isEmpty);
    expect(model.entity.activeWarnings, isEmpty);
  });

  test('User role checks handle multi-role and enum-like values', () {
    final now = DateTime.utc(2026, 5, 9);
    final user = UserEntity(
      id: 'user-id',
      email: 'owner@example.com',
      fullName: 'Owner',
      phone: '0900000000',
      roles: const ['renter', 'UserRole.OWNER', 'admin'],
      status: 'ACTIVE',
      trustScore: 100,
      createdAt: now,
      updatedAt: now,
    );

    expect(user.isRenter, isTrue);
    expect(user.isOwner, isTrue);
    expect(user.isAdmin, isTrue);

    final model = UserModel.fromJson({
      'id': 'user-id',
      'email': 'owner@example.com',
      'fullName': 'Owner',
      'phone': '0900000000',
      'roles': ['renter', 'UserRole.OWNER'],
      'status': 'ACTIVE',
      'trustScore': 100,
      'createdAt': '2026-05-09T03:00:00.000Z',
      'updatedAt': '2026-05-09T03:00:00.000Z',
    });

    expect(model.roles, ['RENTER', 'OWNER']);
    expect(model.toEntity().isOwner, isTrue);
  });

  test('NotificationTextLocalizer follows the selected app language', () {
    final vi = NotificationTextLocalizer.localize(
      type: 'BOOKING_REJECTED',
      title: 'Booking Rejected',
      message: 'Your booking request was rejected. Reason: Schedule conflict',
      locale: const Locale('vi'),
    );
    final en = NotificationTextLocalizer.localize(
      type: 'PAYMENT_SUCCESS',
      title: 'Đã nhận thanh toán',
      message: 'Bạn vừa nhận được 250.000 VND từ chuyến thuê xe.',
      locale: const Locale('en'),
    );

    expect(vi.title, 'Đặt xe bị từ chối');
    expect(vi.message, contains('Lý do: Schedule conflict'));
    expect(en.title, 'Payment received');
    expect(en.message, contains('250.000 VND'));
  });

  testWidgets('AppAvatar does not load network images in data saver mode', (
    tester,
  ) async {
    final preferences = AppPreferencesController(StorageService());
    await preferences.setDataSaverEnabled(true);

    await tester.pumpWidget(
      AppPreferencesScope(
        controller: preferences,
        child: const MaterialApp(
          home: Scaffold(
            body: AppAvatar(
              imageUrl: 'https://example.com/avatar.jpg',
              fallbackText: 'Alice',
              size: 64,
            ),
          ),
        ),
      ),
    );

    expect(find.text('A'), findsOneWidget);
    expect(find.byType(Image), findsNothing);
  });

  testWidgets('AppSettingsPage exports data and creates deletion requests', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(900, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final preferences = AppPreferencesController(StorageService());
    await preferences.setLocale(const Locale('en'));
    final privacy = _FakePrivacyRemoteDataSource();

    await tester.pumpWidget(
      AppPreferencesScope(
        controller: preferences,
        child: MaterialApp(
          locale: preferences.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: AppSettingsPage(privacyRemoteDataSource: privacy),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No requests yet.'), findsOneWidget);

    await tester.ensureVisible(find.text('Export data'));
    await tester.tap(find.text('Export data'));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Data summary'), findsOneWidget);
    expect(find.text('Bookings'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);

    await tester.tap(find.text('Close'));
    await tester.pump(const Duration(milliseconds: 500));

    await tester.ensureVisible(find.text('Request account deletion'));
    await tester.tap(find.text('Request account deletion'));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.text('Confirm'));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Pending'), findsOneWidget);
    expect(privacy.deletionRequests, 1);
  });

  testWidgets('AppSettingsPage fits compact phone and tablet viewports', (
    tester,
  ) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final viewports = [
      const Size(320, 568),
      const Size(390, 844),
      const Size(768, 1024),
      const Size(1024, 1366),
    ];

    for (final viewport in viewports) {
      await tester.binding.setSurfaceSize(viewport);
      final preferences = AppPreferencesController(StorageService());
      await preferences.setLocale(const Locale('en'));

      await tester.pumpWidget(
        AppPreferencesScope(
          controller: preferences,
          child: MaterialApp(
            locale: preferences.locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: AppSettingsPage(
              privacyRemoteDataSource: _FakePrivacyRemoteDataSource(),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      expect(tester.takeException(), isNull);
      expect(find.text('App settings'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Export data'),
        200,
        maxScrolls: 20,
      );
      await tester.pump(const Duration(milliseconds: 200));
      expect(tester.takeException(), isNull);
      expect(find.text('Export data'), findsOneWidget);
    }
  });

  testWidgets('AppSettingsPage exposes accessibility labels for controls', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(900, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final semantics = tester.ensureSemantics();

    try {
      final preferences = AppPreferencesController(StorageService());
      await preferences.setLocale(const Locale('en'));

      await tester.pumpWidget(
        AppPreferencesScope(
          controller: preferences,
          child: MaterialApp(
            locale: preferences.locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: AppSettingsPage(
              privacyRemoteDataSource: _FakePrivacyRemoteDataSource(),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      await tester.scrollUntilVisible(
        find.byTooltip('Refresh'),
        200,
        maxScrolls: 20,
      );
      expect(find.byTooltip('Refresh'), findsOneWidget);
      expect(find.text('Export data'), findsOneWidget);
      expect(find.text('Request account deletion'), findsOneWidget);
    } finally {
      semantics.dispose();
    }
  });
}

class _FakePrivacyRemoteDataSource implements PrivacyRemoteDataSource {
  int deletionRequests = 0;

  @override
  Future<PrivacyExportResult> exportPersonalData() async {
    return PrivacyExportResult(
      generatedAt: DateTime(2026, 4, 29, 10, 30),
      user: {
        'bookingsAsRenter': [{}, {}],
        'bookingsAsOwner': [],
        'paymentsAsPayer': [{}],
        'paymentsAsReceiver': [],
        'trips': [{}],
        'reviews': [{}],
      },
    );
  }

  @override
  Future<List<PrivacyRequestItem>> getMyRequests() async => [];

  @override
  Future<PrivacyRequestItem> requestAccountDeletion() async {
    deletionRequests += 1;
    return PrivacyRequestItem(
      id: 'privacy-request-1',
      type: 'DELETE_ACCOUNT',
      status: 'PENDING',
      dueAt: DateTime(2026, 5, 2, 10, 30),
      createdAt: DateTime(2026, 4, 29, 10, 30),
      completedAt: null,
    );
  }
}
