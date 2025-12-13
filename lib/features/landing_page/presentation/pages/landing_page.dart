// File: lib/features/landing_page/presentation/pages/landing_page.dart

import 'package:flutter/material.dart';
import 'all_bikes_page.dart'; // Nhớ import file vừa tạo ở trên cùng
// import '../../../../core/theme/app_theme.dart'; // Import theme từ project của bạn

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Màu nền nhẹ
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header (Location + Avatar)
              const _HeaderSection(),
              const SizedBox(height: 24),

              // 2. Title (Select or search...)
              RichText(
                text: TextSpan(
                  text: 'Select or search your\n',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    height: 1.2,
                  ),
                  children: const [
                    TextSpan(
                      text: 'Favourite vehicle',
                      style: TextStyle(
                        color: Color(0xFF5C6BC0), // Màu xanh giống thiết kế
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 3. Search Bar
              const _SearchBar(),
              const SizedBox(height: 24),

              // 4. Brands List (VinFast, Pega, Yadea)
              const _BrandSection(),
              const SizedBox(height: 24),

              // 5. Featured Section Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'All Bikes',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      // Điều hướng sang trang All Bikes
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AllBikesPage(),
                        ),
                      );
                    },
                    child: const Text('View All'),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 6. Featured Bike Card
              const _BikeCard(),

              // Khoảng trống để không bị BottomNav che
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: const Color(0xFF5C6BC0),
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_border),
            label: 'Saved',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_none),
            label: 'Notify',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// --- Sub Widgets (Tách nhỏ để dễ quản lý) ---

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5),
                ],
              ),
              child: const Icon(Icons.location_on_outlined, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your location',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
                const Text(
                  'Lý Thường Kiệt, P.Diên Hồng',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
          ],
        ),
        const CircleAvatar(
          radius: 20,
          backgroundImage: NetworkImage(
            'https://i.pravatar.cc/150?img=11',
          ), // Ảnh đại diện mẫu
        ),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF5C6BC0),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.filter_list, color: Colors.white),
        ),
      ],
    );
  }
}

class _BrandSection extends StatelessWidget {
  const _BrandSection();

  @override
  Widget build(BuildContext context) {
    // Danh sách brand giả lập
    final brands = [
      {'name': 'VINFAST', 'img': 'assets/VinFast.png'},
      {'name': 'PEGA', 'img': 'assets/Pega.png'},
      {'name': 'YADEA', 'img': 'assets/Yadea.png'},
    ];

    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: brands.length + 1, // +1 cho nút mũi tên
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          if (index == brands.length) {
            return Container(
              width: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.arrow_forward, color: Colors.black),
            );
          }
          return Container(
            width: 80,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            // Dùng Column để hiển thị Logo + Tên (hoặc chỉ Logo tùy asset của bạn)
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon giả lập logo, bạn hãy dùng Image.asset
                Image.asset(brands[index]['img']!),
                const SizedBox(height: 4),
                // Text(
                //   brands[index]['name']!,
                //   style: const TextStyle(
                //     fontSize: 10,
                //     fontWeight: FontWeight.bold,
                //   ),
                //   textAlign: TextAlign.center,
                // ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _BikeCard extends StatelessWidget {
  const _BikeCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ảnh xe (Dùng placeholder)
          Center(
            child: Image.network(
              'https://vinfast.vn/wp-content/uploads/2022/09/Evo200-Lite-Den-Nham.png', // Ảnh mẫu VinFast Evo
              height: 150,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.motorcycle, size: 100, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 16),

          // Tên xe
          const Text(
            'VinFast Evo200',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),

          // Địa chỉ
          Row(
            children: [
              Icon(Icons.location_on, size: 14, color: Colors.grey[400]),
              const SizedBox(width: 4),
              Text(
                'Phường Bình Hưng Hòa',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Rating và Lượt dùng
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Rating
              Row(
                children: const [
                  Icon(Icons.star_border, color: Colors.amber, size: 20),
                  SizedBox(width: 4),
                  Text('4.0', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              // Drivers Used
              Text(
                '150 Drivers Used',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
