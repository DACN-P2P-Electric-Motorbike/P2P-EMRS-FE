import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_theme.dart'; // Đảm bảo đường dẫn đúng tới theme
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import '../bloc/auth_event.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool? _isFirstTime;
  bool _isAuthChecked = false;

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    // 1. Kích hoạt kiểm tra đăng nhập từ Bloc
    context.read<AuthBloc>().add(const AuthCheckRequested());

    // 2. Kiểm tra SharedPreferences (Onboarding)
    final prefs = await SharedPreferences.getInstance();

    // --- THÊM DÒNG NÀY ĐỂ RESET (Chạy 1 lần rồi xóa đi) ---
    // await prefs.remove('isFirstTime');
    // Hoặc:
    // await prefs.clear(); // Xóa sạch mọi thứ
    // -----------------------------------------------------

    // Giả lập delay 2 giây để hiển thị Logo
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        // Mặc định là true (người mới) nếu chưa có dữ liệu
        _isFirstTime = prefs.getBool('isFirstTime') ?? true;
      });
      _navigateIfReady();
    }
  }

  void _navigateIfReady() {
    // Chỉ điều hướng khi đã có kết quả từ cả SharedPreferences VÀ AuthBloc
    if (_isFirstTime == null || !_isAuthChecked) return;

    final state = context.read<AuthBloc>().state;

    if (state is AuthAuthenticated || state is AuthSuccess) {
      // ƯU TIÊN 1: Đã đăng nhập -> Vào Home
      context.go('/home');
    } else {
      // Nếu chưa đăng nhập (bao gồm cả trường hợp lỗi mạng/server khi check token)
      if (_isFirstTime == true) {
        // ƯU TIÊN 2: Lần đầu -> Vào Onboarding
        context.go('/onboarding');
      } else {
        // ƯU TIÊN 3: Khách cũ -> Vào Login
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // Cập nhật trạng thái đã check xong khi có kết quả từ Bloc
        if (state is AuthAuthenticated ||
            state is AuthSuccess ||
            state is AuthUnauthenticated ||
            state is AuthFailure) {
          // <--- Đã sửa từ AuthError thành AuthFailure

          setState(() {
            _isAuthChecked = true;
          });
          _navigateIfReady();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(
          0xFF4A80F0,
        ), // Màu xanh từ thiết kế Home.png
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo Text (Fallback khi chưa import ảnh logo)
              Column(
                children: [
                  Text(
                    'DREAM',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'R',
                        style: Theme.of(context).textTheme.displayMedium
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(width: 8),
                      // Icon mũ bảo hiểm tạm thời
                      const Icon(
                        Icons.sports_motorsports_outlined,
                        color: Colors.white,
                        size: 40,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'IDE',
                        style: Theme.of(context).textTheme.displayMedium
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 40),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
