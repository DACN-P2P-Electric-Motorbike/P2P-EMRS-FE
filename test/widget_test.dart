import 'package:fe_capstone_project/core/settings/app_preferences_controller.dart';
import 'package:fe_capstone_project/core/storage/storage_service.dart';
import 'package:fe_capstone_project/core/widgets/app_avatar.dart';
import 'package:fe_capstone_project/core/widgets/app_network_image.dart';
import 'package:fe_capstone_project/core/localization/app_localizations.dart';
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
