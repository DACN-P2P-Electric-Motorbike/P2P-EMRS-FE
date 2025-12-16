import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Danh sách dữ liệu (Đảm bảo bạn đã đổi tên file ảnh như hướng dẫn)
  final List<Map<String, String>> _onboardingData = [
    {
      "image": "assets/images/intro.jpg",
      "title": "Dream Ride - Your hassle-free ride-sharing solution",
      "desc":
          "Get ready to experience hassle-free transportation. We've got everything you need to travel with ease. Let's get started!",
    },
    {
      "image": "assets/images/intro.jpg",
      "title": "Discover available rides tailored to your needs.",
      "desc":
          "Choose from a variety of rides offered by nearby drivers. Submit a request and start your journey hassle-free.",
    },
    {
      "image": "assets/images/intro.jpg",
      "title": "Enjoy a seamless ride sharing experience.",
      "desc":
          "Communicate with your driver, apply promos and choose your preferred payment method your comfort and convenience are our priority",
    },
  ];

  void _completeOnboarding() {
    if (mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    // --- MÀU SẮC MỚI: XANH BIỂN (BLUE) ---
    // Mã màu này lấy từ hình nút "Continue" bạn gửi (khoảng #2196F3)
    const primaryBlue = Color(0xFF2196F3);
    const lightBlueBg = Color(0xFFE3F2FD); // Màu nền nhạt cho nút Skip

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Phần hiển thị nội dung (Ảnh + Chữ)
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (value) => setState(() => _currentPage = value),
                itemCount: _onboardingData.length,
                itemBuilder: (context, index) =>
                    _buildContent(_onboardingData[index]),
              ),
            ),

            // Phần điều khiển (Nút bấm)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Nút Skip (Màu nền xanh nhạt, chữ xanh dương)
                  TextButton(
                    onPressed: _completeOnboarding,
                    style: TextButton.styleFrom(
                      backgroundColor: lightBlueBg,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      "Skip",
                      style: GoogleFonts.poppins(
                        color: primaryBlue,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),

                  // Dots Indicator (Dấu chấm)
                  Row(
                    children: List.generate(
                      _onboardingData.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 6),
                        height: 8,
                        width: _currentPage == index ? 24 : 8,
                        decoration: BoxDecoration(
                          // Chấm đang chọn màu xanh dương, chấm khác màu xám
                          color: _currentPage == index
                              ? primaryBlue
                              : const Color(0xFFE0E0E0),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),

                  // Nút Continue / Start (Màu nền xanh dương đậm)
                  ElevatedButton(
                    onPressed: () {
                      if (_currentPage == _onboardingData.length - 1) {
                        _completeOnboarding();
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 14,
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      _currentPage == _onboardingData.length - 1
                          ? "Start"
                          : "Next",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(Map<String, String> data) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 1),
          // Hình ảnh
          Expanded(
            flex: 5,
            child: Image.asset(
              data["image"]!,
              fit: BoxFit.contain,
              // Xử lý lỗi nếu chưa tìm thấy ảnh (tránh màn hình đỏ)
              errorBuilder: (context, error, stackTrace) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.broken_image,
                      size: 50,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Không tìm thấy ảnh:\n${data["image"]}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 32),
          // Tiêu đề
          Text(
            data["title"]!,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1D1617),
            ),
          ),
          const SizedBox(height: 16),
          // Mô tả
          Text(
            data["desc"]!,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: const Color(0xFF7B6F72),
              height: 1.5,
            ),
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}
