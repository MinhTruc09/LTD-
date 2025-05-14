import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:movieom_app/widgets/support_page_layout.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SupportPageLayout(
      title: 'Điều khoản sử dụng',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFF3F54D1).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.gavel,
                size: 50,
                color: Color(0xFF3F54D1),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          Center(
            child: Text(
              'Điều khoản sử dụng',
              style: GoogleFonts.aBeeZee(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Text(
                'Cập nhật lần cuối: 01/06/2024',
                style: GoogleFonts.aBeeZee(
                  fontSize: 14,
                  color: Colors.grey[400],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          
          const SectionTitle('1. Giới thiệu'),
          const Paragraph(
            'Movieom là một ứng dụng xem phim được phát triển với mục đích học tập. Ứng dụng này được tạo ra bởi nhóm sinh viên năm 3 đang học môn Lập Trình Thiết Bị Di Động tại trường đại học. Bằng việc sử dụng ứng dụng này, bạn đồng ý với các điều khoản sử dụng được nêu dưới đây.'
          ),
          
          const SectionTitle('2. Mục đích sử dụng'),
          const Paragraph(
            'Movieom được phát triển với mục đích học tập và nghiên cứu. Ứng dụng không có mục đích thương mại và không thu thập bất kỳ khoản phí nào từ người dùng. Mọi nội dung phim ảnh được hiển thị trong ứng dụng đều được lấy từ các nguồn công khai trên internet.'
          ),
          
          const SectionTitle('3. Tài khoản người dùng'),
          const Paragraph(
            'Khi tạo tài khoản trên Movieom, bạn phải cung cấp thông tin chính xác và cập nhật. Bạn chịu trách nhiệm bảo mật thông tin tài khoản của mình, bao gồm mật khẩu, và bạn chịu trách nhiệm cho tất cả hoạt động diễn ra dưới tài khoản của mình.'
          ),
          const Paragraph(
            'Chúng tôi có quyền xóa hoặc từ chối cung cấp dịch vụ cho bất kỳ tài khoản nào nếu phát hiện vi phạm điều khoản sử dụng.'
          ),
          
          const SectionTitle('4. Quyền sở hữu trí tuệ'),
          const Paragraph(
            'Movieom là một dự án học tập và không sở hữu bản quyền đối với các nội dung phim ảnh được hiển thị trong ứng dụng. Tất cả nội dung phim, hình ảnh, và thông tin liên quan đều thuộc về chủ sở hữu bản quyền tương ứng.'
          ),
          const Paragraph(
            'Chúng tôi tôn trọng quyền sở hữu trí tuệ và sẽ gỡ bỏ bất kỳ nội dung nào vi phạm bản quyền khi nhận được thông báo hợp lệ.'
          ),
          
          const SectionTitle('5. Giới hạn trách nhiệm'),
          const Paragraph(
            'Movieom được cung cấp "nguyên trạng" và "như có sẵn" mà không có bất kỳ sự đảm bảo nào. Chúng tôi không chịu trách nhiệm về bất kỳ thiệt hại nào phát sinh từ việc sử dụng hoặc không thể sử dụng ứng dụng.'
          ),
          const Paragraph(
            'Chúng tôi không chịu trách nhiệm về tính chính xác, đầy đủ hoặc hữu ích của thông tin được cung cấp trong ứng dụng, cũng như không chịu trách nhiệm về bất kỳ lỗi hoặc gián đoạn nào trong việc cung cấp dịch vụ.'
          ),
          
          const SectionTitle('6. Quyền riêng tư'),
          const Paragraph(
            'Chúng tôi tôn trọng quyền riêng tư của người dùng. Thông tin cá nhân của bạn sẽ chỉ được sử dụng cho mục đích cung cấp dịch vụ và sẽ không được chia sẻ với bên thứ ba mà không có sự đồng ý của bạn.'
          ),
          const Paragraph(
            'Để biết thêm chi tiết về cách chúng tôi thu thập, sử dụng và bảo vệ thông tin cá nhân của bạn, vui lòng tham khảo Chính sách Quyền riêng tư của chúng tôi.'
          ),
          
          const SectionTitle('7. Thay đổi điều khoản'),
          const Paragraph(
            'Chúng tôi có thể cập nhật Điều khoản sử dụng này theo thời gian. Chúng tôi sẽ thông báo cho bạn về bất kỳ thay đổi nào bằng cách đăng các điều khoản mới trên ứng dụng. Việc bạn tiếp tục sử dụng ứng dụng sau khi các thay đổi có hiệu lực đồng nghĩa với việc bạn chấp nhận các điều khoản mới.'
          ),
          
          const SectionTitle('8. Liên hệ'),
          const Paragraph(
            'Nếu bạn có bất kỳ câu hỏi nào về Điều khoản sử dụng này, vui lòng liên hệ với chúng tôi qua email: movieapp006@gmail.com hoặc số điện thoại: 0384548931.'
          ),
          
          const SizedBox(height: 40),
          Center(
            child: Text(
              '© 2024 Movieom - Dự án học tập',
              style: GoogleFonts.aBeeZee(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
} 