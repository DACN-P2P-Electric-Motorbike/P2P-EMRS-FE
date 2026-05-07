import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:fe_capstone_project/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('UC-10: Dream Ride - Chủ xe đăng ký xe mới', () {
    testWidgets('Luồng đăng ký xe qua 3 bước và Submit', (
      WidgetTester tester,
    ) async {
      app.main();
      await tester.pumpAndSettle();

      // --- BƯỚC 1: ĐĂNG NHẬP (image_1b95e0.png) ---
      await tester.enterText(
        find.byType(TextField).at(0),
        'hungmanh15032004@gmail.com',
      );
      await tester.enterText(find.byType(TextField).at(1), '123456789');
      await tester.tap(find.text('Log In'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // --- BƯỚC 2: ĐIỀU HƯỚNG ĐẾN TAB ĐĂNG KÝ ---
      // Vì dùng Icons.add_business khi chưa là Owner nên ta tìm icon này để nhấn vào
      final becomeOwnerTab = find.byIcon(Icons.add_business);

      await tester.tap(becomeOwnerTab);
      await tester.pumpAndSettle();

      // Nhấn nút "Đăng ký xe ngay" tại màn hình giới thiệu
      await tester.tap(find.text('Đăng ký xe ngay'));
      await tester.pumpAndSettle();

      // --- BƯỚC 3: STEP 1 - THÔNG TIN XE ---
      // 1. Chọn Model Brand (image_1cfa82.png)
      // Nhấn vào dropdown chọn hãng xe
      await tester.tap(find.text('Select one brand'));
      await tester.pumpAndSettle();

      // Chọn hãng "VinFast" từ danh sách hiện ra
      await tester.tap(find.text('VinFast').last);
      await tester.pumpAndSettle();

      // 2. Chọn Additional Features (image_1cfb1c.png)
      // Nhấn vào dropdown chọn tính năng
      await tester.tap(find.text('Select features (optional)'));
      await tester.pumpAndSettle();

      // Chọn các tính năng: "Fast Charging" và "GPS Tracking"
      await tester.tap(find.text('Fast Charging'));
      await tester.tap(find.text('GPS Tracking'));

      // Nhấn lại vào vùng dropdown để đóng danh sách (nếu cần) hoặc scroll tiếp
      await tester.pumpAndSettle();
      // Nhập Model Name và Biển số
      await tester.enterText(
        find.widgetWithText(TextField, 'e.g., VinFast Evo200'),
        'VinFast Klara S',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'e.g., 59A-12345'),
        '51A-99999',
      );

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // --- BƯỚC 4: STEP 2 - GIẤY TỜ (image_1b9283.png) ---
      await tester.enterText(
        find.widgetWithText(TextField, 'Enter vehicle registration number'),
        'REG12345678',
      );

      // (Tùy chọn) Giả lập upload ảnh nếu cần, ở đây ta nhấn Next luôn
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // --- BƯỚC 5: STEP 3 - GIÁ & ĐỊA ĐIỂM (image_1b9285.png) ---
      await tester.enterText(
        find.widgetWithText(TextField, 'VD: 150000'),
        '200000',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'VD: 123 Nguyễn Huệ, Quận 1, TP.HCM'),
        '123 Lê Lợi, Quận 1, TP.HCM',
      );

      // Nhấn Submit để gửi yêu cầu phê duyệt cho Admin
      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // --- KIỂM TRA KẾT QUẢ ---
      // Xác nhận thông báo thành công hoặc trạng thái chờ duyệt xuất hiện
      expect(find.text('Submit thành công'), findsOneWidget);
    });
  });
}
