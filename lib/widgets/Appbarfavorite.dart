import 'package:flutter/material.dart';

// import 'package:movieom_app/views/favorite_screen.dart';
class Appbarfavorite extends StatelessWidget {
  const Appbarfavorite({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black, // Nền đen cho AppBar
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Nút quay lại
          IconButton(
            icon: const Icon(
              Icons.arrow_back,
              size: 30,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context); // Quay lại màn hình trước
            },
          ),
          // Tiêu đề
          const Text(
            'Danh sách yêu thích',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          // Nút chỉnh sửa
          TextButton(
            onPressed: () {
              print('Chỉnh sửa được nhấn!');
            },
            child: const Text(
              'Chỉnh sửa',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
