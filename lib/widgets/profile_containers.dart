import 'package:flutter/material.dart';
import 'package:movieom_app/widgets/diagonal_container.dart';
import 'package:movieom_app/widgets/item_tile.dart';

class ProfileContainers extends StatelessWidget {
  final VoidCallback? onSignOut;

  const ProfileContainers({super.key, this.onSignOut});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Container cho "Nội dung tài xuồng"
        const DiagonalContainer(
          title: 'NỘI DUNG TẢI XUỐNG',
          items: [
            ItemTile(
              title: 'Nội dung tải xuống',
              subtitle: 'Xem và tải nội dung',
              icon: Icons.download,
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Container cho "Trò giúp"
        const DiagonalContainer(
          title: "SERVICES",
          items: [
            ItemTile(
              title: 'Trung tâm hỗ trợ',
              subtitle: 'Nhận trợ giúp từ chúng tôi',
              icon: Icons.support_agent,
            ),
            ItemTile(
              title: 'CONTACT',
              subtitle: 'Liên hệ với chúng tôi',
              icon: Icons.email,
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Container cho "Giới thiệu"
        const DiagonalContainer(
          title: 'ABOUT',
          items: [
            ItemTile(
              title: 'Thông tin về Movieom',
              subtitle: 'Tìm hiểu thêm về chúng tôi',
              icon: Icons.info,
            ),
            ItemTile(
              title: 'Điều khoản sử dụng',
              subtitle: 'Xem điều khoản và chính sách',
              icon: Icons.description,
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Container cho "Đăng xuất"
        DiagonalContainer(
          title: '',
          items: [
            ItemTile(
              title: 'Đăng xuất',
              subtitle: '',
              icon: Icons.logout,
              onTap: onSignOut,
            ),
          ],
        ),
      ],
    );
  }
}