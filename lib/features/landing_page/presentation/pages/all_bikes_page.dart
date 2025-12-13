import 'package:flutter/material.dart';

class AllBikesPage extends StatelessWidget {
  const AllBikesPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock Data: Danh sách xe giả lập (Bạn có thể thay bằng dữ liệu thật từ API)
    final List<Map<String, dynamic>> bikes = [
      {
        'name': 'VinFast Evo200',
        'img':
            'https://vinfast.vn/wp-content/uploads/2022/09/Evo200-Lite-Den-Nham.png', // Hoặc đường dẫn assets
        'location': 'Phường Bình Hưng Hòa',
        'rating': 4.0,
        'price': 200,
      },
      {
        'name': 'VinFast Klara S',
        'img':
            'https://shop.vinfastauto.com/on/demandware.static/-/Sites-app_vinfast_vn-Library/default/dw83742468/images/Klara-S/Hinh-anh-xe-may-dien-VinFast-Klara-S-2022-mau-xanh-blue.png',
        'location': 'Phường Bàn Cờ',
        'rating': 4.1,
        'price': 100,
      },
      {
        'name': 'Yadea Odora',
        'img':
            'https://yadeavietnam.vn/wp-content/uploads/2021/07/trang-su-copy.png',
        'location': 'Quận 1, TP.HCM',
        'rating': 4.5,
        'price': 150,
      },
      {
        'name': 'Pega New Tech',
        'img':
            'https://pega.com.vn/uploads/product/2020/01/10/5e183e8a6f669-den-bong-copy.png',
        'location': 'Quận 3, TP.HCM',
        'rating': 3.8,
        'price': 120,
      },
    ];

    return Scaffold(
      backgroundColor: Colors.grey[50], // Màu nền xám nhẹ
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'All Bikes',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            // Header Text: Hello Hùng Mạnh...
            const Text(
              'Hello, Hùng Mạnh!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'What bike you choose today?',
              style: TextStyle(fontSize: 16, color: Colors.grey[800]),
            ),
            const SizedBox(height: 20),

            // Danh sách xe (ListView)
            Expanded(
              child: ListView.separated(
                itemCount: bikes.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final bike = bikes[index];
                  return BikeListItem(
                    name: bike['name'],
                    imageUrl: bike['img'],
                    location: bike['location'],
                    rating: bike['rating'],
                    price: bike['price'],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget thẻ xe (Tách riêng để tái sử dụng)
class BikeListItem extends StatelessWidget {
  final String name;
  final String imageUrl;
  final String location;
  final double rating;
  final int price;

  const BikeListItem({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.location,
    required this.rating,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // 1. Hình ảnh xe
          Hero(
            // Hiệu ứng chuyển cảnh mượt
            tag: name,
            child: Image.network(
              imageUrl,
              height: 140,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.motorcycle, size: 80, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 16),

          // 2. Tên xe và Rating
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  Text(
                    rating.toString(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.star_border, color: Colors.amber, size: 20),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),

          // 3. Địa điểm và Giá
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Địa điểm (có icon)
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        location,
                        style: TextStyle(color: Colors.grey[500], fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              // Giá tiền
              RichText(
                text: TextSpan(
                  text: '\$$price',
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  children: [
                    TextSpan(
                      text: '/day',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
