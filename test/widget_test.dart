import 'package:fe_capstone_project/core/settings/app_preferences_controller.dart';
import 'package:fe_capstone_project/core/storage/storage_service.dart';
import 'package:fe_capstone_project/core/widgets/app_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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
}
