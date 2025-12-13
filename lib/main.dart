import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/landing_page/presentation/pages/landing_page.dart';
import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppColors.background,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize dependency injection
  await di.init();

  runApp(const MyApp());
}

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'P2P Electric Motorbike Rental',
//       debugShowCheckedModeBanner: false,
//       theme: AppTheme.lightTheme,
//       home: const LoginPage(),
//     );
//   }
// }

// --- TRANG MENU ĐỂ TEST UI NHANH ---
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,

      // Trỏ home vào trang Menu Test
      home: const TestMenuPage(),
    );
  }
}

// --- TRANG MENU ĐỂ TEST UI NHANH ---
class TestMenuPage extends StatelessWidget {
  const TestMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dev UI Testing Menu')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildNavButton(context, 'Go to Login Page', const LoginPage()),
          const SizedBox(height: 10),
          _buildNavButton(context, 'Go to Landing Page', const LandingPage()),
          const SizedBox(height: 10),
          // Thêm các nút khác khi bạn có thêm màn hình mới
        ],
      ),
    );
  }

  Widget _buildNavButton(BuildContext context, String label, Widget page) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => page));
      },
      child: Text(label),
    );
  }
}
