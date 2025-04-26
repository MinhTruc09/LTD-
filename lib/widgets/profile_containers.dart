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
        // Container cho "Nội dung tài xuống"
        const DiagonalContainer(
          title: 'NỘI DUNG',
          items: [
            ItemTile(
              title: 'Nội dung tải xuống',
              subtitle: 'Xem và quản lý nội dung đã lưu',
              icon: Icons.download_rounded,
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Container cho "Trò giúp"
        const DiagonalContainer(
          title: "HỖ TRỢ",
          items: [
            ItemTile(
              title: 'Trung tâm hỗ trợ',
              subtitle: 'Nhận trợ giúp từ chúng tôi',
              icon: Icons.support_agent,
            ),
            ItemTile(
              title: 'Liên hệ',
              subtitle: 'Gửi phản hồi hoặc báo cáo sự cố',
              icon: Icons.email_outlined,
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Container cho "Giới thiệu"
        const DiagonalContainer(
          title: 'THÔNG TIN',
          items: [
            ItemTile(
              title: 'Về Movieom',
              subtitle: 'Tìm hiểu thêm về chúng tôi',
              icon: Icons.info_outline,
            ),
            ItemTile(
              title: 'Điều khoản sử dụng',
              subtitle: 'Xem điều khoản và chính sách',
              icon: Icons.description_outlined,
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Container cho "Đăng xuất"
        DiagonalContainer(
          title: 'TÀI KHOẢN',
          items: [
            ItemTile(
              title: 'Đăng xuất',
              subtitle: 'Đăng xuất khỏi tài khoản của bạn',
              icon: Icons.logout_rounded,
              onTap: onSignOut,
            ),
          ],
        ),
      ],
    );
  }
}