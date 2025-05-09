import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Appbarfavorite extends StatelessWidget {
  const Appbarfavorite({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(

      backgroundColor: Colors.black,
      automaticallyImplyLeading: false, // Ngăn AppBar tự động thêm nút back
      // leading: IconButton(
      //   icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
      //   onPressed: () {
      //     Navigator.pop(context);
      //   },
      // ),
      title:  Center(
        // Căn giữa tiêu đề
        child: Text(
          'Danh sách yêu thích',
          style: GoogleFonts.aBeeZee(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      // actions: [
      //   Padding(
      //     padding: const EdgeInsets.only(
      //         right: 16.0), // Thêm một chút padding bên phải (tùy chọn)
      //     child: TextButton(
      //       onPressed: () {
      //         print('Chỉnh sửa được nhấn!');
      //       },
      //       child:  Text(
      //         'Chỉnh sửa',
      //         style: GoogleFonts.aBeeZee(color: Colors.white, fontSize: 16),
      //       ),
      //     ),
      //   ),
      // ],
    );
  }
}
